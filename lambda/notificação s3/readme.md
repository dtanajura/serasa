### ✅ Roteiro aprimorado para configurar trigger S3 → Lambda

```bash
#!/bin/bash

# =============================
# CONFIGURAÇÕES
# =============================
BUCKET_NAME="eec-aws-br-eits-datahub-positivo-mercantil-raw-dev-bucket"
LAMBDA_NAME="experian-datahub-mercantil-valida-remessa-dev"
PROFILE="datahubdev"
STATEMENT_ID="AllowExecutionFromS3"

echo "Iniciando configuração S3 -> Lambda..."

# =============================
# 1. PERMISSÃO NA LAMBDA
# =============================
echo "Adicionando permissão na Lambda..."

aws lambda add-permission \
  --function-name "$LAMBDA_NAME" \
  --principal s3.amazonaws.com \
  --statement-id "$STATEMENT_ID" \
  --action "lambda:InvokeFunction" \
  --source-arn "arn:aws:s3:::${BUCKET_NAME}" \
  --profile "$PROFILE" 2>/dev/null

if [ $? -eq 0 ]; then
  echo "Permissão adicionada com sucesso ✅"
else
  echo "Permissão pode já existir ou houve erro ⚠️"
fi

# =============================
# 2. CONFIGURAR NOTIFICAÇÃO S3
# =============================
echo "Aplicando configuração de notificação no bucket..."

aws s3api put-bucket-notification-configuration \
  --bucket "$BUCKET_NAME" \
  --notification-configuration file://notification.json \
  --profile "$PROFILE"

if [ $? -eq 0 ]; then
  echo "Configuração aplicada com sucesso ✅"
else
  echo "Erro ao aplicar configuração ❌"
  exit 1
fi

# =============================
# 3. VALIDAR CONFIGURAÇÃO
# =============================
echo "Validando configuração..."

aws s3api get-bucket-notification-configuration \
  --bucket "$BUCKET_NAME" \
  --profile "$PROFILE"

echo "Processo concluído 🚀"
```

***

### 💡 Melhorias que incluí

* Variáveis no topo (facilita reaproveitar)
* Logs (`echo`) para acompanhamento
* Tratamento simples de erro
* Validação final (`get-bucket-notification-configuration`)
* Evita quebrar se a permissão já existir

***
