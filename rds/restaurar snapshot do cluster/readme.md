# 🧬 Roteiro – Restauração de Snapshot de Cluster (RDS/Aurora)

## 🎯 Objetivo

Restaurar um cluster de banco de dados a partir de um snapshot existente, criando um novo cluster funcional.

***

## 📋 Pré-requisitos

* AWS CLI configurado
* Permissões IAM:
  * `rds:RestoreDBClusterFromSnapshot`
  * `rds:CreateDBInstance`
  * `rds:DescribeDBClusters`
* Snapshot existente disponível
* Subnet group e security group definidos

***

## ⚙️ Variáveis utilizadas

```bash
SNAPSHOT_ID="meu-snapshot-cluster"
NEW_CLUSTER_ID="meu-cluster-restaurado"
DB_INSTANCE_ID="meu-cluster-restaurado-instance-1"
ENGINE="aurora-postgresql"
INSTANCE_CLASS="db.r6g.large"
SUBNET_GROUP="meu-subnet-group"
SECURITY_GROUP="sg-xxxxxxxx"
REGION="sa-east-1"
PROFILE="datahubdev"
```

***

## 🔍 1. Validar snapshot disponível

```bash
aws rds describe-db-cluster-snapshots \
  --db-cluster-snapshot-identifier "$SNAPSHOT_ID" \
  --region "$REGION" \
  --profile "$PROFILE"
```

***

## 🔄 2. Restaurar cluster a partir do snapshot

```bash
aws rds restore-db-cluster-from-snapshot \
  --db-cluster-identifier "$NEW_CLUSTER_ID" \
  --snapshot-identifier "$SNAPSHOT_ID" \
  --engine "$ENGINE" \
  --db-subnet-group-name "$SUBNET_GROUP" \
  --vpc-security-group-ids "$SECURITY_GROUP" \
  --region "$REGION" \
  --profile "$PROFILE"
```

***

## 🖥️ 3. Criar instância dentro do cluster

> ⚠️ Necessário — o cluster sozinho não aceita conexões

```bash
aws rds create-db-instance \
  --db-instance-identifier "$DB_INSTANCE_ID" \
  --db-cluster-identifier "$NEW_CLUSTER_ID" \
  --engine "$ENGINE" \
  --db-instance-class "$INSTANCE_CLASS" \
  --region "$REGION" \
  --profile "$PROFILE"
```

***

## ⏳ 4. Acompanhar status do cluster

```bash
STATUS="creating"

while [ "$STATUS" == "creating" ]; do
  STATUS=$(aws rds describe-db-clusters \
    --db-cluster-identifier "$NEW_CLUSTER_ID" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'DBClusters[0].Status' \
    --output text)

  echo "Cluster status: $STATUS"
  sleep 15
done
```

***

## ✅ 5. Validar status final

```bash
aws rds describe-db-clusters \
  --db-cluster-identifier "$NEW_CLUSTER_ID" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'DBClusters[0].Status'
```

Esperado:

```
available
```

***

## 🔗 6. Obter endpoint do cluster

```bash
aws rds describe-db-clusters \
  --db-cluster-identifier "$NEW_CLUSTER_ID" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'DBClusters[0].Endpoint'
```

***

## ⚠️ Observações importantes

* Snapshot restaura:
  * estrutura
  * dados
* Não restaura automaticamente:
  * security groups customizados (precisa validar)
  * parâmetros específicos (parameter group)
* Pode levar **10–30 minutos**
* Sempre cria um **novo cluster** (não sobrescreve)

***

## 🚀 Boas práticas

* ✅ Restaurar com nome diferente (`-restore` ou `-dr`)
* ✅ Validar antes em ambiente DEV
* ✅ Atualizar credenciais se necessário
* ✅ Conferir parameter groups
* ✅ Validar conexões pós-restore

***

## 🔥 Script completo (restore rápido)

```bash
#!/bin/bash

SNAPSHOT_ID="meu-snapshot-cluster"
NEW_CLUSTER_ID="meu-cluster-restaurado"
DB_INSTANCE_ID="meu-cluster-restaurado-instance-1"
ENGINE="aurora-postgresql"
INSTANCE_CLASS="db.r6g.large"
SUBNET_GROUP="meu-subnet-group"
SECURITY_GROUP="sg-xxxxxxxx"
REGION="sa-east-1"
PROFILE="datahubdev"

echo "Iniciando restore do cluster..."

aws rds restore-db-cluster-from-snapshot \
  --db-cluster-identifier "$NEW_CLUSTER_ID" \
  --snapshot-identifier "$SNAPSHOT_ID" \
  --engine "$ENGINE" \
  --db-subnet-group-name "$SUBNET_GROUP" \
  --vpc-security-group-ids "$SECURITY_GROUP" \
  --region "$REGION" \
  --profile "$PROFILE"

echo "Criando instância..."

aws rds create-db-instance \
  --db-instance-identifier "$DB_INSTANCE_ID" \
  --db-cluster-identifier "$NEW_CLUSTER_ID" \
  --engine "$ENGINE" \
  --db-instance-class "$INSTANCE_CLASS" \
  --region "$REGION" \
  --profile "$PROFILE"

STATUS="creating"

while [ "$STATUS" == "creating" ]; do
  STATUS=$(aws rds describe-db-clusters \
    --db-cluster-identifier "$NEW_CLUSTER_ID" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'DBClusters[0].Status' \
    --output text)

  echo "Status: $STATUS"
  sleep 15
done

echo "Cluster pronto ✅"
```