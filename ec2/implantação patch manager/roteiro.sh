corporateprod
architecture-sandbox
ssrmdev
ssrmsandbox
ssrmprod
corporatedev
sredev
dsstage
dsprod
dsdev
datahubprod
datahubdev

# Fazer logon na conta
.\saml2aws.exe login -a eec-aws-br-eits-devexperience-dev

##################
### Configuração do Systems Manager
##################


# Criar a função IAM:
aws iam create-role --role-name BURoleForSSM-Instance-Role --assume-role-policy-document file://BURoleforSSM.json --profile devexperience-dev

# ===> Este comando cria uma função chamada "SSM-Instance-Role" que pode ser assumida por instâncias EC2.

# Anexar a política do Systems Manager à função:
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile devexperience-dev
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy  --profile devexperience-dev
# ===> Este comando anexa a política do Systems Manager à função para conceder permissões de gerenciamento básicas.

# Criar um perfil IAM para as instâncias EC2:
aws iam create-instance-profile --instance-profile-name SSM-Instance-Profile  --profile devexperience-dev

# Adicionar a função à instância do perfil IAM:
aws iam add-role-to-instance-profile --instance-profile-name SSM-Instance-Profile --role-name BURoleForSSM-Instance-Role   --profile devexperience-dev

# Criar uma chave
aws ec2 create-key-pair --key-name bastion-devexperience-dev --key-type rsa --key-format pem --query "KeyMaterial" --profile devexperience-dev --output text > bastion-devexperience-dev.pem

# Listar VPC
aws ec2 describe-vpcs  --profile devexperience-dev --query  "Vpcs[].[VpcId]" --output text

# Criar Security Group para o Bastion
# ===> vpc-id = vpc-0b489cbdfc54b8660
# ===> CostString = 1800.BR.134.607500
# ===> AppID = 20274
# ===> Environment = dev
aws ec2 create-security-group --group-name SG-Bastion --description "SG para acesso ao bastion" --vpc-id vpc-0b489cbdfc54b8660 --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=SG-Bastion},{Key=CostString,Value=1800.BR.134.607500},{Key=AppID,Value=20274},{Key=Environment,Value=dev}]' --profile devexperience-dev

# Lembrar de atualizar o SG id no comando a seguir
# ===> GroupId = sg-0b0d5cdbeb86089b3
aws ec2 authorize-security-group-ingress --group-id sg-0b0d5cdbeb86089b3 --protocol tcp --port 22 --cidr 10.0.0.0/8 --profile devexperience-dev

# Listar subnets
aws ec2 describe-subnets  --profile devexperience-dev --output text --query "Subnets[].[SubnetId,Tags[?Key=='Name']]" --filters "Name=tag:Name,Values=aws*"

# Lançar ou atualizar instâncias EC2 associadas ao perfil IAM:
# lembrar de pegar um subnet id e security group ID
# ===> subnet-id = subnet-0dc04c64ee229f6b0
# ===> GroupId = sg-0b0d5cdbeb86089b3
aws ec2 run-instances --image-id ami-0e2c5604ae8bb1c54 --subnet-id subnet-0dc04c64ee229f6b0 --security-group-ids sg-0b0d5cdbeb86089b3 --key-name bastion-devexperience-dev --instance-type t3.micro --iam-instance-profile Name=SSM-Instance-Profile --profile devexperience-dev --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bastion-devexperience-dev},{Key=CostString,Value=1800.BR.134.607500},{Key=AppID,Value=20274},{Key=Environment,Value=dev},{Key=CentrifyUnixRole,Value=0},{Key=ResourceName,Value=bastion-devexperience-dev},{Key=ResourceAppRole,Value=app},{Key=ResourceOwner,Value=devhub_team@br.experian.com},{Key=adDomain,Value=br.experian.local},{Key=adGroup,Value=0}]' --profile devexperience-dev 

# Testar logon na instância
# ===> target = i-0bdbce87cd4533706
aws ssm start-session --target i-0bdbce87cd4533706 --profile devexperience-dev 

#### AWS Backup
# Create a backup vault by running:
aws backup create-backup-vault --backup-vault-name backup-vault-devexperience-dev --profile devexperience-dev

# Create a backup plan by running 
# Ajustar arquivo JSON com:
# ===> backup-vault-name = backup-vault-devexperience-dev
aws backup create-backup-plan --cli-input-json file://backup-plan.json --profile devexperience-dev

