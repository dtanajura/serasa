# If your account does not have a secondary IP range, please submit a request to the Cloud Team to add a secondary Subnet/IP Range (100.64.0.0/16) to your VPC with 3 AZs.
aws ec2 describe-subnets --profile devhub-sandbox --no-verify-ssl --query "Subnets[].[CidrBlock]" --filters "Name=tag:Name,Values=pod*" --output text
100.64.0.0/18
100.64.128.0/18
100.64.64.0/18

# Validate if your VPC is tagged with "AWS_Solutions = LandingZoneStackSet", your Experian IP range subnets with "Network = Private" and the Pod IP range (100.64.0.0/16) subnets with "Network = Pod".
aws ec2 describe-vpcs --profile devhub-sandbox --no-verify-ssl --query "Vpcs[].[Tags[?Key==`Name`].Value[],Tags[?Key==`AWS_Solutions`].Value[],CidrBlock]" --output text
10.120.134.0/25
aws-landing-zone-VPC
LandingZoneStackSet

aws ec2 describe-subnets --profile devhub-sandbox --no-verify-ssl --query "Subnets[].[SubnetId,CidrBlock,Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --output text  --filters "Name=tag:Name,Values=aws*"
subnet-020277a560d32ece6        10.120.134.64/27
aws-landing-zone-Private subnet 3A
Private
subnet-01ae076c3421d58a9        10.120.134.0/27
aws-landing-zone-PrivateSubnet1A
Private
subnet-0a3119550a3c9da5d        10.120.134.32/27
aws-landing-zone-Private subnet 2A
Private

aws ec2 describe-subnets --profile devhub-sandbox --no-verify-ssl --query "Subnets[].[SubnetId,CidrBlock,Tags[?Key=='Name'].Value[],Tags[?Key=='Network'].Value[]]" --output text  --filters "Name=tag:Name,Values=pod*"
subnet-01a1aa5379822cf47        100.64.0.0/18
pod-subnet-1A
Pod
subnet-06df35c4efe594f02        100.64.128.0/18
pod-subnet-3C
Pod
subnet-0609901bcfc574d07        100.64.64.0/18
pod-subnet-2B
Pod

aws ec2 describe-vpcs --profile devhub-sandbox --no-verify-ssl --query "Vpcs[].[VpcId]" --output text
aws ec2 describe-vpcs --profile devhub-dev --no-verify-ssl --query "Vpcs[].[VpcId]" --output text
aws ec2 describe-vpcs --profile devhub-test --no-verify-ssl --query "Vpcs[].[VpcId]" --output text
aws ec2 describe-vpcs --profile devhub-prod --no-verify-ssl --query "Vpcs[].[VpcId]" --output text

### Depois criar o SG, as regras e os endpoints, usando os comandos a seguir:
# Criar o SG para os endpoints
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-0f405711cd62b7ac8 --profile devhub-sandbox --no-verify-ssl
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-00c8ba3ca859c6546 --profile devhub-dev --no-verify-ssl
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-0caa86767b44fe141 --profile devhub-test --no-verify-ssl
aws ec2 create-security-group --group-name endpoints-sg --description "SG for endpoints - EKS pre-reqs" --vpc-id vpc-0b4a9286d9288da07 --profile devhub-prod --no-verify-ssl

# Adicionar regras para o SG
aws ec2 authorize-security-group-ingress --group-id sg-048442ee9e8636c82 --protocol tcp --port 80 --cidr 10.0.0.0/8 --profile devhub-sandbox --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-048442ee9e8636c82 --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile devhub-sandbox --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-01c3fe4c7c250e77c --protocol tcp --port 80 --cidr 10.0.0.0/8 --profile devhub-dev --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-01c3fe4c7c250e77c --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile devhub-dev --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-0378277a6b14c950a --protocol tcp --port 80 --cidr 10.0.0.0/8 --profile devhub-test --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-0378277a6b14c950a --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile devhub-test --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-01176a51f390814a4 --protocol tcp --port 80 --cidr 10.0.0.0/8 --profile devhub-prod --no-verify-ssl
aws ec2 authorize-security-group-ingress --group-id sg-01176a51f390814a4 --protocol tcp --port 443 --cidr 100.64.0.0/16 --profile devhub-prod --no-verify-ssl

