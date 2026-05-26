# Setar variáveis de ambiente no powershell
$env:AWS_CA_BUNDLE="c:\tmp\serasa.pem"
$env:PATH += ";C:\tmp;C:\Program Files\Python38"
$env:PATH += ";C:\Program Files\Python38\Scripts"
# Configuração do Prompt no PowerShell
function global:prompt {
    $dirSep = [IO.Path]::DirectorySeparatorChar
    $pathComponents = $PWD.Path.Split($dirSep)
    $displayPath = if ($pathComponents.Count -le 3) {$PWD.Path
    } else {
      '…{0}{1}' -f $dirSep, ($pathComponents[-2,-1] -join $dirSep)
    }
    "PS {0}$('>' * ($nestedPromptLevel + 1)) " -f $displayPath
  }

Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\_outras tarefas\rev_labs"

# Logar nas contas
saml2aws.exe login -a eec-aws-br-eits-dx-lab01-sandbox
saml2aws.exe login -a eec-aws-br-eits-dx-lab02-sandbox
saml2aws.exe login -a eec-aws-br-eits-dx-lab03-sandbox
saml2aws.exe login -a eec-aws-br-eits-dx-lab04-sandbox
saml2aws.exe login -a eec-aws-br-eits-dx-lab05-sandbox

# Atualizar permissões do usuário de automação
$profile = "lab05"
$stackName = "ServiceCatalog"
$templateFile = "AssumeRole.yml"
$maxAttempts = 100
$attempt = 1

# Delete the stack
aws cloudformation delete-stack --stack-name $stackName --profile $profile

# Wait until the stack is deleted or max attempts reached
do {
    Start-Sleep -Seconds 10
    Write-Host "Attempt # $attempt" 
    $status = aws cloudformation describe-stacks --stack-name $stackName --query 'Stacks[].StackStatus' --output text --profile $profile
    $attempt++
} while ($status -eq "DELETE_IN_PROGRESS" -and $attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "Error: Maximum number of attempts reached. The stack deletion is still in progress."
} else {
    # Deploy the new stack
    aws cloudformation deploy --template-file $templateFile --stack-name $stackName --capabilities CAPABILITY_NAMED_IAM --profile $profile
}


# VPC_ID: 
aws ec2 describe-vpcs  --profile lab02 --query  "Vpcs[].[VpcId]" --output text
# vpc-0f5fd0d8503472173
aws ec2 describe-vpcs  --profile lab03 --query  "Vpcs[].[VpcId]" --output text
# vpc-0a579a62f2bffd564
aws ec2 describe-vpcs  --profile lab04 --query  "Vpcs[].[VpcId]" --output text
# vpc-0dcbd6183f039b944
aws ec2 describe-vpcs  --profile lab05 --query  "Vpcs[].[VpcId]" --output text
# vpc-0d9441e6aae5b8317

# Subnets:
aws ec2 describe-subnets  --profile lab02 --output text --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" 
# subnet-0fdca253e603c9798
# subnet-00e22ce0c648923eb
# subnet-0549950821842305c
aws ec2 describe-subnets  --profile lab03 --output text --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" 
# subnet-08ad98b61504a4dea
# subnet-00baf326089e17536
# subnet-053c7b2ba2b7e53e7
aws ec2 describe-subnets  --profile lab04 --output text --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" 
# subnet-03017c19ea1fc0bed
# subnet-065f78c71e0fb9f6c
# subnet-0b24430d6606272f4
aws ec2 describe-subnets  --profile lab05 --output text --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" 
# subnet-0a8520f306c314ee0
# subnet-058ebfae0ee95e12e
# subnet-03b1c5508fd41fad3

