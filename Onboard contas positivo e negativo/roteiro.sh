cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\Onboard contas positivo e negativo"
# Segui roteiro: https://pages.experian.local/pages/viewpage.action?pageId=1081626313

# Rodar a automação para criar a Role do Service Catalog
aws cloudformation deploy --stack-name ServiceCatalog --capabilities CAPABILITY_NAMED_IAM --template-file AssumeRole.yaml --profile negativodev
# deu um erro: 'NoneType' object has no attribute 'get'

# Resolvi forçar o parâmetro
aws cloudformation deploy --stack-name ServiceCatalog --capabilities CAPABILITY_NAMED_IAM --template-file AssumeRole.yaml --parameter-overrides WorkerJoaquinAccount=707064604759 --profile negativodev
# Deu certo dessa vez:
# Waiting for changeset to be created..
# Waiting for stack create/update to complete
# Successfully created/updated stack - ServiceCatalog

# Executar mais uma vez para a conta positivodev
aws cloudformation deploy --stack-name ServiceCatalog --capabilities CAPABILITY_NAMED_IAM --template-file AssumeRole.yaml --parameter-overrides WorkerJoaquinAccount=707064604759 --profile positivodev
# Deu certo também:
# Waiting for changeset to be created..
# Waiting for stack create/update to complete
# Successfully created/updated stack - ServiceCatalog

# Go to: https://experian.okta.com/app/UserHome --> and search for Cockpit DevSecOps 

# Onboarding:
# Positivo 
account_id - 109804294614
domain - .serasa.intranet
Region - us-east-1
Env - Dev
Tribe - Positivo
VPC ID - vpc-02fafde418156c503
aws ec2 describe-vpcs --profile positivodev --query  "Vpcs[].VpcId" --output text
Subnet A - subnet-0ccc0b54c5bbd89a5
Subnet B - subnet-046dd5974b375e35e
Subnet C - subnet-014c7f43ebbaa30e2
aws ec2 describe-subnets  --profile positivodev --output text --query "Subnets[].[SubnetId]" 

# Route53 Subdomain - Service Catalog
aws servicecatalog describe-product --name Route53SubDomain --output text --profile negativodev --query "ProductViewSummary.[ProductId,Name]"
# prod-6da43okdmfjzi      Route53SubDomain

# Vamos agora obter o ProvisioningArtifacts Id
aws servicecatalog describe-product --name Route53SubDomain --output text --profile negativodev --query "ProvisioningArtifacts[].Id"
# ProvisioningArtifactsId = pa-mdig7p3c7r4xu

# Por último, vamos obter o Path ID
aws servicecatalog describe-product --name Route53SubDomain --output text --profile negativodev --output text --query LaunchPaths[].Id
# LaunchPaths.Id = lpv3-qp3cvfasgkl4y

# Para listar os parâmetros obrigatórios, usei:
aws servicecatalog describe-provisioning-parameters --product-name Route53SubDomain --provisioning-artifact-id pa-mdig7p3c7r4xu --path-id lpv3-qp3cvfasgkl4y --profile negativodev

# Por fim, executar o produto Route53SubDomain
# Importante: os passos anteriores são apenas uma verificação 
# e possivel que os passos não sejam necessarios se os parametros
# da automacao nao se alterem  
aws servicecatalog provision-product  --product-name Route53SubDomain  --provisioning-artifact-id pa-mdig7p3c7r4xu --provisioned-product-name Route53SubDomain-negativodev  --provisioning-parameters file://provision-parameters-negativodev.json  --profile negativodev


aws servicecatalog describe-product --name Route53SubDomain --output text --profile positivodev --query "ProductViewSummary.[ProductId,Name]"
# prod-6da43okdmfjzi      Route53SubDomain

# Vamos agora obter o ProvisioningArtifacts Id
aws servicecatalog describe-product --name Route53SubDomain --output text --profile positivodev --query "ProvisioningArtifacts[].Id"
# ProvisioningArtifactsId = pa-mdig7p3c7r4xu

# Por último, vamos obter o Path ID
aws servicecatalog describe-product --name Route53SubDomain --output text --profile positivodev --output text --query LaunchPaths[].Id
# LaunchPaths.Id = lpv3-qp3cvfasgkl4y

# Para listar os parâmetros obrigatórios, usei:
aws servicecatalog describe-provisioning-parameters --product-name Route53SubDomain --provisioning-artifact-id pa-mdig7p3c7r4xu --path-id lpv3-qp3cvfasgkl4y --profile positivodev