# Criar VPC Endpoints
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0f405711cd62b7ac8 --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids "sg-048442ee9e8636c82" --subnet-ids "subnet-020277a560d32ece6" "subnet-01ae076c3421d58a9" "subnet-0a3119550a3c9da5d" --profile devhub-sandbox --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0f405711cd62b7ac8 --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-048442ee9e8636c82" --subnet-ids "subnet-020277a560d32ece6" "subnet-01ae076c3421d58a9" "subnet-0a3119550a3c9da5d" --profile devhub-sandbox --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0f405711cd62b7ac8 --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids "sg-048442ee9e8636c82" --subnet-ids "subnet-020277a560d32ece6" "subnet-01ae076c3421d58a9" "subnet-0a3119550a3c9da5d" --profile devhub-sandbox --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0f405711cd62b7ac8 --service-name com.amazonaws.sa-east-1.logs --security-group-ids "sg-048442ee9e8636c82" --subnet-ids "subnet-020277a560d32ece6" "subnet-01ae076c3421d58a9" "subnet-0a3119550a3c9da5d" --profile devhub-sandbox --no-verify-ssl

aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-00c8ba3ca859c6546 --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids "sg-01c3fe4c7c250e77c" --subnet-ids "subnet-086adfca9bc8df6aa" "subnet-0424f48254d1772e8" "subnet-09074fc0cb8b3b0bd" --profile devhub-dev --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-00c8ba3ca859c6546 --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-01c3fe4c7c250e77c" --subnet-ids "subnet-086adfca9bc8df6aa" "subnet-0424f48254d1772e8" "subnet-09074fc0cb8b3b0bd" --profile devhub-dev --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-00c8ba3ca859c6546 --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids "sg-01c3fe4c7c250e77c" --subnet-ids "subnet-086adfca9bc8df6aa" "subnet-0424f48254d1772e8" "subnet-09074fc0cb8b3b0bd" --profile devhub-dev --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-00c8ba3ca859c6546 --service-name com.amazonaws.sa-east-1.logs --security-group-ids "sg-01c3fe4c7c250e77c" --subnet-ids "subnet-086adfca9bc8df6aa" "subnet-0424f48254d1772e8" "subnet-09074fc0cb8b3b0bd" --profile devhub-dev --no-verify-ssl

aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0caa86767b44fe141 --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids "sg-0378277a6b14c950a" --subnet-ids "subnet-0167345181547d50c" "subnet-0738c743fcee77120" "subnet-051534abd2d3405c0" --profile devhub-test --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0caa86767b44fe141 --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-0378277a6b14c950a" --subnet-ids "subnet-0167345181547d50c" "subnet-0738c743fcee77120" "subnet-051534abd2d3405c0" --profile devhub-test --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0caa86767b44fe141 --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids "sg-0378277a6b14c950a" --subnet-ids "subnet-0167345181547d50c" "subnet-0738c743fcee77120" "subnet-051534abd2d3405c0" --profile devhub-test --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0caa86767b44fe141 --service-name com.amazonaws.sa-east-1.logs --security-group-ids "sg-0378277a6b14c950a" --subnet-ids "subnet-0167345181547d50c" "subnet-0738c743fcee77120" "subnet-051534abd2d3405c0" --profile devhub-test --no-verify-ssl

aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0b4a9286d9288da07 --service-name com.amazonaws.sa-east-1.ecr.api --security-group-ids "sg-01176a51f390814a4" --subnet-ids "subnet-0a43f7aad6d89c36e" "subnet-06e3666066b1396d8" "subnet-00eb36983a957fcc3" --profile devhub-prod --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0b4a9286d9288da07 --service-name com.amazonaws.sa-east-1.ecr.dkr --security-group-ids "sg-01176a51f390814a4" --subnet-ids "subnet-0a43f7aad6d89c36e" "subnet-06e3666066b1396d8" "subnet-00eb36983a957fcc3" --profile devhub-prod --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0b4a9286d9288da07 --service-name com.amazonaws.sa-east-1.ec2 --security-group-ids "sg-01176a51f390814a4" --subnet-ids "subnet-0a43f7aad6d89c36e" "subnet-06e3666066b1396d8" "subnet-00eb36983a957fcc3" --profile devhub-prod --no-verify-ssl
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --vpc-id vpc-0b4a9286d9288da07 --service-name com.amazonaws.sa-east-1.logs --security-group-ids "sg-01176a51f390814a4" --subnet-ids "subnet-0a43f7aad6d89c36e" "subnet-06e3666066b1396d8" "subnet-00eb36983a957fcc3" --profile devhub-prod --no-verify-ssl

