# 📦 Roteiro – Configuração de Permissões S3 → Lambda

## 🎯 Objetivo

Configurar um bucket S3 para acionar uma função Lambda, incluindo:

* Permissão de execução na Lambda
* Configuração de notificação no bucket

***

## 📋 Pré-requisitos

* AWS CLI configurado
* Permissões IAM para:
  * `lambda:add-permission`
  * `s3:PutBucketNotification`
* Arquivo `notification.json` configurado corretamente

***

## ⚙️ Variáveis utilizadas

```bash
BUCKET_NAME="eec-aws-br-eits-datahub-positivo-mercantil-raw-dev-bucket"
LAMBDA_NAME="experian-datahub-mercantil-valida-remessa-dev"
PROFILE="datahubdev"
STATEMENT_ID="AllowExecutionFromS3"
```

***

## 🔐 1. Adicionar permissão na Lambda

Permite que o S3 invoque a função Lambda:

```bash
aws lambda add-permission \
  --function-name "$LAMBDA_NAME" \
  --principal s3.amazonaws.com \
  --statement-id "$STATEMENT_ID" \
  --action "lambda:InvokeFunction" \
  --source-arn "arn:aws:s3:::${BUCKET_NAME}" \
  --profile "$PROFILE"
```

***

## 🔔 2. Configurar notificação no bucket S3

Aplica a configuração definida no arquivo `notification.json`:

```bash
aws s3api put-bucket-notification-configuration \
  --bucket "$BUCKET_NAME" \
  --notification-configuration file://notification.json \
  --profile "$PROFILE"
```

***

## ✅ 3. Validar configuração

Consulta a configuração aplicada no bucket:

```bash
aws s3api get-bucket-notification-configuration \
  --bucket "$BUCKET_NAME" \
  --profile "$PROFILE"
```

***

## 📄 Exemplo de `notification.json`

```json
{
  "LambdaFunctionConfigurations": [
    {
      "Id": "TriggerLambdaOnObjectCreate",
      "LambdaFunctionArn": "arn:aws:lambda:sa-east-1:123456789012:function:experian-datahub-mercantil-valida-remessa-dev",
      "Events": ["s3:ObjectCreated:*"]
    }
  ]
}
```

***

## ⚠️ Observações importantes

* O `statement-id` deve ser único por função Lambda
* Se a permissão já existir, o comando pode falhar sem impacto
* Certifique-se que:
  * A Lambda e o bucket estão na **mesma região**
  * O ARN da Lambda no JSON está correto
* Você pode incluir filtros:
  * prefix (ex: `entrada/`)
  * suffix (ex: `.csv`)

***

## 🚀 Exemplo com filtro (opcional)

```json
{
  "LambdaFunctionConfigurations": [
    {
      "Id": "TriggerFiltrado",
      "LambdaFunctionArn": "arn:aws:lambda:sa-east-1:123456789012:function:experian-datahub-mercantil-valida-remessa-dev",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            {
              "Name": "prefix",
              "Value": "entrada/"
            },
            {
              "Name": "suffix",
              "Value": ".csv"
            }
          ]
        }
      }
    }
  ]
}
```

***

## 🧱 Boas práticas

* Versionar o `notification.json`
* Padronizar nomes de `Id` nos triggers
* Automatizar via script (`.sh`) ou pipeline CI/CD
* Evitar usar `ObjectCreated:*` se quiser granularidade

