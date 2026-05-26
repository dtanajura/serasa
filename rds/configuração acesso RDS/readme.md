Aqui vai um `README.md` para esse terceiro roteiro, focado em acesso a RDS via EKS/Kubernetes:

***

# 🧪 Roteiro de Acesso a RDS via EKS (Kubernetes)

Este repositório contém um roteiro com os passos necessários para:

* Listar e identificar bancos RDS na AWS
* Conectar em clusters EKS
* Criar um POD para testes
* Acessar um banco PostgreSQL dentro da VPC
* Validar conectividade via `psql` e Python

***

## 🎯 Objetivo

Permitir o acesso controlado a um banco RDS a partir de um container dentro de um cluster EKS, geralmente para:

* Testes de conectividade
* Diagnóstico de rede
* Validação de permissões
* Execução de queries

***

## 📋 Pré-requisitos

Antes de executar o roteiro:

* AWS CLI configurado
* `kubectl` instalado e configurado
* Permissão para:
  * EKS
  * RDS
* Acesso ao cluster Kubernetes
* Arquivo `pod-ubuntu.yaml` disponível

***

## ⚙️ Etapas do Processo

### 1. Navegar para o diretório de trabalho

```bash
cd "C:\\Users\\<usuario>\\OneDrive\\...\\configuração acesso RDS"
```

***

### 2. Definir Profile AWS

```powershell
$profile_aws = "corporateprod"
```

***

### 3. Listar recursos RDS

#### Listar clusters:

```bash
aws rds describe-db-clusters --profile $profile_aws --query "DBClusters[].DBClusterIdentifier"
```

#### Listar instâncias:

```bash
aws rds describe-db-instances --profile $profile_aws --query "DBInstances[].DBInstanceIdentifier"
```

#### Obter endpoint de uma instância específica:

```bash
aws rds describe-db-instances \
  --db-instance-identifier dev-hub-portal-qa \
  --profile $profile_aws \
  --query "DBInstances[].Endpoint.Address"
```

***

### 4. Conectar ao cluster EKS

#### Listar clusters:

```bash
aws eks list-clusters --profile $profile_aws
```

#### Atualizar kubeconfig:

```bash
aws eks update-kubeconfig --name nike-tech-dev --profile $profile_aws
```

***

### 5. Criar POD para testes

Criar um POD com Ubuntu:

```bash
kubectl create -f pod-ubuntu.yaml
```

***

### 6. Acessar o container

```bash
kubectl exec -it ubuntu-pod -- bash
```

***

### 7. Instalar cliente PostgreSQL

```bash
apt update
apt install -y postgresql-client
```

Verificar instalação:

```bash
psql --version
```

***

### 8. Conectar ao banco RDS

```bash
psql -h <endpoint> -p 5432 -U <usuario> -d <database>
```

Exemplo:

```bash
psql -h observabilidade-0.cwhrk1jkkma0.sa-east-1.rds.amazonaws.com \
  -p 5432 \
  -U pgadmin \
  -d custos_nike
```

> ⚠️ Será solicitada a senha do banco

***

### 9. Testar acesso via Python

Instalar Python:

```bash
apt install -y python3 python3-pip
```

Verificar:

```bash
python3 --version
pip3 --version
```

(Pode ser usado para testes com `psycopg2`, por exemplo)

***

## 🔐 Segurança e Acesso

Para acesso correto ao banco:

* Security Groups devem permitir conexão na porta 5432
* O POD deve estar na mesma VPC ou com rotas válidas
* Usuário e senha do banco devem ser válidos
* Pode ser necessário configurar:
  * IAM Role (IRSA)
  * Policies específicas

***

## 🌍 Cenário descrito

O roteiro cobre o caso:

> Acessar o banco `custos_nike` (RDS) a partir de um POD rodando no EKS da conta `corporateprod`.

***

## ⚠️ Observações Importantes

* Nunca exponha credenciais em arquivos ou scripts (como senha do banco)
* Use Secrets do Kubernetes para armazenar informações sensíveis
* O POD utilizado é apenas para testes — não recomendado para produção
* Ajuste nomes de cluster, banco e usuário conforme ambiente real

***

## 🔧 Próximos Passos / Melhorias

* Criar Deployment ao invés de POD simples
* Usar Kubernetes Secrets para credenciais
* Automatizar criação do POD
* Implementar script de conexão (bash/python)
* Configurar acesso via IAM Database Authentication

***

## 🧑‍💻 Uso recomendado

Esse roteiro é ideal para:

* ✅ SRE / DevOps troubleshooting
* ✅ Testes de acesso a banco
* ✅ Validação de networking em EKS
* ✅ Setup inicial de integrações com RDS

***

Se quiser, posso juntar os 3 README em um padrão único (tipo um repositório interno organizado com “playbooks” de operações).
