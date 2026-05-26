# Fazer logon na conta
saml2aws.exe login -a eec-aws-br-eits-nike-sre-management-dev
cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\Onboarding conta SRE DEV"
$profile_aws = "sredev"
# Para as informações a seguir verificar: https://eec.us.experian.eeca/eec-cloud-environments.html
$cost_string="1800.BR.134.404506"
$app_id="21427"
$environment = "dev"
$email="nikesre@br.experian.com"

##################
### Configuração do Systems Manager
##################
# Criar a função IAM:
aws iam create-role --role-name BURoleForSSM-Instance-Role --assume-role-policy-document file://BURoleforSSM.json --profile $profile_aws

# Anexar a política do Systems Manager à função:
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy  --profile $profile_aws

# Criar um perfil IAM para as instâncias EC2:
aws iam create-instance-profile --instance-profile-name SSM-Instance-Profile  --profile $profile_aws

# Adicionar a função à instância do perfil IAM:
aws iam add-role-to-instance-profile --instance-profile-name SSM-Instance-Profile --role-name BURoleForSSM-Instance-Role   --profile $profile_aws

# Criar uma chave
aws ec2 create-key-pair --key-name bastion-$profile_aws --key-type rsa --key-format pem --query "KeyMaterial" --profile $profile_aws --output text > bastion-$profile_aws.pem

# Listar VPC
$vpc_id = aws ec2 describe-vpcs  --profile $profile_aws --query  "Vpcs[].[VpcId]" --output text

# Criar Security Group para o Bastion

$sg_id=aws ec2 create-security-group --group-name SG-Bastion --description "SG para acesso ao bastion" --vpc-id $vpc_id --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=SG-Bastion},{Key=CostString,Value=$cost_string},{Key=AppID,Value=$app_id},{Key=Environment,Value=$environment}]" --profile $profile_aws --query "GroupId" --output text

# Lembrar de atualizar o SG id no comando a seguir
aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 22 --cidr 10.0.0.0/8 --profile $profile_aws

# Listar subnets
$subnet_id=aws ec2 describe-subnets  --profile $profile_aws --output text --query "Subnets[0].SubnetId" --filters "Name=tag:Name,Values=aws*"

# Obter a imagem mais atualizada do Amazon Linux 2 do EEC
$images = aws ec2 describe-images --filters Name=architecture,Values=x86_64 Name=is-public,Values=false Name=name,Values="eec_aws_amzn-lnx_2*" Name=state,Values=available --profile $profile_aws | ConvertFrom-Json
$sorted_images = $images.Images | Sort-Object -Property @{Expression = {($_.ImageLocation.Substring(20,10))}} -Descending
$nova_ami = $sorted_images.ImageId[0]

# Lançar ou atualizar instâncias EC2 associadas ao perfil IAM:
# lembrar de pegar um subnet id e security group ID
aws ec2 run-instances --image-id $novaAmi --subnet-id $subnet_id --security-group-ids $sg_id --key-name bastion-$profile_aws --instance-type t3.micro --iam-instance-profile Name=SSM-Instance-Profile --profile $profile_aws --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=bastion-$profile_aws},{Key=CostString,Value=$cost_string},{Key=AppID,Value=$app_id},{Key=Environment,Value=$environment},{Key=CentrifyUnixRole,Value=0},{Key=ResourceName,Value=bastion-$profile_aws},{Key=ResourceAppRole,Value=app},{Key=ResourceOwner,Value=$email},{Key=adDomain,Value=br.experian.local},{Key=adGroup,Value=0}]" --profile $profile_aws 

# Testar logon na instância
aws ssm start-session --target i-05b1fe91621c66dd3 --profile $profile_aws 

#### AWS Backup
# Create a backup vault by running:
aws backup create-backup-vault --backup-vault-name backup-vault-$profile_aws --profile $profile_aws

# Create a backup plan by running 
# Ajustar arquivo JSON com:
# ===> backup-vault-name = backup-vault-devexperience-prod
aws backup create-backup-plan --cli-input-json file://backup-plan.json --profile $profile_aws

