# eec-aws-br-eits-devhub-sandbox
.\saml2aws.exe login -a eec-aws-br-eits-devhub-sandbox

# levantamento das instâncias da conta
aws ec2 describe-instances --query "Reservations[].Instances[].{Name:Tags[?Key=='Name']|[0].Value,Resource:Tags[?Key=='ResourceName']|[0].Value,Instance:InstanceId,State:State.Name,IP:PrivateIpAddress,AMI:ImageId,AZ:Placement.AvailabilityZone,Tipo:InstanceType,Chave:KeyName,VPC:VpcId,Subnet:SubnetId,CostString:Tags[?Key=='CostString']|[0].Value,AppID:Tags[?Key=='AppID']|[0].Value,Environment:Tags[?Key=='Environment']|[0].Value,ResourceName:Tags[?Key=='ResourceName']|[0].Value,ResourceOwner:Tags[?Key=='ResourceOwner']|[0].Value,ResourceAppRole:Tags[?Key=='ResourceAppRole']|[0].Value,adDomain:Tags[?Key=='adDomain']|[0].Value,adGroup:Tags[?Key=='adGroup']|[0].Value,CentrifyUnixRole:Tags[?Key=='CentrifyUnixRole']|[0].Value}" --output table --profile devhub-sandbox --no-verify-ssl

# Criar tags para as instâncias
aws ec2 create-tags --resources $(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output text --profile devhub-sandbox --no-verify-ssl) --tags Key=CostString,Value="1800.BR.134.607500"  --profile devhub-sandbox --no-verify-ssl

aws ec2 describe-instances --query 'Reservations[].Instances[].{InstanceId}' --output text --profile devhub-sandbox --no-verify-ssl

aws ec2 create-tags --resources i-058fa18beeca46a25 --tags Key=CostString,Value='1800.BR.134.607500' Key=Environment,Value='sbx' Key=AppID,Value='21231' Key=CentrifyUnixRole,Value='' Key=ResourceName,Value='devhub-eks-sandbox-test01' Key=ResourceAppRole,Value='app' Key=ResourceOwner,Value='devhub_team@br.experian.com' Key=adDomain,Value='br.experian.local' Key=adGroup,Value='' --profile devhub-sandbox --no-verify-ssl
aws ec2 create-tags --resources i-0c5bf25d2bc71bdc1 --tags Key=CostString,Value='1800.BR.134.607500' Key=Environment,Value='sbx' Key=AppID,Value='21231' Key=CentrifyUnixRole,Value='None' Key=ResourceName,Value='devhub-eks-sandbox-test01' Key=ResourceAppRole,Value='app' Key=ResourceOwner,Value='devhub_team@br.experian.com' Key=adDomain,Value='br.experian.local' Key=adGroup,Value='' --profile devhub-sandbox --no-verify-ssl
aws ec2 create-tags --resources i-0d308a6afbfb61648 --tags Key=CostString,Value='1800.BR.134.607500' Key=Environment,Value='sbx' Key=AppID,Value='21231' Key=CentrifyUnixRole,Value='None' Key=ResourceName,Value='devhub-eks-sandbox-test01' Key=ResourceAppRole,Value='app' Key=ResourceOwner,Value='devhub_team@br.experian.com' Key=adDomain,Value='br.experian.local' Key=adGroup,Value='' --profile devhub-sandbox --no-verify-ssl
aws ec2 create-tags --resources i-0d277f3eab4c9a965 --tags Key=CostString,Value='1800.BR.134.607500' Key=Environment,Value='sbx' Key=AppID,Value='20274' Key=CentrifyUnixRole,Value='None' Key=ResourceName,Value='devhub-bastion-sandbox.br.experian.eeca1' Key=ResourceAppRole,Value='misc' Key=ResourceOwner,Value='devhub_team@br.experian.com' Key=adDomain,Value='br.experian.local' Key=adGroup,Value='' --profile devhub-sandbox --no-verify-ssl
aws ec2 create-tags --resources i-0609bb278b93fba7c --tags Key=CostString,Value='1800.BR.134.607500' Key=Environment,Value='sbx' Key=AppID,Value='20274' Key=CentrifyUnixRole,Value='None' Key=ResourceName,Value='devhub-eks-sandbox-test01' Key=ResourceAppRole,Value='app' Key=ResourceOwner,Value='devhub_team@br.experian.com' Key=adDomain,Value='br.experian.local' Key=adGroup,Value='' --profile devhub-sandbox --no-verify-ssl
aws ec2 create-tags --resources i-0468a5fc4136d748b --tags Key=CostString,Value='1800.BR.134.607500' Key=Environment,Value='sbx' Key=AppID,Value='20274' Key=CentrifyUnixRole,Value='None' Key=ResourceName,Value='devhub-eks-sandbox-test01' Key=ResourceAppRole,Value='app' Key=ResourceOwner,Value='devhub_team@br.experian.com' Key=adDomain,Value='br.experian.local' Key=adGroup,Value='' --profile devhub-sandbox --no-verify-ssl
aws ec2 create-tags --resources i-075a1457355fabe01 --tags Key=CostString,Value='1800.BR.134.607500' Key=Environment,Value='sbx' Key=AppID,Value='21231' Key=CentrifyUnixRole,Value='None' Key=ResourceName,Value='devhub-eks-sandbox-test01' Key=ResourceAppRole,Value='app' Key=ResourceOwner,Value='devhub_team@br.experian.com' Key=adDomain,Value='br.experian.local' Key=adGroup,Value='' --profile devhub-sandbox --no-verify-ssl