# Keys
$profile = "lab02"
$keys = (aws kms list-keys --profile $profile --query 'Keys[*].KeyId' --output text).Split() | Where-Object { $_ }
foreach ($key in $keys)
{
  $keyDescription = aws kms describe-key --key-id $key --profile $profile | ConvertFrom-Json
  if ($keyDescription.KeyMetadata.Description -eq "Onboarding-test-key") {
    Write-Output $keyDescription.KeyMetadata.Arn
  }
}
arn:aws:kms:sa-east-1:336544373402:key/8271201b-041c-4893-b55f-edb6577c4b36
arn:aws:kms:sa-east-1:726532742050:key/121826da-412f-4d42-89bd-3600cb2fee75
arn:aws:kms:sa-east-1:576259954360:key/59b870df-286f-424b-97f1-172bb4f9ff54
arn:aws:kms:sa-east-1:258050508433:key/ad001be3-58a7-41ad-bf71-1ae6f825dd97
aws kms schedule-key-deletion --key-id arn:aws:kms:sa-east-1:336544373402:key/8271201b-041c-4893-b55f-edb6577c4b36 --pending-window-in-days 7 --profile lab02
aws kms schedule-key-deletion --key-id arn:aws:kms:sa-east-1:726532742050:key/121826da-412f-4d42-89bd-3600cb2fee75 --pending-window-in-days 7 --profile lab03
aws kms schedule-key-deletion --key-id arn:aws:kms:sa-east-1:576259954360:key/59b870df-286f-424b-97f1-172bb4f9ff54 --pending-window-in-days 7 --profile lab04
aws kms schedule-key-deletion --key-id arn:aws:kms:sa-east-1:258050508433:key/ad001be3-58a7-41ad-bf71-1ae6f825dd97 --pending-window-in-days 7 --profile lab05

# Criar novas chaves:
aws kms create-key --description "Onboarding-test-key" --region sa-east-1 --profile lab01
aws kms create-key --description "Onboarding-test-key" --region sa-east-1 --profile lab02
aws kms create-key --description "Onboarding-test-key" --region sa-east-1 --profile lab03
aws kms create-key --description "Onboarding-test-key" --region sa-east-1 --profile lab04
aws kms create-key --description "Onboarding-test-key" --region sa-east-1 --profile lab05

# 1f2b91a2-d36c-4530-a8e1-c05194777d7b
# 8271201b-041c-4893-b55f-edb6577c4b36
# 121826da-412f-4d42-89bd-3600cb2fee75
# 59b870df-286f-424b-97f1-172bb4f9ff54
# ad001be3-58a7-41ad-bf71-1ae6f825dd97

aws kms create-key --description "Onboarding-test-key" --region sa-east-1 --profile lab02 --key-usage ENCRYPT_DECRYPT --customer-master-key-spec SYMMETRIC_DEFAULT --origin AWS_KMS
# 9eb7215b-20f4-4326-88ec-41502c5a567f
aws kms create-key --description "Onboarding-test-key" --region sa-east-1 --profile lab03 --key-usage ENCRYPT_DECRYPT --customer-master-key-spec SYMMETRIC_DEFAULT --origin AWS_KMS
# 3ce2c862-f3ee-448c-9536-52cf2bf42f14
aws kms create-key --description "Onboarding-test-key" --region sa-east-1 --profile lab04 --key-usage ENCRYPT_DECRYPT --customer-master-key-spec SYMMETRIC_DEFAULT --origin AWS_KMS
# "KeyId": "eda146aa-472f-4cef-8bfd-b0541188a2bb",
# "Arn": "arn:aws:kms:sa-east-1:576259954360:key/eda146aa-472f-4cef-8bfd-b0541188a2bb",


# Automação para editar a chave KMS da automação
# aws-edit-your-onboarding-file

# Onboarding Test
# Account ID: 186041780552 336544373402
# App Name: devhub
# Option: default
# Environment: sbx
# App ID: 20274
# Cost Center: 1800.BR.134.607500


########### Para as contas LAB02 até LAB05