# Por fim, executar o produto Route53SubDomain
# Importante: os passos anteriores são apenas uma verificação 
# e possivel que os passos não sejam necessarios se os parametros
# da automacao nao se alterem  
aws servicecatalog provision-product  --product-name Route53SubDomain  --provisioning-artifact-id pa-mdig7p3c7r4xu --provisioned-product-name Route53SubDomain-positivodev  --provisioning-parameters file://provision-parameters-positivodev.json  --profile positivodev


##### Repetir os passos para a automação VPCEndpointAssociation 

aws servicecatalog describe-product --name VPCEndpointAssociation --output text --profile negativodev --query "ProductViewSummary.[ProductId,Name]"
# prod-w4gi6ji76ffr4      VPCEndpointAssociation

# Vamos agora obter o ProvisioningArtifacts Id
aws servicecatalog describe-product --name VPCEndpointAssociation --output text --profile negativodev --query "ProvisioningArtifacts[].Id"
# ProvisioningArtifactsId = pa-fqlv4b36urqfs

# Por último, vamos obter o Path ID
aws servicecatalog describe-product --name VPCEndpointAssociation --output text --profile negativodev --output text --query LaunchPaths[].Id
# LaunchPaths.Id = lpv3-qp3cvfasgkl4y

# Para listar os parâmetros obrigatórios, usei:
aws servicecatalog describe-provisioning-parameters --product-name VPCEndpointAssociation --provisioning-artifact-id pa-fqlv4b36urqfs --path-id lpv3-qp3cvfasgkl4y --profile negativodev

# Por fim, executar o produto Route53SubDomain
# Importante: os passos anteriores são apenas uma verificação 
# e possivel que os passos não sejam necessarios se os parametros
# da automacao nao se alterem  
aws servicecatalog provision-product  --product-name VPCEndpointAssociation  --provisioning-artifact-id pa-fqlv4b36urqfs --provisioned-product-name VPCEndpointAssociation-negativodev  --provisioning-parameters file://provision-parameters-negativodev-2.json  --profile negativodev


aws servicecatalog describe-product --name VPCEndpointAssociation --output text --profile positivodev --query "ProductViewSummary.[ProductId,Name]"
# prod-w4gi6ji76ffr4      VPCEndpointAssociation

# Vamos agora obter o ProvisioningArtifacts Id
aws servicecatalog describe-product --name VPCEndpointAssociation --output text --profile positivodev --query "ProvisioningArtifacts[].Id"
# ProvisioningArtifactsId = pa-fqlv4b36urqfs

# Por último, vamos obter o Path ID
aws servicecatalog describe-product --name VPCEndpointAssociation --output text --profile positivodev --output text --query LaunchPaths[].Id
# LaunchPaths.Id = lpv3-qp3cvfasgkl4y

# Para listar os parâmetros obrigatórios, usei:
aws servicecatalog describe-provisioning-parameters --product-name VPCEndpointAssociation --provisioning-artifact-id pa-fqlv4b36urqfs --path-id lpv3-qp3cvfasgkl4y --profile positivodev

# Por fim, executar o produto Route53SubDomain
# Importante: os passos anteriores são apenas uma verificação 
# e possivel que os passos não sejam necessarios se os parametros
# da automacao nao se alterem  
aws servicecatalog provision-product  --product-name VPCEndpointAssociation  --provisioning-artifact-id pa-fqlv4b36urqfs --provisioned-product-name VPCEndpointAssociation-positivodev  --provisioning-parameters file://provision-parameters-positivodev-2.json  --profile positivodev

# Criar o SG para os endpoints
aws ec2 describe-vpcs --query "Vpcs[].[VpcId]" --profile negativodev
vpc-0c097736e5bf857f5
aws ec2 describe-vpcs --query "Vpcs[].[VpcId]" --profile positivodev
vpc-02fafde418156c503

# vpc-id = vpc-0b489cbdfc54b8660
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-0c097736e5bf857f5 --profile negativodev --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=endpoints-sg},{Key=CostString,Value=1800.BR.134.602018},{Key=AppID,Value=9339},{Key=Environment,Value=dev}]' 
sg-099352df8790f3364
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-02fafde418156c503 --profile positivodev --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=endpoints-sg},{Key=CostString,Value=1800.BR.134.602018},{Key=AppID,Value=9339},{Key=Environment,Value=dev}]' 
sg-045701b68f64bf405