# Create a backup selection by running:
# Ajustar arquivo JSON com:
# ===> BackupPlanId = 7a38f5ec-ea85-4722-b6f2-acfe5280000e
# ===> IamRoleArn = arn:aws:iam::562223391796:role/aws-service-role/backup.amazonaws.com/AWSServiceRoleForBackup
aws iam list-roles --query 'Roles[?RoleName==`AWSServiceRoleForBackup`].Arn' --output text --profile $profile_aws

aws backup create-backup-selection --cli-input-json file://backup-selection.json  --profile $profile_aws
aws ec2 create-tags --resources i-00c2bd09bfc06b371 --tags Key=Backup,Value='True' --profile $profile_aws


#####
### Systems Manager
#####
#### Configuração para atualização de patches
# Criar Role para atualização de patches
aws iam create-role --role-name BURoleForDevHubSSMMaintenanceWindow --assume-role-policy-document file://assumerole_BURoleForDevHubSSMMaintenanceWindow.json  --profile $profile_aws

aws iam create-policy --policy-name BUPolicyForDevHubSSMMaintenanceWindow --policy-document file://BUPolicyForDevHubSSMMaintenanceWindow.json  --profile $profile_aws

# ===>  policy-arn = arn:aws:iam::562223391796:policy/BUPolicyForDevHubSSMMaintenanceWindow
aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::562223391796:policy/BUPolicyForDevHubSSMMaintenanceWindow  --profile $profile_aws

# Criar o Patch Baseline
aws ssm create-patch-baseline --name "Baseline_AMZLinux2" --operating-system "AMAZON_LINUX_2" --approval-rules "PatchRules=[{PatchFilterGroup={PatchFilters=[{Key=PRODUCT,Values=[AmazonLinux2,AmazonLinux2.0]},{Key=CLASSIFICATION,Values=[Bugfix,Enhancement,Newpackage,Recommended,Security]},{Key=SEVERITY,Values=[Critical,Important,Medium]}]},ApproveAfterDays=7}]" --profile $profile_aws
# lembrar de atualizar o baseline ID
# ===>  baseline-id = pb-0ce8e0f048492b7aa
aws ssm update-patch-baseline --baseline-id pb-0ce8e0f048492b7aa   --approved-patches-enable-non-security --approval-rules "PatchRules=[{PatchFilterGroup={PatchFilters=[{Key=PRODUCT,Values=[AmazonLinux2,AmazonLinux2.0]},{Key=CLASSIFICATION,Values=[Bugfix,Enhancement,Newpackage,Recommended,Security]},{Key=SEVERITY,Values=[Critical,Important,Medium]}]},ApproveAfterDays=7,EnableNonSecurity=true}]" --profile $profile_aws
aws ssm register-default-patch-baseline --baseline-id pb-0ce8e0f048492b7aa --profile $profile_aws
aws ssm get-default-patch-baseline --operating-system AMAZON_LINUX_2 --profile $profile_aws

# Rodar o quick setup para criar a patch policy
# ===> intanceid = i-00c2bd09bfc06b371 
aws ec2 create-tags --resources i-00c2bd09bfc06b371 --tags Key=PatchGroup,Value='PatchGroup02' --profile $profile_aws

##########################
#### Terça
##########################
# Criar a janela de manutenção para instalação dos poatches
aws ssm create-maintenance-window --name "Patches-Terca" --schedule "cron(0 22 ? * TUE *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile $profile_aws

# ===> window-id = mw-047c942f19f4d1853
aws ssm register-target-with-maintenance-window --window-id mw-047c942f19f4d1853 --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira " --profile $profile_aws

# ===> window-id = mw-047c942f19f4d1853
# ===> WindowTargetIds = c9483bf2-6049-4f86-a447-8bddbf02ca58
# ===> service-role-arn = arn:aws:iam::562223391796:role/BURoleForDevHubSSMMaintenanceWindow
aws ssm register-task-with-maintenance-window --window-id mw-047c942f19f4d1853  --targets "Key=WindowTargetIds,Values=c9483bf2-6049-4f86-a447-8bddbf02ca58" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::562223391796:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile $profile_aws

