# 🔄 Roteiro – Implantação AWS DataSync (Cross Account S3)

## 🎯 Objetivo

Configurar DataSync para transferência de dados entre buckets S3:

* ✅ Cross-account (origem → destino)
* ✅ Automação via script Python
* ✅ Logging + monitoramento
* ✅ Segurança via IAM Role

***

# 🧠 1. Arquitetura

```text
Conta Origem (S3)
     ↓
IAM Role (DataSync)
     ↓
AWS DataSync
     ↓
Conta Destino (S3)
```

***

# 📦 2. Cenário do seu ambiente

## 📌 Origem

* Bucket: `experian-reports-extraction-files-prod`
* Conta: `225989352496`

## 📌 Destino

* Bucket: `serasaexperian-coe-data-platform-prod-landing`
* Conta: `221992887590`

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20prod.sh)

***

# 🔐 3. Criar Role na conta de origem

## 📄 Trust Policy

```json
{
  "Effect": "Allow",
  "Principal": {
    "Service": "datasync.amazonaws.com"
  },
  "Action": "sts:AssumeRole"
}
```

***

## 📄 Policy (S3 access)

Permissões principais:

```json
"s3:GetBucketLocation",
"s3:ListBucket",
"s3:GetObject",
"s3:PutObject",
"s3:DeleteObject"
```

👉 Já incluída no seu roteiro    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20prod.sh)

***

## ▶️ Criar Role

```bash
aws iam create-role \
  --role-name BURoleForDataSyncService \
  --assume-role-policy-document file://trust.json
```

***

## ▶️ Anexar policy

```bash
aws iam put-role-policy \
  --role-name BURoleForDataSyncService \
  --policy-name PolicyDataSyncService \
  --policy-document file://policy.json
```

***

# 🪣 4. Configurar bucket destino

## 📄 Bucket policy

Permitir acesso da role origem:

```json
"Principal": {
  "AWS": "arn:aws:iam::225989352496:role/BURoleForDataSyncService"
}
```

👉 Dá acesso ao DataSync para escrita    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20prod.sh)

***

## ▶️ Aplicar policy

```bash
aws s3api put-bucket-policy \
  --bucket teste-aws-sync \
  --policy file://bucket_policy.json
```

***

# 🔒 5. Desabilitar ACL (recomendado)

```bash
aws s3api put-bucket-ownership-controls \
  --bucket teste-aws-sync \
  --ownership-controls file://ownership.json
```

👉 Evita conflitos de ownership    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20prod.sh)

***

# ⚙️ 6. Criar DataSync Locations

Seu script faz isso automaticamente:

```python
create_location_s3()
```

📌 Cria:

* source location
* destination location

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/datasync.py)

***

# 🏗️ 7. Criar Task DataSync

## 📌 No script:

```python
create_datasync_task()
```

Inclui:

* SourceLocationArn
* DestinationLocationArn
* LogGroup

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/datasync.py)

***

# 📊 8. CloudWatch Logs

O script cria automaticamente:

```python
create_log_group()
```

👉 Logs ficam em:

```
/aws/datasync/*
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/datasync.py)

***

# ▶️ 9. Executar sincronização

```python
start_datasync_task()
```

👉 Executa a transferência completa

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/datasync.py)

***

# 🔎 10. Monitorar execução

O script monitora automaticamente:

```python
describe_task_execution()
```

Status possíveis:

* `RUNNING`
* `SUCCESS`
* `ERROR`

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/datasync.py)

***

## 📊 Output esperado

```text
Status da execução da tarefa: SUCCESS
```

***

# 🚀 11. Execução completa

## ▶️ Comando final

```bash
python3 datasync.py \
  --source-profile nikedatauat \
  --source-bucket experian-reports-extraction-files-uat \
  --destination-bucket teste-aws-sync \
  --source-role-arn arn:aws:iam::225989352496:role/BURoleForDataSyncService \
  --subdirectory /ESPNEG_BB_PF/extraction/
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20prod.sh)

***

# ✅ 12. Validação

## 📌 Ver arquivos no destino

```bash
aws s3 ls s3://teste-aws-sync/
```

***

## 📌 Logs

```bash
aws logs tail /aws/datasync/*
```

***

## 📌 Status

```bash
aws datasync list-task-executions
```

***

# ⚠️ 13. Pontos críticos

## 🔐 IAM

* Role deve existir na origem
* Bucket policy deve permitir escrita

***

## 🪣 S3

* Sem ACL (preferível)
* Prefix correto

***

## 📛 Subdirectory

```text
/ESPNEG_BB_PF/extraction/
```

👉 Muito importante (evita copiar tudo)

***

## 🌐 Cross-account

* Conferir Account IDs
* Conferir ARN correto

***

# 🚀 14. Boas práticas

* ✅ Usar prefixo (subdirectory)
* ✅ Criar log group sempre
* ✅ Testar antes em dev
* ✅ Criar naming padrão

***

# 🔥 15. Script simplificado (resumo)

```bash
#!/bin/bash

echo "Iniciando DataSync..."

python3 datasync.py \
  --source-profile $1 \
  --source-bucket $2 \
  --destination-bucket $3 \
  --source-role-arn $4 \
  --subdirectory $5

echo "Concluído ✅"
```


# 🧠 16. Próximo nível (posso montar)

* 🔹 DataSync agendado (EventBridge)
* 🔹 replicação incremental automática
* 🔹 monitoramento + alertas
* 🔹 sync multi-bucket
* 🔹 integração com Glue/Athena


✅ Resumo direto:

Você já tem um **pipeline completo e automatizado**:

* Role → bucket policy → locations → task → execução → monitoramento

👉 Isso já é padrão **enterprise de data movement (DataHub / data lake ingestion)**

