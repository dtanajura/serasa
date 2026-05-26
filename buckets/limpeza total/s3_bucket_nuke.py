#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
s3_bucket_nuke.py
Apaga TODO o conteúdo de um bucket S3 (incluindo TODAS as versões e delete markers
se o bucket for versionado) e depois remove o bucket.

Requisitos:
  - Python 3.8+
  - boto3, botocore

Uso:
  python s3_bucket_nuke.py --bucket NOME --profile PROFILE [opções]
"""

import argparse
import sys
import time
from typing import Iterable, List, Dict, Optional

import boto3
from botocore.config import Config
from botocore.exceptions import ClientError, EndpointConnectionError

# -------- Utilidades --------

def chunked(seq: Iterable, size: int) -> Iterable[List]:
    """Divide um iterável em listas de tamanho máximo 'size'."""
    batch = []
    for item in seq:
        batch.append(item)
        if len(batch) >= size:
            yield batch
            batch = []
    if batch:
        yield batch

def confirm(prompt: str) -> bool:
    try:
        ans = input(f"{prompt} [digite o nome do bucket para confirmar]: ").strip()
        return bool(ans)
    except (EOFError, KeyboardInterrupt):
        return False

def make_session(profile: Optional[str], region: Optional[str]):
    if profile:
        sess = boto3.Session(profile_name=profile, region_name=region)
    else:
        sess = boto3.Session(region_name=region)
    # Região fallback se ainda estiver None
    if not sess.region_name:
        # S3 é global, mas algumas operações requerem região; usar padrão pedido
        sess = boto3.Session(profile_name=profile, region_name="sa-east-1")
    return sess

def make_s3_client(sess: boto3.session.Session):
    # Config com retries agressivos e keepalive
    cfg = Config(
        retries={"max_attempts": 10, "mode": "adaptive"},
        connect_timeout=10,
        read_timeout=120,
        tcp_keepalive=True,
        signature_version="s3v4",
    )
    return sess.client("s3", config=cfg)

# -------- Checagens --------

def get_bucket_region(s3, bucket: str) -> Optional[str]:
    try:
        resp = s3.get_bucket_location(Bucket=bucket)
        loc = resp.get("LocationConstraint")
        # Em us-east-1 a API retorna None
        return "us-east-1" if loc in (None, "") else loc
    except ClientError as e:
        code = e.response["Error"].get("Code")
        if code in ("NoSuchBucket",):
            raise
        return None

def is_versioned_bucket(s3, bucket: str) -> bool:
    """Retorna True se o bucket tem versionamento 'Enabled' ou 'Suspended'."""
    try:
        resp = s3.get_bucket_versioning(Bucket=bucket)
        status = resp.get("Status")  # 'Enabled' | 'Suspended' | None
        return status in ("Enabled", "Suspended")
    except ClientError as e:
        # Se não conseguir checar, faça fallback conservador: tentar versões
        print(f"[aviso] Falha ao checar versionamento: {e}", file=sys.stderr)
        return True

def has_object_lock(s3, bucket: str) -> bool:
    try:
        resp = s3.get_object_lock_configuration(Bucket=bucket)
        return bool(resp.get("ObjectLockConfiguration"))
    except ClientError as e:
        code = e.response["Error"].get("Code")
        # Se não configurado, AWS retorna 404/InvalidRequest às vezes
        return False

# -------- Deleções --------

def delete_unversioned(s3, bucket: str, requester_pays: bool = False) -> int:
    """Remove todos os objetos de um bucket não versionado."""
    paginator = s3.get_paginator("list_objects_v2")
    params = {"Bucket": bucket}
    if requester_pays:
        params["RequestPayer"] = "requester"

    deleted = 0
    for page in paginator.paginate(**params):
        contents = page.get("Contents", [])
        keys = [{"Key": obj["Key"]} for obj in contents]
        if not keys:
            continue
        for batch in chunked(keys, 1000):
            del_params = {
                "Bucket": bucket,
                "Delete": {"Objects": batch, "Quiet": True},
            }
            if requester_pays:
                del_params["RequestPayer"] = "requester"
            s3.delete_objects(**del_params)
            deleted += len(batch)
            if deleted % 10000 == 0:
                print(f"  - apagados {deleted} objetos (não versionado)...")
    return deleted

def delete_versioned(
    s3,
    bucket: str,
    mfa: Optional[str] = None,
    bypass_governance: bool = False,
    requester_pays: bool = False,
) -> int:
    """
    Remove todas as versões e delete markers de um bucket versionado.
    Observação: 'Suspended' também pode possuir versões antigas.
    """
    paginator = s3.get_paginator("list_object_versions")
    params = {"Bucket": bucket}
    if requester_pays:
        params["RequestPayer"] = "requester"

    deleted = 0
    for page in paginator.paginate(**params):
        versions = page.get("Versions", []) or []
        markers = page.get("DeleteMarkers", []) or []
        items = [{"Key": v["Key"], "VersionId": v["VersionId"]} for v in versions]
        items += [{"Key": m["Key"], "VersionId": m["VersionId"]} for m in markers]
        if not items:
            continue

        for batch in chunked(items, 1000):
            del_params = {
                "Bucket": bucket,
                "Delete": {"Objects": batch, "Quiet": True},
            }
            if mfa:
                del_params["MFA"] = mfa
            if bypass_governance:
                del_params["BypassGovernanceRetention"] = True
            if requester_pays:
                del_params["RequestPayer"] = "requester"

            s3.delete_objects(**del_params)
            deleted += len(batch)
            if deleted % 10000 == 0:
                print(f"  - apagados {deleted} versões/markers...")
    return deleted

def abort_multipart_uploads(s3, bucket: str) -> int:
    """Aborta uploads multipart pendentes (não são objetos, mas é bom higienizar)."""
    aborted = 0
    try:
        paginator = s3.get_paginator("list_multipart_uploads")
        for page in paginator.paginate(Bucket=bucket):
            uploads = page.get("Uploads", []) or []
            for u in uploads:
                s3.abort_multipart_upload(
                    Bucket=bucket, Key=u["Key"], UploadId=u["UploadId"]
                )
                aborted += 1
                if aborted % 1000 == 0:
                    print(f"  - abortados {aborted} multipart uploads...")
    except ClientError as e:
        code = e.response["Error"].get("Code")
        if code not in ("NoSuchUpload", "NoSuchBucket"):
            print(f"[aviso] Falha ao listar/abortar MPUs: {e}", file=sys.stderr)
    return aborted

def delete_bucket_with_retries(s3, bucket: str, requester_pays: bool = False, max_attempts: int = 5) -> None:
    for attempt in range(1, max_attempts + 1):
        try:
            params = {"Bucket": bucket}
            if requester_pays:
                params["RequestPayer"] = "requester"
            s3.delete_bucket(**params)
            print("Bucket removido com sucesso.")
            return
        except ClientError as e:
            code = e.response["Error"].get("Code")
            msg = e.response["Error"].get("Message", "")
            if code in ("BucketNotEmpty", "OperationAborted", "InternalError"):
                wait = min(2 ** attempt, 30)
                print(f"[info] Tentativa {attempt}/{max_attempts} falhou ({code}: {msg}). Retentando em {wait}s...")
                time.sleep(wait)
                continue
            raise
        except EndpointConnectionError as e:
            wait = min(2 ** attempt, 30)
            print(f"[info] Problema de rede: {e}. Retentando em {wait}s...")
            time.sleep(wait)
    raise RuntimeError("Falha ao remover o bucket após múltiplas tentativas.")

# -------- Main --------

def main():
    parser = argparse.ArgumentParser(
        description="Apaga todo o conteúdo de um bucket S3 (incluindo versões) e remove o bucket."
    )
    parser.add_argument("--bucket", required=True, help="Nome do bucket S3.")
    parser.add_argument("--profile", required=True, help="Profile do AWS CLI/SDK a ser usado.")
    parser.add_argument("--region", help="(Opcional) Região. Se ausente, usa a do profile; fallback sa-east-1.")
    parser.add_argument("--yes", "-y", action="store_true", help="Não perguntar confirmação.")
    parser.add_argument("--abort-mpu", action="store_true", help="Aborta multipart uploads pendentes antes de apagar.")
    parser.add_argument("--bypass-governance", action="store_true",
                        help="Define BypassGovernanceRetention=True (Object Lock - governance).")
    parser.add_argument("--mfa-serial", help="ARN do dispositivo MFA (ex.: arn:aws:iam::123456789012:mfa/usuario).")
    parser.add_argument("--mfa-code", help="Código MFA de 6 dígitos.")
    parser.add_argument("--requester-pays", action="store_true",
                        help="Define RequestPayer=requester (para buckets requester-pays).")

    args = parser.parse_args()

    # Monta string MFA se ambos fornecidos
    mfa_header = None
    if args.mfa_serial and args.mfa_code:
        mfa_header = f"{args.mfa_serial} {args.mfa_code}"
    elif args.mfa_serial or args.mfa_code:
        print("[erro] Para MFA, informe --mfa-serial e --mfa-code.", file=sys.stderr)
        sys.exit(2)

    # Sessão e cliente
    sess = make_session(args.profile, args.region)
    s3 = make_s3_client(sess)

    # Confirmação
    if not args.yes:
        print("=== ATENÇÃO ===")
        print(f"Isto irá APAGAR TODO o conteúdo do bucket 's3://{args.bucket}' e REMOVER o bucket.")
        print("Esta ação é IRREVERSÍVEL.")
        ok = confirm(f"Para confirmar, digite exatamente o nome do bucket: {args.bucket}")
        if not ok:
            print("Operação cancelada pelo usuário.")
            sys.exit(1)

    # Info
    try:
        region = get_bucket_region(s3, args.bucket)
        if region:
            print(f"Bucket detectado na região: {region}")
    except ClientError as e:
        print(f"[erro] Não foi possível obter região do bucket: {e}", file=sys.stderr)
        sys.exit(1)

    versioned = is_versioned_bucket(s3, args.bucket)
    lock_enabled = has_object_lock(s3, args.bucket)
    print(f"Versionado: {'sim' if versioned else 'não'} | Object Lock: {'sim' if lock_enabled else 'não'}")

    # (Opcional) abortar MPUs
    if args.abort_mpu:
        aborted = abort_multipart_uploads(s3, args.bucket)
        print(f"MPUs abortados: {aborted}")

    total_deleted = 0
    try:
        if versioned:
            print("Apagando versões e delete markers (bucket versionado)...")
            total_deleted = delete_versioned(
                s3,
                args.bucket,
                mfa=mfa_header,
                bypass_governance=args.bypass_governance,
                requester_pays=args.requester_pays,
            )
            print(f"Total versões/markers apagados: {total_deleted}")

            # Em alguns casos, ainda podem restar objetos sem versão (teoricamente não, mas por segurança)
            print("Conferindo e apagando objetos remanescentes (se houver)...")
            total_deleted += delete_unversioned(s3, args.bucket, requester_pays=args.requester_pays)
        else:
            print("Apagando objetos (bucket não versionado)...")
            total_deleted = delete_unversioned(s3, args.bucket, requester_pays=args.requester_pays)

        print(f"Total de itens removidos (objetos + versões/markers): {total_deleted}")

        print("Removendo bucket...")
        delete_bucket_with_retries(s3, args.bucket, requester_pays=args.requester_pays)
        print("Concluído.")

    except ClientError as e:
        err = e.response.get("Error", {})
        print(f"[erro] AWS retornou erro: {err.get('Code')} - {err.get('Message')}", file=sys.stderr)
        if err.get("Code") in ("AccessDenied", "InvalidRequest"):
            print("Verifique permissões: s3:ListBucket, s3:DeleteObject, s3:DeleteObjectVersion, s3:PutBucketVersioning (se necessário), "
                  "e se o bucket possui MFA Delete ou Object Lock exigindo parâmetros apropriados.",
                  file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n[info] Interrompido pelo usuário.", file=sys.stderr)
        sys.exit(130)


if __name__ == "__main__":
    main()