## Roteiro onboarding conta devhub-sandbox
### 1 - login
.\saml2aws.exe login -a eec-aws-br-eits-devhub-sandbox

## Verificar elementos previamente instalados na conta
aws ce get-cost-and-usage --profile devhub-sandbox --no-verify-ssl --granularity "MONTHLY" --time-period Start=2023-10-01,End=2023-10-31 --metrics "UsageQuantity" --group-by Type=DIMENSION,Key=SERVICE --output text
# Listar instâncias
aws ec2 describe-instances --profile devhub-sandbox --no-verify-ssl --query "FileSystems[].[FileSystemId]" --output text
# Listar Buckets S3
aws s3 ls --profile devhub-sandbox --no-verify-ssl
# Listar bancos RDS
aws rds describe-db-instances --profile devhub-sandbox --no-verify-ssl
# Listar cluster EKS
aws eks list-clusters --profile devhub-sandbox --no-verify-ssl
# Listar chaves KMS
aws kms list-keys --profile devhub-sandbox --no-verify-ssl
# Listar EFS
aws efs describe-file-systems --profile devhub-sandbox --no-verify-ssl  --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name'].Value]" --output text
## Limpar instancias
aws ec2 terminate-instances --instance-ids i-0d277f3eab4c9a965 --profile devhub-sandbox --no-verify-ssl
## Limpar FileSystem EFS
aws efs describe-mount-targets --file-system-id fs-036ca688e2966d970  --profile devhub-sandbox --no-verify-ssl
aws efs delete-mount-target --mount-target-id fsmt-05655c005f4d7d100   --profile devhub-sandbox --no-verify-ssl
aws efs delete-mount-target --mount-target-id fsmt-0b71555eb9b06ac7e   --profile devhub-sandbox --no-verify-ssl
aws efs delete-mount-target --mount-target-id fsmt-0d31b17f15f4ecb67   --profile devhub-sandbox --no-verify-ssl

aws efs delete-file-system --file-system-id fs-036ca688e2966d970  --profile devhub-sandbox --no-verify-ssl

aws efs describe-mount-targets --file-system-id fs-0c7ea4e0a050663ba  --profile devhub-sandbox --no-verify-ssl
aws efs delete-mount-target --mount-target-id fsmt-007205984a9f6cb4b   --profile devhub-sandbox --no-verify-ssl
aws efs delete-mount-target --mount-target-id fsmt-058f13e42801172be   --profile devhub-sandbox --no-verify-ssl
aws efs delete-mount-target --mount-target-id fsmt-0771cfee8f2b3d9a5   --profile devhub-sandbox --no-verify-ssl

aws efs delete-file-system --file-system-id fs-0c7ea4e0a050663ba --profile devhub-sandbox --no-verify-ssl

aws efs describe-mount-targets --file-system-id fs-0f6b784c9de860c00  --profile devhub-sandbox --no-verify-ssl
aws efs delete-mount-target --mount-target-id fsmt-03c79ec41c5c118d4   --profile devhub-sandbox --no-verify-ssl
aws efs delete-mount-target --mount-target-id fsmt-0bfc3fefdacb24e12   --profile devhub-sandbox --no-verify-ssl
aws efs delete-mount-target --mount-target-id fsmt-0fb8b6b2007cd21ee   --profile devhub-sandbox --no-verify-ssl

aws efs delete-file-system --file-system-id fs-0f6b784c9de860c00 --profile devhub-sandbox --no-verify-ssl

## Passo 01 - onboarding - executar o CloudFormation
aws cloudformation deploy --template-file assumeRole.yaml --stack-name ServiceCatalog --profile devhub-sandbox --no-verify-ssl

