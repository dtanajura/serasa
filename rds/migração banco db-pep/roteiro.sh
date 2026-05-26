# Migração do banco db-pep da conta eec-aws-br-ds-dataservices-prod (662860092544) para a conta eec-aws-br-eits-datahub-prod (415071355886)
# Foi aberta a CHG2499772 para realizar os teste

# Criar snapshot do RDS
aws rds create-db-cluster-snapshot --db-cluster-snapshot-identifier snapshot-antes-change-13-12-2024 --db-cluster-identifier experian-newinfo-rds --profile dsprod --region sa-east-1
# {
#     "DBClusterSnapshot": {
#         "AvailabilityZones": [
#             "sa-east-1a",
#             "sa-east-1b",
#             "sa-east-1c"
#         ],
#         "DBClusterSnapshotIdentifier": "snapshot-antes-change-13-12-2024",
#         "DBClusterIdentifier": "experian-newinfo-rds",
#         "SnapshotCreateTime": "2024-12-13T21:15:13.995000+00:00",
#         "Engine": "aurora-mysql",
#         "EngineMode": "provisioned",
#         "AllocatedStorage": 1,
#         "Status": "creating",
#         "Port": 0,
#         "VpcId": "vpc-0aaa559b9d2ae20c8",
#         "ClusterCreateTime": "2022-10-28T20:22:01.465000+00:00",
#         "MasterUsername": "new_info",
#         "EngineVersion": "8.0.mysql_aurora.3.05.2",
#         "LicenseModel": "aurora-mysql",
#         "SnapshotType": "manual",
#         "PercentProgress": 0,
#         "StorageEncrypted": true,
#         "KmsKeyId": "arn:aws:kms:sa-east-1:662860092544:key/f23cc847-2c9b-400c-8735-215ed18f06e6",
#         "DBClusterSnapshotArn": "arn:aws:rds:sa-east-1:662860092544:cluster-snapshot:snapshot-antes-change-13-12-2024",

aws rds describe-db-cluster-snapshots --db-cluster-snapshot-identifier snapshot-antes-change-13-12-2024 --profile dsprod --region sa-east-1 --query "DBClusterSnapshots[].Status"
# [
#     "available"
# ]

k config use-context arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod

k exec -it ubuntu-pod -- bash

mysqldump -h experian-newinfo-rds.cluster-csrf6dwrcmnh.sa-east-1.rds.amazonaws.com -u new_info -p --single-transaction --triggers --routines --events --set-gtid-purged=OFF db_pep > db_pep_dump_dsprod.sql
# Enter password:

ls -l db_pep_dump_dsprod.sql
# -rw-r--r-- 1 root root 188805012 Dec 13 21:39 db_pep_dump_dsprod.sql

k config use-context arn:aws:eks:sa-east-1:415071355886:cluster/datahub-prod

k get pods
# NAME         READY   STATUS    RESTARTS       AGE
# ubuntu-pod   1/1     Running   1 (4d9h ago)   9d

kubectl cp db_pep_dump_dsprod.tar ubuntu-pod:/db_pep_dump_dsprod.tar

k exec -it ubuntu-pod -- bash

ls -l db_pep_dump_dsprod.tar
# -rw-rw-rw- 1 root root 188815360 Dec 13 21:59 db_pep_dump_dsprod.tar

tar xf /db_pep_dump_dsprod.tar -C /

ls -l db_pep_dump_dsprod.sql
# -rw-r--r-- 1 root root 188805012 Dec 13 21:39 db_pep_dump_dsprod.sql