# Create a backup selection by running:
# Ajustar arquivo JSON com:
# ===> BackupPlanId = e8ee9e97-10cd-4145-9e71-08a65d1ed928
# ===> IamRoleArn = arn:aws:iam::015334905722:role/aws-service-role/backup.amazonaws.com/AWSServiceRoleForBackup
aws iam list-roles --query 'Roles[?RoleName==`AWSServiceRoleForBackup`].Arn' --output text --profile devexperience-dev

aws backup create-backup-selection --cli-input-json file://backup-selection.json  --profile devexperience-dev
aws ec2 create-tags --resources i-0bdbce87cd4533706 --tags Key=Backup,Value='True' --profile devexperience-dev


#####
### Systems Manager
#####
#### Configuração para atualização de patches
# Criar Role para atualização de patches
aws iam create-role --role-name BURoleForDevHubSSMMaintenanceWindow --assume-role-policy-document file://assumerole_BURoleForDevHubSSMMaintenanceWindow.json  --profile devexperience-dev

aws iam create-policy --policy-name BUPolicyForDevHubSSMMaintenanceWindow --policy-document file://BUPolicyForDevHubSSMMaintenanceWindow.json  --profile devexperience-dev

# ===>  policy-arn = arn:aws:iam::015334905722:policy/BUPolicyForDevHubSSMMaintenanceWindow
aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::015334905722:policy/BUPolicyForDevHubSSMMaintenanceWindow  --profile devexperience-dev

# Criar o Patch Baseline
aws ssm create-patch-baseline --name "Baseline_AMZLinux2" --operating-system "AMAZON_LINUX_2" --approval-rules "PatchRules=[{PatchFilterGroup={PatchFilters=[{Key=PRODUCT,Values=[AmazonLinux2,AmazonLinux2.0]},{Key=CLASSIFICATION,Values=[Bugfix,Enhancement,Newpackage,Recommended,Security]},{Key=SEVERITY,Values=[Critical,Important,Medium]}]},ApproveAfterDays=7}]" --profile devexperience-dev
# lembrar de atualizar o baseline ID
# ===>  baseline-id = pb-0225c031aee5625cb
aws ssm update-patch-baseline --baseline-id pb-0225c031aee5625cb   --approved-patches-enable-non-security --approval-rules "PatchRules=[{PatchFilterGroup={PatchFilters=[{Key=PRODUCT,Values=[AmazonLinux2,AmazonLinux2.0]},{Key=CLASSIFICATION,Values=[Bugfix,Enhancement,Newpackage,Recommended,Security]},{Key=SEVERITY,Values=[Critical,Important,Medium]}]},ApproveAfterDays=7,EnableNonSecurity=true}]" --profile devexperience-dev
aws ssm register-default-patch-baseline --baseline-id pb-0225c031aee5625cb --profile devexperience-dev
aws ssm get-default-patch-baseline --operating-system AMAZON_LINUX_2 --profile devexperience-dev

# Rodar o quick setup para criar a patch policy
# ===> intanceid = i-0bdbce87cd4533706 
aws ec2 create-tags --resources i-0bdbce87cd4533706 --tags Key=PatchGroup,Value='PatchGroup02' --profile devexperience-dev

##########################
#### Terça
##########################
# Criar a janela de manutenção para instalação dos poatches
aws ssm create-maintenance-window --name "Patches-Terca" --schedule "cron(0 22 ? * TUE *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devexperience-dev

# ===> window-id = mw-047033bc9f983388d
aws ssm register-target-with-maintenance-window --window-id mw-047033bc9f983388d --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira " --profile devexperience-dev

# ===> window-id = mw-047033bc9f983388d
# ===> WindowTargetIds = 1506e49e-870b-4ea0-a66b-968ffb3abc54
# ===> service-role-arn = arn:aws:iam::015334905722:role/BURoleForDevHubSSMMaintenanceWindow
aws ssm register-task-with-maintenance-window --window-id mw-047033bc9f983388d  --targets "Key=WindowTargetIds,Values=1506e49e-870b-4ea0-a66b-968ffb3abc54" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::015334905722:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devexperience-dev

##########################
#### Quarta
##########################
# Criar a janela de manutenção para instalação dos poatches
aws ssm create-maintenance-window --name "Patches-Quarta" --schedule "cron(0 22 ? * WED *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devexperience-dev

