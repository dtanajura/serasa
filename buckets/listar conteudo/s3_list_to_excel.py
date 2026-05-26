#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import sys
from datetime import datetime, timezone
from openpyxl import Workbook

import boto3
from botocore.exceptions import ClientError

import pandas as pd


def parse_args():
    p = argparse.ArgumentParser(
        description="Lista objetos de um bucket S3 e exporta para Excel com tamanho e data da última modificação."
    )
    p.add_argument("--bucket", required=True, help="Nome do bucket S3.")
    p.add_argument("--prefix", default="", help="Prefix opcional para filtrar objetos.")
    p.add_argument("--profile", default=None, help="AWS profile (opcional).")
    p.add_argument("--region", default=None, help="Região AWS (opcional).")
    # p.add_argument("--output", default="s3_objetos.xlsx", help="Arquivo Excel de saída (.xlsx).")
    p.add_argument("--max-rows", type=int, default=None,
                   help="Limite máximo de linhas (para testes/lab).")
    p.add_argument("--dry-run", action="store_true",
                   help="Executa uma chamada simples para validar acesso, sem gerar o Excel.")
    # >>> Novos parâmetros de progresso
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
    """Converte bytes para formato humano (KB/MB/GB)."""
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

    try:
        s3.head_bucket(Bucket=args.bucket)
    except ClientError as e:
        print(f"[ERROR] Sem acesso ao bucket '{args.bucket}': {e}")
        sys.exit(1)

    # Configuração opcional da barra de progresso (tqdm)
    use_tqdm = False
    tqdm = None
    if args.use_tqdm:
        try:
            from tqdm import tqdm as _tqdm  # type: ignore
            tqdm = _tqdm
            use_tqdm = True
        except Exception:
            safe_print("[WARN] tqdm não encontrado; usando contador simples.", quiet=args.quiet)

    rows = []
    total_size = 0
    count = 0

    # DRY-RUN: só conta e soma, com progresso
    if args.dry_run:
        bar = tqdm(desc="Contando objetos", unit="obj") if use_tqdm else None
        for obj in list_objects(s3, args.bucket, args.prefix):
            count += 1
            total_size += obj.get("Size", 0)

            if use_tqdm and bar:
                bar.update(1)
            elif args.progress_every and (count % args.progress_every == 0):
                safe_print(f"[PROGRESS] {count:,} objetos lidos...", quiet=args.quiet)

            if args.max_rows and count >= args.max_rows:
                break

        if use_tqdm and bar:
            bar.close()

        safe_print(f"[DRY-RUN] Objetos encontrados: {count:,}", quiet=args.quiet)
        safe_print(f"[DRY-RUN] Tamanho total: {sizeof_fmt(total_size)} ({total_size} bytes)", quiet=args.quiet)
        return

    # Execução normal: coleta linhas com progresso
    bar = tqdm(desc="Lendo objetos", unit="obj") if use_tqdm else None

    try:
        for obj in list_objects(s3, args.bucket, args.prefix):
            key = obj["Key"]
            size = obj.get("Size", 0)
            lm = obj.get("LastModified")  # datetime timezone-aware (UTC)
            sc = obj.get("StorageClass", "STANDARD")
            etag = obj.get("ETag", "").strip('"')

            total_size += size
            count += 1

            rows.append({
                "Bucket": args.bucket,
                "Prefix": args.prefix,
                "Key": key,
                "Tamanho (bytes)": size,
                "Tamanho (humano)": sizeof_fmt(size),
                "Última modificação (UTC)": lm.isoformat() if isinstance(lm, datetime) else "",
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

    # Cria DataFrame e exporta para Excel
    df = pd.DataFrame(rows)

    # =========================
    # Exporta para Excel (split em múltiplas abas) + resumo
    # =========================

    EXCEL_MAX_ROWS = 1_048_576
    # vamos reservar 1 linha para o cabeçalho
    MAX_DATA_ROWS_PER_SHEET = EXCEL_MAX_ROWS - 1

    header = [
        "Bucket", "Prefix", "Key", "Tamanho (bytes)", "Tamanho (humano)",
        "Última modificação (UTC)", "StorageClass", "ETag"
    ]

    output_file = f"{args.bucket}.xlsx"

    # Descobre se há versionamento habilitado
    # get_bucket_versioning pode retornar: {"Status": "Enabled"} / "Suspended" / vazio
    try:
        ver = s3.get_bucket_versioning(Bucket=args.bucket)
        versioning_status = ver.get("Status", "NotEnabled")  # NotEnabled se não houver "Status"
    except ClientError as e:
        versioning_status = f"Erro ao consultar versionamento: {e}"

    # Helpers para volume em MB/TB (base 1024)
    def bytes_to_mb(b): return b / (1024 ** 2)
    def bytes_to_tb(b): return b / (1024 ** 4)

    wb = Workbook(write_only=True)

    # Primeira aba
    sheet_idx = 1
    ws = wb.create_sheet(title=f"objetos_s3_{sheet_idx}")
    ws.append(header)

    rows_in_current_sheet = 0  # só conta linhas de dados (sem header)

    # Recomeça contadores (não use o 'rows' em memória)
    total_size = 0
    count = 0

    # Lista objetos e escreve direto no Excel
    for obj in list_objects(s3, args.bucket, args.prefix):
        key = obj["Key"]
        size = obj.get("Size", 0)
        lm = obj.get("LastModified")
        sc = obj.get("StorageClass", "STANDARD")
        etag = obj.get("ETag", "").strip('"')

        total_size += size
        count += 1

        # Progresso
        if args.progress_every and (count % args.progress_every == 0):
            safe_print(f"[PROGRESS] {count:,} objetos lidos...", quiet=args.quiet)

        # Se atingiu o limite por aba, cria uma nova
        if rows_in_current_sheet >= MAX_DATA_ROWS_PER_SHEET:
            sheet_idx += 1
            ws = wb.create_sheet(title=f"objetos_s3_{sheet_idx}")
            ws.append(header)
            rows_in_current_sheet = 0

        ws.append([
            args.bucket,
            args.prefix,
            key,
            size,
            sizeof_fmt(size),
            lm.isoformat() if isinstance(lm, datetime) else "",
            sc,
            etag
        ])
        rows_in_current_sheet += 1

        if args.max_rows and count >= args.max_rows:
            break

    # Aba de resumo
    ws_sum = wb.create_sheet(title="resumo")
    ws_sum.append(["Bucket", args.bucket])
    ws_sum.append(["Prefix", args.prefix])
    ws_sum.append(["Total de objetos", int(count)])
    ws_sum.append(["Versionamento", versioning_status])
    ws_sum.append(["Tamanho total (bytes)", int(total_size)])
    ws_sum.append(["Tamanho total (MB)", round(bytes_to_mb(total_size), 2)])
    ws_sum.append(["Tamanho total (TB)", round(bytes_to_tb(total_size), 4)])
    ws_sum.append(["Tamanho total (humano)", sizeof_fmt(total_size)])
    ws_sum.append(["Gerado em (UTC)", datetime.now(timezone.utc).isoformat()])

    wb.save(output_file)

    safe_print(f"[OK] Excel gerado: {output_file}", quiet=args.quiet)
    safe_print(
        f"[INFO] Objetos: {count:,} | Versionamento: {versioning_status} | Volume: {sizeof_fmt(total_size)}",
        quiet=args.quiet
    )

    # if not df.empty:
    #     df.sort_values(by=["Key"], inplace=True)

    with pd.ExcelWriter(f"{args.bucket}.xlsx", engine="openpyxl") as writer:
        # with pd.ExcelWriter(args.output, engine="openpyxl") as writer:
        df.to_excel(writer, index=False, sheet_name="objetos_s3")

        resumo = pd.DataFrame([{
            "Bucket": args.bucket,
            "Prefix": args.prefix,
            "Total de objetos": int(count),
            "Tamanho total (bytes)": int(total_size),
            "Tamanho total (humano)": sizeof_fmt(total_size),
            "Gerado em": datetime.now(timezone.utc).isoformat(),
        }])
        resumo.to_excel(writer, index=False, sheet_name="resumo")

    safe_print(f"[OK] Excel gerado: {args.bucket}.xlxs", quiet=args.quiet)
    safe_print(f"[INFO] Objetos: {count:,} | Tamanho total: {sizeof_fmt(total_size)} ({total_size} bytes)", quiet=args.quiet)

if __name__ == "__main__":
    main()
