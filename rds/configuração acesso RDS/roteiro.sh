cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\_outras tarefas\configuração acesso RDS"
$profile_aws = "corporateprod"
aws rds describe-db-clusters --profile $profile_aws --query  "DBClusters[].DBClusterIdentifier"
aws rds describe-db-instances --profile $profile_aws --query "DBInstances[].DBInstanceIdentifier"
[
    "database-datahub-test-instance-1",
    "dev-hub-portal-dev",
    "dev-hub-portal-qa",
    "eitsenterprise-snd-devsecopslakesnd-1"
]
aws rds describe-db-instances  --db-instance-identifier dev-hub-portal-qa --profile $profile_aws --query "DBInstances[].Endpoint.Address"

# Cenário:
### conectar no cluster eks da conta:
aws eks list-clusters --profile $profile_aws
# {
#     "clusters": [
#         "nike-tech-dev"
#     ]
# }

aws eks update-kubeconfig --name nike-tech-dev  --profile $profile_aws

### quero dar acesso a um container na conta arcsandbox no rds dev-hub-portal-qa  dbname: custos_nike
# 1) vou criar um POD com o ubuntu
k create -f pod-ubuntu.yaml
# 2) acessar o S.O. do POD
k exec -it ubuntu-pod -- bash
# 3) Instalar o psql
apt update
apt install -y postgresql-client
psql --version
psql -h  observabilidade-0.cwhrk1jkkma0.sa-east-1.rds.amazonaws.com -p 5432 -U pgadmin -W -d custos_nike -W
# s*-VqNz0(f)Db~:gKY4VXUg9iPHU
# 4) Instalar o python para testar acesso ao database
apt install -y python3 python3-pip
python3 --version
# apt install -y 
pip3 --version

### criar a role e a policy para acesso ao database
# 1) Criar uma role