# ===> window-id = mw-00c92473065702f75
aws ssm register-target-with-maintenance-window --window-id "mw-00c92473065702f75" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira" --profile devexperience-dev

# ===> window-id = mw-00c92473065702f75
# ===> WindowTargetIds = 479af075-3946-4fcc-9874-d4b29ce28712
# ===> service-role-arn = arn:aws:iam::015334905722:role/BURoleForDevHubSSMMaintenanceWindow
aws ssm register-task-with-maintenance-window --window-id "mw-00c92473065702f75" --targets "Key=WindowTargetIds,Values=479af075-3946-4fcc-9874-d4b29ce28712" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::015334905722:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devexperience-dev

##########################
#### Quinta
##########################
# Criar a janela de manutenção para instalação dos poatches
aws ssm create-maintenance-window --name "Patches-Quinta" --schedule "cron(0 22 ? * THU *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devexperience-dev


# ===> window-id = mw-099e0e0cc39b3e874
aws ssm register-target-with-maintenance-window --window-id "mw-099e0e0cc39b3e874" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira" --profile devexperience-dev

# ===> window-id = mw-099e0e0cc39b3e874
# ===> WindowTargetIds = 597edc25-2624-4bc2-abe5-55cf5be225d1
# ===> service-role-arn = arn:aws:iam::015334905722:role/BURoleForDevHubSSMMaintenanceWindow
aws ssm register-task-with-maintenance-window --window-id "mw-099e0e0cc39b3e874" --targets "Key=WindowTargetIds,Values=597edc25-2624-4bc2-abe5-55cf5be225d1" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::015334905722:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devexperience-dev

##############
# Onboarding da conta
##############

# Execução do CloudFormation
aws cloudformation deploy --template-file AssumeRole.yml --stack-name ServiceCatalog --capabilities CAPABILITY_NAMED_IAM --profile devexperience-dev

# Criar Chave
aws kms create-key --description "Onboarding-test-key" --region sa-east-1 --profile devexperience-dev 
# arn:aws:kms:sa-east-1:015334905722:key/99b15095-7c9e-4a21-9c64-c1d4d4abd6ba

############################## 
#####  Passo 02 - executar no Cockpit - aws-onboarding-new-account
##############################
# NEW_AWS_ACCOUNT_ID: 015334905722
# DOMAIN: .serasa.intranet
# AWS_REGION: sa-east1
# ENV: dev
# TRIBE: devhub
# VPC_ID: 
aws ec2 describe-vpcs  --profile devexperience-dev --query  "Vpcs[].[VpcId]" --output text
vpc-0b489cbdfc54b8660
# Subnets:
aws ec2 describe-subnets  --profile devexperience-dev --output text --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" 
subnet-0dc04c64ee229f6b0
subnet-0887aefa104138058
subnet-01c74aba35bb72c5d
# KMS: 99b15095-7c9e-4a21-9c64-c1d4d4abd6ba

############################## 
#####  Passo 03 - executar no Cockpit - aws-onboarding-test
##############################
# NEW_AWS_ACCOUNT_ID: 015334905722
# app_id: devhub
# OPTION: none
# CostString = 1800.BR.134.607500
# AppID = 20274
# First, list all attached policies
aws iam list-attached-role-policies --role-name BURoleForaws-onboarding-devhub --profile devexperience-dev 

# Then, detach each policy
aws iam detach-role-policy --role-name BURoleForaws-onboarding-devhub --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess --profile devexperience-dev
aws iam detach-role-policy --role-name BURoleForaws-onboarding-devhub --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess --profile devexperience-dev
aws iam detach-role-policy --role-name BURoleForaws-onboarding-devhub --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess --profile devexperience-dev

# list instance profile
aws iam list-instance-profiles-for-role --role-name BURoleForaws-onboarding-devhub --profile devexperience-dev --query "InstanceProfiles[].InstanceProfileName" --output text

# desanexar o instance profile da role
aws iam remove-role-from-instance-profile --instance-profile-name BURoleForaws-onboarding-devhub --role-name BURoleForaws-onboarding-devhub --profile devexperience-dev

# Finally, delete the role
aws iam delete-role --role-name BURoleForaws-onboarding-devhub --profile devexperience-dev 

aws iam delete-instance-profile --instance-profile-name BURoleForaws-onboarding-devhub --profile devexperience-dev