# Adicionar regras para o SG
aws ec2 authorize-security-group-ingress --group-id sg-099352df8790f3364 --protocol tcp --port 443 --cidr 10.0.0.0/8 --profile negativodev
aws ec2 authorize-security-group-ingress --group-id sg-099352df8790f3364 --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile negativodev

aws ec2 authorize-security-group-ingress --group-id sg-045701b68f64bf405 --protocol tcp --port 443 --cidr 10.0.0.0/8 --profile positivodev
aws ec2 authorize-security-group-ingress --group-id sg-045701b68f64bf405 --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile positivodev

# Listar subnets
aws ec2 describe-subnets  --profile negativodev --output text --query "Subnets[].[SubnetId]"
subnet-03fdb69de03ec032c
subnet-05df4112c8597e669
subnet-09a45adfd919bfc1b

aws ec2 describe-subnets  --profile positivodev --output text --query "Subnets[].[SubnetId]"
subnet-0ccc0b54c5bbd89a5
subnet-046dd5974b375e35e
subnet-014c7f43ebbaa30e2

# # Criar Endpoint adicional - não é necessário
# aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0c097736e5bf857f5 --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-099352df8790f3364" --subnet-ids subnet-03fdb69de03ec032c subnet-05df4112c8597e669 subnet-09a45adfd919bfc1b --profile negativodev

# aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-02fafde418156c503 --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-045701b68f64bf405" --subnet-ids subnet-0ccc0b54c5bbd89a5 subnet-046dd5974b375e35e subnet-014c7f43ebbaa30e2 --profile positivodev

# Execução da rotina aws-eks-pre-reqs
ID da conta - 300374333803
Region - us-east-1
VPC Id - vpc-0c097736e5bf857f5
SG - sg-099352df8790f3364

# Execução da rotina aws-eks-pre-reqs
ID da conta - 109804294614
Region - us-east-1
VPC Id - vpc-02fafde418156c503
SG - sg-045701b68f64bf405

### AWS Secondary IP Address
# If your account does not have a secondary IP range, please submit a request to the Cloud Team to add a secondary Subnet/IP Range (100.64.0.0/16) to your VPC with 3 AZs.
aws ec2 describe-vpcs --query "Vpcs[].CidrBlockAssociationSet[*].CidrBlock" --profile positivodev --output text
# 10.2.102.0/24   100.64.0.0/16   100.65.0.0/16
aws ec2 describe-vpcs --query "Vpcs[].CidrBlockAssociationSet[*].CidrBlock" --profile negativodev --output text
# 10.2.103.0/24   100.64.0.0/16   100.65.0.0/16

# Validate if your VPC is tagged with "AWS_Solutions = LandingZoneStackSet", your Experian IP range subnets with "Network = Private" and the Pod IP range (100.64.0.0/16) subnets with "Network = Pod".
aws ec2 describe-subnets --query "Subnets[].[Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Network,Values=Private" --output text --profile positivodev
# EEC-PrivateSubnet2A
# Private
# EEC-PrivateSubnet1A
# Private
# EEC-PrivateSubnet3A
# Private
aws ec2 describe-subnets --query "Subnets[].[Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Network,Values=pod" --output text --profile positivodev
# pod-subnet-1a
# pod
# pod-subnet-1b
# pod
# pod-subnet-1c
# pod

aws ec2 describe-subnets --query "Subnets[].[Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Network,Values=emr" --output text --profile positivodev
# emr-subnet-1b
# emr
# emr-subnet-1a
# emr
# emr-subnet-1c
# emr

aws ec2 describe-subnets --query "Subnets[].[Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Network,Values=Private" --output text --profile negativodev
# EEC-PrivateSubnet1A
# Private
# EEC-PrivateSubnet2A
# Private
# EEC-PrivateSubnet3A
# Private

aws ec2 describe-subnets --query "Subnets[].[Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Network,Values=pod" --output text --profile negativodev
# pod-subnet-1a
# pod
# pod-subnet-1c
# pod
# pod-subnet-1b
# pod

aws ec2 describe-subnets --query "Subnets[].[Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Network,Values=emr" --output text --profile negativodev
# emr-subnet-1b
# emr
# emr-subnet-1c
# emr
# emr-subnet-1a
# emr

