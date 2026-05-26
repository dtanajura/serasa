# 🔍 Roteiro – Execução de Queries no Amazon Athena

## 🎯 Objetivo

Executar consultas no Amazon Athena via AWS CLI e salvar os resultados em um bucket S3.

***

## 📋 Pré-requisitos

* AWS CLI configurado
* Permissões IAM:
  * `athena:StartQueryExecution`
  * `athena:GetQueryExecution`
  * `athena:GetQueryResults`
  * `s3:PutObject` no bucket de saída
* Bucket S3 para armazenar resultados
* Database e tabelas já criados no Athena/Glue

***

## ⚙️ Variáveis utilizadas

```bash
QUERY_STRING="SELECT * FROM minha_tabela LIMIT 10;"
DATABASE="meu_database"
OUTPUT_LOCATION="s3://meu-bucket-athena-results/output/"
PROFILE="datahubdev"
```

***

## ▶️ 1. Executar query no Athena

```bash
QUERY_EXECUTION_ID=$(aws athena start-query-execution \
  --query-string "$QUERY_STRING" \
  --query-execution-context Database="$DATABASE" \
  --result-configuration OutputLocation="$OUTPUT_LOCATION" \
  --profile "$PROFILE" \
  --query 'QueryExecutionId' \
  --output text)

echo "QueryExecutionId: $QUERY_EXECUTION_ID"
```

***

## ⏳ 2. Acompanhar status da execução

```bash
STATUS="RUNNING"

while [ "$STATUS" == "RUNNING" ] || [ "$STATUS" == "QUEUED" ]; do
  STATUS=$(aws athena get-query-execution \
    --query-execution-id "$QUERY_EXECUTION_ID" \
    --profile "$PROFILE" \
    --query 'QueryExecution.Status.State' \
    --output text)

  echo "Status: $STATUS"
  sleep 2
done
```

***

## ✅ 3. Validar resultado

```bash
if [ "$STATUS" == "SUCCEEDED" ]; then
  echo "Query executada com sucesso ✅"
else
  echo "Erro na execução ❌"
  exit 1
fi
```

***

## 📥 4. Obter resultados (opcional)

```bash
aws athena get-query-results \
  --query-execution-id "$QUERY_EXECUTION_ID" \
  --profile "$PROFILE"
```

***

## 📂 5. Localizar resultado no S3

Os resultados ficam disponíveis em:

```
s3://meu-bucket-athena-results/output/<QueryExecutionId>.csv
```

***

## ⚠️ Observações importantes

* Cada execução gera um arquivo CSV no S3
* Queries grandes podem demorar dependendo do volume de dados
* Custo é baseado em dados lidos (scan)
* Use `LIMIT` para testes iniciais
* Prefira formatos otimizados (Parquet, ORC)

***

## 🚀 Boas práticas

* ✅ Usar partições nas tabelas
* ✅ Evitar `SELECT *` em produção
* ✅ Configurar compressão (Snappy/Parquet)
* ✅ Separar bucket de resultado por ambiente (dev/hml/prd)
* ✅ Automatizar via script ou pipeline

***

## 🔥 Exemplo completo (script)

```bash
#!/bin/bash

QUERY="SELECT count(*) FROM minha_tabela;"
DB="meu_database"
OUTPUT="s3://meu-bucket-athena-results/output/"
PROFILE="datahubdev"

echo "Executando query..."

QID=$(aws athena start-query-execution \
  --query-string "$QUERY" \
  --query-execution-context Database="$DB" \
  --result-configuration OutputLocation="$OUTPUT" \
  --profile "$PROFILE" \
  --query 'QueryExecutionId' \
  --output text)

echo "Query ID: $QID"

STATUS="RUNNING"

while [ "$STATUS" == "RUNNING" ] || [ "$STATUS" == "QUEUED" ]; do
  STATUS=$(aws athena get-query-execution \
    --query-execution-id "$QID" \
    --profile "$PROFILE" \
    --query 'QueryExecution.Status.State' \
    --output text)

  echo "Status: $STATUS"
  sleep 2
done

if [ "$STATUS" == "SUCCEEDED" ]; then
  echo "Sucesso ✅"
else
  echo "Falha ❌"
fi
```
