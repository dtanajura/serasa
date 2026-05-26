#!/usr/bin/env python3

import argparse
import boto3
import subprocess
import re
from cryptography import x509
from cryptography.hazmat.backends import default_backend


# -------------------------------
# Utilidades
# -------------------------------

def normalize_domain(domain: str) -> str:
    """Remove wildcard se existir"""
    return domain[2:] if domain.startswith("*.") else domain


def parse_cert(pem: str):
    cert = x509.load_pem_x509_certificate(
        pem.encode(), default_backend()
    )
    return cert.subject.rfc4514_string(), cert.issuer.rfc4514_string()


# -------------------------------
# AWS helpers
# -------------------------------

def get_matching_hosted_zone(r53, base_domain):
    zones = r53.list_hosted_zones()["HostedZones"]

    for z in zones:
        zone_name = z["Name"].rstrip(".")
        if base_domain.endswith(zone_name):
            return z["Id"].split("/")[-1], zone_name

    return None, None


def get_hostnames(r53, hosted_zone_id):
    hostnames = []

    paginator = r53.get_paginator("list_resource_record_sets")
    for page in paginator.paginate(HostedZoneId=hosted_zone_id):
        for r in page["ResourceRecordSets"]:
            if r["Type"] in ("A", "CNAME"):
                hostnames.append(r["Name"].rstrip("."))

    return hostnames


# -------------------------------
# TLS / OpenSSL
# -------------------------------

def fetch_cert_chain_openssl(hostname):
    cmd = [
        "openssl", "s_client",
        "-connect", f"{hostname}:443",
        "-servername", hostname,
        "-showcerts"
    ]

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        stdin=subprocess.DEVNULL,   # 🔑 evita bloqueio interativo
        timeout=15
    )

    certs_pem = re.findall(
        r"-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----",
        result.stdout,
        re.S
    )

    return certs_pem


# -------------------------------
# Main
# -------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Audita a CA raiz real de certificados ACM via Route53 + TLS"
    )
    parser.add_argument("--profile", required=True, help="AWS profile")
    parser.add_argument("--region", default="sa-east-1", help="Região AWS")

    args = parser.parse_args()

    session = boto3.Session(
        profile_name=args.profile,
        region_name=args.region
    )

    acm = session.client("acm")
    r53 = session.client("route53")

    certs = acm.list_certificates()["CertificateSummaryList"]

    for cert in certs:
        domain = cert["DomainName"]
        base_domain = normalize_domain(domain)

        print("\n==============================")
        print(f"📄 Certificado: {domain}")

        zone_id, zone_name = get_matching_hosted_zone(r53, base_domain)
        if not zone_id:
            print("❌ Hosted Zone não encontrada")
            continue

        print(f"🌐 Hosted Zone detectada: {zone_name}")

        hostnames = get_hostnames(r53, zone_id)
        if not hostnames:
            print("❌ Nenhum hostname A/CNAME encontrado na zona")
            continue

        valid_chain = None
        valid_hostname = None

        for hostname in hostnames:
            print(f"🔍 Tentando hostname: {hostname}")

            try:
                chain = fetch_cert_chain_openssl(hostname)
            except subprocess.TimeoutExpired:
                print("⚠️  Timeout ao conectar (pulando)")
                continue
            except Exception as e:
                print(f"⚠️  Erro ao executar openssl: {e}")
                continue

            if not chain:
                print("⚠️  Nenhum certificado TLS retornado")
                continue

            # Cadeia válida encontrada
            valid_chain = chain
            valid_hostname = hostname
            break

        if not valid_chain:
            print("❌ Nenhum hostname da zona retornou cadeia TLS válida")
            continue

        print(f"\n✅ Cadeia TLS válida encontrada em: {valid_hostname}")
        print("\n📜 Cadeia de certificados:")

        for i, pem in enumerate(valid_chain):
            subject, issuer = parse_cert(pem)
            print(f"\n  📜 Cert [{i}]")
            print(f"     Subject: {subject}")
            print(f"     Issuer : {issuer}")

        # Identificar CA raiz real (self-signed)
        root_subject = None
        for pem in valid_chain:
            subject, issuer = parse_cert(pem)
            if subject == issuer:
                root_subject = subject
                break

        if root_subject:
            print("\n✅ CA RAIZ DETECTADA")
            print(f"   {root_subject}")
            if "Entrust" in root_subject:
                print("⚠️  RAIZ: ENTRUST")
            else:
                print("✅ RAIZ: NÃO ENTRUST")
        else:
            print("\n⚠️  Não foi possível identificar a CA raiz")


if __name__ == "__main__":
    main()