#################
# Pre-reqs EKS
################
### AWS Secondary IP Address
# If your account does not have a secondary IP range, please submit a request to the Cloud Team to add a secondary Subnet/IP Range (100.64.0.0/16) to your VPC with 3 AZs.
aws ec2 describe-vpcs --query "Vpcs[].CidrBlockAssociationSet[*]" --profile devexperience-dev

# Validate if your VPC is tagged with "AWS_Solutions = LandingZoneStackSet", your Experian IP range subnets with "Network = Private" and the Pod IP range (100.64.0.0/16) subnets with "Network = Pod".

aws ec2 describe-subnets --query "Subnets[].[CidrBlock,Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Name,Values=aws*" --output text --profile devexperience-dev

aws ec2 describe-subnets --query "Subnets[].[CidrBlock,Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --filters "Name=tag:Name,Values=Pod*" --output text --profile devexperience-dev

### Firewall Rules
# The BU team needs to open a firewall request to allow the traffic outbound - não é mais necessário!
# IMPORTANT NOTE: When BU team open this request, always need to mention that the traffic will go through the CSS Egress (CSS firewall rule must be applied).

### Criação dos Endpoints
# Criar o SG para os endpoints
aws ec2 describe-vpcs --query "Vpcs[].[VpcId]" --profile devexperience-dev

# vpc-id = vpc-0b489cbdfc54b8660
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-0b489cbdfc54b8660 --profile devexperience-dev --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=endpoints-sg},{Key=CostString,Value=1800.BR.134.607500},{Key=AppID,Value=20274},{Key=Environment,Value=dev}]' 

# Adicionar regras para o SG
# GroupId = sg-04979de565213319c
aws ec2 authorize-security-group-ingress --group-id sg-04979de565213319c --protocol tcp --port 443 --cidr 10.0.0.0/8 --profile devexperience-dev
aws ec2 authorize-security-group-ingress --group-id sg-04979de565213319c --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile devexperience-dev

# Criar VPC Endpoints
# vpc-id = vpc-0b489cbdfc54b8660
# GroupId = sg-04979de565213319c
aws ec2 describe-subnets --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" --output text --profile devexperience-dev
# Subnet-ids = subnet-0dc04c64ee229f6b0 subnet-0887aefa104138058 subnet-01c74aba35bb72c5d
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0b489cbdfc54b8660 --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids "sg-04979de565213319c" --subnet-ids subnet-0dc04c64ee229f6b0 subnet-0887aefa104138058 subnet-01c74aba35bb72c5d --profile devexperience-dev
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0b489cbdfc54b8660 --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-04979de565213319c" --subnet-ids subnet-0dc04c64ee229f6b0 subnet-0887aefa104138058 subnet-01c74aba35bb72c5d --profile devexperience-dev
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0b489cbdfc54b8660 --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids "sg-04979de565213319c" --subnet-ids subnet-0dc04c64ee229f6b0 subnet-0887aefa104138058 subnet-01c74aba35bb72c5d --profile devexperience-dev
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0b489cbdfc54b8660 --service-name com.amazonaws.sa-east-1.logs --security-group-ids "sg-04979de565213319c" --subnet-ids subnet-0dc04c64ee229f6b0 subnet-0887aefa104138058 subnet-01c74aba35bb72c5d --profile devexperience-dev


# Criar Key
aws kms create-key --description "Chave para onboarding da conta" --profile devexperience-dev
# KeyId = c2d412c1-64e9-4fcd-85a7-05d1b9155025
# Arn = arn:aws:kms:sa-east-1:015334905722:key/c2d412c1-64e9-4fcd-85a7-05d1b9155025

# Criar Policy
aws iam create-policy --policy-name BUPolicyForDevSecOpsPiaaS --policy-document file://BUPolicyForDevSecOpsPiaaS.json --profile devexperience-dev
# Arn = arn:aws:iam::015334905722:policy/BUPolicyForDevSecOpsPiaaS

aws iam create-service-linked-role --aws-service-name autoscaling.amazonaws.com --profile devexperience-dev 
 
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com --profile devexperience-dev 

##### ECR Pull Through Cache
# Go to the Pull through cache configuration in the ECR console and then click on "Add Rule".
aws ecr create-pull-through-cache-rule --ecr-repository-prefix aws-public --upstream-registry-url public.ecr.aws --region sa-east-1 --profile devexperience-dev 


