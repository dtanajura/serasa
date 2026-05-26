# ⚡ Roteiro – Criação de Rotina AWS Lambda

## 🎯 Objetivo

Criar uma função Lambda responsável por executar uma rotina automatizada (ex: teste de conectividade TCP), com deploy via AWS CLI.

***

## 📋 Pré-requisitos

* AWS CLI configurado
* Permissões IAM:
  * `lambda:CreateFunction`
  * `lambda:UpdateFunctionCode`
  * `iam:PassRole`
* Role IAM para Lambda
* Código Python da função

***

## 📦 1. Código da Lambda

Exemplo baseado no seu `teste.py`:

```python
import socket

def lambda_handler(event, context):
    server = "10.99.48.51"
    port = 443
    timeout = 10

    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)

        sock.connect((server, port))

        return {
            'statusCode': 200,
            'body': f"Conexão bem-sucedida com {server}:{port}"
        }

    except socket.error as e:
        return {
            'statusCode': 500,
            'body': f"Erro ao conectar com {server}:{port} - {e}"
        }

    finally:
        sock.close()
```

✔ Essa Lambda faz:

* Teste de conectividade (healthcheck)
* Pode ser usada para monitoramento de rede/endpoints    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/teste.py)

***

## 📦 2. Empacotar código

```bash
zip function.zip teste.py
```

***

## 🏗️ 3. Criar função Lambda

```bash
aws lambda create-function \
  --function-name lambda-teste-conectividade \
  --runtime python3.10 \
  --role arn:aws:iam::123456789012:role/LambdaExecutionRole \
  --handler teste.lambda_handler \
  --zip-file fileb://function.zip \
  --timeout 15 \
  --memory-size 128 \
  --region sa-east-1 \
  --profile datahubdev
```

***

## 🔄 4. Atualizar código (se necessário)

```bash
aws lambda update-function-code \
  --function-name lambda-teste-conectividade \
  --zip-file fileb://function.zip \
  --region sa-east-1 \
  --profile datahubdev
```

***

## ▶️ 5. Testar execução

```bash
aws lambda invoke \
  --function-name lambda-teste-conectividade \
  output.json \
  --region sa-east-1 \
  --profile datahubdev

cat output.json
```

***

## ⏰ 6. Criar rotina (trigger com CloudWatch/EventBridge)

Exemplo: rodar a cada 5 minutos

### Criar regra:

```bash
aws events put-rule \
  --name lambda-teste-cada-5min \
  --schedule-expression "rate(5 minutes)" \
  --region sa-east-1 \
  --profile datahubdev
```

### Associar Lambda à regra:

```bash
aws events put-targets \
  --rule lambda-teste-cada-5min \
  --targets "Id"="1","Arn"="arn:aws:lambda:sa-east-1:123456789012:function:lambda-teste-conectividade" \
  --region sa-east-1 \
  --profile datahubdev
```

***

## 🔐 7. Permitir execução pelo EventBridge

```bash
aws lambda add-permission \
  --function-name lambda-teste-conectividade \
  --statement-id eventbridge-invoke \
  --action 'lambda:InvokeFunction' \
  --principal events.amazonaws.com \
  --source-arn arn:aws:events:sa-east-1:123456789012:rule/lambda-teste-cada-5min \
  --region sa-east-1 \
  --profile datahubdev
```

***

## ✅ 8. Validar funcionamento

* Ver logs no CloudWatch:

```bash
/aws/lambda/lambda-teste-conectividade
```

* Esperado:

```json
{
  "statusCode": 200,
  "body": "Conexão bem-sucedida"
}
```

***

## ⚠️ Observações importantes

* Lambda dentro de VPC precisa de:
  * Subnets
  * Security Groups liberando saída
* Timeout deve ser maior que tempo de teste
* Evite IP hardcoded → use variável de ambiente

***

## 🚀 Boas práticas

* ✅ Usar variáveis de ambiente:

```bash
--environment Variables={SERVER=10.99.48.51,PORT=443}
```

* ✅ Monitorar via CloudWatch
* ✅ Criar alarmes (Lambda error > 0)
* ✅ Versionar código (Git)

***

## 🔥 Script completo (automatizado)

```bash
#!/bin/bash

FUNCTION_NAME="lambda-teste-conectividade"
ROLE_ARN="arn:aws:iam::123456789012:role/LambdaExecutionRole"
PROFILE="datahubdev"
REGION="sa-east-1"

echo "Empacotando código..."
zip function.zip teste.py

echo "Criando função Lambda..."
aws lambda create-function \
  --function-name "$FUNCTION_NAME" \
  --runtime python3.10 \
  --role "$ROLE_ARN" \
  --handler teste.lambda_handler \
  --zip-file fileb://function.zip \
  --timeout 15 \
  --memory-size 128 \
  --region "$REGION" \
  --profile "$PROFILE"

echo "Criando rotina..."
aws events put-rule \
  --name "${FUNCTION_NAME}-schedule" \
  --schedule-expression "rate(5 minutes)" \
  --region "$REGION" \
  --profile "$PROFILE"

echo "Configurando trigger..."
aws events put-targets \
  --rule "${FUNCTION_NAME}-schedule" \
  --targets "Id"="1","Arn"="arn:aws:lambda:${REGION}:123456789012:function:${FUNCTION_NAME}" \
  --region "$REGION" \
  --profile "$PROFILE"

echo "Finalizado ✅"
```

