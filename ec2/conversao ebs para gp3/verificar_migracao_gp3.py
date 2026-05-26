#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""verificar_migracao_gp3.py

Verifica o estado de volumes EBS após a migração (ex.: GP2->GP3).

O que checa:
- Tipo do volume (gp2/gp3/io1/etc)
- Estado do volume (in-use/available)
- Anexo (InstanceId + Device)
- Modificações em andamento (describe_volumes_modifications): ModificationState, Progress
- Parâmetros alvo (TargetVolumeParameters: VolumeType/Iops/Throughput)

Modos de seleção de volumes:
- --all: verifica todos os volumes da região
- --only-gp2: verifica apenas volumes gp2 (útil p/ confirmar que não sobrou)
- --only-gp3: verifica apenas volumes gp3
- --volume-ids vol-... vol-...: lista explícita
- --from-file arquivo.txt: um VolumeId por linha (comentários com # são ignorados)

Saída:
- Tabela resumida
- Código de saída (exit code):
  0: OK (nenhum gp2 quando --only-gp2 ou quando --fail-if-gp2; sem erros)
  2: Encontrou gp2 quando --fail-if-gp2
  3: Encontrou volumes ainda "modifying" quando --fail-if-modifying
  10: Erro de execução

Exemplos:
  python3 verificar_migracao_gp3.py --profile dataofficedev --region sa-east-1 --only-gp2 --fail-if-gp2
  python3 verificar_migracao_gp3.py --profile dataofficedev --region sa-east-1 --only-gp3 --fail-if-modifying
  python3 verificar_migracao_gp3.py --profile dataofficedev --region sa-east-1 --volume-ids vol-aaa vol-bbb
"""

import argparse
import sys
from datetime import datetime

import boto3
from botocore.exceptions import BotoCoreError, ClientError


def _session(profile: str, region: str | None):
    if region:
        return boto3.Session(profile_name=profile, region_name=region)
    s = boto3.Session(profile_name=profile)
    if s.region_name is None:
        s = boto3.Session(profile_name=profile, region_name="sa-east-1")
    return s


def _read_ids_file(path: str):
    ids = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            ids.append(line.split()[0])
    return ids


def _chunk(lst, n=200):
    for i in range(0, len(lst), n):
        yield lst[i : i + n]


def _describe_volumes(ec2, filters=None, volume_ids=None):
    vols = []
    paginator = ec2.get_paginator("describe_volumes")
    kwargs = {}
    if filters:
        kwargs["Filters"] = filters
    if volume_ids:
        # API aceita até 500 ids por chamada; paginador não suporta VolumeIds com paginate? mas funciona via kwargs.
        kwargs["VolumeIds"] = volume_ids
    for page in paginator.paginate(**kwargs):
        vols.extend(page.get("Volumes", []))
    return vols


def _describe_modifications(ec2, volume_ids):
    """Retorna dict volume_id -> modification record (ou None)."""
    mods_by_id = {vid: None for vid in volume_ids}
    if not volume_ids:
        return mods_by_id

    # describe_volumes_modifications aceita até 500 ids por chamada.
    for part in _chunk(volume_ids, 200):
        try:
            resp = ec2.describe_volumes_modifications(VolumeIds=part)
        except ClientError as e:
            # Algumas contas sem histórico podem retornar InvalidVolume.NotFound p/ volumes recém-criados; ignore individual?
            raise
        for m in resp.get("VolumesModifications", []):
            mods_by_id[m.get("VolumeId")] = m
    return mods_by_id


def _fmt(s, width):
    s = "" if s is None else str(s)
    if len(s) > width:
        return s[: width - 1] + "…"
    return s.ljust(width)


def main():
    ap = argparse.ArgumentParser(description="Verifica estado de volumes EBS após migração para gp3.")
    ap.add_argument("--profile", required=True, help="AWS profile")
    ap.add_argument("--region", required=False, help="AWS region (default: do profile; fallback sa-east-1)")

    sel = ap.add_mutually_exclusive_group(required=True)
    sel.add_argument("--all", action="store_true", help="Verifica todos os volumes")
    sel.add_argument("--only-gp2", action="store_true", help="Verifica somente volumes gp2")
    sel.add_argument("--only-gp3", action="store_true", help="Verifica somente volumes gp3")
    sel.add_argument("--volume-ids", nargs="+", help="Lista explícita de VolumeIds")
    sel.add_argument("--from-file", help="Arquivo com VolumeIds (1 por linha)")

    ap.add_argument("--show-tags", action="store_true", help="Mostra Name e tags principais")
    ap.add_argument("--fail-if-gp2", action="store_true", help="Exit 2 se houver algum gp2 no resultado")
    ap.add_argument("--fail-if-modifying", action="store_true", help="Exit 3 se houver algum volume ainda modifying")

    args = ap.parse_args()

    try:
        session = _session(args.profile, args.region)
        ec2 = session.client("ec2")
        region = ec2.meta.region_name

        # Seleção
        volume_ids = None
        filters = None
        if args.all:
            pass
        elif args.only_gp2:
            filters = [{"Name": "volume-type", "Values": ["gp2"]}]
        elif args.only_gp3:
            filters = [{"Name": "volume-type", "Values": ["gp3"]}]
        elif args.volume_ids:
            volume_ids = args.volume_ids
        elif args.from_file:
            volume_ids = _read_ids_file(args.from_file)

        # Buscar volumes
        vols = []
        if volume_ids:
            for part in _chunk(volume_ids, 200):
                vols.extend(_describe_volumes(ec2, volume_ids=part))
        else:
            vols = _describe_volumes(ec2, filters=filters)

        if not vols:
            print(f"Nenhum volume encontrado na região {region} para o critério informado.")
            return 0

        # Buscar modifications
        ids = [v["VolumeId"] for v in vols]
        mods = _describe_modifications(ec2, ids)

        # Cabeçalho
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"\nVerificação de volumes EBS - {now} - profile={args.profile} region={region}")
        print("\n" + "=" * 130)
        cols = [
            ("VolumeId", 20),
            ("Type", 5),
            ("GiB", 5),
            ("AZ", 12),
            ("State", 10),
            ("AttachedTo", 20),
            ("Device", 10),
            ("ModState", 12),
            ("Prog%", 6),
            ("Target", 24),
        ]
        if args.show_tags:
            cols.append(("Name", 22))
        header = " ".join(_fmt(n, w) for n, w in cols)
        print(header)
        print("-" * len(header))

        found_gp2 = 0
        found_modifying = 0

        for v in sorted(vols, key=lambda x: x["VolumeId"]):
            vid = v["VolumeId"]
            vtype = v.get("VolumeType")
            size = v.get("Size")
            az = v.get("AvailabilityZone")
            state = v.get("State")
            atts = v.get("Attachments", [])
            inst = atts[0].get("InstanceId") if atts else "-"
            dev = atts[0].get("Device") if atts else "-"

            m = mods.get(vid)
            mod_state = m.get("ModificationState") if m else "-"
            prog = m.get("Progress") if m else None
            target = m.get("TargetVolumeParameters") if m else None
            target_str = "-"
            if target:
                ttype = target.get("VolumeType")
                tiops = target.get("Iops")
                tthr = target.get("Throughput")
                bits = [ttype]
                if tiops is not None:
                    bits.append(f"IOPS={tiops}")
                if tthr is not None:
                    bits.append(f"THR={tthr}")
                target_str = ",".join(bits)

            if vtype == "gp2":
                found_gp2 += 1
            if mod_state in ("modifying", "optimizing"):
                # 'optimizing' geralmente já é ok, mas ainda indica mudança recente
                found_modifying += 1

            row = [
                (vid, 20),
                (vtype, 5),
                (size, 5),
                (az, 12),
                (state, 10),
                (inst, 20),
                (dev, 10),
                (mod_state, 12),
                ("-" if prog is None else prog, 6),
                (target_str, 24),
            ]

            if args.show_tags:
                name = "-"
                for t in v.get("Tags", []) or []:
                    if t.get("Key") == "Name":
                        name = t.get("Value")
                        break
                row.append((name, 22))

            print(" ".join(_fmt(val, w) for val, w in row))

        print("=" * 130)
        print(f"Total: {len(vols)} | gp2: {found_gp2} | com modificação recente (modifying/optimizing): {found_modifying}")

        if args.fail_if_gp2 and found_gp2 > 0:
            return 2
        if args.fail_if_modifying and found_modifying > 0:
            return 3
        return 0

    except (BotoCoreError, ClientError) as e:
        print(f"[ERRO] Falha ao consultar volumes/modificações: {e}")
        return 10


if __name__ == "__main__":
    raise SystemExit(main())
