Aqui está um único `README.md` unificado para os dois arquivos (`roteiro.sh` + `policies.sh`), já organizando o fluxo completo do processo:

***

# 🔐 Roteiro Completo: Acesso a S3 com KMS + Configuração de Role (Cross-Account)

Este repositório contém um conjunto de scripts (`roteiro.sh` e `policies.sh`) que juntos realizam:

* Configuração de permissões em bucket S3
* Ajustes de policy em chave KMS
* Configuração de uma IAM Role com políticas necessárias
* Liberação de acesso cross-account a dados

***

## 🎯 Objetivo

Garantir que uma **IAM Role em outra conta AWS** consiga:

* Ler dados de um bucket S3 específico
* Acessar objetos criptografados com KMS
* Possuir todas as policies necessárias (custom e AWS managed)

***

## 📋 Cenário

* **Conta destino (bucket/KMS)**: `datahub-dev`
* **Bucket S3**: `eec-aws-br-do-positivo-table-dev-bucket`
* **Path liberado**:  
  `/hive/reloads/positivo.reload_ds_optinout`
* **Role a ser configurada**:  
  `BURoleForPositivoMercantil`
* **Conta de origem da role**: `415071355886`
* **Região**: `sa-east-1`

***

# ⚙️ Parte 1 — Liberação de acesso no S3 e KMS (`roteiro.sh`)

## 1. Validar a role

```bash
aws iam get-role \
  --role-name BURoleForPositivoMercantil \
  --profile datahubdev
```

***

## 2. Verificar e atualizar policy do bucket S3

### Ver policy atual:

```bash
aws s3api get-bucket-policy \
  --bucket eec-aws-br-do-positivo-table-dev-bucket \
  --profile dodev
```

### Aplicar nova policy:

```bash
aws s3api put-bucket-policy \
  --bucket eec-aws-br-do-positivo-table-dev-bucket \
  --policy file://policy_bucket.json \
  --profile dodev
```

👉 A policy deve incluir a role externa com permissão de leitura.

***

## 🔑 3. Configurar acesso à chave KMS

### Obter ARN da chave:

```bash
aws s3api get-bucket-encryption \
  --bucket eec-aws-br-do-positivo-table-dev-bucket \
  --profile dodev
```

***

### Ver policy atual da KMS:

```bash
aws kms get-key-policy \
  --key-id <KMS_KEY_ARN> \
  --policy-name default \
  --profile dodev
```

***

### Atualizar policy da KMS:

```bash
aws kms put-key-policy \
  --key-id <KMS_KEY_ARN> \
  --policy-name default \
  --policy file://kms_policy.json \
  --profile dodev
```

👉 É obrigatório incluir a role externa com permissão de:

* `kms:Decrypt`
* `kms:DescribeKey`

***

# ⚙️ Parte 2 — Configuração da Role e Policies (`policies.sh`)

Este script automatiza a configuração da role na conta de destino (stage).

***

## 📌 O que o script faz

1. Define variáveis principais:
   * Profile AWS
   * Região
   * Nome da role

2. Define duas listas de policies:
   * ✅ Customer Managed Policies (precisam existir na conta)
   * ✅ AWS Managed Policies (já existem globalmente)

3. Valida se as policies customizadas existem

4. Anexa todas as policies à role

5. Faz validação final

***

## 🧰 Variáveis principais

```bash
PROFILE="datahubstage"
REGION="sa-east-1"
ROLE_NAME="BURoleForPositivoMercantil"
```

***

## 📦 Customer Managed Policies

Essas policies precisam existir previamente na conta:

```bash
eec-aws-baseline-emr-encryption-policy
eec-aws-baseline-emr-role-policy
eec-aws-baseline-emr-ec2-role-policy
```

Caso não existam, o script **interrompe a execução automaticamente**.

***

## ☁️ AWS Managed Policies

Exemplo de policies anexadas:

```bash
AmazonS3ReadOnlyAccess
AmazonSQSFullAccess
AWSLambdaVPCAccessExecutionRole
AmazonEC2RoleforSSM
```

***

## ▶️ Como executar

```bash
bash policies.sh
```

***

## ✅ Verificação final

O script executa:

```bash
aws iam list-attached-role-policies \
  --role-name BURoleForPositivoMercantil
```

***

# ✅ Fluxo Completo (Resumo)

Ordem recomendada de execução:

1. ✅ Configurar acesso no S3 (bucket policy)
2. ✅ Configurar acesso no KMS (key policy)
3. ✅ Garantir que a role existe
4. ✅ Executar `policies.sh` para anexar policies
5. ✅ Validar acesso real ao bucket

***

# ⚠️ Problemas Comuns

### ❌ AccessDenied ao acessar S3

* Bucket policy não inclui a role
* Prefixo/path incorreto

***

### ❌ Erro de KMS (AccessDeniedException)

* Role não está na policy da KMS
* Falta permissão `kms:Decrypt`

***

### ❌ Policy não encontrada (script falha)

* Customer managed policy não existe na conta stage

***

# 🔐 Boas práticas

* Restrinja acesso ao menor escopo possível (path específico no S3)
* Nunca use `"Resource": "*"` sem necessidade
* Versione suas policies (JSON em repositório)
* Sempre valide antes e depois com testes

***

# 📈 Melhorias futuras

* Automatizar via Terraform
* Criar validação automatizada (healthcheck)
* Pipeline CI/CD para políticas IAM
* Auditoria com CloudTrail

***

# 🧑‍💻 Uso recomendado

Esse roteiro é ideal para:

* ✅ Data Lake / Analytics
* ✅ Integrações cross-account
* ✅ Times de plataforma / SRE
* ✅ Governança e segurança cloud

***