# Criar policy BUPolicyForDevSecOpsPiaaS
aws iam create-policy --policy-name BUPolicyForDevSecOpsPiaaS --policy-document file://BUPolicyForDevSecOpsPiaaS.json --profile negativodev
aws iam create-policy --policy-name BUPolicyForDevSecOpsPiaaS --policy-document file://BUPolicyForDevSecOpsPiaaS.json --profile positivodev

# Automação EEC IAM User - Service Catalog
aws servicecatalog describe-product --name "EEC IAM User" --output text --profile negativodev --query "ProductViewSummary.[ProductId,Name]"
# prod-ov3fcictodr44      EEC IAM User
# prod-ov3fcictodr44      EEC IAM User

# Vamos agora obter o ProvisioningArtifacts Id
aws servicecatalog describe-product --name "EEC IAM User" --output text --profile negativodev --query "ProvisioningArtifacts[].Id"
# pa-dd46akq5b24au
# pa-w4c7z3lnnkslw

# Por último, vamos obter o Path ID
aws servicecatalog describe-product --name "EEC IAM User" --output text --profile negativodev --output text --query LaunchPaths[].Id
# lpv3-qp3cvfasgkl4y
# lpv3-qp3cvfasgkl4y

# Para listar os parâmetros obrigatórios, usei:
aws servicecatalog describe-provisioning-parameters --product-name "EEC IAM User" --provisioning-artifact-id pa-dd46akq5b24au --path-id lpv3-qp3cvfasgkl4y --profile negativodev

# Por fim, executar o produto EEC IAM User
aws servicecatalog provision-product  --product-name "EEC IAM User"  --provisioning-artifact-id pa-w4c7z3lnnkslw --provisioned-product-name EECIAMUser-negativodev-2  --provisioning-parameters file://provision-parameters-negativodev-3.json  --profile negativodev

# Automação EEC IAM User - Service Catalog
aws servicecatalog describe-product --name "EEC IAM User" --output text --profile positivodev --query "ProductViewSummary.[ProductId,Name]"
# prod-ov3fcictodr44      EEC IAM User
# prod-ov3fcictodr44      EEC IAM User

# Vamos agora obter o ProvisioningArtifacts Id
aws servicecatalog describe-product --name "EEC IAM User" --output text --profile positivodev --query "ProvisioningArtifacts[].Id"
# pa-dd46akq5b24au
# pa-w4c7z3lnnkslw

# Por último, vamos obter o Path ID
aws servicecatalog describe-product --name "EEC IAM User" --output text --profile positivodev --output text --query LaunchPaths[].Id
# lpv3-qp3cvfasgkl4y
# lpv3-qp3cvfasgkl4y

# Para listar os parâmetros obrigatórios, usei:
aws servicecatalog describe-provisioning-parameters --product-name "EEC IAM User" --provisioning-artifact-id pa-dd46akq5b24au --path-id lpv3-qp3cvfasgkl4y --profile positivodev

# Por fim, executar o produto EEC IAM User
aws servicecatalog provision-product  --product-name "EEC IAM User"  --provisioning-artifact-id pa-w4c7z3lnnkslw --provisioned-product-name EECIAMUser-positivodev-2  --provisioning-parameters file://provision-parameters-positivodev-3.json  --profile positivodev

aws servicecatalog terminate-provisioned-product  --provisioned-product-name EECIAMUser-positivodev --profile positivodev
aws iam create-group --group-name BUGroupForDevSecOpsPiaaS  --profile positivodev
aws servicecatalog provision-product  --product-name "EEC IAM User"  --provisioning-artifact-id pa-dd46akq5b24au --provisioned-product-name EECIAMUser-positivodev-2  --provisioning-parameters file://provision-parameters-positivodev-3.json  --profile positivodev

$status = "IN_PROGRESS"
while ($status -eq "IN_PROGRESS") {
    $status = aws servicecatalog describe-record --id rec-mel6kdo5knb4e --profile dsprod --query "RecordDetail.Status" --output text
    Write-Host "Status atual: $status"
    Start-Sleep -Seconds 30
}

$status = "IN_PROGRESS"
while ($status -eq "IN_PROGRESS") {
    $status = aws servicecatalog describe-record --id rec-k62rigngywtxs --profile negativodev --query "RecordDetail.Status" --output text
    Write-Host "Status atual: $status"
    Start-Sleep -Seconds 30
}