##########################
#### Quarta
##########################
# Criar a janela de manutenção para instalação dos poatches
aws ssm create-maintenance-window --name "Patches-Quarta" --schedule "cron(0 22 ? * WED *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile $profile_aws

# ===> window-id = mw-09260276b273abe93
aws ssm register-target-with-maintenance-window --window-id "mw-09260276b273abe93" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira" --profile $profile_aws

# ===> window-id = mw-09260276b273abe93
# ===> WindowTargetIds = 4e6bd880-be08-46b5-bb49-b62939695413
# ===> service-role-arn = arn:aws:iam::562223391796:role/BURoleForDevHubSSMMaintenanceWindow
aws ssm register-task-with-maintenance-window --window-id "mw-09260276b273abe93" --targets "Key=WindowTargetIds,Values=4e6bd880-be08-46b5-bb49-b62939695413" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::562223391796:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile $profile_aws

##########################
#### Quinta
##########################
# Criar a janela de manutenção para instalação dos poatches
aws ssm create-maintenance-window --name "Patches-Quinta" --schedule "cron(0 22 ? * THU *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile $profile_aws

# ===> window-id = mw-0796cedf88fff6c2c
aws ssm register-target-with-maintenance-window --window-id "mw-0796cedf88fff6c2c" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira" --profile $profile_aws

# ===> window-id = mw-0796cedf88fff6c2c
# ===> WindowTargetIds = 10bc38b8-6dd1-4288-ac30-6e608f37b493
# ===> service-role-arn = arn:aws:iam::562223391796:role/BURoleForDevHubSSMMaintenanceWindow
aws ssm register-task-with-maintenance-window --window-id "mw-0796cedf88fff6c2c" --targets "Key=WindowTargetIds,Values=10bc38b8-6dd1-4288-ac30-6e608f37b493" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::562223391796:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile $profile_aws

##############
# Onboarding da conta
##############

# Execução do CloudFormation
aws cloudformation deploy --template-file AssumeRole.yml --stack-name ServiceCatalog --capabilities CAPABILITY_NAMED_IAM --profile $profile_aws

# Criar Chave
aws kms create-key --description "Onboarding-test-key" --region sa-east-1 --profile $profile_aws 
# 5de21289-96cb-4a66-a610-b2e25e885d4e

############################## 
#####  Passo 02 - executar no Cockpit - aws-onboarding-new-account
##############################
# NEW_AWS_ACCOUNT_ID: 562223391796
# DOMAIN: .serasa.intranet
# AWS_REGION: sa-east1
# ENV: prd
# TRIBE: devhub
# VPC_ID: 
aws ec2 describe-vpcs  --profile $profile_aws --query  "Vpcs[].[VpcId]" --output text
vpc-0fa4692625691ff01
# Subnets:
aws ec2 describe-subnets  --profile $profile_aws --output text --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" 
subnet-0c5e2a1b7678f962f
subnet-025e5a9d81abe9170
subnet-003094d7dae673abc


# KMS: 5de21289-96cb-4a66-a610-b2e25e885d4e

############################## 
#####  Passo 03 - executar no Cockpit - aws-onboarding-test
##############################
# NEW_AWS_ACCOUNT_ID: 562223391796
# app_id: devhub
# OPTION: none
# CostString = 1800.BR.134.607500
# AppID = 20274
# First, list all attached policies
aws iam list-attached-role-policies --role-name BURoleForaws-onboarding-devhub --profile $profile_aws 

# Then, detach each policy
aws iam detach-role-policy --role-name BURoleForaws-onboarding-devhub --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess --profile $profile_aws
aws iam detach-role-policy --role-name BURoleForaws-onboarding-devhub --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess --profile $profile_aws
aws iam detach-role-policy --role-name BURoleForaws-onboarding-devhub --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess --profile $profile_aws