# Execução do Cloudformation
aws cloudformation deploy --template-file AssumeRole.yaml --stack-name ServiceCatalog --capabilities CAPABILITY_NAMED_IAM --profile lab02
aws cloudformation deploy --template-file AssumeRole.yaml --stack-name ServiceCatalog --capabilities CAPABILITY_NAMED_IAM --profile lab03
aws cloudformation deploy --template-file AssumeRole.yaml --stack-name ServiceCatalog --capabilities CAPABILITY_NAMED_IAM --profile lab04
aws cloudformation deploy --template-file AssumeRole.yaml --stack-name ServiceCatalog --capabilities CAPABILITY_NAMED_IAM --profile lab05

aws ec2 describe-vpcs  --query "Vpcs[].[CidrBlock]" --output text --profile lab02
# 10.99.241.128/25
aws ec2 describe-vpcs  --query "Vpcs[].[CidrBlock]" --output text --profile lab03
# 10.99.242.0/25
aws ec2 describe-vpcs  --query "Vpcs[].[CidrBlock]" --output text --profile lab04
# 10.99.242.128/25
aws ec2 describe-vpcs  --query "Vpcs[].[CidrBlock]" --output text --profile lab05
# 10.99.11.128/25

# Excluir componentes após falha do Onboarding Test

$profile = "lab05"
# First, list all attached policies
aws iam list-attached-role-policies --role-name BURoleForaws-onboarding-devhub --profile $profile 

# Then, detach each policy
aws iam detach-role-policy --role-name BURoleForaws-onboarding-devhub --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess --profile $profile
aws iam detach-role-policy --role-name BURoleForaws-onboarding-devhub --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess --profile $profile
aws iam detach-role-policy --role-name BURoleForaws-onboarding-devhub --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess --profile $profile

# list instance profile
aws iam list-instance-profiles-for-role --role-name BURoleForaws-onboarding-devhub --profile $profile --query "InstanceProfiles[].InstanceProfileName" --output text

# desanexar o instance profile da role
aws iam remove-role-from-instance-profile --instance-profile-name BURoleForaws-onboarding-devhub --role-name BURoleForaws-onboarding-devhub --profile $profile

# Finally, delete the role
aws iam delete-role --role-name BURoleForaws-onboarding-devhub --profile $profile 

aws iam delete-instance-profile --instance-profile-name BURoleForaws-onboarding-devhub --profile $profile

#### Excluir o SG aws-onboarding-devhub-sg-sg
# Listar regras
# aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupName,GroupId]' --output text --profile $profile
# aws-onboarding-devhub-sg-sg     $groupid
$groupid = aws ec2 describe-security-groups --filters Name=group-name,Values=aws-onboarding-devhub-sg-sg --query 'SecurityGroups[*].GroupId' --output text --profile $profile

aws ec2 describe-security-groups --group-ids $groupid --query 'SecurityGroups[*].IpPermissions[*]' --profile $profile --output text
# 80      tcp     80
# IPRANGES        10.0.0.0/9
# 5432    tcp     5432
# IPRANGES        10.0.0.0/9
# 22      tcp     22
# IPRANGES        10.0.0.0/9
# 3000    tcp     3000
# IPRANGES        10.0.0.0/9
# 443     tcp     443
# IPRANGES        10.0.0.0/9

# Excluir regras
aws ec2 revoke-security-group-ingress --group-id $groupid  --protocol tcp --port 80 --cidr 10.0.0.0/9 --profile $profile
aws ec2 revoke-security-group-ingress --group-id $groupid  --protocol tcp --port 22 --cidr 10.0.0.0/9 --profile $profile
aws ec2 revoke-security-group-ingress --group-id $groupid  --protocol tcp --port 5432 --cidr 10.0.0.0/9 --profile $profile
aws ec2 revoke-security-group-ingress --group-id $groupid  --protocol tcp --port 443 --cidr 10.0.0.0/9 --profile $profile
# aws ec2 revoke-security-group-egress --group-id sg-0abcd1234efgh5678 --protocol tcp --port 22 --cidr 203.0.113.0/24 --profile lab05

# Terminating previous instances of onboarding test
aws ec2 describe-instances --filters "Name=tag:Name,Values=aws-onboarding-devhub" --query "Reservations[].Instances[].[InstanceId]" --output text --profile $profile | ForEach-Object {aws ec2 terminate-instances --instance-ids $_ --profile $profile}

