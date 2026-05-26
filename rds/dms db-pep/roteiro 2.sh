# Esse roteiro é para a operação de refazer o dms para cópia dos dados do banco db-pep da conta dsprod para datahubprod
# Nesse cenário existe um banco migrado que vai ser dropado para ser recriado
# e uma estrutura de migração do DMS pronta

cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\_outras tarefas\dms db-pep-2"

$profile_aws="datahubprod"

# Alterar o RDS para remover o parâmetro do auto increment
aws rds reset-db-cluster-parameter-group --db-cluster-parameter-group-name eec-aws-br-eits-datahub-prod-pep-aurora-pg --parameters "ParameterName=innodb_autoinc_lock_mode,ApplyMethod=pending-reboot" --profile $profile_aws

aws rds reboot-db-instance --db-instance-identifier eec-aws-br-eits-datahub-prod-pep-aurora-0 --profile $profile_aws
aws rds reboot-db-instance --db-instance-identifier eec-aws-br-eits-datahub-prod-pep-aurora-1 --profile $profile_aws

aws secretsmanager get-secret-value --secret-id "rds!cluster-36ec8ef7-ad01-4034-93a2-61c17675d8e3" --profile datahubprod
{
    "ARN": "arn:aws:secretsmanager:sa-east-1:415071355886:secret:rds!cluster-36ec8ef7-ad01-4034-93a2-61c17675d8e3-lGFF6f",
    "Name": "rds!cluster-36ec8ef7-ad01-4034-93a2-61c17675d8e3",
    "VersionId": "3255e9bd-b30f-4c03-830b-efe24aafd45d",
    "SecretString": "{\"username\":\"admin\",\"password\":\"BsM!12:.pW[J:vOo|>$Yp]0rK[5>\"}",
    "VersionStages": [
        "AWSCURRENT",
        "AWSPENDING"
    ],
    "CreatedDate": "2024-12-12T06:08:25.899000-03:00"
}

# Dropar e recriar o banco db-pep
k config use-context arn:aws:eks:sa-east-1:415071355886:cluster/datahub-prod
k exec -it ubuntu-pod -c ubuntu-container -- bash
root@ubuntu-pod:/# mysql -u admin -p -h eec-aws-br-eits-datahub-prod-pep-aurora.cluster-cpvfmbpitn3a.sa-east-1.rds.amazonaws.com -P 3306
# Apague o banco de dados db_pep:
DROP DATABASE db_pep;
# Crie um novo banco de dados db_pep:
CREATE DATABASE db_pep;

# Criar um novo snapshot no RDS da conta DSPROD
aws rds create-db-cluster-snapshot --db-cluster-snapshot-identifier snapshot-antes-migracao-18-12-2024 --db-cluster-identifier experian-newinfo-rds --profile dsprod --region sa-east-1

# Verificar o snapshot
aws rds describe-db-cluster-snapshots --db-cluster-snapshot-identifier snapshot-antes-migracao-18-12-2024 --profile dsprod --region sa-east-1
aws rds describe-db-cluster-snapshots --db-cluster-snapshot-identifier snapshot-antes-migracao-18-12-2024 --profile dsprod --region sa-east-1 --query "DBClusterSnapshots[].Status"

# reiniciar a task de cópia do DMS
$replicationTaskArn = 'arn:aws:dms:sa-east-1:415071355886:task:EFW6MEHXWZCTLOHG4GP3WRCWEY'
aws dms start-replication-task --replication-task-arn $replicationTaskArn --start-replication-task-type reload-target --profile $profile_aws

# voltar parâmetro do RDS
aws rds modify-db-cluster-parameter-group --db-cluster-parameter-group-name eec-aws-br-eits-datahub-prod-pep-aurora-pg --parameters "ParameterName=innodb_autoinc_lock_mode,ParameterValue=1,ApplyMethod=pending-reboot" --profile $profile_aws

aws rds reboot-db-instance --db-instance-identifier eec-aws-br-eits-datahub-prod-pep-aurora-0 --profile $profile_aws
aws rds reboot-db-instance --db-instance-identifier eec-aws-br-eits-datahub-prod-pep-aurora-1 --profile $profile_aws

# Realizar os selects de comparação ao finalizar cada modificação

ALTER TABLE db_pep.pep_titulares_mandatos_silver_rechaco MODIFY id BIGINT AUTO_INCREMENT;
ALTER TABLE db_pep.pep_titulares_mandatos_silver MODIFY id BIGINT AUTO_INCREMENT;

ALTER TABLE db_pep.pep_titulares_mandatos_silver ADD constraint co_cargo_0 foreign key (co_cargo) references db_pep.pep_cargos (co_cargo) on update cascade;
ALTER TABLE db_pep.pep_titulares_mandatos_silver ADD constraint co_orgao_0 foreign key (co_orgao) references db_pep.pep_orgaos (co_orgao) on update cascade;

k config use-context arn:aws:eks:sa-east-1:415071355886:cluster/datahub-prod
k exec -it ubuntu-pod -c ubuntu-container -- bash
root@ubuntu-pod:/# mysql -u admin -p -h eec-aws-br-eits-datahub-prod-pep-aurora.cluster-cpvfmbpitn3a.sa-east-1.rds.amazonaws.com -P 3306
# Realizar os selects de comparação ao finalizar cada modificação

ALTER TABLE db_pep.pep_titulares_mandatos_silver_rechaco MODIFY id BIGINT AUTO_INCREMENT;
ALTER TABLE db_pep.pep_titulares_mandatos_silver MODIFY id BIGINT AUTO_INCREMENT;

ALTER TABLE db_pep.pep_titulares_mandatos_silver ADD constraint co_cargo_0 foreign key (co_cargo) references db_pep.pep_cargos (co_cargo) on update cascade;
ALTER TABLE db_pep.pep_titulares_mandatos_silver ADD constraint co_orgao_0 foreign key (co_orgao) references db_pep.pep_orgaos (co_orgao) on update cascade;

create index co_cargo_idx on db_pep.pep_titulares_mandatos_silver (co_cargo);
create index co_orgao_idx on db_pep.pep_titulares_mandatos_silver (co_orgao);

# Criar snapshot do RDS no datahubprod
aws rds create-db-cluster-snapshot --db-cluster-snapshot-identifier snapshot-apos-migracao-18-12-2024 --db-cluster-identifier eec-aws-br-eits-datahub-prod-pep-aurora --profile $profile_aws --region sa-east-1


# A rotina está com problema por que o instance size do RDS está muito pequeno. Dessa forma, vamos alterar aqui:
aws rds modify-db-instance --db-instance-identifier eec-aws-br-eits-datahub-prod-pep-aurora-0 --db-instance-class db.r6g.2xlarge --apply-immediately --profile $profile_aws --region sa-east-1
aws rds modify-db-instance --db-instance-identifier eec-aws-br-eits-datahub-prod-pep-aurora-1 --db-instance-class db.r6g.2xlarge --apply-immediately --profile $profile_aws --region sa-east-1
