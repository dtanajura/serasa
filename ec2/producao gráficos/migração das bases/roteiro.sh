# Verificar se existe algum RDS na conta Corporate Prod
aws rds describe-db-instances --profile corporateprod
{
    "DBInstances": []
}

# Preciso criar o serviço RDS com Postgres para esse banco de dados
# Para isso vou usar a automação do Terraform na pasta "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\Prometheus - versão 3\servidores\iac-eec-aws-br-nike-corporate-prod"

aws rds modify-db-instance --db-instance-identifier observabilidade-0 --master-user-password 5f59CC3UHS0u0QyV --apply-immediately --profile corporateprod
aws rds modify-db-cluster --db-cluster-identifier observabilidade --master-user-password 5f59CC3UHS0u0QyV --apply-immediately --profile corporateprod
aws secretsmanager list-secrets --profile corporateprod --query  "SecretList[].Arn"
aws secretsmanager get-secret-value --secret-id "rds!cluster-2c7e9353-171d-4439-88a2-7ededfc19aa6" --profile corporateprod
aws rds describe-db-clusters  --db-cluster-identifier observabilidade --profile corporateprod
aws rds modify-db-instance --db-instance-identifier observabilidade-0  --apply-immediately --profile corporateprod --no-publicly-accessible


aws rds describe-db-subnet-groups --profile corporateprod

aws rds modify-db-cluster --db-cluster-identifier observabilidade --multi-az --profile corporateprod --apply-immediately

aws rds modify-db-subnet-group  --db-subnet-group-name observabilidade-subnet  --subnet-ids "subnet-0b502f71eace9c5b5" "subnet-0d9b9426ecb1299ee" "subnet-06588e5b9be554263" --profile corporateprod

aws rds modify-db-instance --db-instance-identifier observabilidade-0 --db-subnet-group-name novo-observabilidade-subnet --apply-immediately --profile corporateprod