$maxAttempts = 100
$attempt = 1

# Wait until the instance is terminated or max attempts reached
do {
    Start-Sleep -Seconds 10
    Write-Host "Attempt # $attempt" 
    $status = aws ec2 describe-instances --filters "Name=tag:Name,Values=aws-onboarding-devhub" --query "Reservations[].Instances[].State.Name" --output text --profile $profile
    $attempt++
} while ($status -ne "terminated" -and $attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "Error: Maximum number of attempts reached. The stack deletion is still in progress."
} else {
    # Excluir SG
    aws ec2 delete-security-group  --group-id $groupid  --profile $profile
}



# Pre-reqs do EKS

$profile = "lab05"
$account = "258050508433"

# Verificar se a conta tem um range secundário de IPs para execução dos pods (100.64.0.0/16)
aws ec2 describe-vpcs --query "Vpcs[].CidrBlockAssociationSet[*].CidrBlock" --profile $profile --output text

# Verificar se a VPC possui os tags "AWS_Solutions = LandingZoneStackSet" para as redes com range Experian e as subnets possuem os tags "Network = Private" e "Network = Pod" para as redes Experian e pars execução de pods, respectivamente

aws ec2 describe-subnets --query "Subnets[].[CidrBlock,Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Name,Values=aws*" --output text --profile $profile

aws ec2 describe-subnets --query "Subnets[].[CidrBlock,Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Name,Values=Pod*" --output text --profile $profile

### Security Group para os endpoints
# Obter o ID do VPC
$vpcid = aws ec2 describe-vpcs --query "Vpcs[].[VpcId]" --profile $profile --output text

# Verificar se o grupo de segurança existe
$sg = aws ec2 describe-security-groups --filters Name=group-name,Values=endpoints-sg --query 'SecurityGroups[0].GroupId' --profile $profile --output text

if ($sg -eq 'None') {
    # Criar o grupo de segurança se ele não existir
    $sg = aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id $vpcid --profile $profile --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=endpoints-sg},{Key=CostString,Value=1800.BR.seucc},{Key=AppID,Value=seuGEARID},{Key=Environment,Value=prod}]' --query 'GroupId' --output text

    # Autorizar o tráfego de entrada no grupo de segurança
    aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 443 --cidr 10.0.0.0/8 --profile $profile
    aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile $profile
}

# Mostrar o ID do grupo de segurança
Write-Output "O ID do grupo de segurança é $sg"

# Obter os IDs das sub-redes
$subnetids = aws ec2 describe-subnets --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" --output text --profile $profile

# Criar VPC Endpoints:
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id $vpcid --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids $sg --subnet-ids $subnetids --profile $profile

aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id $vpcid --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids $sg --subnet-ids $subnetids --profile $profile

aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id $vpcid --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids $sg --subnet-ids $subnetids --profile $profile

aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id $vpcid --service-name com.amazonaws.sa-east-1.logs --security-group-ids $sg --subnet-ids $subnetids --profile $profile

# Criar as Services Linked Roles
aws iam create-service-linked-role --aws-service-name autoscaling.amazonaws.com --profile $profile
 
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com --profile $profile

# Criar Policy - Configurar uma policy para permitir acesso do usuário de automação
aws iam create-policy --policy-name BUPolicyForDevSecOpsPiaaS --policy-document file://BUPolicyForDevSecOpsPiaaS.json --profile $profile

# ECR Pull Through Cache
# Configurar o ECR Pull through cache configuration:
aws ecr create-pull-through-cache-rule --profile $profile --ecr-repository-prefix "aws-public" --upstream-registry-url "public.ecr.aws"

# Ajustar o ECR Permissions configuration
aws ecr put-registry-policy --policy-text file://registry_policy.json --profile $profile


# Criação do bucket
aws s3api create-bucket --bucket cockpit-devsecops-states-$account --region sa-east-1 --create-bucket-configuration LocationConstraint=sa-east-1 --profile $profile

