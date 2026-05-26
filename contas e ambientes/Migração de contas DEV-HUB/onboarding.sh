# Logar na conta
.\saml2aws.exe login -a eec-aws-br-eits-dx-lab01-sandbox

# Listar as VPCs
aws ec2 describe-vpcs --profile lab01 --no-verify-ssl --query "Vpcs[].{name:Tags[?Key==`Name`].Value[],ID:VpcId}" --output table
aws ec2 describe-subnets --profile lab01 --no-verify-ssl --query "Subnets[].{Name:Tags[?Key==`Name`].Value[],ID:SubnetId}" --output text

# Criar o SG para os endpoints
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-085f31990074f17ab --profile lab01 --no-verify-ssl

# Adicionar regras para o SG
aws ec2 authorize-security-group-ingress --group-id sg-00232e594d9d496a1 --protocol tcp --port 80 --cidr 10.0.0.0/8 --profile lab01 --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-00232e594d9d496a1 --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile lab01 --no-verify-ssl

# Criar VPC Endpoints
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-085f31990074f17ab --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids "sg-00232e594d9d496a1" --subnet-ids "subnet-09b31519466ea770c" "subnet-0cd04680da6d95113" "subnet-04756c2417c30202e" --profile lab01 --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-085f31990074f17ab --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-00232e594d9d496a1" --subnet-ids "subnet-09b31519466ea770c" "subnet-0cd04680da6d95113" "subnet-04756c2417c30202e" --profile lab01 --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-085f31990074f17ab --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids "sg-00232e594d9d496a1" --subnet-ids "subnet-09b31519466ea770c" "subnet-0cd04680da6d95113" "subnet-04756c2417c30202e" --profile lab01 --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-085f31990074f17ab --service-name com.amazonaws.sa-east-1.logs --security-group-ids "sg-00232e594d9d496a1" --subnet-ids "subnet-09b31519466ea770c" "subnet-0cd04680da6d95113" "subnet-04756c2417c30202e" --profile lab01 --no-verify-ssl

# Criar bucket
aws s3api create-bucket --bucket tfstate-lab01 --acl private --region sa-east-1 --profile lab01 --no-verify-ssl

# Criar Key
aws kms create-key --description "Chave para onboarding da conta" --profile lab01 --no-verify-ssl

# Criar Policy
aws iam create-policy --policy-name BUPolicyForDevSecOpsPiaaS --policy-document file://BUPolicyForDevSecOpsPiaaS.json --profile lab01 --no-verify-ssl

# Pre-requisite:

aws iam create-service-linked-role --aws-service-name autoscaling.amazonaws.com --profile lab01 --no-verify-ssl

aws iam create-service-linked-role --aws-service-name spot.amazonaws.com --profile lab01 --no-verify-ssl

aws ecr create-pull-through-cache-rule --ecr-repository-prefix ecr-public --upstream-registry-url public.ecr.aws --region sa-east-1 --profile lab01 --no-verify-ssl

#########################################################
# Logar na conta lab02
.\saml2aws.exe login -a eec-aws-br-eits-dx-lab02-sandbox

# Listar as VPCs
aws ec2 describe-vpcs --profile lab02 --no-verify-ssl --query "Vpcs[].{name:Tags[?Key=='Name'].Value[],ID:VpcId}" --output text
aws ec2 describe-subnets --profile lab02 --no-verify-ssl --query "Subnets[].{Name:Tags[?Key=='Name'].Value[],ID:SubnetId}" --output text

# Criar o SG para os endpoints
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-0f5fd0d8503472173 --profile lab02 --no-verify-ssl

# Adicionar regras para o SG
aws ec2 authorize-security-group-ingress --group-id sg-0d7759cfe8f121988 --protocol tcp --port 80 --cidr 10.0.0.0/8 --profile lab02 --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-0d7759cfe8f121988 --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile lab02 --no-verify-ssl

# Criar VPC Endpoints
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0f5fd0d8503472173 --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids "sg-0d7759cfe8f121988" --subnet-ids "subnet-00e22ce0c648923eb" "subnet-0fdca253e603c9798" "subnet-0549950821842305c" --profile lab02 --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0f5fd0d8503472173 --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-0d7759cfe8f121988" --subnet-ids "subnet-00e22ce0c648923eb" "subnet-0fdca253e603c9798" "subnet-0549950821842305c" --profile lab02 --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0f5fd0d8503472173 --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids "sg-0d7759cfe8f121988" --subnet-ids "subnet-00e22ce0c648923eb" "subnet-0fdca253e603c9798" "subnet-0549950821842305c" --profile lab02 --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0f5fd0d8503472173 --service-name com.amazonaws.sa-east-1.logs --security-group-ids "sg-0d7759cfe8f121988" --subnet-ids "subnet-00e22ce0c648923eb" "subnet-0fdca253e603c9798" "subnet-0549950821842305c" --profile lab02 --no-verify-ssl