#### Importar chave privada para o ACM
# No MobaTerm
# Extrair a chave privada
openssl pkcs12 -in dev-us-negativo.br.experian.eeca.pfx -nocerts -out dev-us-negativo.br.experian.eeca.key
# Enter Import Password: s3r4s$@6590
# Enter PEM pass phrase: negativos
# Confirm: nagativos
openssl pkcs12 -in dev-us-positivo.br.experian.eeca.pfx -nocerts -out dev-us-positivo.br.experian.eeca.key
# Enter Import Password: s3r4s$@6590
# Enter PEM pass phrase: positivo
# Confirm: positivo

# Remover a senha da chave privada (opcional, mas necessário para o ACM)
openssl rsa -in dev-us-negativo.br.experian.eeca.key -out chave-privada-dev-us-negativo.br.experian.eeca.key
openssl rsa -in dev-us-positivo.br.experian.eeca.key -out chave-privada-dev-us-positivo.br.experian.eeca.key

# Extrair o certificado
openssl pkcs12 -in dev-us-negativo.br.experian.eeca.pfx -clcerts -nokeys -out dev-us-negativo.br.experian.eeca.crt
openssl pkcs12 -in dev-us-positivo.br.experian.eeca.pfx -clcerts -nokeys -out dev-us-positivo.br.experian.eeca.crt

# Extrair a cadeia de certificados (se houver)
openssl pkcs12 -in dev-us-negativo.br.experian.eeca.pfx -cacerts -nokeys -chain -out cadeia-dev-us-negativo.br.experian.eeca.crt
openssl pkcs12 -in dev-us-positivo.br.experian.eeca.pfx -cacerts -nokeys -chain -out cadeia-dev-us-positivo.br.experian.eeca.crt

# importar os certificados
aws acm import-certificate --certificate fileb://dev-us-negativo.br.experian.eeca.crt --private-key fileb://chave-privada-dev-us-negativo.br.experian.eeca.key --certificate-chain fileb://cadeia-dev-us-negativo.br.experian.eeca.crt --profile negativodev 

aws acm import-certificate --certificate fileb://dev-us-positivo.br.experian.eeca.crt --private-key fileb://chave-privada-dev-us-positivo.br.experian.eeca.key --certificate-chain fileb://cadeia-dev-us-positivo.br.experian.eeca.crt --profile positivodev 


### aws-service-s3-safe
# Account ID: 300374333803
# Country: US
# Asset Category: Development
# Data Type: N/A
# Data Category: Negative
# Bucket Name: cockpit-devsecops-states-300374333803
# SSE Algoritm: AES256
# KMS Master Key ARN: daixar vazio
# ACL: Private
# Force destroy: true
# Versioning enable: true
# CostCenter: 1800.BR.134.602018
# AppID: 9339
# Env: Dev

# Account ID: 109804294614
# Country: US
# Asset Category: Development
# Data Type: N/A
# Data Category: Positive
# Bucket Name: cockpit-devsecops-states-109804294614
# SSE Algoritm: AES256
# KMS Master Key ARN: daixar vazio
# ACL: Private
# Force destroy: true
# Versioning enable: true
# CostCenter: 1800.BR.134.602018
# AppID: 9339
# Env: Dev


#### aws-eks-serasa
# RITM: RITM4201516
# Account Id: 300374333803
# AWS Region: us-east-1
# EKS Cluster Name: negativo-dev
# Env: dev
# Tfstate name: tfstate-negativo-dev
# EKS Cluster Version: 1.32
# ACM: arn:aws:acm:us-east-1:300374333803:certificate/f38e630e-23f4-4bba-8c90-08ae485b4a30
# Domain name: dev-us-negativo.br.experian.eeca
# VPC: vpc-0c097736e5bf857f5
# subnets: subnet-03fdb69de03ec032c,subnet-05df4112c8597e669,subnet-09a45adfd919bfc1b
# AD domain: br.experian.local
# Resource Business Unit: EITS
# Resource name: negativo-dev
# Resource owner: Datahub_Squad_NegativosPrivados@experian.com
# App Id: 9339
# Cost Center: 1800.BR.134.602018
# EFS enabled: true
# Kubeconfig enabled: true
# node infra instance type: c6i.2xlarge
# node small instance type: t3.large
# node medium instance type: t3.xlarge
# node large instance type: t3.2xlarge
# node spot instance type: t3.xlarge

