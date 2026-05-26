
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Lista todos os volumes EBS na região configurada pelo profile AWS:
- VolumeId, Estado (in-use/available), Tamanho (GB), Tipo (gp2/gp3/etc)
- Instâncias anexadas (se houver)
- Exporta opcionalmente para CSV

Uso:
  python listar_ebs.py --profile BURoleForSREAutomation
  python listar_ebs.py --profile BURoleForSREAutomation --csv ebs_volumes.csv
"""

import argparse
import csv
from datetime import datetime
import boto3


def iter_volumes(session):
    """Percorre volumes com paginação na região do profile."""
    ec2 = session.client("ec2")
    paginator = ec2.get_paginator("describe_volumes")
    rows = []

    for page in paginator.paginate():
        for v in page.get("Volumes", []):
            attachments = v.get("Attachments", []) or []
            instance_ids = [a.get("InstanceId") for a in attachments if a.get("InstanceId")]
            device_names = [a.get("Device") for a in attachments if a.get("Device")]
            in_use = "in-use" if instance_ids else "available"

            # Tag Name, se existir
            name_tag = next((t.get("Value") for t in v.get("Tags", []) if t.get("Key") == "Name"), "")

            rows.append({
                "volume_id": v.get("VolumeId"),
                "state": v.get("State"),
                "in_use": in_use,
                "size_gb": v.get("Size"),
                "volume_type": v.get("VolumeType"),
                "availability_zone": v.get("AvailabilityZone"),
                "encrypted": v.get("Encrypted"),
                "iops": v.get("Iops"),
                "throughput": v.get("Throughput"),
                "attached_instance_ids": ",".join(instance_ids),
                "attached_device_names": ",".join(device_names),
                "name_tag": name_tag,
                "create_time": v.get("CreateTime").isoformat() if isinstance(v.get("CreateTime"), datetime) else str(v.get("CreateTime"))
            })
    return rows


def print_table(rows):
    if not rows:
        print("Nenhum volume encontrado.")
        return
    headers = ["volume_id", "in_use", "size_gb", "volume_type", "attached_instance_ids"]
    widths = {h: max(len(h), *(len(str(r.get(h, ""))) for r in rows)) for h in headers}
    print(" | ".join(h.ljust(widths[h]) for h in headers))
    print("-" * sum(widths.values()))
    for r in rows:
        print(" | ".join(str(r.get(h, "")).ljust(widths[h]) for h in headers))


def write_csv(rows, path):
    if not rows:
        print("Nenhum volume para gravar em CSV.")
        return
    fieldnames = list(rows[0].keys())
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    print(f"CSV gravado em: {path}")


def main():
    parser = argparse.ArgumentParser(description="Listar volumes EBS com uso, tamanho e tipo.")
    parser.add_argument("--profile", required=True, help="Profile AWS (ex.: BURoleForSREAutomation)")
    parser.add_argument("--csv", help="Caminho para exportar CSV (opcional)")
    args = parser.parse_args()

    session = boto3.Session(profile_name=args.profile)
    rows = iter_volumes(session)
    print_table(rows)
    if args.csv:
        write_csv(rows, args.csv)


if __name__ == "__main__":
    main()
