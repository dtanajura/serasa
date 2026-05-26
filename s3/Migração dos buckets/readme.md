# 📦 Roteiro – Migração de Bucket S3 (Cross Account)

## 🎯 Objetivo

Migrar dados de um bucket S3 entre contas AWS garantindo:

* Integridade dos dados
* Controle de versionamento
* Segurança (IAM + KMS)
* Validação pós-migração

***

# 🧭 1. Cenário

* **Conta origem (legada)**
* **Conta destino (nova)**
* Migração via:
  * S3 Inventory
  * Batch Operations

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20migrac%CC%A7a%CC%83o%20bucket.sh)

***

# 🔍 2. Levantamento inicial

## 📌 Listar buckets origem

```bash
aws s3 ls \
  --profile digital-legada \
  --region sa-east-1
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20migrac%CC%A7a%CC%83o%20bucket.sh)

***

## 📌 Criar bucket para inventory

```bash
aws s3 mb s3://inventory-results-231124 \
  --profile digital-legada \
  --region sa-east-1
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20migrac%CC%A7a%CC%83o%20bucket.sh)

***

# 📊 3. Configurar S3 Inventory

## 📄 Arquivo `inventory-configuration.json`

```json
{
  "Destination": {
    "S3BucketDestination": {
      "AccountId": "ACCOUNT_ID",
      "Bucket": "arn:aws:s3:::inventory-results-231124",
      "Format": "CSV"
    }
  },
  "IsEnabled": true,
  "Id": "inventory-bucket",
  "IncludedObjectVersions": "Current",
  "Schedule": {
    "Frequency": "Weekly"
  }
}
```

***

## ▶️ Aplicar inventory

```bash
aws s3api put-bucket-inventory-configuration \
  --bucket <BUCKET_ORIGEM> \
  --id "inventory-bucket" \
  --inventory-configuration file://inventory-configuration.json \
  --profile digital-legada
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20migrac%CC%A7a%CC%83o%20bucket.sh)

***

# 🏗️ 4. Criar bucket de destino

````bash
aws s3api create-bucket \
  --bucket <BUCKET_DESTINO> \
  --region us-east-1 \
  --profile digital-paas-stage
```  

---

## 🔁 Habilitar versionamento

```bash
aws s3api put-bucket-versioning \
  --bucket <BUCKET_DESTINO> \
  --versioning-configuration Status=Enabled \
  --profile digital-paas-stage
````

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20migrac%CC%A7a%CC%83o%20bucket.sh)

***

# 🔐 5. Configurar permissões (Cross Account)

## 📄 Bucket policy destino

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<ACCOUNT_ORIGEM>:role/ROLE"
      },
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Resource": "arn:aws:s3:::<BUCKET_DESTINO>/*"
    }
  ]
}
```

***

## ▶️ Aplicar policy

```bash
aws s3api put-bucket-policy \
  --bucket <BUCKET_DESTINO> \
  --policy file://bucket-policy.json \
  --profile digital-paas-stage
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20migrac%CC%A7a%CC%83o%20bucket.sh)

***

# 🔑 6. (Opcional) Configurar KMS

## Criar chave

```bash
aws kms create-key \
  --description "Key for S3 migration"
```

## Criar alias

```bash
aws kms create-alias \
  --alias-name alias/s3-migration-key \
  --target-key-id <KEY_ID>
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20migrac%CC%A7a%CC%83o%20bucket.sh)

***

# 📑 7. Gerar manifesto (Inventory)

```bash
aws s3api get-object \
  --bucket inventory-results-231124 \
  --key <PATH_MANIFEST> \
  --profile digital-legada
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20migrac%CC%A7a%CC%83o%20bucket.sh)

***

# 🚀 8. Executar migração (Batch Operations)

```bash
aws s3control create-job \
  --account-id <ACCOUNT_ID> \
  --operation '{
    "S3PutObjectCopy": {
      "TargetResource": "arn:aws:s3:::<BUCKET_DESTINO>"
    }
  }' \
  --manifest '{
    "Spec": {
      "Format": "S3InventoryReport_CSV_20161130"
    },
    "Location": {
      "ObjectArn": "s3://inventory-results/.../manifest.json",
      "ETag": "<ETAG>"
    }
  }' \
  --report '{
    "Bucket": "arn:aws:s3:::logs-migracao-s3",
    "Prefix": "reports",
    "Format": "Report_CSV_20180820",
    "Enabled": true
  }' \
  --role-arn arn:aws:iam::<ACCOUNT>:role/<ROLE_BATCH> \
  --priority 42 \
  --profile contanova
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20migrac%CC%A7a%CC%83o%20bucket.sh)

***

# 🔍 9. Validação pós-migração

## 📌 Listar objetos destino

```bash
aws s3api list-objects \
  --bucket <BUCKET_DESTINO> \
  --prefix <FOLDER> \
  --output table
```

***

## 📌 Listar objetos origem

```bash
aws s3api list-objects \
  --bucket <BUCKET_ORIGEM> \
  --prefix <FOLDER> \
  --output table
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20migrac%CC%A7a%CC%83o%20bucket.sh)

***

## 📊 Comparação

* Exportar saída → arquivo `.txt`
* Importar no Excel
* Validar:
  * ✅ Quantidade
  * ✅ Tamanho
  * ✅ Estrutura

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20migrac%CC%A7a%CC%83o%20bucket.sh)

***

# 🔄 10. Ajuste final (cutover)

## Renomear pasta no destino

```bash
aws s3 mv \
  s3://destino/crypto-files-bkp \
  s3://destino/crypto-files \
  --recursive
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/roteiro%20migrac%CC%A7a%CC%83o%20bucket.sh)

***

## Limpar resíduos

```bash
aws s3 rm s3://destino/crypto-files-bkp --recursive
```

***

# 🚫 11. Desativar origem

* Parar replicação
* Remover acesso
* Opcional: apagar dados

***

# ✅ 12. Checklist final

* ✅ Inventory gerado
* ✅ Bucket destino criado
* ✅ Versionamento ativo
* ✅ Policy aplicada
* ✅ KMS configurado (se necessário)
* ✅ Job executado
* ✅ Dados validados
* ✅ Cutover realizado
* ✅ Origem desativada

***

# 🚀 Boas práticas

* ✅ Sempre usar S3 Inventory (escala grande)
* ✅ Não migrar direto com `cp` (evita erro)
* ✅ Validar com comparação estruturada
* ✅ Usar Batch Operations (performance + controle)
* ✅ Ter rollback (manter origem intacta até validar)

***

# 🔥 Evoluções que posso te montar

* 🔹 script automatizado end-to-end
* 🔹 migração incremental (delta sync)
* 🔹 validação automática (checksum)
* 🔹 dashboard de progresso
* 🔹 versão Terraform
