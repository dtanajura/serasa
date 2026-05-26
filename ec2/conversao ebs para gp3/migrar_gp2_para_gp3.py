#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Migra volumes EBS GP2 para GP3 de forma segura.

- Usa um profile AWS obrigatório e região opcional.
- Se a região não for informada, usa a região padrão do profile/config, 
  e se não houver, usa 'sa-east-1'.
- Lista volumes GP2, confirma com o usuário e migra para GP3 preservando performance:
    * IOPS (GP2) ~= min(16000, max(3000, 3 * tamanho_em_GiB))
    * Throughput: 250 MiB/s se tamanho >= 334 GiB; caso contrário 125 MiB/s
- Pode aguardar o término das modificações (–-wait) e funcionar sem prompt (–-yes).
"""

import argparse
import sys
import time

import unicodedata
from datetime import datetime, UTC


import boto3
from botocore.exceptions import BotoCoreError, ClientError, WaiterError

def resolve_session(profile: str, region: str | None):
    try:
        if region:
            session = boto3.Session(profile_name=profile, region_name=region)
        else:
            session = boto3.Session(profile_name=profile)
            if session.region_name is None:
                # fallback para sa-east-1 conforme solicitado
                session = boto3.Session(profile_name=profile, region_name="sa-east-1")
        return session
    except (BotoCoreError, ClientError) as e:
        print(f"[ERRO] Falha ao criar sessão com o profile '{profile}': {e}")
        sys.exit(1)


def get_ec2_client(session):
    try:
        return session.client("ec2")
    except (BotoCoreError, ClientError) as e:
        print(f"[ERRO] Falha ao criar cliente EC2: {e}")
        sys.exit(1)


def list_gp2_volumes(ec2):
    """Retorna lista de dicionários com info dos volumes GP2."""
    vols = []
    paginator = ec2.get_paginator("describe_volumes")
    try:
        for page in paginator.paginate(
            Filters=[{"Name": "volume-type", "Values": ["gp2"]}]
        ):
            for v in page.get("Volumes", []):
                vols.append(
                    {
                        "VolumeId": v["VolumeId"],
                        "Size": v["Size"],  # GiB
                        "State": v.get("State"),
                        "Az": v.get("AvailabilityZone"),
                        "Encrypted": v.get("Encrypted", False),
                        "Attachments": v.get("Attachments", []),
                        "Tags": v.get("Tags", []),
                    }
                )
    except (BotoCoreError, ClientError) as e:
        print(f"[ERRO] Falha ao listar volumes GP2: {e}")
        sys.exit(1)
    return vols


def compute_preserved_perf(size_gib: int):
    """
    Preserva performance ao migrar GP2 -> GP3:
    - IOPS: baseline GP2 = 3 * GiB, limitado a 16.000; mínimo de 3.000 em GP3
    - Throughput: 250 MiB/s se tamanho >= 334 GiB; senão 125 MiB/s
    """
    iops_gp2_baseline = min(16000, 3 * size_gib)
    iops_gp3 = max(3000, iops_gp2_baseline)
    throughput_gp3 = 250 if size_gib >= 334 else 125
    return iops_gp3, throughput_gp3


def print_volumes(vols):
    if not vols:
        print("Nenhum volume GP2 encontrado.")
        return
    print("\nVolumes GP2 encontrados:\n")
    header = f"{'VolumeId':<20} {'Tamanho(GiB)':>12} {'AZ':<14} {'Estado':<10} {'Anexado a':<20} {'Cript.':<7}"
    print(header)
    print("-" * len(header))
    for v in vols:
        attached = v["Attachments"][0]["InstanceId"] if v["Attachments"] else "-"
        print(
            f"{v['VolumeId']:<20} {v['Size']:>12} {v['Az']:<14} {v['State']:<10} {attached:<20} {str(v['Encrypted']):<7}"
        )
    print()


def confirm(prompt: str, auto_yes: bool = False) -> bool:
    if auto_yes:
        return True
    ans = input(f"{prompt} [s/N]: ").strip().lower()
    return ans in ("s", "sim", "y", "yes")


def modify_to_gp3(ec2, volume_id: str, size_gib: int, preserve_perf: bool = True):
    params = {"VolumeId": volume_id, "VolumeType": "gp3"}
    if preserve_perf:
        iops, throughput = compute_preserved_perf(size_gib)
        params["Iops"] = iops
        params["Throughput"] = throughput

    try:
        resp = ec2.modify_volume(**params)
        return resp
    except ClientError as e:
        # exemplos: VolumeInUse, IncorrectModificationState, Throttling, etc.
        print(f"[ERRO] modify_volume falhou para {volume_id}: {e}")
        return None
    except BotoCoreError as e:
        print(f"[ERRO] modify_volume (boto core) para {volume_id}: {e}")
        return None


def wait_for_modification(ec2, volume_id: str):
    """
    Aguarda até que o estado esteja em 'optimizing' ou 'completed'.
    'optimizing' já é seguro, mas você pode esperar até 'completed'
    se desejar customizar essa função.
    """
    print(f"Aguardando modificação de {volume_id} ...")
    while True:
        try:
            resp = ec2.describe_volumes_modifications(
                VolumeIds=[volume_id],
                Filters=[{"Name": "volume-id", "Values": [volume_id]}],
            )
        except (BotoCoreError, ClientError) as e:
            print(f"[ERRO] describe_volumes_modifications para {volume_id}: {e}")
            return False

        mods = resp.get("VolumesModifications", [])
        if not mods:
            time.sleep(5)
            continue

        m = mods[0]
        progress = m.get("Progress")
        target = m.get("TargetVolumeParameters", {})
        status = m.get("ModificationState")

        prog_str = f" {progress}%" if progress is not None else ""
        t_iops = target.get("Iops")
        t_thr = target.get("Throughput")
        sys.stdout.write(
            f"\r - {volume_id}: estado={status}{prog_str} (alvo: gp3, IOPS={t_iops}, THR={t_thr})"
        )
        sys.stdout.flush()

        if status in ("optimizing", "completed"):
            print("")  # newline
            return True

        time.sleep(10)

import unicodedata
from datetime import datetime, UTC

def ascii_safe(text: str) -> str:
    # remove acentos e deixa apenas ASCII
    return unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()

def create_snapshot_and_wait(ec2, volume_id: str, reason: str, wait_delay: int = 10, wait_attempts: int = 360) -> str | None:
    """
    Cria snapshot e aguarda até o estado 'completed'.
    Retorna o SnapshotId em caso de sucesso; caso contrário, retorna None.
    - wait_delay: segundos entre checagens
    - wait_attempts: número máximo de tentativas (padrão: 360 => ~1 hora)
    """
    safe_reason = ascii_safe(reason)
    snap_id = None

    try:
        resp = ec2.create_snapshot(
            VolumeId=volume_id,
            Description=safe_reason,
            TagSpecifications=[
                {
                    "ResourceType": "snapshot",
                    "Tags": [
                        {"Key": "CreatedBy", "Value": "migrar_gp2_para_gp3.py"},
                        {"Key": "CreatedAt", "Value": datetime.now(UTC).isoformat()},
                        {"Key": "Purpose", "Value": "Pre-migracao GP2->GP3"},
                        {"Key": "SourceVolume", "Value": volume_id},
                    ],
                }
            ],
        )
        snap_id = resp["SnapshotId"]
        print(f"   Snapshot criado: {snap_id}. Aguardando 'completed' ...")
    except (BotoCoreError, ClientError) as e:
        print(f"[ERRO] Falha ao criar snapshot de {volume_id}: {e}")
        return None

    # Aguardar a conclusão usando waiter nativo
    try:
        waiter = ec2.get_waiter("snapshot_completed")
        waiter.wait(
            SnapshotIds=[snap_id],
            WaiterConfig={"Delay": wait_delay, "MaxAttempts": wait_attempts},
        )
        print(f"   Snapshot {snap_id} está 'completed'.")
        return snap_id
    except WaiterError as we:
        print(f"[ERRO] Snapshot {snap_id} não ficou 'completed' no tempo esperado: {we}")
        return None
    except (BotoCoreError, ClientError) as e:
        print(f"[ERRO] Falha ao aguardar conclusão do snapshot {snap_id}: {e}")
        return None

# def maybe_create_snapshot(ec2, volume_id: str, reason: str) -> str | None:
#     """
#     Cria snapshot com descrição ASCII-safe (AWS exige isso).
#     """
#     # limpa a descrição antes de enviar p/ AWS
#     safe_reason = ascii_safe(reason)