############################## 
#####  Passo 02 - executar no Cockpit - aws-onboarding-new-account
##############################
# NEW_AWS_ACCOUNT_ID: 071087690196
# DOMAIN: .serasa.intranet
# AWS_REGION: sa-east1
# ENV: snd
# TRIBE: devhub
# VPC_ID: vpc-0f405711cd62b7ac8 
### Listar as VPCs
aws ec2 describe-vpcs --profile devhub-sandbox --no-verify-ssl --query "Vpcs[].{name:Tags[?Key==`Name`].Value[],ID:VpcId}" --output text
# SUBNET A: subnet-01ae076c3421d58a9
# SUBNET B: subnet-0a3119550a3c9da5d
# SUBNET C: subnet-020277a560d32ece6
# SUBNET D: 
aws ec2 describe-subnets --profile devhub-sandbox --no-verify-ssl --query "Subnets[].[Tags[?Key==`Name`].Value,SubnetId]" --filters "Name=tag:Name,Values=aws*" --output text
# KMS_ID: Não é obrigatório
aws kms list-keys --profile devhub-sandbox --no-verify-ssl

## Passo 03 - Proxy request: Service Catalog=>Networking=>GNS=>Internet Egress=>Request Server Proxy 
### Abrir Chamado: https://experian.service-now.com/nav_to.do?uri=%2Fcom.glideapp.servicecatalog_cat_item_view.do%3Fv%3D1%26sysparm_id%3Dc9f500d0db086f00af053b2ffe9619a3%26sysparm_link_parent%3Dd5c4e613db8383007bd1317ffe96191e%26sysparm_catalog%3De0d08b13c3330100c8b837659bba8fb4%26sysparm_catalog_view%3Dcatalog_default%26sysparm_view%3Dtext_search
### Informações:
# App Name: dev-hub-portal
# App ID: 20274
# What is the Project/Service name? Nike
# IP(s) for requested URL(s) static or dynamic? Dynamic or source server is already configured to use the proxies. This is a request for additional access.
# What tier is this system? TIER 1
# What is the data classification of the server? Experian Confidential
# Change Type: Management server access to update servers/patching/signatures
# Business Justification: Follow the RITM above as example, changing the SOURCE with your AWS subnets
aws ec2 describe-subnets --profile devhub-sandbox --no-verify-ssl --query "Subnets[].[Tags[?Key==`Name`].Value,CidrBlock]" --filters "Name=tag:Name,Values=aws*" --output text
### Allow access to update/instal package to RHEL servers 
### Source:
### 10.120.134.64/27 
### 10.120.134.0/27 
### 10.120.134.32/27

### Destination Category:
### Software/Hardware
### Technical/Business Forums
### Business

### Detailed destinations:
### URL	Status	Categorization	Reputation	Obs
### http://repo.zabbix.com/za ...	Categorized URL	- Software/Hardware	Minimal Risk	Zabbix
### https://www.zabbix.com/do ...	Categorized URL	- Software/Hardware	Minimal Risk	Zabbix
### https://repo.mongodb.org/ ...	Categorized URL	- Technical/Business Forums	Minimal Risk	MongoDB
### https://www.mongodb.org        Categorized URL	- Technical/Business Forums	Minimal Risk	MongoDB
### https://packagecloud.io             Categorized URL	- Business	Minimal Risk	RabbitMQ
### https://github.com/rabbit ...    Categorized URL	- Technical/Business Forums	Minimal Risk	RabbitMQ
### https://dl.bintray.com/               Categorized URL	- Software/Hardware	Minimal Risk	RabbitMQ
### https://www.rabbitmq.com/   Categorized URL	"- Business" - Software/Hardware	Minimal Risk	RabbitMQ
### http://bitbucket.org/                   Categorized URL	- Technical/Business Forums	Minimal Risk	Claranet repo


### All these categaory is Minimal Risk


### Region: LATAM, APAC, UK&I/EMEA OR US
### Location/Business Unit: Choose your location
### Environment: Prod or Dev
### Can you telnet to the IP's listed on port 9595 from the server requiring access? None

#### Passo 04 - Open Firewall Request
### Informações:
# App Name: dev-hub-portal
# App ID: 20274



aws ec2 describe-vpcs --profile devhub-sandbox --no-verify-ssl --query "Vpcs[].[Tags[?Key==`Name`].Value[],CidrBlock]" --output text