# list instance profile
aws iam list-instance-profiles-for-role --role-name BURoleForaws-onboarding-devhub --profile $profile_aws --query "InstanceProfiles[].InstanceProfileName" --output text

# desanexar o instance profile da role
aws iam remove-role-from-instance-profile --instance-profile-name BURoleForaws-onboarding-devhub --role-name BURoleForaws-onboarding-devhub --profile $profile_aws

# Finally, delete the role
aws iam delete-role --role-name BURoleForaws-onboarding-devhub --profile $profile_aws 

aws iam delete-instance-profile --instance-profile-name BURoleForaws-onboarding-devhub --profile $profile_aws

#################
# Pre-reqs EKS
################
### AWS Secondary IP Address
# If your account does not have a secondary IP range, please submit a request to the Cloud Team to add a secondary Subnet/IP Range (100.64.0.0/16) to your VPC with 3 AZs.
aws ec2 describe-vpcs --no-verify-ssl --query "Vpcs[].CidrBlockAssociationSet[*]" --profile devexperience-prod

# Validate if your VPC is tagged with "AWS_Solutions = LandingZoneStackSet", your Experian IP range subnets with "Network = Private" and the Pod IP range (100.64.0.0/16) subnets with "Network = Pod".

aws ec2 describe-subnets --no-verify-ssl --query "Subnets[].[CidrBlock,Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Name,Values=aws*" --output text --profile devexperience-prod

aws ec2 describe-subnets --no-verify-ssl --query "Subnets[].[CidrBlock,Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Name,Values=Pod*" --output text --profile devexperience-prod

### Firewall Rules
# The BU team needs to open a firewall request to allow the traffic outbound - não é mais necessário!
# IMPORTANT NOTE: When BU team open this request, always need to mention that the traffic will go through the CSS Egress (CSS firewall rule must be applied).

### Criação dos Endpoints
# Criar o SG para os endpoints
aws ec2 describe-vpcs --no-verify-ssl --query "Vpcs[].[VpcId]" --profile devexperience-prod

# vpc-id = vpc-0fa4692625691ff01
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-0fa4692625691ff01 --profile $profile_aws --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=endpoints-sg},{Key=CostString,Value=1800.BR.134.607500},{Key=AppID,Value=20274},{Key=Environment,Value=prod}]' 

# Adicionar regras para o SG
# GroupId = sg-0368d5266e1124b7d
aws ec2 authorize-security-group-ingress --group-id sg-0368d5266e1124b7d --protocol tcp --port 443 --cidr 10.0.0.0/8 --profile $profile_aws
aws ec2 authorize-security-group-ingress --group-id sg-0368d5266e1124b7d --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile $profile_aws

# Criar VPC Endpoints
# vpc-id = vpc-0fa4692625691ff01
# GroupId = sg-0368d5266e1124b7d
aws ec2 describe-subnets --no-verify-ssl --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" --output text --profile devexperience-prod
# Subnet-ids = subnet-0c5e2a1b7678f962f subnet-025e5a9d81abe9170 subnet-003094d7dae673abc
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0fa4692625691ff01 --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids "sg-0368d5266e1124b7d" --subnet-ids subnet-0c5e2a1b7678f962f subnet-025e5a9d81abe9170 subnet-003094d7dae673abc --profile $profile_aws
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0fa4692625691ff01 --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-0368d5266e1124b7d" --subnet-ids subnet-0c5e2a1b7678f962f subnet-025e5a9d81abe9170 subnet-003094d7dae673abc --profile $profile_aws
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0fa4692625691ff01 --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids "sg-0368d5266e1124b7d" --subnet-ids subnet-0c5e2a1b7678f962f subnet-025e5a9d81abe9170 subnet-003094d7dae673abc --profile $profile_aws
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0fa4692625691ff01 --service-name com.amazonaws.sa-east-1.logs --security-group-ids "sg-0368d5266e1124b7d" --subnet-ids subnet-0c5e2a1b7678f962f subnet-025e5a9d81abe9170 subnet-003094d7dae673abc --profile $profile_aws

