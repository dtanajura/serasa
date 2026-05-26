# 🔐 Roteiro – Criação de Secrets (AWS / Kubernetes)

## 🎯 Objetivo

Criar e gerenciar secrets de forma segura para:

* Aplicações (credenciais, tokens, APIs)
* Integrações (DB, Kafka, APIs externas)
* Infra (Helm, Airflow, Bastion, etc)

***

# 🧠 1. Tipos de Secrets

## ✅ AWS Secrets Manager

* Recomendado para produção
* Rotação automática
* Integração com Lambda

***

## ✅ AWS SSM Parameter Store

* Mais simples
* Menor custo
* Ideal para configs leves

***

## ✅ Kubernetes Secrets

* Consumidos por Pods
* Usados em Helm / Deploy

***

## ✅ Airflow Connections (MWAA)

* Armazenados como secrets
* Usados por DAGs

***

# 🔐 2. Criar Secret no AWS Secrets Manager

## ▶️ Criar secret simples

```bash
aws secretsmanager create-secret \
  --name datahub/db-credentials \
  --secret-string '{
    "username":"user",
    "password":"senha123"
  }' \
  --region sa-east-1 \
  --profile datahubdev
```

***

## 🔄 Atualizar secret

```bash
aws secretsmanager update-secret \
  --secret-id datahub/db-credentials \
  --secret-string '{
    "username":"user",
    "password":"nova_senha"
  }'
```

***

## 🔍 Recuperar secret

```bash
aws secretsmanager get-secret-value \
  --secret-id datahub/db-credentials
```

***

# ⚙️ 3. Criar Secret no SSM Parameter Store

## ▶️ Criar secret

```bash
aws ssm put-parameter \
  --name "/datahub/db/password" \
  --value "senha123" \
  --type SecureString \
  --overwrite \
  --profile datahubdev
```

***

## 🔍 Buscar

```bash
aws ssm get-parameter \
  --name "/datahub/db/password" \
  --with-decryption
```

***

# ☸️ 4. Criar Secret no Kubernetes

## ▶️ Secret genérico

```bash
kubectl create secret generic db-credentials \
  --from-literal=username=user \
  --from-literal=password=senha123 \
  -n default
```

***

## ▶️ A partir de arquivo

```bash
kubectl create secret generic app-secret \
  --from-file=config.json
```

***

## 🔍 Ver secret

```bash
kubectl get secret db-credentials -o yaml
```

***

## 🔓 Decodificar valor

```bash
kubectl get secret db-credentials \
  -o jsonpath="{.data.password}" | base64 -d
```

***

# 🚀 5. Uso em Pods

```yaml
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: password
```

***

# 🌀 6. Uso em Helm

## values.yaml

```yaml
env:
  DB_USER: user
  DB_PASS:
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: password
```

***

# 🌪️ 7. Secrets no MWAA (Airflow)

## ▶️ Criar connection via CLI

```bash
aws mwaa create-cli-token --name <ENV>
```

Depois:

```bash
connections add 'meu_conn' \
  --conn-type postgres \
  --conn-login user \
  --conn-password senha123 \
  --conn-host db.internal
```

***

# 🔎 8. Boas práticas

## ✅ Segurança

* ✅ Nunca versionar secrets (Git)
* ✅ Usar Secrets Manager em prod
* ✅ Criptografar (KMS)

***

## ✅ Governança

* ✅ Padronizar nomes:

```text
/datahub/<env>/<service>/<tipo>
```

***

## ✅ Rotação

* ✅ Rotacionar credenciais periodicamente
* ✅ Usar Lambda (Secrets Manager)

***

## ✅ Acesso

* ✅ IAM least privilege
* ✅ Não usar root

***

# ⚠️ Pontos de atenção

* Secrets no Kubernetes são base64 (não criptografados por padrão)
* Evitar expor:
  * logs
  * variáveis shell
* Rotação manual é risco

***

# 🔥 Script padrão (AWS Secrets)

```bash
#!/bin/bash

NAME="datahub/api-key"

echo "Criando secret..."

aws secretsmanager create-secret \
  --name $NAME \
  --secret-string '{"api_key":"123456"}'

echo "Validando..."

aws secretsmanager get-secret-value \
  --secret-id $NAME

echo "Concluído ✅"
```

***

# ✅ Checklist final

* ✅ Secret criado
* ✅ Acesso restrito (IAM)
* ✅ Criptografia ativa
* ✅ Testado na aplicação
* ✅ Não exposto em código

***

# 🧠 Próximo nível (posso montar pra você)

* 🔹 integração Secrets Manager + Kubernetes (External Secrets)
* 🔹 rotação automática de DB credentials
* 🔹 secrets via Terraform
* 🔹 CI/CD seguro (GitHub Actions + secrets)
* 🔹 policy AWS para bloquear secrets inseguros

