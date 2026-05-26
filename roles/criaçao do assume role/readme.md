# 🔐 Roteiro – Criação de Assume Role (IAM Role AWS)

## 🎯 Objetivo

Criar uma IAM Role com **Assume Role (OIDC/EKS)** para permitir que aplicações (ex: pods Kubernetes) acessem recursos AWS com segurança:

* ✅ Assumido via ServiceAccount (IRSA)
* ✅ Permissões controladas (inline policy)
* ✅ Sem uso de credenciais fixas

***

# 🧠 1. Arquitetura

Fluxo:

```text
Pod (Kubernetes)
   ↓
ServiceAccount
   ↓
OIDC Provider (EKS)
   ↓
IAM Role (AssumeRoleWithWebIdentity)
   ↓
Permissões AWS (S3, etc)
```

***

# 📄 2. Trust Policy (Assume Role)

Arquivo: `trust2.json`

## 📌 Exemplo (seu modelo)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::105794972139:oidc-provider/oidc.eks.sa-east-1.amazonaws.com/id/B9414B05E6ACE60A23B746C0BFAFC46F"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.sa-east-1.amazonaws.com/id/B9414B05E6ACE60A23B746C0BFAFC46F:sub": "system:serviceaccount:mesa-optin-prod:experian-mesa-positivo-optin-serviceaccount"
        }
      }
    }
  ]
}
```

👉 Esse trust permite:

* Apenas um ServiceAccount específico assumir a role    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/trust2.json)

***

# 📦 3. Policy de permissões (inline)

Arquivo: `inline_policy.json`

## 📌 Exemplo

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::mesaoptin-bucket-prod",
        "arn:aws:s3:::mesaoptin-bucket-prod/*"
      ]
    }
  ]
}
```

👉 Permite acesso completo ao bucket    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/inline_policy.json)

***

# 🏗️ 4. Criar a IAM Role

```bash
aws iam create-role \
  --role-name mesa-optin-role \
  --assume-role-policy-document file://trust2.json
```

***

# 🔐 5. Anexar policy

## ▶️ Inline policy

```bash
aws iam put-role-policy \
  --role-name mesa-optin-role \
  --policy-name mesa-optin-policy \
  --policy-document file://inline_policy.json
```

***

# 🔗 6. Vincular ao ServiceAccount (Kubernetes)

## ▶️ Anotação

```bash
kubectl annotate serviceaccount \
  experian-mesa-positivo-optin-serviceaccount \
  -n mesa-optin-prod \
  eks.amazonaws.com/role-arn=arn:aws:iam::<ACCOUNT_ID>:role/mesa-optin-role
```

***

# ⚙️ 7. Validar configuração

## 📌 Ver role

```bash
aws iam get-role --role-name mesa-optin-role
```

***

## 📌 Ver policy

```bash
aws iam list-role-policies \
  --role-name mesa-optin-role
```

***

## 📌 Testar dentro do pod

```bash
aws s3 ls s3://mesaoptin-bucket-prod
```

***

# ✅ 8. Checklist final

* ✅ Role criada
* ✅ Trust configurado (OIDC)
* ✅ Policy aplicada
* ✅ ServiceAccount anotado
* ✅ Teste no pod funcionando

***

# ⚠️ Pontos de atenção

## 🔒 Segurança

* Limitar ServiceAccount:

```text
system:serviceaccount:<namespace>:<serviceaccount>
```

* Não usar wildcard!

***

## 🔐 Permissões

* Evitar:

```text
"Resource": "*"
```

***

## 🌐 OIDC

* Cluster deve ter OIDC configurado:

```bash
aws eks describe-cluster \
  --name <CLUSTER> \
  --query "cluster.identity.oidc.issuer"
```

***

# 🚀 Boas práticas

* ✅ Um role por aplicação
* ✅ Um serviceaccount por app
* ✅ Policy mínima (least privilege)
* ✅ Versionar JSONs (Git)
* ✅ Padronizar nomes

***

# 🔥 Script completo (automatizado)

```bash
#!/bin/bash

ROLE_NAME="mesa-optin-role"

echo "Criando role..."

aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://trust2.json

echo "Anexando policy..."

aws iam put-role-policy \
  --role-name $ROLE_NAME \
  --policy-name ${ROLE_NAME}-policy \
  --policy-document file://inline_policy.json

echo "Concluído ✅"
```
