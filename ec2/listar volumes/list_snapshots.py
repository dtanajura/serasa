
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Lista snapshots/backups de múltiplos serviços AWS na região do profile informado:
- EC2/EBS snapshots (disco)
- RDS DB Instance snapshots
- RDS DB Cluster snapshots (Aurora)
- DocumentDB DB Cluster snapshots
- Redshift Cluster snapshots
- ElastiCache snapshots (Redis)
- AWS Backup (Recovery Points por Backup Vault)

Colunas do CSV (schema unificado):
- profile, region, tipo, resource_id, parent_id, name, status, engine,
  size_gb, encrypted, kms_key_id, start_time, description, snapshot_type, tags_name

Uso:
  python list_all_snapshots.py --profile <meu-profile>
  python list_all_snapshots.py --profile <meu-profile> --csv snapshots_<meu-profile>.csv
"""

import argparse
import csv
from datetime import datetime
import boto3
from botocore.exceptions import ClientError, EndpointConnectionError, UnknownServiceError, ParamValidationError


# ---------- utils ----------

def resolve_region(session) -> str:
    """
    Resolve a região a partir do profile informado.
    Tenta session.region_name e, se None, tenta botocore (session._session.get_config_variable('region')).
    """
    print("[DEBUG] *** Resolve Region")
    region = session.region_name
    if not region:
        try:
            region = session._session.get_config_variable("region")
        except Exception:
            region = None
    return region


def iso(dt) -> str:
    """Formata datetime para ISO 8601 (UTC/local dependendo do tzinfo) ou string vazia."""
    if isinstance(dt, datetime):
        try:
            return dt.isoformat()
        except Exception:
            return str(dt)
    return ""


def add_common(row_list, profile, region, tipo, **fields):
    """Adiciona linha ao buffer com colunas unificadas."""
    base = {
        "profile": profile,
        "region": region,
        "tipo": tipo,
        "resource_id": "",
        "parent_id": "",
        "name": "",
        "status": "",
        "engine": "",
        "size_gb": "",
        "encrypted": "",
        "kms_key_id": "",
        "start_time": "",
        "description": "",
        "snapshot_type": "",
        "tags_name": "",
    }
    base.update({k: ("" if v is None else v) for k, v in fields.items()})
    row_list.append(base)


# ---------- EC2/EBS ----------

def list_ebs_snapshots(session, profile, region, rows):
    print(f"[DEBUG] *** EBS Snapshots: {profile}, {region})")
    try:
        ec2 = session.client("ec2", region_name=region)
        paginator = ec2.get_paginator("describe_snapshots")
        params = {"OwnerIds": ["self"]}
        for page in paginator.paginate(**params):
            for s in page.get("Snapshots", []):
                name_tag = next((t.get("Value") for t in s.get("Tags", []) if t.get("Key") == "Name"), "")
                add_common(
                    rows, profile, region, "ebs",
                    resource_id=s.get("SnapshotId"),
                    parent_id=s.get("VolumeId"),
                    name=s.get("SnapshotId"),
                    status=s.get("State"),
                    engine="",
                    size_gb=s.get("VolumeSize"),
                    encrypted=s.get("Encrypted"),
                    kms_key_id=s.get("KmsKeyId"),
                    start_time=iso(s.get("StartTime")),
                    description=s.get("Description"),
                    snapshot_type="",  # EC2 não retorna 'automated/manual' aqui
                    tags_name=name_tag,
                )
    except (ClientError, EndpointConnectionError) as e:
        print(f"[WARN] EC2/EBS: {e}")
    except UnknownServiceError:
        print("[WARN] Serviço EC2 indisponível nesta região.")


# ---------- RDS (DB Instance) ----------

def list_rds_instance_snapshots(session, profile, region, rows):
    print(f"[DEBUG] *** RDS Instannce Snapshots: {profile}, {region})")
    try:
        rds = session.client("rds", region_name=region)
        paginator = rds.get_paginator("describe_db_snapshots")
        for resp in paginator.paginate():
            for s in resp.get("DBSnapshots", []):
                add_common(
                    rows, profile, region, "rds-instance",
                    resource_id=s.get("DBSnapshotIdentifier"),
                    parent_id=s.get("DBInstanceIdentifier"),
                    name=s.get("DBSnapshotIdentifier"),
                    status=s.get("Status"),
                    engine=s.get("Engine"),
                    size_gb=s.get("AllocatedStorage"),
                    encrypted=s.get("Encrypted"),
                    kms_key_id=s.get("KmsKeyId"),
                    start_time=iso(s.get("SnapshotCreateTime")),
                    description="",
                    snapshot_type=s.get("SnapshotType"),  # automated | manual | shared | public
                    tags_name="",  # RDS snapshots não trazem 'Tags' neste endpoint
                )
    except (ClientError, EndpointConnectionError) as e:
        print(f"[WARN] RDS (Instance): {e}")
    except UnknownServiceError:
        print("[WARN] Serviço RDS indisponível nesta região.")


# ---------- RDS (DB Cluster / Aurora) ----------

def list_rds_cluster_snapshots(session, profile, region, rows):
    print(f"[DEBUG] *** RDS Cluster Snapshots: {profile}, {region})")
    try:
        rds = session.client("rds", region_name=region)
        paginator = rds.get_paginator("describe_db_cluster_snapshots")
        for resp in paginator.paginate():
            for s in resp.get("DBClusterSnapshots", []):
                add_common(
                    rows, profile, region, "rds-cluster",
                    resource_id=s.get("DBClusterSnapshotIdentifier"),
                    parent_id=s.get("DBClusterIdentifier"),
                    name=s.get("DBClusterSnapshotIdentifier"),
                    status=s.get("Status"),
                    engine=s.get("Engine"),
                    size_gb="",  # cluster snapshot não fornece tamanho direto
                    encrypted=s.get("StorageEncrypted"),
                    kms_key_id=s.get("KmsKeyId"),
                    start_time=iso(s.get("SnapshotCreateTime")),
                    description="",
                    snapshot_type=s.get("SnapshotType"),  # automated | manual | shared | public
                    tags_name="",
                )
    except (ClientError, EndpointConnectionError) as e:
        print(f"[WARN] RDS (Cluster): {e}")
    except UnknownServiceError:
        print("[WARN] Serviço RDS indisponível nesta região.")


# ---------- DocumentDB (DB Cluster) ----------

def list_docdb_cluster_snapshots(session, profile, region, rows):
    print(f"[DEBUG] *** DOCDB Snapshots: {profile}, {region})")
    try:
        docdb = session.client("docdb", region_name=region)
        paginator = docdb.get_paginator("describe_db_cluster_snapshots")
        for resp in paginator.paginate():
            for s in resp.get("DBClusterSnapshots", []):
                add_common(
                    rows, profile, region, "docdb-cluster",
                    resource_id=s.get("DBClusterSnapshotIdentifier"),
                    parent_id=s.get("DBClusterIdentifier"),
                    name=s.get("DBClusterSnapshotIdentifier"),
                    status=s.get("Status"),
                    engine="docdb",
                    size_gb="",
                    encrypted=s.get("StorageEncrypted"),
                    kms_key_id=s.get("KmsKeyId"),
                    start_time=iso(s.get("SnapshotCreateTime")),
                    description="",
                    snapshot_type=s.get("SnapshotType"),
                    tags_name="",
                )
    except UnknownServiceError:
        # DocumentDB pode não estar disponível em algumas regiões
        print("[INFO] DocumentDB não disponível nesta região; ignorando.")
    except (ClientError, EndpointConnectionError) as e:
        print(f"[WARN] DocumentDB: {e}")


# ---------- Redshift ----------

def list_redshift_snapshots(session, profile, region, rows):
    print(f"[DEBUG] *** RedShift Snapshots: {profile}, {region})")
    try:
        redshift = session.client("redshift", region_name=region)
        paginator = redshift.get_paginator("describe_cluster_snapshots")
        for resp in paginator.paginate():
            for s in resp.get("Snapshots", []):
                add_common(
                    rows, profile, region, "redshift",
                    resource_id=s.get("SnapshotIdentifier"),
                    parent_id=s.get("ClusterIdentifier"),
                    name=s.get("SnapshotIdentifier"),
                    status=s.get("Status"),
                    engine="redshift",
                    size_gb="",  # tamanho não é direto aqui
                    encrypted=s.get("Encrypted"),
                    kms_key_id=s.get("KmsKeyId"),
                    start_time=iso(s.get("SnapshotCreateTime")),
                    description="",
                    snapshot_type=s.get("SnapshotType"),  # automated | manual
                    tags_name="",
                )
    except UnknownServiceError:
        print("[INFO] Redshift não disponível nesta região; ignorando.")
    except (ClientError, EndpointConnectionError) as e:
        print(f"[WARN] Redshift: {e}")


# ---------- ElastiCache ----------

def list_elasticache_snapshots(session, profile, region, rows):
    print(f"[DEBUG] *** Elasticache Snapshots: {profile}, {region})")
    try:
        ec = session.client("elasticache", region_name=region)
        paginator = ec.get_paginator("describe_snapshots")
        for resp in paginator.paginate():
            for s in resp.get("Snapshots", []):
                add_common(
                    rows, profile, region, "elasticache",
                    resource_id=s.get("SnapshotName"),
                    parent_id=s.get("ReplicationGroupId") or s.get("CacheClusterId"),
                    name=s.get("SnapshotName"),
                    status=s.get("SnapshotStatus"),
                    engine=s.get("Engine"),
                    size_gb="",  # tamanho não é direto
                    encrypted="",  # não há campo boolean explícito aqui
                    kms_key_id=s.get("KmsKeyId"),
                    start_time=iso(s.get("SnapshotCreateTime")),
                    description="",
                    snapshot_type="",  # não há tipo manual/automático explícito
                    tags_name="",
                )
    except UnknownServiceError:
        print("[INFO] ElastiCache não disponível nesta região; ignorando.")
    except (ClientError, EndpointConnectionError) as e:
        print(f"[WARN] ElastiCache: {e}")

def list_aws_backup(session, profile, region, rows):
    print(f"[DEBUG] *** Backup Snapshots: {profile}, {region})")
    try:
        backup = session.client("backup", region_name=region)

        # 1) Lista todos os backup vaults da conta/região
        vaults = []
        vp = backup.get_paginator("list_backup_vaults")
        for vpage in vp.paginate():
            vaults.extend(vpage.get("BackupVaultList", []))

        # 2) Para cada vault, pagina recovery points
        for v in vaults:
            vault_name = v.get("BackupVaultName")
            if not vault_name:
                continue

            rp = backup.get_paginator("list_recovery_points_by_backup_vault")
            for rpage in rp.paginate(BackupVaultName=vault_name):
                for rpnt in rpage.get("RecoveryPoints", []):
                    # Campos principais
                    add_common(
                        rows, profile, region, "backup",
                        resource_id=rpnt.get("RecoveryPointArn"),
                        parent_id=rpnt.get("ResourceArn"),
                        name=vault_name,
                        status=rpnt.get("Status"),
                        engine=rpnt.get("ResourceType"),
                        size_gb=(
                            round((rpnt.get("BackupSizeInBytes") or 0) / (1024**3), 2)
                            if rpnt.get("BackupSizeInBytes") else ""
                        ),
                        encrypted="",  # EncryptionKeyArn indica KMS; manteremos em kms_key_id
                        kms_key_id=rpnt.get("EncryptionKeyArn"),
                        start_time=iso(rpnt.get("CreatedDate")),
                        description="",
                        snapshot_type="",  # AWS Backup não usa esse campo
                        tags_name="",
                    )
    except UnknownServiceError:
        print("[INFO] AWS Backup não disponível nesta região; ignorando.")
    except ParamValidationError as e:
        print(f"[ERROR] AWS Backup (param): {e}")
    except (ClientError, EndpointConnectionError) as e:
        print(f"[ERROR] AWS Backup (endpoint): {e}")


# ---------- impressão/CSV ----------

def print_table(rows):
    if not rows:
        print("Nenhum snapshot/backup encontrado.")
        return

    headers = ["tipo", "resource_id", "parent_id", "name", "status", "size_gb", "start_time", "region", "profile"]
    widths = {h: max(len(h), *(len(str(r.get(h, ""))) for r in rows)) for h in headers}

    # # Cabeçalho
    # print(" ".join(h.ljust(widths[h]) for h in headers))
    # print("-" * (sum(widths.values()) + len(headers) - 1))

    # # Linhas
    # for r in rows:
    #     print(" ".join(str(r.get(h, "")).ljust(widths[h]) for h in headers))


def write_csv(rows, path):
    if not rows:
        print("Nenhum snapshot/backup para gravar em CSV.")
        return

    fieldnames = [
        "profile", "region", "tipo", "resource_id", "parent_id", "name", "status", "engine",
        "size_gb", "encrypted", "kms_key_id", "start_time", "description", "snapshot_type", "tags_name"
    ]
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        for r in rows:
            # garante que colunas existam
            w.writerow({k: r.get(k, "") for k in fieldnames})
    print(f"CSV gravado em: {path}")


# ---------- main ----------

def main():
    parser = argparse.ArgumentParser(
        description="Listar snapshots/backups (EBS, RDS, DocDB, Redshift, ElastiCache, AWS Backup) usando a região do profile."
    )
    parser.add_argument("--profile", required=True, help="Profile AWS (ex.: ssrmdev)")
    parser.add_argument("--csv", help="Caminho para exportar CSV (opcional)")
    args = parser.parse_args()

    session = boto3.Session(profile_name=args.profile)
    region = resolve_region(session)
    if not region:
        raise RuntimeError(
            "Não foi possível resolver a região do profile AWS. "
            "Defina 'region' no arquivo ~/.aws/config para este profile ou exporte AWS_DEFAULT_REGION."
        )

    print(f"[DEBUG] Profile: {args.profile} | Região: {region}")

    rows = []
    # Ordem: EBS, RDS instância, RDS cluster, DocDB cluster, Redshift, ElastiCache, AWS Backup
    list_ebs_snapshots(session, args.profile, region, rows)
    list_rds_instance_snapshots(session, args.profile, region, rows)
    list_rds_cluster_snapshots(session, args.profile, region, rows)
    list_docdb_cluster_snapshots(session, args.profile, region, rows)
    list_redshift_snapshots(session, args.profile, region, rows)
    list_elasticache_snapshots(session, args.profile, region, rows)
    list_aws_backup(session, args.profile, region, rows)

    print_table(rows)

    if args.csv:
        write_csv(rows, args.csv)



if __name__ == "__main__":
    main()