# Enable versioning
aws s3api put-bucket-versioning --bucket cockpit-devsecops-states-$account --versioning-configuration Status=Enabled   --profile $profile

# Add tags
aws s3api put-bucket-tagging --bucket cockpit-devsecops-states-$account --tagging 'TagSet=[{Key=CostString,Value=1800.BR.134.607500},{Key=AppID,Value=20274},{Key=Environment,Value=sbx}]'  --profile $profile

aws acm list-certificates --profile $profile --query "CertificateSummaryList[].CertificateArn" --output=text
# "CertificateArn": "arn:aws:acm:sa-east-1:576259954360:certificate/7c8fe824-865a-4a67-8666-f40139819baa",
# "DomainName": "*.lab04.br.experian.eeca",
# "CertificateArn": "arn:aws:acm:sa-east-1:258050508433:certificate/8a786c96-c463-4d57-8f98-cc50bb8130b3",
# "DomainName": "*.lab05.br.experian.eeca",


$stream_names = aws logs describe-log-streams --log-group-name /aws/eks/lab02-sandbox/cluster --query 'logStreams[*].logStreamName' --output text --profile $profile

# Dividir a string em um array
$array = $stream_names.Split(' ', [StringSplitOptions]::RemoveEmptyEntries)

# Processar cada nome no array
foreach ($name in $array)
{
    # Verificar se o stream de log existe
    $exists = aws logs describe-log-streams --log-group-name /aws/eks/lab02-sandbox/cluster --log-stream-name-prefix $name --query 'logStreams[*].logStreamName' --output text --profile $profile

    if ($exists -eq $name)
    {
        Write-Host "Deleting log stream $name"
        aws logs delete-log-stream --log-group-name /aws/eks/lab02-sandbox/cluster --log-stream-name $name --profile $profile
    }
    else
    {
        Write-Host "Log stream $name does not exist"
    }
}

aws eks update-cluster-config --region sa-east-1 --name lab02-sandbox --profile lab02 --logging '{\"clusterLogging\":[{\"types\":[\"api\",\"audit\",\"authenticator\",\"controllerManager\",\"scheduler\"],\"enabled\":false}]}'

# Parametros execucao do EKS SERASA 
Automação EKS-SERASA
RITM: RITM3342422
Account: 
336544373402
726532742050
576259954360
258050508433
Region: sa-east-1
Cluster Name:
lab02
lab03
lab04
lab05
Cluster Version: 1.27
Project Name: dev-hub-portal
env: sandbox
ARN do certificado: 
arn:aws:acm:sa-east-1:336544373402:certificate/7f03f349-2744-4be6-9a13-61647bf140e6
arn:aws:acm:sa-east-1:726532742050:certificate/1af65690-6921-4879-b556-65623a81d309
arn:aws:acm:sa-east-1:576259954360:certificate/7c8fe824-865a-4a67-8666-f40139819baa
arn:aws:acm:sa-east-1:258050508433:certificate/8a786c96-c463-4d57-8f98-cc50bb8130b3
domain name: 
lab02.br.experian.eeca
lab03.br.experian.eeca
lab04.br.experian.eeca
lab05.br.experian.eeca
TF State Name: 
lab02
lab03
lab04
lab05
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
Subnet Id: 
subnet-0fdca253e603c9798,subnet-00e22ce0c648923eb,subnet-0549950821842305c
subnet-08ad98b61504a4dea,subnet-00baf326089e17536,subnet-053c7b2ba2b7e53e7
subnet-03017c19ea1fc0bed,subnet-065f78c71e0fb9f6c,subnet-0b24430d6606272f4
subnet-0a8520f306c314ee0,subnet-058ebfae0ee95e12e,subnet-03b1c5508fd41fad3
Resource Business Unit: EITS
Resource name: 
lab02-eks-instance
lab03-eks-instance
lab04-eks-instance
lab05-eks-instance
Resource owner: devhub_team@br.experian.com
App Id: 20274
Cost Center: 1800.BR.134.607500
EFS enabled: true
Kubeconfig enabled: false

