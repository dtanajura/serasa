#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Lista objetos de um bucket S3 e exporta para CSV (streaming) com:
- tamanho
- data da última modificação
- storage class
- ETag
- coluna adicional para indicar se o objeto tem mais de X dias (padrão 180)

Dependências:
- boto3
(opcional) tqdm para barra de progresso, se usar --use-tqdm
"""

import argparse
import sys
import csv
from datetime import datetime, timezone, timedelta

import boto3
from botocore.exceptions import ClientError


def parse_args():
    p = argparse.ArgumentParser(
        description="Lista objetos de um bucket S3 e exporta para CSV com tamanho e data da última modificação."
    )
    p.add_argument("--bucket", required=True, help="Nome do bucket S3.")
    p.add_argument("--prefix", default="", help="Prefix opcional para filtrar objetos.")
    p.add_argument("--profile", default=None, help="AWS profile (opcional).")
    p.add_argument("--region", default=None, help="Região AWS (opcional).")

    p.add_argument("--output", default=None, help="Arquivo CSV de saída (padrão: <bucket>.csv).")
    p.add_argument("--days", type=int, default=180,
                   help="Idade mínima (em dias) para marcar como antigo (padrão: 180).")

    p.add_argument("--max-rows", type=int, default=None,
                   help="Limite máximo de linhas (para testes/lab).")
    p.add_argument("--dry-run", action="store_true",
                   help="Executa uma varredura simples para validar acesso e contar, sem gerar CSV.")
    p.add_argument("--progress-every", type=int, default=1000,
                   help="Imprime progresso a cada N objetos lidos (padrão: 1000).")
    p.add_argument("--use-tqdm", action="store_true",
                   help="Tenta usar barra de progresso com tqdm (se disponível).")
    p.add_argument("--quiet", action="store_true",
                   help="Modo silencioso: minimiza saídas no console.")
    return p.parse_args()


def make_session(profile=None, region=None):
    if profile or region:
        return boto3.Session(profile_name=profile, region_name=region)
    return boto3.Session()


def sizeof_fmt(num, suffix="B"):
    """Converte bytes para formato humano (KB/MB/GB/TB...)."""
    if num is None:
        return ""
    for unit in ["", "K", "M", "G", "T", "P", "E", "Z"]:
        if abs(num) < 1024.0:
            return f"{num:3.1f} {unit}{suffix}"
        num /= 1024.0
    return f"{num:.1f} Y{suffix}"


def list_objects(s3_client, bucket, prefix=""):
    """Generator de objetos com paginação."""
    paginator = s3_client.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for item in page.get("Contents", []):
            yield item


def safe_print(*args, quiet=False, **kwargs):
    if not quiet:
        print(*args, **kwargs)


def main():
    args = parse_args()
    session = make_session(args.profile, args.region)
    s3 = session.client("s3")

    # valida acesso ao bucket
    try:
        s3.head_bucket(Bucket=args.bucket)
    except ClientError as e:
        print(f"[ERROR] Sem acesso ao bucket '{args.bucket}': {e}")
        sys.exit(1)

    # versionamento
    try:
        ver = s3.get_bucket_versioning(Bucket=args.bucket)
        versioning_status = ver.get("Status", "NotEnabled")  # Enabled / Suspended / NotEnabled
    except ClientError as e:
        versioning_status = f"Erro ao consultar versionamento: {e}"

    # progresso (tqdm opcional)
    use_tqdm = False
    tqdm = None
    if args.use_tqdm:
        try:
            from tqdm import tqdm as _tqdm  # type: ignore
            tqdm = _tqdm
            use_tqdm = True
        except Exception:
            safe_print("[WARN] tqdm não encontrado; usando contador simples.", quiet=args.quiet)

    # referência fixa de tempo para consistência no cutoff e no cálculo de dias
    now_utc = datetime.now(timezone.utc)
    cutoff = now_utc - timedelta(days=args.days)

    # DRY-RUN: só conta e soma, sem gerar CSV
    if args.dry_run:
        count = 0
        total_size = 0
        older_count = 0

        bar = tqdm(desc="Contando objetos", unit="obj") if use_tqdm else None
        for obj in list_objects(s3, args.bucket, args.prefix):
            count += 1
            size = obj.get("Size", 0)
            total_size += size

            lm = obj.get("LastModified")
            if isinstance(lm, datetime) and lm <= cutoff:
                older_count += 1

            if use_tqdm and bar:
                bar.update(1)
            elif args.progress_every and (count % args.progress_every == 0):
                safe_print(f"[PROGRESS] {count:,} objetos lidos...", quiet=args.quiet)

            if args.max_rows and count >= args.max_rows:
                break

        if use_tqdm and bar:
            bar.close()

        safe_print(f"[DRY-RUN] Bucket: {args.bucket}", quiet=args.quiet)
        safe_print(f"[DRY-RUN] Prefix: {args.prefix or '(sem)'}", quiet=args.quiet)
        safe_print(f"[DRY-RUN] Versionamento: {versioning_status}", quiet=args.quiet)
        safe_print(f"[DRY-RUN] Objetos encontrados: {count:,}", quiet=args.quiet)
        safe_print(f"[DRY-RUN] Objetos > {args.days} dias: {older_count:,}", quiet=args.quiet)
        safe_print(f"[DRY-RUN] Cutoff (UTC): {cutoff.isoformat()}", quiet=args.quiet)
        safe_print(f"[DRY-RUN] Tamanho total: {sizeof_fmt(total_size)} ({total_size} bytes)", quiet=args.quiet)
        return

    # Execução normal: escreve CSV em streaming
    output_file = args.output or f"{args.bucket}.csv"

    # colunas do CSV
    older_col_name = f"Mais de {args.days} dias"
    fieldnames = [
        "Bucket", "Prefix", "Key",
        "Tamanho (bytes)", "Tamanho (humano)",
        "Última modificação (UTC)",
        "Dias sem modificação",
        older_col_name,
        "StorageClass", "ETag",
    ]

    total_size = 0
    count = 0
    older_count = 0

    bar = tqdm(desc="Lendo objetos", unit="obj") if use_tqdm else None

    with open(output_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()

        try:
            for obj in list_objects(s3, args.bucket, args.prefix):
                key = obj["Key"]
                size = obj.get("Size", 0)
                lm = obj.get("LastModified")  # datetime tz-aware (UTC)
                sc = obj.get("StorageClass", "STANDARD")
                etag = obj.get("ETag", "").strip('"')

                total_size += size
                count += 1

                if isinstance(lm, datetime):
                    dias_sem_mod = (now_utc - lm).days
                    mais_de = lm <= cutoff
                    if mais_de:
                        older_count += 1
                    lm_str = lm.isoformat()
                else:
                    dias_sem_mod = ""
                    mais_de = ""
                    lm_str = ""

                writer.writerow({
                    "Bucket": args.bucket,
                    "Prefix": args.prefix,
                    "Key": key,
                    "Tamanho (bytes)": size,
                    "Tamanho (humano)": sizeof_fmt(size),
                    "Última modificação (UTC)": lm_str,
                    "Dias sem modificação": dias_sem_mod,
                    older_col_name: mais_de,  # True/False
                    "StorageClass": sc,
                    "ETag": etag,
                })

                if use_tqdm and bar:
                    bar.update(1)
                elif args.progress_every and (count % args.progress_every == 0):
                    safe_print(f"[PROGRESS] {count:,} objetos lidos...", quiet=args.quiet)

                if args.max_rows and count >= args.max_rows:
                    break
        finally:
            if use_tqdm and bar:
                bar.close()

    safe_print(f"[OK] CSV gerado: {output_file}", quiet=args.quiet)
    safe_print(
        f"[INFO] Objetos: {count:,} | >{args.days} dias: {older_count:,} | Versionamento: {versioning_status} | Volume: {sizeof_fmt(total_size)}",
        quiet=args.quiet
    )
    safe_print(f"[INFO] Cutoff (UTC): {cutoff.isoformat()}", quiet=args.quiet)


if __name__ == "__main__":
    main()