BsM!12:.pW[J:vOo|>$Yp]0rK[5>
mysql -u admin -p -h eec-aws-br-eits-datahub-prod-pep-aurora.cluster-cpvfmbpitn3a.sa-east-1.rds.amazonaws.com -P 3306

DROP DATABASE db_pep;


mysql -u admin -p -h eec-aws-br-eits-datahub-prod-pep-aurora.cluster-cpvfmbpitn3a.sa-east-1.rds.amazonaws.com -P 3306 db_pep < db_pep_dump_dsprod.sql






# Testes:
# Criar pod do ubuntu no cluster DSPROD
aws eks list-clusters --profile dsprod
# {
#     "clusters": [
#         "ds-eks-01-prod"
#     ]
# }
k config use-context arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod
# Switched to context "arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod".
k create -f .\pod-ubuntu.yaml
# pod/ubuntu-pod created
k exec -it ubuntu-pod -- bash

# Sai do pod para buscar informações de conexão com o banco
# Os comandos a seguir são no prompt do Powershell
############################################################
$profile_aws = "dsprod"
aws rds describe-db-clusters --profile $profile_aws --query  "DBClusters[].DBClusterIdentifier"
# "ds-documentdb-prod",
# "ds-lockunlock-prod",
# "ds-positivodb-prod",
# "experian-newinfo-rds"

aws rds describe-db-clusters --profile $profile_aws --db-cluster-identifier experian-newinfo-rds
# ...
# "Endpoint": "experian-newinfo-rds.cluster-csrf6dwrcmnh.sa-east-1.rds.amazonaws.com",
# "MasterUsername": "new_info",


# Para mudar a masteruser passwoword
aws rds modify-db-instance --db-instance-identifier experian-newinfo-rds --master-user-password <nova-senha> --profile $profile_aws

aws secretsmanager get-secret-value --secret-id "rds!cluster-36ec8ef7-ad01-4034-93a2-61c17675d8e3" --profile datahubprod
# {
#     "ARN": "arn:aws:secretsmanager:sa-east-1:415071355886:secret:rds!cluster-36ec8ef7-ad01-4034-93a2-61c17675d8e3-lGFF6f",
#     "Name": "rds!cluster-36ec8ef7-ad01-4034-93a2-61c17675d8e3",
#     "VersionId": "3255e9bd-b30f-4c03-830b-efe24aafd45d",
#     "SecretString": "{\"username\":\"admin\",\"password\":\"BsM!12:.pW[J:vOo|>$Yp]0rK[5>\"}",
#     "VersionStages": [
#         "AWSCURRENT",
#         "AWSPENDING"
#     ],
#     "CreatedDate": "2024-12-12T06:08:25.899000-03:00"
# }

k config use-context arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod
k config use-context arn:aws:eks:sa-east-1:415071355886:cluster/datahub-prod

# todos os comandos aqui são no container do Ubuntu
####################################################
apt-get update
# Get:1 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
# Get:2 http://archive.ubuntu.com/ubuntu noble InRelease [256 kB]
# Get:3 http://security.ubuntu.com/ubuntu noble-security/multiverse amd64 Packages [15.3 kB]
# Get:4 http://security.ubuntu.com/ubuntu noble-security/main amd64 Packages [677 kB]
# Get ...

apt-get upgrade -y
# Reading package lists... Done
# Building dependency tree... Done
# Reading state information... Done
# Calculating upgrade... Done
# 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.

apt-get install mysql-client -y
# Reading package lists... Done
# Building dependency tree... Done
# Reading state information... Done
# The following ...

# Para exportar no banco da conta DSPROD:
$Endpoint = "experian-newinfo-rds.cluster-csrf6dwrcmnh.sa-east-1.rds.amazonaws.com"
$ReaderEndpoint = "experian-newinfo-rds.cluster-ro-csrf6dwrcmnh.sa-east-1.rds.amazonaws.com"
###############################################
# Conecte-se ao MySQL:
mysql -h experian-newinfo-rds.cluster-csrf6dwrcmnh.sa-east-1.rds.amazonaws.com -u new_info -p
# Após logar, saia do MySQL para voltar ao terminal:
exit;
# No terminal, execute o comando mysqldump:
mysqldump -h experian-newinfo-rds.cluster-csrf6dwrcmnh.sa-east-1.rds.amazonaws.com -u new_info -p db_pep > db_pep_dump_dsprod.sql

# Para importar no banco da conta DATAHUBPROD:
$Endpoint = "eec-aws-br-eits-datahub-prod-pep-aurora.cluster-cpvfmbpitn3a.sa-east-1.rds.amazonaws.com"
$ReaderEndpoint = "eec-aws-br-eits-datahub-prod-pep-aurora.cluster-ro-cpvfmbpitn3a.sa-east-1.rds.amazonaws.com"
###############################################
# Faça um backup do banco de dados dessa conta
mysqldump -u admin -p -h $Endpoint -P 3306 db_pep > db_pep_backup_datahubprod.sql
# Conecte-se ao MySQL:
mysql -u admin -p -h eec-aws-br-eits-datahub-prod-pep-aurora.cluster-cpvfmbpitn3a.sa-east-1.rds.amazonaws.com -P 3306
# Apague o banco de dados db_pep:
DROP DATABASE db_pep;
# Crie um novo banco de dados db_pep:
CREATE DATABASE db_pep;
# Saia do MySQL:
exit;
# Restaure o dump no novo banco de dados db_pep:
mysql -u admin -p -h eec-aws-br-eits-datahub-prod-pep-aurora.cluster-cpvfmbpitn3a.sa-east-1.rds.amazonaws.com -P 3306 db_pep < db_pep_dump_dsprod.sql


kubectl cp ubuntu-pod:teste teste
# Copia o arquivo do pod para minha estação

















# Não é necessário
apt-get install unzip curl -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
/usr/local/bin/aws --version
# aws-cli/2.22.16 Python/3.12.6 Linux/5.10.227-219.884.amzn2.x86_64 exe/x86_64.ubuntu.24
export AWS_PAGER=""
aws sts get-caller-identity

aws s3 ls s3://se-64308a3b5b9fe7f8-ds-eks-01-prod-metrics-logs
#                            PRE fake/
#                            PRE index/
# 2024-11-29 18:48:53        252 loki_cluster_seed.json
touch teste
aws s3 cp teste s3://se-64308a3b5b9fe7f8-ds-eks-01-prod-metrics-logs
# upload: ./teste to s3://se-64308a3b5b9fe7f8-ds-eks-01-prod-metrics-logs/teste
aws s3 ls s3://se-64308a3b5b9fe7f8-ds-eks-01-prod-metrics-logs
#                            PRE fake/
#                            PRE index/
# 2024-11-29 18:48:53        252 loki_cluster_seed.json
# 2024-12-12 21:30:56          0 teste