# Instance Scheduler
aws ec2 create-tags --resources i-0d277f3eab4c9a965 --tags Key=Instance-Scheduler,Value='br-saopaulo-office-hours' --profile devhub-sandbox --no-verify-ssl
aws ec2 describe-instances --instances i-0d277f3eab4c9a965 --profile devhub-sandbox --no-verify-ssl

# levantamento dos buckets S3
aws s3 ls --profile devhub-sandbox --no-verify-ssl
aws s3api list-buckets --query "Buckets[].Name" --profile devhub-sandbox --no-verify-ssl --output table
aws s3api get-bucket-tagging --bucket my-bucket  --profile devhub-sandbox --no-verify-ssl
aws s3api put-bucket-tagging --bucket my-bucket --tagging file://tagging.json

aws s3api put-bucket-tagging --bucket aws-logs-071087690196-sa-east-1 --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl
aws s3api put-bucket-tagging --bucket cf-templates-1kqedoe4s8d9w-sa-east-1 --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl
aws s3api put-bucket-tagging --bucket se-351659e8f4e7cdca-devhub-eks-01-sandbox-access-logs --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl
aws s3api put-bucket-tagging --bucket se-351659e8f4e7cdca-devhub-eks-01-sandbox-backup --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl
aws s3api put-bucket-tagging --bucket se-351659e8f4e7cdca-devhub-eks-01-sandbox-helm-charts --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl
aws s3api put-bucket-tagging --bucket se-351659e8f4e7cdca-devhub-eks-01-sandbox-metrics-logs --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl
aws s3api put-bucket-tagging --bucket se-4003f8f8a4ce8ad1-devhub-eks-01-sandbox-access-logs --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl
aws s3api put-bucket-tagging --bucket se-4003f8f8a4ce8ad1-devhub-eks-01-sandbox-backup --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl
aws s3api put-bucket-tagging --bucket se-4003f8f8a4ce8ad1-devhub-eks-01-sandbox-helm-charts --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl
aws s3api put-bucket-tagging --bucket se-4003f8f8a4ce8ad1-devhub-eks-01-sandbox-metrics-logs --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl
aws s3api put-bucket-tagging --bucket tfstate-eks-071087690196 --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl

# levantamento dos clusters EKS
aws eks list-clusters --profile devhub-sandbox --no-verify-ssl --output table
aws eks describe-cluster --name devhub-eks-01-sandbox --profile devhub-sandbox --no-verify-ssl
 --query "cluster.{Name:name,ARN:arn,Resource:Tags[?Key=='ResourceName']|[0].Value,CostString:Tags[?Key=='CostString']|[0].Value,AppID:Tags[?Key=='AppID']|[0].Value,Environment:Tags[?Key=='Environment']|[0].Value,ResourceName:Tags[?Key=='ResourceName']|[0].Value,ResourceOwner:Tags[?Key=='ResourceOwner']|[0].Value,ResourceAppRole:Tags[?Key=='ResourceAppRole']|[0].Value,adDomain:Tags[?Key=='adDomain']|[0].Value,adGroup:Tags[?Key=='adGroup']|[0].Value,CentrifyUnixRole:Tags[?Key=='CentrifyUnixRole']|[0].Value}" --output table