# Criar bucket
aws s3api create-bucket --bucket tfstate-lab02 --acl private --region sa-east-1 --profile lab02 --no-verify-ssl

# Criar Key
aws kms create-key --description "Chave para onboarding da conta" --profile lab02 --no-verify-ssl

# Criar Policy
aws iam create-policy --policy-name BUPolicyForDevSecOpsPiaaS --policy-document file://BUPolicyForDevSecOpsPiaaS.json --profile lab02 --no-verify-ssl

#########################################################
# Logar na conta lab03
.\saml2aws.exe login -a eec-aws-br-eits-dx-lab03-sandbox

# Listar as VPCs
aws ec2 describe-vpcs --profile lab03 --no-verify-ssl --query "Vpcs[].{name:Tags[?Key=='Name'].Value[],ID:VpcId}" --output text
aws ec2 describe-subnets --profile lab03 --no-verify-ssl --query "Subnets[].{Name:Tags[?Key=='Name'].Value[],ID:SubnetId}" --output text

aws ec2 describe-vpcs --profile lab03 --no-verify-ssl --query "Vpcs[].VpcId" --output text
aws ec2 describe-subnets --profile lab03 --no-verify-ssl --query "Subnets[].SubnetId" --output text --filters "Name=tag:Name,Values=*Private*"

# Criar o SG para os endpoints
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-0a579a62f2bffd564 --profile lab03 --no-verify-ssl

# Adicionar regras para o SG
aws ec2 authorize-security-group-ingress --group-id sg-0b1785874b584f649 --protocol tcp --port 80 --cidr 10.0.0.0/8 --profile lab03 --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-0b1785874b584f649 --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile lab03 --no-verify-ssl

# Criar VPC Endpoints
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0a579a62f2bffd564 --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids "sg-0b1785874b584f649" --subnet-ids "subnet-08ad98b61504a4dea" "subnet-00baf326089e17536" "subnet-053c7b2ba2b7e53e7" --profile lab03 --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0a579a62f2bffd564 --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-0b1785874b584f649" --subnet-ids "subnet-08ad98b61504a4dea" "subnet-00baf326089e17536" "subnet-053c7b2ba2b7e53e7" --profile lab03 --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0a579a62f2bffd564 --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids "sg-0b1785874b584f649" --subnet-ids "subnet-08ad98b61504a4dea" "subnet-00baf326089e17536" "subnet-053c7b2ba2b7e53e7" --profile lab03 --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0a579a62f2bffd564 --service-name com.amazonaws.sa-east-1.logs --security-group-ids "sg-0b1785874b584f649" --subnet-ids "subnet-08ad98b61504a4dea" "subnet-00baf326089e17536" "subnet-053c7b2ba2b7e53e7" --profile lab03 --no-verify-ssl

# Criar bucket
aws s3api create-bucket --bucket tfstate-lab03 --acl private --region sa-east-1 --profile lab03 --no-verify-ssl

# Criar Key
aws kms create-key --description "Chave para onboarding da conta" --profile lab03 --no-verify-ssl

# Criar Policy
aws iam create-policy --policy-name BUPolicyForDevSecOpsPiaaS --policy-document file://BUPolicyForDevSecOpsPiaaS.json --profile lab03 --no-verify-ssl

#########################################################
# Logar na conta lab04
.\saml2aws.exe login -a eec-aws-br-eits-dx-lab04-sandbox

# Listar as VPCs
aws ec2 describe-vpcs --profile lab04 --no-verify-ssl --query "Vpcs[].{name:Tags[?Key=='Name'].Value[],ID:VpcId}" --output text
aws ec2 describe-subnets --profile lab04 --no-verify-ssl --query "Subnets[].{Name:Tags[?Key=='Name'].Value[],ID:SubnetId}" --output text

aws ec2 describe-vpcs --profile lab04 --no-verify-ssl --query "Vpcs[].VpcId" --output text
aws ec2 describe-subnets --profile lab04 --no-verify-ssl --query "Subnets[].SubnetId" --output text --filters "Name=tag:Name,Values=*Private*"

# Criar o SG para os endpoints
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-0dcbd6183f039b944 --profile lab04 --no-verify-ssl

# Adicionar regras para o SG
aws ec2 authorize-security-group-ingress --group-id sg-036cd3e559314bb58 --protocol tcp --port 80 --cidr 10.0.0.0/8 --profile lab04 --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-036cd3e559314bb58 --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile lab04 --no-verify-ssl

