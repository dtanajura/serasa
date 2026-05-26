#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import sys
from datetime import datetime, timezone
from typing import List, Dict, Any, Optional

import boto3
from botocore.exceptions import ClientError, ProfileNotFound, NoCredentialsError
import pandas as pd


ALL_STATUSES = [
    "PENDING_VALIDATION",
    "ISSUED",
    "INACTIVE",
    "EXPIRED",
    "VALIDATION_TIMED_OUT",
    "REVOKED",
    "FAILED",
]


def get_session(profile: str) -> boto3.session.Session:
    try:
        return boto3.session.Session(profile_name=profile)
    except ProfileNotFound as e:
        raise RuntimeError(f"Profile '{profile}' não encontrado: {e}")


def get_default_region(session: boto3.session.Session) -> Optional[str]:
    # Região default derivada do profile/config/ambiente
    return session.region_name


def get_account_id(session: boto3.session.Session) -> str:
    sts = session.client("sts")
    return sts.get_caller_identity()["Account"]


def list_cert_summaries(acm_client) -> List[Dict[str, Any]]:
    """Lista resumos de certificados com paginação, em uma única região (a default do profile)."""
    paginator = acm_client.get_paginator("list_certificates")
    summaries = []
    for page in paginator.paginate(
        CertificateStatuses=ALL_STATUSES,
        Includes={"extendedKeyUsage": [], "keyTypes": []}
    ):
        summaries.extend(page.get("CertificateSummaryList", []))
    return summaries


def describe_certificate(acm_client, arn: str) -> Optional[Dict[str, Any]]:
    try:
        return acm_client.describe_certificate(CertificateArn=arn)["Certificate"]
    except ClientError as e:
        sys.stderr.write(f"[warn] Falha ao descrever {arn}: {e}\n")
        return None


def flatten_certificate_row(
    profile: str,
    account_id: str,
    region: str,
    cert: Dict[str, Any]
) -> Dict[str, Any]:
    domain = cert.get("DomainName")
    sans = cert.get("SubjectAlternativeNames") or []
    issued_at = cert.get("NotBefore")
    expires_at = cert.get("NotAfter")
    status = cert.get("Status")
    ctype = cert.get("Type")  # AMAZON_ISSUED | IMPORTED | PRIVATE
    in_use_by = cert.get("InUseBy") or []
    renewal_eligibility = cert.get("RenewalEligibility")  # ELIGIBLE | INELIGIBLE

    now = datetime.now(timezone.utc)
    days_to_expire = None
    if isinstance(expires_at, datetime):
        days_to_expire = (expires_at - now).days

    return {
        "profile": profile,
        "account_id": account_id,
        "region": region,
        "certificate_arn": cert.get("CertificateArn"),
        "domain_name": domain,
        "subject_alternative_names": ", ".join(sans),
        "status": status,
        "type": ctype,
        "issued_at": issued_at,
        "expires_at": expires_at,
        "days_to_expire": days_to_expire,
        "in_use_by": ", ".join(in_use_by),
        "renewal_eligibility": renewal_eligibility,
        "key_algorithm": cert.get("KeyAlgorithm"),
        "signature_algorithm": cert.get("SignatureAlgorithm"),
        "serial": cert.get("Serial"),
        "issuer": cert.get("Issuer"),
    }


def process_profile(profile: str) -> List[Dict[str, Any]]:
    rows: List[Dict[str, Any]] = []
    try:
        session = get_session(profile)
    except RuntimeError as e:
        sys.stderr.write(f"[erro] {e}\n")
        return rows
    except NoCredentialsError:
        sys.stderr.write(f"[erro] Sem credenciais válidas para o profile '{profile}'.\n")
        return rows

    region = get_default_region(session)
    if not region:
        sys.stderr.write(
            f"[erro] O profile '{profile}' não possui região default configurada. "
            "Defina 'region' no ~/.aws/config ou exporte AWS_DEFAULT_REGION.\n"
        )
        return rows

    try:
        account_id = get_account_id(session)
    except ClientError as e:
        sys.stderr.write(f"[erro] Falha ao obter AccountId do profile '{profile}': {e}\n")
        return rows

    sys.stderr.write(f"[info] Profile={profile} Account={account_id} Região={region}\n")

    try:
        acm = session.client("acm", region_name=region)
        summaries = list_cert_summaries(acm)
        for s in summaries:
            arn = s.get("CertificateArn")
            detail = describe_certificate(acm, arn)
            if not detail:
                continue
            rows.append(flatten_certificate_row(profile, account_id, region, detail))
    except ClientError as e:
        sys.stderr.write(f"[warn] Erro do cliente em {region} (profile {profile}): {e}\n")
    except Exception as e:
        sys.stderr.write(f"[warn] Erro inesperado em {region} (profile {profile}): {e}\n")

    return rows


def main():
    parser = argparse.ArgumentParser(
        description="Lista certificados do AWS ACM usando apenas a região default do profile e exporta para Excel."
    )
    parser.add_argument(
        "--profiles",
        nargs="+",
        required=True,
        help="Perfis do AWS CLI a analisar (ex.: acct1 acct2 acct3)."
    )
    parser.add_argument(
        "--output",
        default="acm_certificates.xlsx",
        help="Caminho do arquivo Excel de saída (default: acm_certificates.xlsx)."
    )
    args = parser.parse_args()

    all_rows: List[Dict[str, Any]] = []

    for profile in args.profiles:
        rows = process_profile(profile)
        all_rows.extend(rows)

    if not all_rows:
        sys.stderr.write("[info] Nenhum certificado encontrado.\n")

    df = pd.DataFrame(all_rows)

    if not df.empty and "expires_at" in df.columns:
        df = df.sort_values(by=["expires_at", "profile"], ascending=[True, True])

    # Converter datetimes para strings ISO (UTC) para compatibilidade no Excel
    from datetime import datetime as dt  # evitar confusão
    datetime_cols = ["issued_at", "expires_at"]
    for col in datetime_cols:
        if col in df.columns:
            df[col] = df[col].apply(
                lambda d: d.astimezone(timezone.utc).strftime("%Y-%m-%d %H:%M:%S %Z")
                if isinstance(d, dt) else d
            )

    with pd.ExcelWriter(args.output, engine="openpyxl", datetime_format="YYYY-MM-DD HH:MM:SS", date_format="YYYY-MM-DD") as writer:
        df.to_excel(writer, index=False, sheet_name="ACM_Certificates")
        ws = writer.sheets["ACM_Certificates"]

        # Autoajuste simples de largura das colunas
        for idx, col in enumerate(df.columns, start=1):
            max_len = max((len(str(x)) for x in [col] + df[col].astype(str).tolist()), default=10)
            ws.column_dimensions[ws.cell(row=1, column=idx).column_letter].width = min(max(12, max_len + 2), 80)

        # Congelar primeira linha
        ws.freeze_panes = "A2"

    print(f"[ok] Exportado para: {args.output}")


if __name__ == "__main__":
    main()