aws eks tag-resource --resource-arn arn:aws:eks:sa-east-1:071087690196:cluster/devhub-eks-01-sandbox --tags CostString=1800.BR.134.607500,Environment=sbx,AppID=20274,ResourceAppRole=app --profile devhub-sandbox --no-verify-ssl
# levantamento das instancias RDS
aws rds describe-db-instances --profile devhub-sandbox --no-verify-ssl

# levantamento das tabelas Dynamodb
aws dynamodb list-tables --profile devhub-sandbox --no-verify-ssl

# levantamento dos clusters Redshift
aws redshift describe-clusters --profile devhub-sandbox --no-verify-ssl

# levantamento dos clusters elasticache
aws elasticache describe-cache-clusters --profile devhub-sandbox --no-verify-ssl

# Levantamento dos domínios Elastic Search
aws es list-domain-names --profile devhub-sandbox --no-verify-ssl

# levantamento dos clusters Documentdb
aws docdb describe-db-clusters --profile devhub-sandbox --no-verify-ssl

####################################
# eec-aws-br-eits-devhub-dev
####################################
.\saml2aws.exe login -a eec-aws-br-eits-devhub-dev

# levantamento das instâncias da conta
aws ec2 describe-instances --query "Reservations[].Instances[].{Name:Tags[?Key=='Name']|[0].Value,Resource:Tags[?Key=='ResourceName']|[0].Value,Instance:InstanceId,State:State.Name,IP:PrivateIpAddress,AMI:ImageId,AZ:Placement.AvailabilityZone,Tipo:InstanceType,Chave:KeyName,VPC:VpcId,Subnet:SubnetId,CostString:Tags[?Key=='CostString']|[0].Value,AppID:Tags[?Key=='AppID']|[0].Value,Environment:Tags[?Key=='Environment']|[0].Value,ResourceName:Tags[?Key=='ResourceName']|[0].Value,ResourceOwner:Tags[?Key=='ResourceOwner']|[0].Value,ResourceAppRole:Tags[?Key=='ResourceAppRole']|[0].Value,adDomain:Tags[?Key=='adDomain']|[0].Value,adGroup:Tags[?Key=='adGroup']|[0].Value,CentrifyUnixRole:Tags[?Key=='CentrifyUnixRole']|[0].Value}" --output table --profile devhub-dev --no-verify-ssl

# Criar tags para as instâncias
aws ec2 create-tags --resources i-06989fdf2d1415d2b --tags Key=CostString,Value='1800.BR.134.607500' Key=Environment,Value='dev' Key=AppID,Value='20274' Key=CentrifyUnixRole,Value='None' Key=ResourceName,Value='devhub1bastiondev.br.experian.eeca1' Key=ResourceAppRole,Value='misc' Key=ResourceOwner,Value='devhub_team@br.experian.com' Key=adDomain,Value='br.experian.local' Key=adGroup,Value='' --profile devhub-dev --no-verify-ssl

# levantamento dos buckets S3
aws s3 ls --profile devhub-dev --no-verify-ssl
aws s3api list-buckets --query "Buckets[].Name" --profile devhub-dev --no-verify-ssl --output table

# Criar tags para os buckets
aws s3api put-bucket-tagging --bucket aws-logs-977554819825-sa-east-1 --tagging file://tagging.json  --profile devhub-dev --no-verify-ssl
aws s3api put-bucket-tagging --bucket cf-templates-d3jbefuka89x-sa-east-1 --tagging file://tagging.json  --profile devhub-dev --no-verify-ssl
aws s3api put-bucket-tagging --bucket tfstate-eks-977554819825 --tagging file://tagging.json  --profile devhub-dev --no-verify-ssl