# Criar VPC Endpoints
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0dcbd6183f039b944 --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids "sg-036cd3e559314bb58" --subnet-ids "subnet-03017c19ea1fc0bed" "subnet-065f78c71e0fb9f6c" "subnet-0b24430d6606272f4" --profile lab04 --no-verify-ssl --output text
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0dcbd6183f039b944 --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-036cd3e559314bb58" --subnet-ids "subnet-03017c19ea1fc0bed" "subnet-065f78c71e0fb9f6c" "subnet-0b24430d6606272f4" --profile lab04 --no-verify-ssl --output text
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0dcbd6183f039b944 --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids "sg-036cd3e559314bb58" --subnet-ids "subnet-03017c19ea1fc0bed" "subnet-065f78c71e0fb9f6c" "subnet-0b24430d6606272f4" --profile lab04 --no-verify-ssl --output text
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0dcbd6183f039b944 --service-name com.amazonaws.sa-east-1.logs --security-group-ids "sg-036cd3e559314bb58" --subnet-ids "subnet-03017c19ea1fc0bed" "subnet-065f78c71e0fb9f6c" "subnet-0b24430d6606272f4" --profile lab04 --no-verify-ssl --output text


# Criar bucket
aws s3api create-bucket --bucket tfstate-lab04 --acl private --region sa-east-1 --profile lab04 --no-verify-ssl

# Criar Key
aws kms create-key --description "Chave para onboarding da conta" --profile lab04 --no-verify-ssl

# Criar Policy
aws iam create-policy --policy-name BUPolicyForDevSecOpsPiaaS --policy-document file://BUPolicyForDevSecOpsPiaaS.json --profile lab04 --no-verify-ssl

#########################################################
# Logar na conta lab05
.\saml2aws.exe login -a eec-aws-br-eits-dx-lab05-sandbox

# Listar as VPCs
aws ec2 describe-vpcs --profile lab05 --no-verify-ssl --query "Vpcs[].{name:Tags[?Key=='Name'].Value[],ID:VpcId}" --output text
aws ec2 describe-subnets --profile lab05 --no-verify-ssl --query "Subnets[].{Name:Tags[?Key=='Name'].Value[],ID:SubnetId}" --output text

aws ec2 describe-vpcs --profile lab05 --no-verify-ssl --query "Vpcs[].VpcId" --output text

aws ec2 describe-subnets --profile lab05 --no-verify-ssl --query "Subnets[].SubnetId" --output text --filters "Name=tag:Name,Values=*Private*"


# Criar o SG para os endpoints
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-0d9441e6aae5b8317 --profile lab05 --no-verify-ssl

# Adicionar regras para o SG
aws ec2 authorize-security-group-ingress --group-id sg-0699ca89d0dd17efe --protocol tcp --port 80 --cidr 10.0.0.0/8 --profile lab05 --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-0699ca89d0dd17efe --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile lab05 --no-verify-ssl

# Criar VPC Endpoints
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0d9441e6aae5b8317 --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids "sg-0699ca89d0dd17efe" --subnet-ids "subnet-0a8520f306c314ee0" "subnet-058ebfae0ee95e12e" "subnet-03b1c5508fd41fad3" --profile lab05 --no-verify-ssl --output text
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0d9441e6aae5b8317 --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-0699ca89d0dd17efe" --subnet-ids "subnet-0a8520f306c314ee0" "subnet-058ebfae0ee95e12e" "subnet-03b1c5508fd41fad3" --profile lab05 --no-verify-ssl --output text
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0d9441e6aae5b8317 --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids "sg-0699ca89d0dd17efe" --subnet-ids "subnet-0a8520f306c314ee0" "subnet-058ebfae0ee95e12e" "subnet-03b1c5508fd41fad3" --profile lab05 --no-verify-ssl --output text
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0d9441e6aae5b8317 --service-name com.amazonaws.sa-east-1.logs --security-group-ids "sg-0699ca89d0dd17efe" --subnet-ids "subnet-0a8520f306c314ee0" "subnet-058ebfae0ee95e12e" "subnet-03b1c5508fd41fad3" --profile lab05 --no-verify-ssl --output text

"subnet-0a8520f306c314ee0" "subnet-058ebfae0ee95e12e" "subnet-03b1c5508fd41fad3"
# Criar bucket
aws s3api create-bucket --bucket tfstate-lab05 --acl private --region sa-east-1 --profile lab05 --no-verify-ssl

# Criar Key
aws kms create-key --description "Chave para onboarding da conta" --profile lab05 --no-verify-ssl

