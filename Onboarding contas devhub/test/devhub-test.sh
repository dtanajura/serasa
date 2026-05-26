## Roteiro onboarding conta devhub-test
### 1 - login
.\saml2aws.exe login -a eec-aws-br-eits-devhub-test

## Verificar elementos previamente instalados na conta
aws ce get-cost-and-usage --profile devhub-test --no-verify-ssl --granularity "MONTHLY" --time-period Start=2023-10-01,End=2023-10-31 --metrics "UsageQuantity" --group-by Type=DIMENSION,Key=SERVICE --output text
# Listar instâncias
aws ec2 describe-instances --profile devhub-test --no-verify-ssl --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name'].Value]" --output text
# Listar Buckets S3
aws s3 ls --profile devhub-test --no-verify-ssl
# Listar bancos RDS
aws rds describe-db-instances --profile devhub-test --no-verify-ssl --query "DBInstances[].[DBInstanceIdentifier]" --output text
# Listar cluster EKS
aws eks list-clusters --profile devhub-test --no-verify-ssl
# Listar chaves KMS
aws kms list-keys --profile devhub-test --no-verify-ssl

## Limpar instancias
aws ec2 terminate-instances --instance-ids i-06989fdf2d1415d2b --profile devhub-test --no-verify-ssl

## Limpar RDS
aws rds delete-db-instance --db-instance-identifier eitsenterprise-dev-devhubportal01 --skip-final-snapshot --profile devhub-test --no-verify-ssl
aws rds delete-db-instance --db-instance-identifier eitsenterprise-dev-devhubportalqa --skip-final-snapshot --profile devhub-test --no-verify-ssl

## Apagar cluster EKS
aws eks list-nodegroups --cluster-name devhub-eks-01-uat --profile devhub-test --no-verify-ssl
aws eks delete-nodegroup --cluster-name devhub-eks-01-uat --nodegroup-name node_group_on_demand_infra-20230516131926588400000014 --profile devhub-test --no-verify-ssl
aws eks delete-cluster --name devhub-eks-01-uat  --profile devhub-test --no-verify-ssl

### Apagar Filesystem EFS
# Listar EFS
aws efs describe-file-systems --profile devhub-test --no-verify-ssl
## Limpar FileSystem EFS
aws efs describe-mount-targets --file-system-id fs-024ee5ed7a2bc53e7  --profile devhub-test --no-verify-ssl
aws efs delete-mount-target --mount-target-id fsmt-02850137e38839738   --profile devhub-test --no-verify-ssl
aws efs delete-mount-target --mount-target-id fsmt-095815ce7315631bd   --profile devhub-test --no-verify-ssl
aws efs delete-mount-target --mount-target-id fsmt-0c63a68b18d100da0   --profile devhub-test --no-verify-ssl
aws efs delete-file-system --file-system-id fs-024ee5ed7a2bc53e7  --profile devhub-test --no-verify-ssl

## Passo 01 - onboarding - executar o CloudFormation
aws cloudformation deploy --template-file assumeRole.yaml --stack-name ServiceCatalog --profile devhub-test --no-verify-ssl
aws iam list-role-policies --role-name BURoleForDevSecOpsCockpitService --profile devhub-test --no-verify-ssl
aws iam delete-role-policy --role-name BURoleForDevSecOpsCockpitService --policy-name BUPolicyForUseDevSecOpsServiceCatalog --profile devhub-test --no-verify-ssl
aws iam delete-role --role-name BURoleForDevSecOpsCockpitService --profile devhub-test --no-verify-ssl
## Passo 02 - executar no Cockpit - aws-onboarding-new-account
# NEW_AWS_ACCOUNT_ID: 838498078144
# DOMAIN: .serasa.intranet
# AWS_REGION: sa-east1
# ENV: snd
# TRIBE: devhub
# VPC_ID: vpc-0caa86767b44fe141
### Listar as VPCs
aws ec2 describe-vpcs --profile devhub-test --no-verify-ssl --query "Vpcs[].{ID:VpcId}" --output text
# SUBNET A: subnet-0167345181547d50c
# SUBNET B: subnet-0738c743fcee77120
# SUBNET C: subnet-051534abd2d3405c0
# SUBNET D: 
aws ec2 describe-subnets --profile devhub-test --no-verify-ssl --query "Subnets[].[Tags[?Key==`Name`].Value,SubnetId]" --filters "Name=tag:Name,Values=aws*" --output text
aws ec2 describe-subnets --profile devhub-test --no-verify-ssl --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" --output text
# KMS_ID: Não é obrigatório
aws kms list-keys --profile devhub-test --no-verify-ssl

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
aws ec2 describe-subnets --profile devhub-test --no-verify-ssl --query "Subnets[].[CidrBlock]" --filters "Name=tag:Name,Values=aws*" --output text
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



aws ec2 describe-vpcs --profile devhub-test --no-verify-ssl --query "Vpcs[].[Tags[?Key==`Name`].Value[],CidrBlock]" --output text

10.96.214.13-10.96.214.15
SPOBR1PRX01
10.96.214.13
SPOBR1PRX02
10.96.214.14
SPOBR1PRX03
10.96.214.15
SPOBR1PRX04
10.96.214.25

Automação EKS-SERASA
RITM: RITM3205861
Account: 977554819825
Region: sa-east-1
Cluster Name: devhub-eks-01
Cluster Version: 1.27
Project Name: dev-hub-portal
env: dev
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
Resource name: devhub-eks-instance
Resource owner: devhub_team@br.experian.com
App Id: 20274
Cost Center: 1800.BR.134.607500
EFS enabled: true
Kubeconfig enabled: true