# Criar Key
# KeyId = 5de21289-96cb-4a66-a610-b2e25e885d4e
# Arn = arn:aws:kms:sa-east-1:562223391796:key/5de21289-96cb-4a66-a610-b2e25e885d4e

# Criar Policy
aws iam create-policy --policy-name BUPolicyForDevSecOpsPiaaS --policy-document file://BUPolicyForDevSecOpsPiaaS.json --profile $profile_aws
# Arn = arn:aws:iam::562223391796:policy/BUPolicyForDevSecOpsPiaaS

##### ECR Pull Through Cache
aws iam create-service-linked-role --aws-service-name autoscaling.amazonaws.com --profile $profile_aws 
 
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com --profile $profile_aws 
 
aws ecr create-pull-through-cache-rule --ecr-repository-prefix aws-public --upstream-registry-url public.ecr.aws --region sa-east-1 --profile $profile_aws 


# Go to the Pull through cache configuration in the ECR console and then click on "Add Rule".
aws ecr create-pull-through-cache-rule --profile $profile_aws --ecr-repository-prefix "aws-public" --upstream-registry-url "public.ecr.aws"

# Then you go to the Permissions configuration and click on "Generate Statement".
aws ecr describe-registry  --profile $profile_aws --query "[registryId]" --output text
# RegistryId = 562223391796
aws ecr put-registry-policy --policy-text file://registry_policy.json --profile $profile_aws

# Wildcard certificate assign to Serasa CA Root
# Submit a request to the Cloud team to create a Route53 domain (Private Hosted Zone) in your AWS account with the pattern: <env>-<bu>.br.experian.eeca (e.g. sandbox-arch.br.experian.eeca) - não e necessario! 

# Create Route 53 sub domains
# Novo procedimento: https://pages.experian.local/display/GHFO/How+to+create+a+Route53+zone+for+a+subdomain

# Primeiro vamos obter o PRODUCT-ID da automação
aws servicecatalog describe-product --name Route53SubDomain --output text --profile $profile_aws --query "ProductViewSummary.[ProductId,Name]"
# ProductId = prod-tnkdpfmuz7ajq
# Name = Route53SubDomain

# Vamos agora obter o ProvisioningArtifacts Id
aws servicecatalog describe-product --name Route53SubDomain --output text --profile $profile_aws --query "ProvisioningArtifacts[].Id"
# ProvisioningArtifactsId = pa-w5km2xb67iprg

# Por último, vamos obter o Path ID
aws servicecatalog describe-product --name Route53SubDomain --output text --profile $profile_aws --output text --query LaunchPaths[].Id
# LaunchPaths.Id = lpv3-2o7yrkjdgu6vi

# Para listar os parâmetros obrigatórios, usei:
aws servicecatalog describe-provisioning-parameters --product-name Route53SubDomain --provisioning-artifact-id pa-w5km2xb67iprg --path-id lpv3-2o7yrkjdgu6vi --profile $profile_aws

# Por fim, executar o produto Route53SubDomain
# Importante: os passos anteriores são apenas uma verificação 
# e possivel que os passos não sejam necessarios se os parametros
# da automacao nao se alterem  
aws servicecatalog provision-product  --product-name Route53SubDomain  --provisioning-artifact-id pa-w5km2xb67iprg --provisioned-product-name Route53SubDomain-devexperience-prod  --provisioning-parameters file://provision-parameters.json  --profile $profile_aws

# Submit a request to the Middleware team (BR Accounts Only) asking for Wildcard certificate to a Route53 domain set up in your AWS account

# Import the certificate sent by Middleware team to AWS ACM
aws acm import-certificate --certificate fileb://prod-devhub.br.experian.eeca.pem --certificate-chain fileb://prod-devhub.br.experian.eeca-chain.pem --private-key fileb://prod-devhub.br.experian.eeca.key --profile $profile_aws
# CertificateArn = arn:aws:acm:sa-east-1:562223391796:certificate/8143f281-2fac-4fa9-992a-e0bff46a6d22