# Criar Policy
aws iam create-policy --policy-name BUPolicyForDevSecOpsPiaaS --policy-document file://BUPolicyForDevSecOpsPiaaS.json --profile lab05 --no-verify-ssl


#### Outros comandos:
# Listar IAM Roles:
aws iam list-roles --query 'Roles[*].RoleName' --output text --profile digital-paas-prod --no-verify-ssl

# BURoleForDigitalEC2-SSM
aws iam list-roles --filter 'Roles[*].RoleName=BURoleForDigitalEC2-SSM' --output text --profile digital-paas-prod --no-verify-ssl

# Criar IAM policy
.\saml2aws.exe login -a eec-aws-br-eits-dx-lab01-sandbox
aws iam create-policy --policy-name BUPolicyForLab-SSM-KMS --policy-document file://policyEC2-SSM.json --profile lab01  --no-verify-ssl

aws iam create-role --role-name BURoleForLab-EC2-SSM.json --assume-role-policy-document file://policy2.json  --profile lab01  --no-verify-ssl --permissions-boundary "arn:aws:iam::186041780552:policy/BUAdminBasePolicy"

aws iam list-policies --query 'Policies[*].{Name:PolicyName,ARN:Arn}' --output text --profile lab01  --no-verify-ssl

aws ec2 describe-images --region sa-east-1 --profile lab01  --no-verify-ssl --query 'Images[*].{Name:Name,Descricao:Description,Owner:OwnerId,ID:ImageId}'

aws ec2 describe-subnets --query "Subnets[].{Name:Tags[?Key==`Name`].Value[],ID:SubnetId}" --output text --profile lab01 --no-verify-ssl 

aws ec2 run-instances --image-id ami-0dc65b43b708df762 --instance-type t3.small --subnet-id subnet-f940de9e --security-group-ids sg-099e951dfd89a941d sg-0a3bf42cfca7de464 sg-08f75cbb997e39e5d sg-0a183ebfb0b5f1d55 --key-name digital --tag-specifications 'ResourceType=instance,Tags=[{Key=bu,Value=\"digital\"},{Key=CWRetentionDays,Value=\"30\"},{Key=Name,Value=\"BRASA1UDBUES01\"},{Key=ResourceBusinessUnit,Value=\"Brazil_Digital_Paas\"},{Key=ResourceAppRole,Value=\"db\"},{Key=Description,Value=\"Banco_MONGO_UAT_A\"},{Key=CWAgentInstall,Value=\"true\"},{Key=Backup,Value=\"true\"},{Key=ResourceCostCenter,Value=\"1800.BR.134.502527\"},{Key=ResourceName,Value=\"brasa1udbues01.br.experian.eeca\"},{Key=ResourceOwner,Value=\"devsecopsdigitalpaas@br.experian.com\"},{Key=Ambiente,Value=\"UAT\"}]' --no-verify-ssl

openssl req -newkey rsa:2048 -nodes -keyout lab01.experian.local.key -out lab01.experian.local.csr

# Optimizations

### List all ec2 instances
aws ec2 describe-instances --profile devhub-dev --no-verify-ssl --query "Reservations[].Instances[].{InstanceId:InstanceId,InstanceType:InstanceType}" --output text

### Stop instance
aws ec2 stop-instances --instance-ids i-06989fdf2d1415d2b --profile devhub-dev --no-verify-ssl

### Change instance type
aws ec2 modify-instance-attribute --instance-id  i-06989fdf2d1415d2b --instance-type "{\"Value\": \"t3.small\"}"  --profile devhub-dev --no-verify-ssl

### Start instances
aws ec2 start-instances --instance-ids i-06989fdf2d1415d2b --profile devhub-dev --no-verify-ssl

###  compute-optimizer Recomendações

aws get-recommendation-summaries

aws compute-optimizer get-ec2-instance-recommendations --profile devhub-dev --no-verify-ssl 

### Levantar ambiente RDS
aws rds describe-db-instances --profile devhub-dev --no-verify-ssl --query "DBInstances[].{Identifier:DBInstanceIdentifier,InstanceType:DBInstanceClass}" --output text

### modify RDS Instance Type
aws rds modify-db-instance --db-instance-identifier eitsenterprise-snd-dblab --db-instance-class db.m6g.large --apply-immediately --profile devhub-dev --no-verify-ssl 
aws rds modify-db-instance --db-instance-identifier eitsenterprise-dev-devhubportal01 --db-instance-class db.m6g.large --apply-immediately --profile devhub-dev --no-verify-ssl 
aws rds modify-db-instance --db-instance-identifier eitsenterprise-dev-devhubportalqa --db-instance-class db.m6g.large --apply-immediately --profile devhub-dev --no-verify-ssl 
