Aqui está um `README.md` para esse quarto roteiro, focado em permissões de S3 + KMS cross-account:

***

# 🔐 Roteiro de Concessão de Acesso a Bucket S3 com KMS (Cross-Account)

Este repositório contém um roteiro para conceder acesso de leitura a um bucket S3 com criptografia KMS para uma role em outra conta AWS.

***

## 🎯 Objetivo

Permitir que uma role externa acesse dados armazenados em um bucket S3 criptografado com KMS, garantindo:

* ✅ Permissão no bucket (S3 Policy)
* ✅ Permissão na chave KMS (Key Policy)

***

## 📋 Cenário

* **Conta do bucket (destino)**: `eec-aws-br-eits-datahub-dev`
* **Bucket S3**: `eec-aws-br-do-positivo-table-dev-bucket`
* **Path específico**: `/hive/reloads/positivo.reload_ds_optinout`
* **Role que precisa de acesso**:  
  `arn:aws:iam::415071355886:role/BURoleForPositivoMercantil`
* **Ambiente**: DEV

***

## ⚙️ Etapas do Processo

### 1. Validar existência da role

```bash
aws iam get-role \
  --role-name BURoleForPositivoMercantil \
  --profile datahubdev
```

***

### 2. Navegar até diretório de policies

```bash
cd "C:\\Users\\<usuario>\\...\\configuração permissão buckets"
```

***

### 3. Validar bucket

Listar buckets e validar existência:

```bash
aws s3 ls --profile dodev | Select-String -Pattern "eec-aws-br-do-positivo-table-dev-bucket"
```

***

### 4. Verificar policy atual do bucket

```bash
aws s3api get-bucket-policy \
  --bucket eec-aws-br-do-positivo-table-dev-bucket \
  --profile dodev
```

***

### 5. Aplicar nova policy no bucket

Criar um arquivo (`policy_bucket.json`) contendo a permissão para a role externa.

Exemplo básico:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowReadSpecificPath",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::415071355886:role/BURoleForPositivoMercantil"
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::eec-aws-br-do-positivo-table-dev-bucket",
        "arn:aws:s3:::eec-aws-br-do-positivo-table-dev-bucket/hive/reloads/positivo.reload_ds_optinout/*"
      ]
    }
  ]
}
```

Aplicar:

```bash
aws s3api put-bucket-policy \
  --bucket eec-aws-br-do-positivo-table-dev-bucket \
  --policy file://policy_bucket.json \
  --profile dodev
```

***

## 🔑 Configuração de KMS

Como o bucket usa criptografia KMS, **não basta liberar acesso no S3** — também é necessário permitir acesso à chave KMS.

***

### 6. Obter configuração de criptografia do bucket

```bash
aws s3api get-bucket-encryption \
  --bucket eec-aws-br-do-positivo-table-dev-bucket \
  --profile dodev
```

Isso retorna o ARN da chave KMS, por exemplo:

```
arn:aws:kms:sa-east-1:916546429908:key/xxxxxxxx
```

***

### 7. Verificar policy atual da chave

```bash
aws kms get-key-policy \
  --key-id <KMS_KEY_ARN> \
  --policy-name default \
  --profile dodev
```

***

### 8. Atualizar policy da chave KMS

Criar o arquivo `kms_policy.json`, incluindo a role externa:

Exemplo (trecho relevante):

```json
{
  "Sid": "AllowUseOfKeyForExternalRole",
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::415071355886:role/BURoleForPositivoMercantil"
  },
  "Action": [
    "kms:Decrypt",
    "kms:DescribeKey"
  ],
  "Resource": "*"
}
```

Aplicar:

```bash
aws kms put-key-policy \
  --key-id <KMS_KEY_ARN> \
  --policy-name default \
  --policy file://kms_policy.json \
  --profile dodev
```

***

## ✅ Checklist Final

Para o acesso funcionar corretamente:

* ✅ Role existe na conta de origem
* ✅ Bucket policy permite acesso
* ✅ KMS policy permite decrypt
* ✅ Path correto foi liberado
* ✅ Região correta está sendo usada

***

## ⚠️ Problemas comuns

* ❌ Acesso negado mesmo com policy S3 → falta permissão no KMS
* ❌ Erro de decrypt → role não está na KMS policy
* ❌ Path incorreto → validar prefixo `/hive/...`
* ❌ Profile errado na CLI

***

## 🔧 Boas práticas

* Sempre restringir acesso ao menor escopo possível (path específico)
* Evitar permissões amplas (`*`)
* Versionar arquivos de policy
* Validar antes e depois com testes reais

***

## 📈 Possíveis melhorias

* Automatizar via Terraform ou CloudFormation
* Criar script que valide permissões automaticamente
* Implementar auditoria de acesso (CloudTrail + S3 Access Logs)

***

## 🧑‍💻 Uso recomendado

Esse roteiro é ideal para:

* ✅ Liberação de acesso cross-account em Data Lakes
* ✅ Times de dados (Data Engineering / Analytics)
* ✅ SRE / Cloud Operations
* ✅ Integrações entre contas AWS

***