# Then you go to the Permissions configuration and click on "Generate Statement".
aws ecr describe-registry  --profile devexperience-dev --query "[registryId]" --output text
# RegistryId = 015334905722
aws ecr put-registry-policy --policy-text file://registry_policy.json --profile devexperience-dev

# Wildcard certificate assign to Serasa CA Root
# Submit a request to the Cloud team to create a Route53 domain (Private Hosted Zone) in your AWS account with the pattern: <env>-<bu>.br.experian.eeca (e.g. sandbox-arch.br.experian.eeca) - não e necessario! 

# Create Route 53 sub domains
# Novo procedimento: https://pages.experian.local/display/GHFO/How+to+create+a+Route53+zone+for+a+subdomain

# Primeiro vamos obter o PRODUCT-ID da automação
aws servicecatalog describe-product --name Route53SubDomain --output text --profile devexperience-dev --query "ProductViewSummary.[ProductId,Name]"
# ProductId = prod-tnkdpfmuz7ajq
# Name = Route53SubDomain

# Vamos agora obter o ProvisioningArtifacts Id
aws servicecatalog describe-product --name Route53SubDomain --output text --profile devexperience-dev --query "ProvisioningArtifacts[].Id"
# ProvisioningArtifactsId = pa-w5km2xb67iprg

# Por último, vamos obter o Path ID
aws servicecatalog describe-product --name Route53SubDomain --output text --profile devexperience-dev --output text --query LaunchPaths[].Id
# LaunchPaths.Id = lpv3-2o7yrkjdgu6vi

# Para listar os parâmetros obrigatórios, usei:
aws servicecatalog describe-provisioning-parameters --product-name Route53SubDomain --provisioning-artifact-id pa-w5km2xb67iprg --path-id lpv3-2o7yrkjdgu6vi --profile devexperience-dev

# Por fim, executar o produto Route53SubDomain
# Importante: os passos anteriores são apenas uma verificação 
# e possivel que os passos não sejam necessarios se os parametros
# da automacao nao se alterem  
aws servicecatalog provision-product  --product-name Route53SubDomain  --provisioning-artifact-id pa-w5km2xb67iprg --provisioned-product-name Route53SubDomain-devexperience-dev  --provisioning-parameters file://provision-parameters.json  --profile devexperience-dev

# Submit a request to the Middleware team (BR Accounts Only) asking for Wildcard certificate to a Route53 domain set up in your AWS account

# Import the certificate sent by Middleware team to AWS ACM
aws acm import-certificate --certificate fileb://dev-devhub.br.experian.eeca.pem --certificate-chain fileb://dev-devhub.br.experian.eeca-chain.pem --private-key fileb://dev-devhub.br.experian.eeca.key --profile devexperience-dev
# CertificateArn = arn:aws:acm:sa-east-1:015334905722:certificate/780c8d56-b946-47c0-ab37-5da270d76126

# Service Catalog Account Onboarding
# Create in the AWS account a S3 bucket do save the Terraform state.
# Step 1: Create a bucket
aws s3api create-bucket --bucket devexperience-dev-tfstate --region sa-east-1 --create-bucket-configuration LocationConstraint=sa-east-1 --profile devexperience-dev

# Step 2: Enable versioning
aws s3api put-bucket-versioning --bucket devexperience-dev-tfstate --versioning-configuration Status=Enabled   --profile devexperience-dev

# Step 3: Add tags
aws s3api put-bucket-tagging --bucket devexperience-dev-tfstate --tagging 'TagSet=[{Key=CostString,Value=1800.BR.134.607500},{Key=AppID,Value=20274},{Key=Environment,Value=dev}]'  --profile devexperience-dev

# Parametros execucao do EKS SERASA 
Automação EKS-SERASA
RITM: RITM3256417
Account: 015334905722
Region: sa-east-1
Cluster Name: devhub-eks-01
Cluster Version: 1.27
Project Name: dev-hub-portal
env: dev
ARN do certificado: arn:aws:acm:sa-east-1:015334905722:certificate/780c8d56-b946-47c0-ab37-5da270d76126
domain name: dev-devhub.br.experian.eeca
TF State Name: devexperience-dev-tfstate
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
Subnet Id: aws ec2 describe-subnets --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" --output text --profile devhub-dev
subnet-0887aefa104138058,subnet-0dc04c64ee229f6b0,subnet-01c74aba35bb72c5d