# RITM: RITM4201534
# Account Id: 109804294614
# AWS Region: us-east-1
# EKS Cluster Name: positivo-us
# Env: dev
# Tfstate name: tfstate-positivo-us
# EKS Cluster Version: 1.32
# ACM: arn:aws:acm:us-east-1:109804294614:certificate/476c701b-a6aa-41f4-8f1f-371e27961d05
# Domain name: dev-us-positivo.br.experian.eeca
# VPC: vpc-02fafde418156c503
# subnets: subnet-0ccc0b54c5bbd89a5,subnet-046dd5974b375e35e,subnet-014c7f43ebbaa30e2
# AD domain: br.experian.local
# Resource Business Unit: EITS
# Resource name: negativo-dev
# Resource owner: Datahub_Squad_NegativosPrivados@experian.com
# App Id: 9339
# Cost Center: 1800.BR.134.602018
# EFS enabled: true
# Kubeconfig enabled: true
# node infra instance type: c6i.2xlarge
# node small instance type: t3.large
# node medium instance type: t3.xlarge
# node large instance type: t3.2xlarge
# node spot instance type: t3.xlarge

aws ec2 describe-subnets --filters "Name=tag:Network,Values=pod" --query "Subnets[*].SubnetId" --output text --profile positivodev

aws ec2 create-tags --resources subnet-06893edb60fc77ad7 subnet-06d5e8a8621799f49 subnet-09892185cfe6ea094 --tags Key=Network,Value=Pod  --profile positivodev

# Primeiro vamos obter o PRODUCT-ID da automação
$profile_aws = "negativodev"
$productID = aws servicecatalog search-products --profile $profile_aws --query "ProductViewSummaries[].[Id]" --output text --filter "FullTextSearch=CustomADGroup"

# Vamos agora obter o ProvisioningArtifacts Id
$provisioningArtifactsId = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --query "ProvisioningArtifacts[].Id"

# Por último, vamos obter o Path ID
$pathID = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --output text --query LaunchPaths[].Id

# Para listar os parâmetros obrigatórios, usei:
# aws servicecatalog describe-provisioning-parameters --product-name CustomADGroup --provisioning-artifact-id $provisioningArtifactsId --path-id $pathID --profile $profile

# Por fim, executar o produto CustomADGroup
aws servicecatalog provision-product  --product-name CustomADGroup  --provisioning-artifact-id $provisioningArtifactsId --provisioned-product-name CustomADGroup-$profile_aws  --provisioning-parameters file://provision-parameters-CustomADGroup.json  --profile $profile_aws

$status = "IN_PROGRESS"
while ($status -eq "IN_PROGRESS") {
    $status = aws servicecatalog describe-record --id rec-lcde664hehida --profile $profile_aws --query "RecordDetail.Status" --output text  --region us-east-1
    Write-Host "Status atual: $status"
    Start-Sleep -Seconds 30
}

$policy_arn = aws iam create-policy --policy-name BUPolicyForEKSAccess --policy-document file://BUPolicyForEKSAccess.json --profile $profile_aws --query "Policy.Arn" --output text
aws iam attach-role-policy  --role-name BURoleForNegativos  --policy-arn $policy_arn --profile $profile_aws

arn:aws:iam::300374333803:role/BURoleForNegativos

 aws iam list-attached-role-policies --role-name BURoleLimitedReadOnlyAccess  --profile dodev

aws iam attach-role-policy --role-name BURoleForNegativos --policy-arn arn:aws:iam::aws:policy/AmazonDocDBReadOnlyAccess --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForNegativos --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForNegativos --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForNegativos --policy-arn arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForNegativos --policy-arn arn:aws:iam::aws:policy/AmazonEMRReadOnlyAccessPolicy_v2 --profile $profile_aws
aws iam put-role-policy --role-name BURoleForNegativo --policy-name InlinePolicyForNegativo --policy-document file://inline-policy-3.json --profile $profile_aws --region us-east-1

# Obter o nome do cluster
aws eks list-clusters --profile  $profile_aws
# {
#     "clusters": [
#         "negativo-us-dev"
#     ]
# }

# Obter contexto do cluster
aws eks update-kubeconfig --name negativo-us-dev --profile $profile_aws
# Added new context arn:aws:eks:us-east-1:300374333803:cluster/negativo-us-dev to C:\Users\c96531a\.kube\config

# Criar Cluster Role
kubectl create -f .\ClusterRole.yaml
kubectl create -f .\ClusterRoleBinding.yaml