# Service Catalog Account Onboarding
# Create in the AWS account a S3 bucket do save the Terraform state.
# Step 1: Create a bucket
aws s3api create-bucket --bucket cockpit-devsecops-states-562223391796 --region sa-east-1 --create-bucket-configuration LocationConstraint=sa-east-1 --profile $profile_aws

# Step 2: Enable versioning
aws s3api put-bucket-versioning --bucket cockpit-devsecops-states-562223391796 --versioning-configuration Status=Enabled   --profile $profile_aws

# Step 3: Add tags
aws s3api put-bucket-tagging --bucket cockpit-devsecops-states-562223391796 --tagging 'TagSet=[{Key=CostString,Value=1800.BR.134.607500},{Key=AppID,Value=20274},{Key=Environment,Value=prod}]'  --profile $profile_aws

# Parametros execucao do EKS SERASA 
Automação EKS-SERASA
RITM: RITM3252507
Account: 562223391796
Region: sa-east-1
Cluster Name: devhub-eks-01
Cluster Version: 1.27
Project Name: dev-hub-portal
env: sandbox
ARN do certificado: arn:aws:acm:sa-east-1:562223391796:certificate/8143f281-2fac-4fa9-992a-e0bff46a6d22
aws acm list-certificates --profile $profile_aws --query "CertificateSummaryList[].CertificateArn" --output=text
domain name: prod-devhub.br.experian.eeca
aws acm list-certificates --profile $profile_aws --query "CertificateSummaryList[].DomainName" --output=text
TF State Name: devexperience-prod-tfstate
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
Subnet Id: subnet-0c5e2a1b7678f962f,subnet-025e5a9d81abe9170,subnet-003094d7dae673abc
aws ec2 describe-subnets --no-verify-ssl --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" --output text --profile devexperience-prod
Resource Business Unit: EITS
Resource name: devhub-eks-instance
Resource owner: devhub_team@br.experian.com
App Id: 20274
Cost Center: 1800.BR.134.607500
EFS enabled: true
Kubeconfig enabled: true

aws eks delete-nodegroup --cluster-name devhub-eks-01-prod --nodegroup-name node_group_on_demand_infra-20240105133656325300000014 --profile $profile_aws

aws eks delete-nodegroup --cluster-name devhub-eks-01-prod --nodegroup-name node_group_on_demand_infra-20240105141455392800000001 --profile $profile_aws

aws eks create-nodegroup --cluster-name devhub-eks-01-prod --nodegroup-name node_group_on_demand_infra-20240105150801704000000003 --scaling-config minSize=1,maxSize=2,desiredSize=2 --profile $profile_aws --subnets subnet-0c5e2a1b7678f962f subnet-025e5a9d81abe9170 subnet-003094d7dae673abc --node-role arn:aws:iam::562223391796:role/BURoleForEksNdevhub-eks-01-prod-20240105132759338500000009 --ami-type ami-04db060b2867828bd

aws eks delete-nodegroup --cluster-name devhub-eks-01-prod --nodegroup-name node_group_on_demand_infra-20240105150801704000000001 --profile $profile_aws

aws eks delete-nodegroup --cluster-name devhub-eks-01-prod --nodegroup-name node_group_on_demand_infra-20240105150801704000000002 --profile $profile_aws

aws eks delete-cluster --name devhub-eks-01-prod --profile $profile_aws

aws iam list-policies --query 'Policies[?PolicyName==`BUPolicyForEksNodes-devhub-eks-01-prod`].Arn' --output text --profile $profile_aws

aws iam delete-policy --policy-arn arn:aws:iam::562223391796:policy/BUPolicyForEksNodes-devhub-eks-01-prod --profile $profile_aws

aws logs delete-log-group --log-group-name /aws/eks/devhub-eks-01-prod/cluster --profile $profile_aws