http://spobrcatalog:8080/job/Joaquin-X.Producao/242832/console


# Criação da role de acesso ao labs
# Minha sugestão é que seja criada uma nova ROLE com permissão de administração da conta ou com um leque de tecnologias para cada conta de laboratório. BURoleForLabUser
# Defina os nomes dos perfis (substitua pelos seus perfis reais)
$perfis = @("lab01", "lab02", "lab03", "lab04", "lab05")

# Carregue o conteúdo do arquivo trust-policy.json
$trustPolicy = Get-Content -Raw -Path "trust-policy.json"

Write-Host $trustPolicy
# Itere sobre cada perfil e crie a função
foreach ($profile in $perfis) {
    Write-Host "Criando função para o perfil $profile"
#    aws iam create-role --role-name BURoleForLabUser --assume-role-policy-document file://trust-policy.json --profile $profile
    aws iam attach-role-policy  --role-name BURoleForLabUser  --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess" --profile $profile
}

Write-Host "Funções criadas com sucesso!"

$perfis = @("lab02", "lab03", "lab04", "lab05")
foreach ($profile in $perfis) {
### Essa ROLE vai ter que ser registrada no IDC para solicitação de acesso
# Primeiro vamos obter o PRODUCT-ID da automação
    $productID = aws servicecatalog search-products --profile $profile --query "ProductViewSummaries[].[Id]" --output table --filter "FullTextSearch=CustomADGroup"

# Vamos agora obter o ProvisioningArtifacts Id
    $provisioningArtifactsId = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile --query "ProvisioningArtifacts[].Id"

# Por último, vamos obter o Path ID
    $pathID = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile --output text --query LaunchPaths[].Id


# Para listar os parâmetros obrigatórios, usei:
# aws servicecatalog describe-provisioning-parameters --product-name CustomADGroup --provisioning-artifact-id $provisioningArtifactsId --path-id $pathID --profile $profile

# Por fim, executar o produto CustomADGroup
    aws servicecatalog provision-product  --product-name CustomADGroup  --provisioning-artifact-id $provisioningArtifactsId --provisioned-product-name CustomADGroup-$profile  --provisioning-parameters file://provision-parameters-CustomADGroup.json  --profile $profile
}

# Importante: os passos anteriores são apenas uma verificação 
# e possivel que os passos não sejam necessarios se os parametros
# da automacao nao se alterem  

# Para acesso ao laboratório, pensei em criar alguma solicitação pelo portal DEVHUB ou pelo SNOW. Com data de início e término.

# Não sei se é possível, mas o ideal é que essa solicitação abra uma requisição pelo usuário no IDC para solicitar acesso a essa ROLE (eventualmente na data prevista solicitar a exclusão do acesso)

# Nas contas, vou criar um alerta de custo para o e-mail do time quando essas contas passarem de um valor que vamos definir

# Não sei ainda como vamos fazer a limpeza dos itens da conta

$perfis = @("lab02", "lab03", "lab04", "lab05")
foreach ($profile in $perfis) {
aws servicecatalog terminate-provisioned-product  --provisioned-product-name CustomADGroup-$profile
#    aws servicecatalog get-provisioned-product-outputs --profile $profile --provisioned-product-name CustomADGroup-$profile
}

$profile = "lab05"
aws iam update-assume-role-policy --role-name BURoleForLabUser --policy-document file://trust-policy.json --profile $profile

$perfis = @("lab01", "lab02", "lab03", "lab04", "lab05")
foreach ($profile in $perfis) {

# Vamos agora obter o ProvisioningArtifacts Id
    $provisioningArtifactsId = aws servicecatalog describe-product --name Route53SubDomain --output text --profile $profile --query "ProvisioningArtifacts[].Id"

# Por último, vamos obter o Path ID
    $pathID = aws servicecatalog describe-product --name Route53SubDomain --output text --profile $profile --output text --query LaunchPaths[].Id

# Por fim, executar o produto Route53SubDomain
    aws servicecatalog provision-product  --product-name Route53SubDomain  --provisioning-artifact-id $provisioningArtifactsId --provisioned-product-name Route53SubDomain-$profile  --provisioning-parameters file://provision-parameters-Route53SubDomain.json  --profile $profile
}