# Verificar tags dos buckets
aws s3api get-bucket-tagging --bucket aws-logs-977554819825-sa-east-1 --profile devhub-dev --no-verify-ssl
aws s3api get-bucket-tagging --bucket cf-templates-d3jbefuka89x-sa-east-1 --profile devhub-dev --no-verify-ssl
aws s3api get-bucket-tagging --bucket tfstate-eks-977554819825 --profile devhub-dev --no-verify-ssl

####################################
# eec-aws-br-eits-devhub-prod
####################################
.\saml2aws.exe login -a eec-aws-br-eits-devhub-prod

# levantamento dos buckets S3
aws s3 ls --profile devhub-prod --no-verify-ssl
aws s3api list-buckets --query "Buckets[].Name" --profile devhub-prod --no-verify-ssl --output table

# Criar tags para os buckets
aws s3api put-bucket-tagging --bucket cf-templates-10ks2i1ljml82-sa-east-1 --tagging file://tagging.json  --profile devhub-prod --no-verify-ssl
aws s3api put-bucket-tagging --bucket devhub-prod-tfstate --tagging file://tagging.json  --profile devhub-prod --no-verify-ssl

# Verificar tags dos buckets
aws s3api get-bucket-tagging --bucket cf-templates-10ks2i1ljml82-sa-east-1 --profile devhub-prod --no-verify-ssl
aws s3api get-bucket-tagging --bucket devhub-prod-tfstate --profile devhub-prod --no-verify-ssl

####################################
# eec-aws-br-eits-devhub-test
####################################
.\saml2aws.exe login -a eec-aws-br-eits-devhub-test

# levantamento dos buckets S3
aws s3 ls --profile devhub-test --no-verify-ssl
aws s3api list-buckets --query "Buckets[].Name" --profile devhub-test --no-verify-ssl --output table

aws s3api put-bucket-tagging --bucket aws-logs-838498078144-sa-east-1 --tagging file://tagging.json  --profile devhub-test --no-verify-ssl
aws s3api put-bucket-tagging --bucket cf-templates-yt9tbuleph0v-sa-east-1 --tagging file://tagging.json  --profile devhub-test --no-verify-ssl
aws s3api put-bucket-tagging --bucket se-ab80d0a43d67a67d-devhub-eks-01-uat-access-logs --tagging file://tagging.json  --profile devhub-test --no-verify-ssl
aws s3api put-bucket-tagging --bucket se-ab80d0a43d67a67d-devhub-eks-01-uat-backup --tagging file://tagging.json  --profile devhub-test --no-verify-ssl
aws s3api put-bucket-tagging --bucket se-ab80d0a43d67a67d-devhub-eks-01-uat-helm-charts --tagging file://tagging.json  --profile devhub-test --no-verify-ssl
aws s3api put-bucket-tagging --bucket se-ab80d0a43d67a67d-devhub-eks-01-uat-metrics-logs --tagging file://tagging.json  --profile devhub-test --no-verify-ssl
aws s3api put-bucket-tagging --bucket tfstate-eks-838498078144 --tagging file://tagging.json  --profile devhub-test --no-verify-ssl

# levantamento dos clusters EKS
aws eks list-clusters --profile devhub-test --no-verify-ssl --output table
aws eks describe-cluster --name  devhub-eks-01-uat --profile devhub-test --no-verify-ssl
aws eks tag-resource --resource-arn arn:aws:eks:sa-east-1:838498078144:cluster/devhub-eks-01-uat --tags CostString=1800.BR.134.607500,Environment=sbx,AppID=20274,ResourceAppRole=app --profile devhub-test --no-verify-ssl

# Listar todas as interfaces que usam um SG
aws ec2 describe-network-interfaces --filters Name=group-id,Values=sg-0a19d3eea72061c66 --region sa-east-1 --output json --profile devhub-prod --no-verify-ssl


aws s3api put-bucket-tagging --bucket sagemaker-studio-0j965z1i0d5 --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl
aws s3api put-bucket-tagging --bucket sagemaker-studio-2le5mnchmxl --tagging file://tagging.json  --profile devhub-sandbox --no-verify-ssl