# ***********************************************
# Primeiro vamos obter o PRODUCT-ID da automação
$profile_aws = "lab01"
$productID = aws servicecatalog search-products --profile $profile_aws --query "ProductViewSummaries[].[Id]" --output text --filter "FullTextSearch=CustomADGroup"

# Vamos agora obter o ProvisioningArtifacts Id
$provisioningArtifactsId = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --query "ProvisioningArtifacts[].Id"

# Por último, vamos obter o Path ID
$pathID = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --output text --query LaunchPaths[].Id

# Para listar os parâmetros obrigatórios, usei:
# aws servicecatalog describe-provisioning-parameters --product-name CustomADGroup --provisioning-artifact-id $provisioningArtifactsId --path-id $pathID --profile $profile

# Por fim, executar o produto CustomADGroup
aws servicecatalog provision-product  --product-name CustomADGroup  --provisioning-artifact-id $provisioningArtifactsId --provisioned-product-name CustomADGroup-$profile_aws-2  --provisioning-parameters file://provision-parameters-CustomADGroup.json  --profile $profile_aws

$status = "IN_PROGRESS"
while ($status -eq "IN_PROGRESS") {
    $status = aws servicecatalog describe-record --id rec-ay7v3juw7zqps --profile $profile_aws --query "RecordDetail.Status" --output text
    Write-Host "Status atual: $status"
    Start-Sleep -Seconds 30
}

aws iam put-role-policy --role-name BURoleForNegativos --policy-name InlinePolicyForNegativos --policy-document file://inline-policy-3.json --profile $profile_aws

# ***************************
# Criar Role da conta Positivo
# Primeiro vamos obter o PRODUCT-ID da automação
$profile_aws = "positivodev"
$productID = aws servicecatalog search-products --profile $profile_aws --query "ProductViewSummaries[].[Id]" --output text --filter "FullTextSearch=CustomADGroup"

# Vamos agora obter o ProvisioningArtifacts Id
$provisioningArtifactsId = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --query "ProvisioningArtifacts[].Id"

# Por último, vamos obter o Path ID
$pathID = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --output text --query LaunchPaths[].Id

# Para listar os parâmetros obrigatórios, usei:
# aws servicecatalog describe-provisioning-parameters --product-name CustomADGroup --provisioning-artifact-id $provisioningArtifactsId --path-id $pathID --profile $profile

# Por fim, executar o produto CustomADGroup
aws servicecatalog provision-product  --product-name CustomADGroup  --provisioning-artifact-id $provisioningArtifactsId --provisioned-product-name CustomADGroup-$profile_aws  --provisioning-parameters file://provision-parameters-CustomADGroup.json  --profile $profile_aws

$status = "IN_PROGRESS"
while ($status -eq "IN_PROGRESS") {
    $status = aws servicecatalog describe-record --id rec-ydtrofzvsjgck --profile $profile_aws --query "RecordDetail.Status" --output text
    Write-Host "Status atual: $status"
    Start-Sleep -Seconds 30
}

$policy_arn = aws iam create-policy --policy-name BUPolicyForEKSAccess --policy-document file://BUPolicyForEKSAccess.json --profile $profile_aws --query "Policy.Arn" --output text
aws iam attach-role-policy  --role-name BURoleForPositivo  --policy-arn $policy_arn --profile $profile_aws

aws iam attach-role-policy --role-name BURoleForPositivo --policy-arn arn:aws:iam::aws:policy/AmazonDocDBReadOnlyAccess --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForPositivo --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForPositivo --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForPositivo --policy-arn arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForPositivo --policy-arn arn:aws:iam::aws:policy/AmazonEMRReadOnlyAccessPolicy_v2 --profile $profile_aws
aws iam put-role-policy --role-name BURoleForPositivo --policy-name InlinePolicyForNegativos --policy-document file://inline-policy-2.json --profile $profile_aws

# Obter o nome do cluster
aws eks list-clusters --profile  $profile_aws
# {
#     "clusters": [
#         "negativo-us-dev"
#     ]
# }

# Obter contexto do cluster
aws eks update-kubeconfig --name negativo-us-dev --profile $profile_aws
# Added new context arn:aws:eks:us-east-1:300374333803:cluster/negativo-us-dev to C:\Users\c96531a\.kube\config

# Criar Cluster Role
kubectl create -f .\ClusterRole.yaml
kubectl create -f .\ClusterRoleBinding.yaml