### Essa ROLE vai ter que ser registrada no IDC para solicitação de acesso
# Primeiro vamos obter o PRODUCT-ID da automação
    $productID = aws servicecatalog search-products --profile $profile --query "ProductViewSummaries[].[Id]" --output table --filter "FullTextSearch=Route53SubDomain"

# Para listar os parâmetros obrigatórios, usei:
# aws servicecatalog describe-provisioning-parameters --product-name Route53SubDomain --provisioning-artifact-id $provisioningArtifactsId --path-id $pathID --profile $profile


$perfis = @("lab02", "lab03", "lab04", "lab05")

foreach ($profile in $perfis) {
    Write-Host "#### $profile ####"
    Write-Host "Obter o ProvisioningArtifacts Id"
    $provisioningArtifactsId = aws servicecatalog describe-product --name Route53SubDomain --output text --profile $profile --query "ProvisioningArtifacts[].Id"
    Write-Host $provisioningArtifactsId

    Write-Host "Obter o Path ID"
    $pathID = aws servicecatalog describe-product --name Route53SubDomain --output text --profile $profile --output text --query LaunchPaths[].Id
    Write-Host $pathID

    Write-Host "Obter o VPC ID da conta"
    $vpcid = aws ec2 describe-vpcs --query "Vpcs[].[VpcId]" --profile $profile --output text
    Write-Host $vpcid

    Write-Host "Criar o arquivo provision-parameters-Route53SubDomain.json com os valores dinâmicos"
    $parameters = @(
        @{
            "Key" = "SubDomain"
            "Value" = $profile
        },
        @{
            "Key" = "ParentDomain"
            "Value" = "br.experian.eeca"
        },
        @{
            "Key" = "VPCId"
            "Value" = $vpcid
        }
    )
    Write-Host $parameters

    $parameters | ConvertTo-Json | Out-File -FilePath provision-parameters-Route53SubDomain-$profile.json

    Write-Host "Executar o produto Route53SubDomain"

    aws servicecatalog provision-product --product-name Route53SubDomain --provisioning-artifact-id $provisioningArtifactsId --provisioned-product-name "Route53SubDomain-$profile" --provisioning-parameters file://provision-parameters-Route53SubDomain-$profile.json --profile $profile
}


$perfis = @("lab03", "lab04", "lab05")

foreach ($profile in $perfis) {
    Write-Host "#### $profile ####"
    Write-Host "Obter o ProvisioningArtifacts Id"
    $provisioningArtifactsId = aws servicecatalog describe-product --name Route53SubDomain --output text --profile $profile --query "ProvisioningArtifacts[].Id"
    Write-Host $provisioningArtifactsId

    Write-Host "Obter o Path ID"
    $pathID = aws servicecatalog describe-product --name Route53SubDomain --output text --profile $profile --output text --query LaunchPaths[].Id
    Write-Host $pathID

    Write-Host "Obter o VPC ID da conta"
    $vpcid = aws ec2 describe-vpcs --query "Vpcs[].[VpcId]" --profile $profile --output text
    Write-Host $vpcid
    Write-Host "Criar o provision-parameters com os valores dinâmicos"
    $parametersJson ='[{\"Key\":\"SubDomain\",\"Value\":\"'+$profile+'\"},{\"Key\":\"ParentDomain\",\"Value\":\"br.experian.eeca\"},{\"Key\":\"VPCId\",\"Value\":\"'+$vpcid+'\"}]'

    Write-Host "Executar o produto Route53SubDomain"

    aws servicecatalog provision-product --product-name Route53SubDomain --provisioning-artifact-id $provisioningArtifactsId --provisioned-product-name "Route53SubDomain-$profile" --provisioning-parameters $parametersJson --profile $profile
}
