
cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\emr studio"
$profile_aws = "datahubdev"

# Criar um EMR Studio
# # Criar um Role IAM: Crie um role IAM com as permissões necessárias para o EMR Studio.
# aws iam create-role --role-name BURoleForEMRStudio --assume-role-policy-document file://trust.json --profile $profile_aws

# # Anexar Políticas ao Role: Anexe as políticas necessárias ao role criado.
# aws iam attach-role-policy --role-name aws iam create-role --role-name BURoleForEMRStudio --assume-role-policy-document file://trust.json
#  --policy-arn arn:aws:iam::aws:policy/AmazonEMRFullAccessPolicy_v2 --profile $profile_aws

$VpcID=aws ec2 describe-vpcs --profile $profile_aws --query  "Vpcs[].VpcId" --output text
$SubnetIDs=aws ec2 describe-subnets  --profile $profile_aws --output text --query "Subnets[].SubnetId" --filters "Name=tag:Network,Values=Private"
$SgId = (aws ec2 create-security-group --group-name emr-studio-security-group --description "Security group for EMR Studio" --tag-specifications file://tags.json --vpc-id $VpcID --output text --profile $profile_aws)

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

$SgId=aws ec2 describe-security-groups --filters Name=group-name,Values=emr-studio-security-group --profile $profile_aws --query 'SecurityGroups[*].GroupId' --output text

# Criei um bucket pela automação: datahub-dev-emr-studio
aws emr create-studio --name "DataHubDev" --auth-mode IAM --vpc-id vpc-0e87239604bd7ce1d --subnet-ids subnet-09457eb844099e03a subnet-07e5d9aace6f61db0 subnet-0ba523237a46d6cbe --service-role BURoleForContatos --workspace-security-group sg-03853fe274aeb3202 --engine-security-group sg-03853fe274aeb3202 --profile $profile_aws --default-s3-location s3://datahub-dev-emr-studio
{
    "StudioId": "es-260FFDG0DBOPQU8DPJANB47LL",
    "Url": "https://es-260FFDG0DBOPQU8DPJANB47LL.emrstudio-prod.sa-east-1.amazonaws.com"
}

# Criar a Aplicação EMR Serverless:
aws emr-serverless create-application --name "DataHubDevServerlessApp" --release-label emr-6.6.0 --type Spark --profile $profile_aws
{
    "applicationId": "00fqoqeh7vcdlf31",
    "name": "DataHubDevServerlessApp",
    "arn": "arn:aws:emr-serverless:sa-east-1:730335661246:/applications/00fqoqeh7vcdlf31"
}



# Criar o EMR Studio: Use o comando abaixo para criar o EMR Studio.
aws emr create-studio --name "DataHubDev" --auth-mode SSO --vpc-id $VpcID --subnet-ids subnet-09457eb844099e03a subnet-07e5d9aace6f61db0 subnet-0ba523237a46d6cbe --user-role BURoleForEMRStudio --service-role BURoleForContatos --workspace-security-group $SgId --engine-security-group $SgId --profile $profile_aws --default-s3-location s3://datahub-dev-emr-studio
# Obter o ID do studio: esse ID será necessário para criar o workspace.
{
    "StudioId": "es-DO6MPM0QCU2LLJ9HVA7B10OPG",
    "Url": "https://es-DO6MPM0QCU2LLJ9HVA7B10OPG.emrstudio-prod.sa-east-1.amazonaws.com"
}


# Passo 3: Configurar o EMR Studio

# Criar a Aplicação EMR Serverless:
aws emr-serverless create-application --name "DataHubDevServerlessApp" --release-label emr-6.6.0 --type Spark --profile $profile_aws
# Obter o ID da Aplicação: Após criar a aplicação, você receberá um application-id que será usado para associar ao workspace.
{
    "applicationId": "00fqif8fmlqdlm31",
    "name": "DataHubDevServerlessApp",
    "arn": "arn:aws:emr-serverless:sa-east-1:730335661246:/applications/00fqif8fmlqdlm31"
}

# Criar Workspaces: Crie workspaces dentro do EMR Studio.
aws emr create-workspace --name "DataHubDevWorkspace" --studio-id es-DO6MPM0QCU2LLJ9HVA7B10OPG --auth-mode SSO --user-role BURoleForEMRStudio --profile $profile_aws

# Acessar o EMR Studio
# Obter URL do Studio: Use o comando abaixo para obter a URL de acesso ao EMR Studio.
aws emr describe-studio --studio-id <studio-id> --profile $profile_aws

# Acessar o Studio: Navegue até a URL fornecida para acessar o EMR Studio e começar a usar.
# No EMR Studio, você pode configurar o workspace para usar a aplicação EMR Serverless criada. Isso pode ser feito através da interface do EMR Studio, onde você pode selecionar a aplicação EMR Serverless ao configurar o workspace.


############################
## Tentativa #2
############################

# Excluir o EMR Studio criado
aws emr delete-studio --studio-id es-DO6MPM0QCU2LLJ9HVA7B10OPG --profile $profile_aws

# Criar a service role
aws iam create-role --role-name BURoleForEMRStudio-ServiceRole --assume-role-policy-document file://servicerole-trust.json --profile $profile_aws
{
    "Role": {
        "Path": "/",
        "RoleName": "BURoleForEMRStudio-ServiceRole",
        "RoleId": "AROA2UC3FZS7AZZMEOIHE",
        "Arn": "arn:aws:iam::730335661246:role/BURoleForEMRStudio-ServiceRole",
        "CreateDate": "2025-02-26T16:44:38+00:00",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "elasticmapreduce.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole",
                    "Condition": {
                        "StringEquals": {
                            "aws:SourceAccount": "730335661246"
                        },
                        "ArnLike": {
                            "aws:SourceArn": "arn:aws:elasticmapreduce:sa-east-1:730335661246:*"
                        }
                    }
                }
            ]
        }
    }
}

# Criar uma inline policy com as permissões:
aws iam put-role-policy --role-name BURoleForEMRStudio-ServiceRole --policy-name InlinePolicy --policy-document file://servicerole-policy.json --profile $profile_aws

# # Na página do EMR Studio - Create Studio:
# Setup  - Custom
# Studio name - DataHubDev
# S3 location for Workspace storage
# Select existing location - s3://datahub-dev-emr-studio
# Service role to let Studio access your AWS resources - BURoleForEMRStudio-ServiceRole

# Workspace settings
# Workspace name - DataHubDev-Workspace
# Allow collaboration - true

# Authentication
# Choose an authentication method for your Studio.
# IAM Identity Center (AWS Single Sign-On)
# User role - BURoleForEMRStudio

# Application access
# Choose who can access your application - All users and groups

# Security and access
# Custom security group
# Cluster/endpoint security group - sg-03853fe274aeb3202 (emr-studio-security-group)
# Workspace security group - sg-03853fe274aeb3202 (emr-studio-security-group)

aws emr create-studio --name "DataHubDev" --auth-mode SSO --vpc-id vpc-0e87239604bd7ce1d --subnet-ids subnet-09457eb844099e03a subnet-07e5d9aace6f61db0 subnet-0ba523237a46d6cbe --user-role BURoleForEMRStudio --service-role BURoleForContatos --workspace-security-group sg-03853fe274aeb3202 --engine-security-group sg-03853fe274aeb3202 --profile $profile_aws --default-s3-location s3://datahub-dev-emr-studio

{
    "StudioId": "es-DT1ULXIC9DHP13S6ZKRWW65O0",
    "Url": "https://es-DT1ULXIC9DHP13S6ZKRWW65O0.emrstudio-prod.sa-east-1.amazonaws.com"
}