#     try:
#         resp = ec2.create_snapshot(
#             VolumeId=volume_id,
#             Description=safe_reason,
#             TagSpecifications=[
#                 {
#                     "ResourceType": "snapshot",
#                     "Tags": [
#                         {"Key": "CreatedBy", "Value": "migrar_gp2_para_gp3.py"},
#                         {"Key": "CreatedAt", "Value": datetime.now(UTC).isoformat()},
#                     ],
#                 }
#             ],
#         )
#         snap_id = resp["SnapshotId"]
#         print(f"   Snapshot criado: {snap_id}")
#         return snap_id
#     except (BotoCoreError, ClientError) as e:
#         print(f"[ERRO] Falha ao criar snapshot de {volume_id}: {e}")
#         return None

# def maybe_create_snapshot(ec2, volume_id: str, reason: str) -> str | None:
#     """
#     Cria snapshot como segurança. Não é obrigatório; chame apenas se desejar.
#     """
#     try:
#         resp = ec2.create_snapshot(
#             VolumeId=volume_id,
#             Description=reason,
#             TagSpecifications=[
#                 {
#                     "ResourceType": "snapshot",
#                     "Tags": [
#                         {"Key": "CreatedBy", "Value": "migrar_gp2_para_gp3.py"},
#                         {"Key": "CreatedAt", "Value": datetime.utcnow().isoformat() + "Z"},
#                     ],
#                 }
#             ],
#         )
#         snap_id = resp["SnapshotId"]
#         print(f"   Snapshot criado: {snap_id}")
#         return snap_id
#     except (BotoCoreError, ClientError) as e:
#         print(f"[ERRO] Falha ao criar snapshot de {volume_id}: {e}")
#         return None


