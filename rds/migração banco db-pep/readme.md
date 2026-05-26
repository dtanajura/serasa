# 🚀 Migração do banco db-pep entre contas AWS

Este repositório documenta o processo de migração do banco de dados `db-pep` da conta:

- **Origem:** `eec-aws-br-ds-dataservices-prod` (662860092544)
- **Destino:** `eec-aws-br-eits-datahub-prod` (415071355886)

A migração combina estratégias de:

- Snapshot (backup nativo do RDS)
- Dump lógico via `mysqldump`
- Restore do banco no ambiente de destino
- Uso de **pods Kubernetes (EKS)** como ambiente intermediário para execução

---

## 📌 Visão Geral do Processo

1. Criar snapshot do cluster RDS (segurança)
2. Validar snapshot
3. Gerar dump (`mysqldump`) do banco na conta origem
4. Transferir o arquivo para o cluster de destino via pod
5. Preparar banco destino (backup + recriação)
6. Restaurar dump no banco destino

---

## 🧱 Pré-requisitos

- AWS CLI configurado (`profiles`: `dsprod` e `datahubprod`)
- Acesso aos clusters EKS: 
    - `ds-eks-01-prod`
    - `datahub-prod`
- `kubectl` configurado
- Pod Ubuntu disponível (`ubuntu-pod`)
- `mysql-client` instalado no pod

---

## ☁️ 1. Criar Snapshot do RDS (Backup)

```bash
aws rds create-db-cluster-snapshot \
  --db-cluster-snapshot-identifier snapshot-antes-change-13-12-2024 \
  --db-cluster-identifier experian-newinfo-rds \
  --profile dsprod \
  --region sa-east-1
```

### ✅ Verificar status do snapshot

```bash
aws rds describe-db-cluster-snapshots \
  --db-cluster-snapshot-identifier snapshot-antes-change-13-12-2024 \
  --profile dsprod \
  --region sa-east-1 \
  --query "DBClusterSnapshots[].Status"
```

Esperado: `available`

---

## 🐬 3. Gerar Dump do Banco

```bash
mysqldump \
  -h experian-newinfo-rds.cluster-csrf6dwrcmnh.sa-east-1.rds.amazonaws.com \
  -u new_info -p \
  --single-transaction \
  --triggers --routines --events \
  --set-gtid-purged=OFF \
  db_pep > db_pep_dump_dsprod.sql
```

---

## 📦 4. Copiar Dump para Conta de Destino

```bash
kubectl cp db_pep_dump_dsprod.tar ubuntu-pod:/db_pep_dump_dsprod.tar
```

---

## ♻️ 7. Restaurar Dump no Destino

```bash
mysql \
  -u admin -p \
  -h eec-aws-br-eits-datahub-prod-pep-aurora.cluster-cpvfmbpitn3a.sa-east-1.rds.amazonaws.com \
  -P 3306 db_pep < db_pep_dump_dsprod.sql
```

---

## ✅ Resultado Esperado

- Banco `db_pep` migrado com sucesso
- Dados preservados

