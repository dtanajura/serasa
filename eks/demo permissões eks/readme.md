Aqui está um `README.md` organizado para esse roteiro (IRSA / acesso IAM dentro do EKS):

***

# ☸️ Roteiro: Configuração de IAM Role para Pods no EKS (IRSA)

Este repositório contém um roteiro para configurar acesso de aplicações em Kubernetes (EKS) a recursos AWS utilizando **IAM Roles for Service Accounts (IRSA)**.

***

## 🎯 Objetivo

Permitir que um **Pod dentro do EKS** utilize permissões AWS de forma segura, sem necessidade de credenciais estáticas.

Isso é feito através de:

* Criação de IAM Role
* Criação de policy
* Associação dessa role a um ServiceAccount
* Uso automático da role dentro do Pod

***

## 📋 Cenário

* **Conta AWS**: `arcsandbox`
* **Cluster EKS**: `nike-tech-dev`
* **Namespace Kubernetes**: `teste`
* **Aplicação exemplo**: nginx (deployment)

***

## ⚙️ Pré-requisitos

* AWS CLI configurado
* `kubectl` instalado
* `saml2aws` configurado
* Arquivos:
  * `trust.json`
  * `policy.json`
  * `deploy.yaml`

***

# 🚀 Etapas do Processo

***

## 1. Autenticação na conta AWS

```bash
saml2aws.exe login -a eec-aws-br-nike-architecture-sandbox
```

Opcional (console):

```bash
saml2aws.exe console -a eec-aws-br-nike-architecture-sandbox
```

***

## 2. Configurar acesso ao cluster EKS

```bash
$profile_aws = "arcsandbox"
```

Listar clusters:

```bash
aws eks list-clusters --profile $profile_aws
```

Atualizar kubeconfig:

```bash
aws eks update-kubeconfig \
  --region sa-east-1 \
  --name nike-tech-dev \
  --profile $profile_aws
```

***

## 3. Validar OIDC Provider do cluster

```bash
aws eks describe-cluster \
  --name nike-tech-dev \
  --query "cluster.identity.oidc.issuer" \
  --output text \
  --profile $profile_aws
```

✅ Necessário para IRSA funcionar.

***

## 🔐 4. Criar IAM Role para a aplicação

### Criar role

```bash
aws iam create-role \
  --role-name BURoleForAppsEKS-teste \
  --assume-role-policy-document file://trust.json \
  --profile $profile_aws
```

***

### Criar policy

```bash
aws iam create-policy \
  --policy-name BUPolicyForAppsEks-teste \
  --policy-document file://policy.json \
  --profile $profile_aws \
  --query "Policy.Arn" \
  --output text
```

***

### Anexar policy à role

```bash
aws iam attach-role-policy \
  --role-name BURoleForAppsEKS-teste \
  --policy-arn <POLICY_ARN> \
  --profile $profile_aws
```

***

## ☸️ 5. Deploy da aplicação no Kubernetes

```bash
kubectl create -f deploy.yaml
```

Listar pods:

```bash
kubectl get pods -n teste
```

***

## 6. Acessar o Pod

```bash
kubectl exec -it <pod-name> -n teste -- bash
```

***

## 7. Testar acesso AWS dentro do Pod

Instalar AWS CLI:

```bash
apt-get update
apt-get upgrade -y
apt-get install awscli -y
```

Verificar:

```bash
aws --version
```

Testar identidade:

```bash
aws sts get-caller-identity
```

✅ Se IRSA estiver correto, a role será assumida automaticamente.

***

## 🔗 8. Associar IAM Role ao ServiceAccount

Listar ServiceAccounts:

```bash
kubectl get serviceaccount -n teste
```

Editar:

```bash
kubectl edit serviceaccount my-service-account -n teste
```

Adicionar annotation:

```yaml
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/BURoleForAppsEKS-teste
```

***

## 🔄 9. Reiniciar deployment

```bash
kubectl rollout restart deployment nginx-deployment -n teste
```

✅ Necessário para o Pod assumir a nova role

***

## 🧹 10. Cleanup (remoção dos recursos)

### Kubernetes:

```bash
kubectl delete -f deploy.yaml
```

***

### IAM:

```bash
aws iam detach-role-policy --role-name BURoleForAppsEKS-teste --policy-arn <POLICY_ARN>
aws iam delete-policy --policy-arn <POLICY_ARN>
aws iam delete-role --role-name BURoleForAppsEKS-teste
```

***

# ✅ Fluxo Resumido

1. Login na conta AWS
2. Conectar no EKS
3. Criar IAM Role + Policy
4. Deploy aplicação
5. Associar ServiceAccount à role
6. Reiniciar pods
7. Testar acesso AWS via STS

***

# ⚠️ Problemas comuns

### ❌ `AccessDenied` no STS

* Policy não permite ação
* Role não está anexada corretamente

***

### ❌ IRSA não funciona

* OIDC não configurado
* Annotation errada no ServiceAccount
* Deployment não foi reiniciado

***

### ❌ Credenciais não aparecem no pod

* ServiceAccount errado
* Pod não usa o ServiceAccount configurado

***

# 🔐 Boas práticas

* Usar uma role por aplicação
* Evitar credenciais hardcoded
* Restringir policies ao mínimo necessário
* Versionar `policy.json` e `trust.json`

***

# 📈 Melhorias futuras

* Automatizar via Terraform
* Criar Helm chart com IRSA embutido
* Adicionar validações automáticas
* Criar pipeline CI/CD para deploy

***

## 🧑‍💻 Uso recomendado

Ideal para:

* ✅ Aplicações rodando em EKS que acessam AWS
* ✅ Integrações com S3, SQS, DynamoDB etc.
* ✅ Ambientes seguros sem uso de secrets estáticos
* ✅ Times de plataforma e SRE

***
