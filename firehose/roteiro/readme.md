# 🔥 Roteiro – Criação e Integração Kinesis Firehose

## 🎯 Objetivo

Criar um **Kinesis Firehose Delivery Stream** para:

* ✅ Consumir dados de um Kinesis Data Stream
* ✅ Transformar dados (JSON → Parquet)
* ✅ Entregar no S3
* ✅ Integrar com Glue/Athena
* ✅ Logging em CloudWatch

***

# 🧠 1. Arquitetura

```text
App / Producer
   ↓
Kinesis Data Stream
   ↓
Kinesis Firehose
   ↓
S3 (Parquet)
   ↓
Glue Catalog / Athena
```

***

# ⚙️ 2. Configuração do Firehose

Você já tem um config bem estruturado 👇

## 📄 `firehose-config.json`

### ✅ Principais pontos:

* Nome do stream:

```json
"DeliveryStreamName": "consentimento-pf-firehose"
```

***

## 🔗 Fonte (Kinesis Data Stream)

```json
"KinesisStreamARN": "arn:aws:kinesis:sa-east-1:730335661246:stream/consentimento-datastream"
```

👉 Firehose consome dados diretamente do stream    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/firehose-config.json)

***

## 🪣 Destino (S3)

```json
"BucketARN": "arn:aws:s3:::eec-aws-br-eits-datahub-consent-dev-bucket"
```

👉 Dados armazenados no bucket DataHub    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/firehose-config.json)

***

## 🔄 Conversão de formato

```json
"DataFormatConversionConfiguration": {
  "Enabled": true
}
```

### 🔁 Input:

```json
"OpenXJsonSerDe"
```

### 🔁 Output:

```json
"ParquetSerDe"
```

👉 JSON → Parquet (ótimo pra Athena)    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/firehose-config.json)

***

## 🧬 Integração com Glue

```json
"DatabaseName": "consentimento-glue-db",
"TableName": "consent_pf"
```

👉 Schema centralizado no Glue    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/firehose-config.json)

***

## 📊 Logs

```json
"LogGroupName": "/aws/kinesisfirehose/consentimento-pf-firehose"
```

👉 Debug e auditoria    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/firehose-config.json)

***

# 🏗️ 3. Criar o Firehose

```bash
aws firehose create-delivery-stream \
  --cli-input-json file://firehose-config.json \
  --region sa-east-1 \
  --profile datahubdev
```

***

# 🔐 4. Role IAM (crítico)

Role: `BURoleForFirehose`

## Deve permitir:

```json
s3:PutObject
s3:AbortMultipartUpload
kinesis:DescribeStream
kinesis:GetShardIterator
kinesis:GetRecords
glue:GetTable
```

***

# 🔎 5. Validar criação

```bash
aws firehose describe-delivery-stream \
  --delivery-stream-name consentimento-pf-firehose
```

***

# 🚀 6. Testar ingestão

## ▶️ Enviar evento para Kinesis

```bash
aws kinesis put-record \
  --stream-name consentimento-datastream \
  --partition-key test \
  --data '{"nome":"teste"}'
```

***

## ✅ Resultado esperado

* Arquivo no S3
* Formato Parquet
* Estrutura no Glue

***

# 📂 7. Verificar no S3

```bash
aws s3 ls s3://eec-aws-br-eits-datahub-consent-dev-bucket/
```

***

# 🔎 8. Consultar via Athena

```sql
SELECT * FROM consentimento_glue_db.consent_pf;
```

***

# 🧩 9. Integração com aplicação (Kubernetes)

## 📄 `deployment.yaml`

Seu app usa:

```yaml
serviceAccountName: consent-sa
```

```yaml
envFrom:
  - secretRef:
      name: experian-datahub-consent-management-api
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/deployment.yaml)

***

## ✅ Significa:

* App envia dados (provavelmente → Kinesis)
* Autenticação via IAM Role (IRSA)

***

# 🔐 10. Permissões da app

Role ligada ao `consent-sa` deve permitir:

```json
kinesis:PutRecord
kinesis:PutRecords
```

***

# ⚠️ 11. Pontos de atenção

## 🔥 Performance

* Buffer (default: 5MB/300s)
* Ajustar se necessário

***

## 📛 Schema Glue

* Deve bater com JSON entrada
* Senão → erro de conversão

***

## 🧪 Debug

```bash
aws logs tail /aws/kinesisfirehose/consentimento-pf-firehose
```

***

# ✅ 12. Checklist final

* ✅ Stream Kinesis criado
* ✅ Firehose criado
* ✅ Role IAM OK
* ✅ S3 configurado
* ✅ Glue schema OK
* ✅ Logs ativos
* ✅ Teste funcionando

***

# 🚀 Boas práticas

* ✅ Sempre usar Parquet
* ✅ Particionar no S3 (ex: date/hour)
* ✅ Versionar config JSON
* ✅ Monitorar erros (CW logs)
* ✅ Criar DLQ (error output prefix)

***

# 🔥 Script padrão

```bash
#!/bin/bash

echo "Criando Firehose..."

aws firehose create-delivery-stream \
  --cli-input-json file://firehose-config.json

echo "Validando..."

aws firehose describe-delivery-stream \
  --delivery-stream-name consentimento-pf-firehose

echo "Concluído ✅"
```
