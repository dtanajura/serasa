### 1 - login
.\saml2aws.exe login -a eec-aws-br-nike-corporate-prod


## Verificar elementos previamente instalados na conta
aws ce get-cost-and-usage --profile devhub-legada-prod --no-verify-ssl --granularity "MONTHLY" --time-period Start=2023-10-01,End=2023-10-31 --metrics "UsageQuantity" --group-by Type=DIMENSION,Key=SERVICE --output text
# Listar instâncias
aws ec2 describe-instances --profile devhub-legada-prod --no-verify-ssl --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name'].Value]" --output text
# Listar Buckets S3
aws s3 ls --profile devhub-legada-prod --no-verify-ssl
# Listar bancos RDS
aws rds describe-db-instances --profile devhub-legada-prod --no-verify-ssl --query "DBInstances[].[DBInstanceIdentifier]" --output text
# Listar cluster EKS
aws eks list-clusters --profile devhub-legada-prod --no-verify-ssl
# Listar chaves KMS
aws kms list-keys --profile devhub-legada-prod --no-verify-ssl
# Listar filesystems do EFS
aws efs describe-file-systems --profile devhub-legada-prod --no-verify-ssl --query "FileSystems[].[CreationToken,FileSystemId]" --output text