def main():
    parser = argparse.ArgumentParser(
        description="Lista e migra volumes EBS GP2 para GP3 em uma conta AWS."
    )
    parser.add_argument(
        "--profile", required=True, help="Nome do profile AWS a ser usado (obrigatório)."
    )
    parser.add_argument(
        "--region",
        required=False,
        help="Região AWS (opcional). Se omitida, usa a default do profile/config; se não houver, usa sa-east-1.",
    )
    parser.add_argument(
        "--yes",
        action="store_true",
        help="Não perguntar confirmação; assumir 'sim' para migração.",
    )
    parser.add_argument(
        "--wait",
        action="store_true",
        help="Aguardar cada modificação entrar em 'optimizing' ou 'completed'.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Apenas listar volumes e estratégia de migração; não alterar nada.",
    )
    parser.add_argument(
        "--no-preserve-perf",
        action="store_true",
        help="Não preservar performance (usa defaults do GP3: 3000 IOPS / 125 MiB/s).",
    )
    parser.add_argument(
        "--snapshot-before",
        action="store_true",
        help="(Opcional) Criar snapshot antes de modificar cada volume.",
    )
    args = parser.parse_args()

    session = resolve_session(args.profile, args.region)
    ec2 = get_ec2_client(session)
    effective_region = ec2.meta.region_name
    print(f"Usando profile='{args.profile}', região='{effective_region}'.")

    vols = list_gp2_volumes(ec2)
    print_volumes(vols)

    if not vols:
        return

    # Mostrar estratégia
    print("Estratégia de migração GP2 -> GP3:")
    if args.no_preserve_perf:
        print(" - Sem preservação de performance (defaults GP3: IOPS=3000, THR=125 MiB/s).")
    else:
        print(" - Preservando performance baseada no tamanho (IOPS e Throughput equivalentes ao GP2).")
        # Exemplo de cálculo para o primeiro volume
        s = vols[0]["Size"]
        iops, thr = compute_preserved_perf(s)
        print(f"   Exemplo (para {s} GiB): IOPS={iops}, Throughput={thr} MiB/s")

    if args.dry_run:
        print("\n[Dry-run] Nenhuma modificação será aplicada.")
        return

    if not confirm(
        f"Deseja migrar {len(vols)} volume(s) GP2 para GP3 na região {effective_region}?",
        auto_yes=args.yes,
    ):
        print("Operação cancelada pelo usuário.")
        return

    # Loop de migração
    preserve = not args.no_preserve_perf
    for v in vols:
        vid = v["VolumeId"]
        size = v["Size"]
        attached = v["Attachments"][0]["InstanceId"] if v["Attachments"] else None
        print(f"\nMigrando volume {vid} ({size} GiB){' anexado a ' + attached if attached else ''} ...")

        # if args.snapshot_before:
        #     maybe_create_snapshot(
        #         ec2, vid, reason=f"Pré-migração GP2->GP3 de {vid} em {effective_region}"
        #     )
        if args.snapshot_before:
            snap_id = create_snapshot_and_wait(
                ec2, vid, reason=f"Pre-migracao GP2->GP3 de {vid} em {effective_region}"
            )
            if not snap_id:
                print(f"[ATENÇÃO] Snapshot não concluído para {vid}. **Pulando** migração deste volume.")
                continue  # não migra este volume

        resp = modify_to_gp3(ec2, vid, size, preserve_perf=preserve)
        if resp is None:
            continue

        if args.wait:
            wait_for_modification(ec2, vid)

    print("\nConcluído. Para verificar, use:")
    print("  aws ec2 describe-volumes --filters Name=volume-type,Values=gp3 --profile {} --region {}".format(
        args.profile, effective_region
    ))
    print("Ou rode novamente este script para confirmar que não há GP2 restantes.")


if __name__ == "__main__":
    main()