Resource Business Unit: EITS
Resource name: devhub-eks-instance
Resource owner: devhub_team@br.experian.com
App Id: 20274
Cost Center: 1800.BR.134.607500
EFS enabled: true
Kubeconfig enabled: true

# Provisionamento RDS
Account: 015334905722
Country: BR
BU: EITS Enterprise
Environment: dev
App Id: 20274
Cost Center: 1800.BR.134.607500
Category_new: Productive Data
Data type: N/A
Category_data: Registry
tag_schedule: utilizar_horario_comercial
engine: postgres 15
db_instance_type: db.m5.large
allocated_storage: 100
Iops: 1000
dbname: devhub01
admin_user: dbadm
admin_password: 94cxP*E9Z
Project Name: dev-hub-portal


# Step 1: Create a bucket
aws s3api create-bucket --bucket devex-devhubportal-dev --region sa-east-1 --create-bucket-configuration LocationConstraint=sa-east-1 --profile devexperience-dev

# Step 2: Enable versioning
aws s3api put-bucket-versioning --bucket devex-devhubportal-dev --versioning-configuration Status=Enabled   --profile devexperience-dev

# Step 3: Add tags
aws s3api put-bucket-tagging --bucket devex-devhubportal-dev --tagging 'TagSet=[{Key=CostString,Value=1800.BR.134.607500},{Key=AppID,Value=20274},{Key=Environment,Value=dev}]'  --profile devexperience-dev



aws ecr create-repository --repository-name dev-hub-portal --image-tag-mutability MUTABLE --image-scanning-configuration scanOnPush=true --encryption-configuration encryptionType=AES256 --profile devexperience-dev

aws eks update-kubeconfig --region sa-east-1 --name devhub-eks-01-dev --profile devexperience-dev

kubectl create -f dev-hub-bitbucket-secrets.yaml
kubectl create -f dev-hub-secrets.yaml


# Configuração da Service Account
# Criação da policy
aws iam create-policy --policy-name BUPolicyForDevHubPortalUser --policy-document file://BUPolicyForDevHubPortalUser.json  --profile devexperience-dev

# Criação da role
aws iam create-role --role-name BURoleForDevHubPortalUser --assume-role-policy-document file://trust-policy.json --profile devexperience-dev

# Atachar policy a role
aws iam attach-role-policy --role-name BURoleForDevHubPortalUser --policy-arn "arn:aws:iam::015334905722:policy/BUPolicyForDevHubPortalUser" --profile devexperience-dev
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role  --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess" --profile devexperience-dev

# adicionar no annotation da Service Account dev-hub-portal no Kubernetes
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::015334905722:role/BURoleForDevHubPortalUser

# incluir o service account no deployment do dev-hub-portal
spec:
  spec:
    serviceAccountName: dev-hub-portal-user
    container: xxxx

# Listar o OIDC do cluster
aws eks describe-cluster --name devhub-eks-01-dev --profile devexperience-dev --query "cluster.identity.oidc.issuer"
"https://oidc.eks.sa-east-1.amazonaws.com/id/DD12068C8784749801AE097A1A7A9C7A"

# Criar o OIDC provider no IAM
aws iam create-open-id-connect-provider --url https://oidc.eks.sa-east-1.amazonaws.com/id/DD12068C8784749801AE097A1A7A9C7A --client-id-list sts.amazonaws.com --thumbprint-list 281b5466a69d7149559a016d8474150a84d9330f --profile devexperience-dev
{
    "OpenIDConnectProviderArn": "arn:aws:iam::015334905722:oidc-provider/oidc.eks.sa-east-1.amazonaws.com/id/DD12068C8784749801AE097A1A7A9C7A"
}

# Alterar o trust relationship da role BURoleForDevHubPortalUser 
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::015334905722:oidc-provider/oidc.eks.sa-east-1.amazonaws.com/id/DD12068C8784749801AE097A1A7A9C7A"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.sa-east-1.amazonaws.com/id/DD12068C8784749801AE097A1A7A9C7A:sub": "system:serviceaccount:dev-hub-portal-dev:dev-hub-portal"
        }
      }
    }
  ]
}


aws iam update-assume-role-policy --role-name BURoleForDevHubPortalUser --policy-document file://trust-policy2.json --profile devexperience-dev

aws iam create-policy-version --policy-arn "arn:aws:iam::015334905722:policy/BUPolicyForDevHubPortalUser" --profile devexperience-dev --policy-document file://BUPolicyForDevHubPortalUser2.json  --set-as-default
