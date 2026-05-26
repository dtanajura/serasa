# Automação EEC IAM User - Service Catalog
aws servicecatalog describe-product --name "EEC IAM User" --output text --profile datahubstage --query "ProductViewSummary.[ProductId,Name]"
# prod-thgz5uzsdjrvu      EEC IAM User

# Vamos agora obter o ProvisioningArtifacts Id
aws servicecatalog describe-product --name "EEC IAM User" --output text --profile datahubstage --query "ProvisioningArtifacts[].Id"
# pa-iuvxtr2orh2yk

# Por último, vamos obter o Path ID
aws servicecatalog describe-product --name "EEC IAM User" --output text --profile datahubstage --output text --query LaunchPaths[].Id


# Para listar os parâmetros obrigatórios, usei:
aws servicecatalog describe-provisioning-parameters --product-name "EEC IAM User" --provisioning-artifact-id pa-iuvxtr2orh2yk --path-id lpv3-qp3cvfasgkl4y --profile datahubstage

# Por fim, executar o produto EEC IAM User
aws servicecatalog provision-product  --product-name "EEC IAM User"  --provisioning-artifact-id pa-iuvxtr2orh2yk --provisioned-product-name EECIAMUser-datahubstage  --provisioning-parameters file://provision-parameters.json  --profile datahubstage

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
    $status = aws servicecatalog describe-record --id rec-k62rigngywtxs --profile datahubstage --query "RecordDetail.Status" --output text
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
aws acm import-certificate --certificate fileb://dev-us-negativo.br.experian.eeca.crt --private-key fileb://chave-privada-dev-us-negativo.br.experian.eeca.key --certificate-chain fileb://cadeia-dev-us-negativo.br.experian.eeca.crt --profile datahubstage 

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
$profile_aws = "datahubstage"
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

