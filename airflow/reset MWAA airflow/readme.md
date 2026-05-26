# 🔄 Roteiro – Reset de Ambiente MWAA (Amazon Managed Airflow)

## 🎯 Objetivo

Realizar o reset de um ambiente MWAA, incluindo:

* Reinício dos componentes (workers, scheduler, webserver)
* Atualização controlada (força refresh)
* Limpeza opcional de DAGs / requirements / configs

***

## 📋 Pré-requisitos

* AWS CLI configurado
* Permissões IAM:
  * `airflow:UpdateEnvironment`
  * `airflow:GetEnvironment`
* Nome do ambiente MWAA
* Bucket S3 associado ao ambiente

***

## ⚙️ Variáveis utilizadas

```bash
ENV_NAME="meu-ambiente-mwaa"
PROFILE="datahubdev"
REGION="sa-east-1"

# (opcional)
S3_DAG_PATH="s3://meu-bucket-mwaa/dags/"
S3_REQUIREMENTS="s3://meu-bucket-mwaa/requirements.txt"
```

***

## 🔍 1. Verificar status atual do ambiente

```bash
aws mwaa get-environment \
  --name "$ENV_NAME" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'Environment.Status'
```

***

## 🔄 2. Forçar “reset” via update (refresh do ambiente)

MWAA não possui um comando direto de "restart", então usamos **update-environment**:

```bash
aws mwaa update-environment \
  --name "$ENV_NAME" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --logging-configuration '{
    "SchedulerLogs": {"Enabled": true, "LogLevel": "INFO"}
  }'
```

👉 Isso força o redeploy dos componentes (scheduler, workers, webserver)

***

## 🔁 3. Acompanhar atualização

```bash
STATUS="UPDATING"

while [ "$STATUS" == "UPDATING" ]; do
  STATUS=$(aws mwaa get-environment \
    --name "$ENV_NAME" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'Environment.Status' \
    --output text)

  echo "Status: $STATUS"
  sleep 10
done

echo "Status final: $STATUS"
```

***

## 🧹 4. (Opcional) Reset completo de DAGs

```bash
aws s3 rm "$S3_DAG_PATH" --recursive --profile "$PROFILE"
echo "DAGs removidas ✅"
```

Depois subir novamente:

```bash
aws s3 cp ./dags/ "$S3_DAG_PATH" --recursive --profile "$PROFILE"
```

***

## 📦 5. (Opcional) Atualizar requirements

Com base no seu `requirements.txt`:

```bash
aws s3 cp requirements.txt "$S3_REQUIREMENTS" --profile "$PROFILE"
```

Exemplo atual:

```txt
apache-airflow==2.7.2
apache-airflow-providers-amazon==8.7.1
boto3==1.28.17
pandas==2.1.1
```

Depois forçar update:

```bash
aws mwaa update-environment \
  --name "$ENV_NAME" \
  --requirements-s3-path "requirements.txt" \
  --region "$REGION" \
  --profile "$PROFILE"
```

***

## ⚙️ 6. (Opcional) Atualizar config do Airflow

Com base no seu `airflow-config.json`:

```json
{
  "logging.logging_level": "INFO"
}
```

Aplicar:

```bash
aws mwaa update-environment \
  --name "$ENV_NAME" \
  --airflow-configuration-options file://airflow-config.json \
  --region "$REGION" \
  --profile "$PROFILE"
```

***

## ✅ 7. Validar ambiente

```bash
aws mwaa get-environment \
  --name "$ENV_NAME" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query 'Environment.Status'
```

Esperado:

```
AVAILABLE
```

***

## ⚠️ Observações importantes

* MWAA **não tem reset direto** → sempre via `update-environment`
* Cada update pode levar **10–20 minutos**
* Atualizar qualquer parâmetro já força restart
* Evite fazer múltiplos updates em sequência
* Logs são essenciais para debug (CloudWatch)

***

## 🚀 Boas práticas

* ✅ Versionar `requirements.txt`
* ✅ Versionar `airflow-config.json`
* ✅ Criar script único de reset (runbook)
* ✅ Usar ambiente separado (dev/hml/prd)
* ✅ Monitorar via CloudWatch Logs

***

## 🔥 Script completo (reset rápido)

```bash
#!/bin/bash

ENV_NAME="meu-ambiente-mwaa"
PROFILE="datahubdev"
REGION="sa-east-1"

echo "Iniciando reset MWAA..."

aws mwaa update-environment \
  --name "$ENV_NAME" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --logging-configuration '{
    "SchedulerLogs": {"Enabled": true, "LogLevel": "INFO"}
  }'

STATUS="UPDATING"

while [ "$STATUS" == "UPDATING" ]; do
  STATUS=$(aws mwaa get-environment \
    --name "$ENV_NAME" \
    --region "$REGION" \
    --profile "$PROFILE" \
    --query 'Environment.Status' \
    --output text)

  echo "Status: $STATUS"
  sleep 10
done

echo "Ambiente final: $STATUS"

if [ "$STATUS" == "AVAILABLE" ]; then
  echo "Reset concluído com sucesso ✅"
else
  echo "Falha no reset ❌"
fi
```