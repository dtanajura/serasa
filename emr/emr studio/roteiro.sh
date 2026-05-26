
cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\emr studio"
$profile_aws = "datahubdev"

# Criar um EMR Studio

# Anexar Políticas ao Role: Anexe as políticas necessárias ao role criado.
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
    "StudioId": "es-DT1ULXIC9DHP13S6ZKRWW65O0",
    "Url": "https://es-DT1ULXIC9DHP13S6ZKRWW65O0.emrstudio-prod.sa-east-1.amazonaws.com"
}

# Criar a Aplicação EMR Serverless:
aws emr-serverless create-application --name "DataHubDevServerlessApp" --release-label emr-6.6.0 --type Spark --profile $profile_aws
{
    "applicationId": "00fqoqeh7vcdlf31",
    "name": "DataHubDevServerlessApp",
    "arn": "arn:aws:emr-serverless:sa-east-1:730335661246:/applications/00fqoqeh7vcdlf31"
}


# Acessar o EMR Studio
# Obter URL do Studio: Use o comando abaixo para obter a URL de acesso ao EMR Studio.
aws emr describe-studio --studio-id <studio-id> --profile $profile_aws

# Acessar o Studio: Navegue até a URL fornecida para acessar o EMR Studio e começar a usar.
# No EMR Studio, você pode configurar o workspace para usar a aplicação EMR Serverless criada. Isso pode ser feito através da interface do EMR Studio, onde você pode selecionar a aplicação EMR Serverless ao configurar o workspace.
# alternativamente use:

# Criar Workspaces: Crie workspaces dentro do EMR Studio.

/usr/local/bin/aws emr-serverless create-application --name "DataHubDevServerlessApp" --release-label emr-6.14.0 --type Spark --interactive-configuration '{"studioEnabled": true}' --profile datahubdev


{
    "applicationId": "00fr2jlq35n9vn31",
    "name": "DataHubDevServerlessApp",
    "arn": "arn:aws:emr-serverless:sa-east-1:730335661246:/applications/00fr2jlq35n9vn31"
}

a versão mais recente do EMR é a 7.8.0