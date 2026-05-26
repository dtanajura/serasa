# Configuração do EMR Studio

Este guia descreve os passos necessários para configurar um EMR Studio na AWS.

## Pré-requisitos

- AWS CLI configurado com o profile apropriado.
- Permissões necessárias para criar roles, políticas, grupos de segurança e recursos EMR.

## Passos

### 1. Navegar para o Diretório de Trabalho

```bash
cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\emr studio"
$profile_aws = "datahubdev"
```

### 2. Criar um EMR Studio

#### 2.1 Anexar Políticas ao Role

Crie um role e anexe as políticas necessárias:

```bash
aws iam create-role --role-name BURoleForEMRStudio --assume-role-policy-document file://trust.json --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForEMRStudio --policy-arn arn:aws:iam::aws:policy/AmazonEMRFullAccessPolicy_v2 --profile $profile_aws
```

#### 2.2 Configurar VPC e Subnets

Obtenha o ID da VPC e os IDs das subnets:

```bash
$VpcID=$(aws ec2 describe-vpcs --profile $profile_aws --query "Vpcs[].VpcId" --output text)
$SubnetIDs=$(aws ec2 describe-subnets --profile $profile_aws --output text --query "Subnets[].SubnetId" --filters "Name=tag:Network,Values=Private")
```

#### 2.3 Criar e Configurar o Grupo de Segurança

Crie um grupo de segurança e configure as regras de entrada:

```bash
$SgId=$(aws ec2 create-security-group --group-name emr-studio-security-group --description "Security group for EMR Studio" --tag-specifications file://tags.json --vpc-id $VpcID --output text --profile $profile_aws)

aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 443 --cidr 10.0.0.0/16 --profile $profile_aws
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 18888 --cidr 10.0.0.0/16 --profile $profile_aws
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 8088 --cidr 10.0.0.0/16 --profile $profile_aws
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 8042 --cidr 10.0.0.0/16 --profile $profile_aws
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 19888 --cidr 10.0.0.0/16 --profile $profile_aws
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 8888 --cidr 10.0.0.0/16 --profile $profile_aws

aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 443 --cidr 100.65.0.0/16 --profile $profile_aws
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 18888 --cidr 100.65.0.0/16 --profile $profile_aws
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 8088 --cidr 100.65.0.0/16 --profile $profile_aws
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 8042 --cidr 100.65.0.0/16 --profile $profile_aws
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 19888 --cidr 100.65.0.0/16 --profile $profile_aws
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 8888 --cidr 100.65.0.0/16 --profile $profile_aws
```

Obtenha o ID do grupo de segurança:

```bash
$SgId=$(aws ec2 describe-security-groups --filters Name=group-name,Values=emr-studio-security-group --profile $profile_aws --query 'SecurityGroups[*].GroupId' --output text)
```

#### 2.4 Criar o EMR Studio

Crie um bucket S3 para o EMR Studio (se necessário) e crie o EMR Studio:

```bash
aws emr create-studio --name "DataHubDev" --auth-mode IAM --vpc-id $VpcID --subnet-ids $SubnetIDs --service-role BURoleForContatos --workspace-security-group $SgId --engine-security-group $SgId --profile $profile_aws --default-s3-location s3://datahub-dev-emr-studio
```

Anote o `StudioId` e a `Url` retornados.

### 3. Criar a Aplicação EMR Serverless

Crie uma aplicação EMR Serverless:

```bash
aws emr-serverless create-application --name "DataHubDevServerlessApp" --release-label emr-6.6.0 --type Spark --profile $profile_aws
```

Anote o `applicationId` e o `arn` retornados.

### 4. Acessar o EMR Studio

#### 4.1 Obter URL do Studio

Use o comando abaixo para obter a URL de acesso ao EMR Studio:

```bash
aws emr describe-studio --studio-id <studio-id> --profile $profile_aws
```

#### 4.2 Acessar o Studio

Navegue até a URL fornecida para acessar o EMR Studio e começar a usar.

### 5. Criar Workspaces

Crie workspaces dentro do EMR Studio:

```bash
aws emr create-workspace --name "DataHubDevWorkspace" --studio-id <studio-id> --auth-mode SSO --user-role BURoleForContatos --profile $profile_aws
```

## Contato

Para mais informações, entre em contato com davi.tanajura@br.experian.com