###################
### Pre-reqs EKS
###################

## 	AWS Secondary IP Address - If your account does not have a secondary IP range, please submit a request to the Cloud Team to add a secondary Subnet/IP Range (100.64.0.0/16) to your VPC with 3 AZs.
aws ec2 describe-vpcs --no-verify-ssl --query "Vpcs[].CidrBlockAssociationSet[*]" --profile devhub-sandbox

##  Validate if your VPC is tagged with "AWS_Solutions = LandingZoneStackSet", your Experian IP range subnets with "Network = Private" and the Pod IP range (100.64.0.0/16) subnets with "Network = Pod".

aws ec2 describe-subnets --no-verify-ssl --query "Subnets[].[CidrBlock,Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Name,Values=aws*" --output text --profile devhub-sandbox

aws ec2 describe-subnets --no-verify-ssl --query "Subnets[].[CidrBlock,Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Name,Values=pod*" --output text --profile devhub-sandbox

### Criação dos Endpoints
# Criar o SG para os endpoints
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-085f31990074f17ab --profile devhub-sandbox --no-verify-ssl

# Adicionar regras para o SG
aws ec2 authorize-security-group-ingress --group-id sg-00232e594d9d496a1 --protocol tcp --port 80 --cidr 10.0.0.0/8 --profile devhub-sandbox --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-00232e594d9d496a1 --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile devhub-sandbox --no-verify-ssl

# Criar VPC Endpoints
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-085f31990074f17ab --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids "sg-00232e594d9d496a1" --subnet-ids "subnet-09b31519466ea770c" "subnet-0cd04680da6d95113" "subnet-04756c2417c30202e" --profile devhub-sandbox --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-085f31990074f17ab --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-00232e594d9d496a1" --subnet-ids "subnet-09b31519466ea770c" "subnet-0cd04680da6d95113" "subnet-04756c2417c30202e" --profile devhub-sandbox --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-085f31990074f17ab --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids "sg-00232e594d9d496a1" --subnet-ids "subnet-09b31519466ea770c" "subnet-0cd04680da6d95113" "subnet-04756c2417c30202e" --profile devhub-sandbox --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-085f31990074f17ab --service-name com.amazonaws.sa-east-1.logs --security-group-ids "sg-00232e594d9d496a1" --subnet-ids "subnet-09b31519466ea770c" "subnet-0cd04680da6d95113" "subnet-04756c2417c30202e" --profile devhub-sandbox --no-verify-ssl

# Criar Key
aws kms create-key --description "Chave para onboarding da conta" --profile devhub-sandbox --no-verify-ssl
# Criar Policy
aws iam create-policy --policy-name BUPolicyForDevSecOpsPiaaS --policy-document file://BUPolicyForDevSecOpsPiaaS.json --profile devhub-sandbox --no-verify-ssl

# Verificar o onboarding das contas

Automação EKS-SERASA
RITM: RITM3191387
Account: 977554819825
Region: sa-east-1
Cluster Name: devhub-eks-01
Cluster Version: 1.27
Project Name: dev-hub-portal
env: sandbox
ARN do certificado: arn:aws:acm:sa-east-1:977554819825:certificate/33ba79fa-7e0d-488e-9239-9e2175736a00
domain name: dev-devhub.br.experian.eeca
TF State Name: dev-devhub-tfstate
node infra max size: 2
node small max size: 3
node medium max size: 1
node large max size: 1
node spot max size: 1
node infra instance type: c6i.2xlarge
node small instance type: t3.large
node medium instance type: t3.xlarge
node large instance type: t3.2xlarge
node spot instance type: t3.xlarge
Subnet Id: aws ec2 describe-subnets --no-verify-ssl --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" --output text --profile devhub-dev
Resource Business Unit: EITS
Resource name: devdevhub-eks-instance
Resource owner: devhub_team@br.experian.com
App Id: 20274
Cost Center: 1800.BR.134.607500
EFS enabled: true
Kubeconfig enabled: true



