cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\_outras tarefas\dms db-pep"

# criar a instância de replicação
$profile_aws="datahubprod"
$vpcIdDestino=aws ec2 describe-vpcs --profile $profile_aws --query  "Vpcs[].VpcId" --output text
$SGGroupName="SG-DMS-Replication-DB-PEP"
$SGGroupDescription="SG para replicacao dos bancos DEVHUB"

# primeiro criar um security group para a instância de replicação:
$SgId = (aws ec2 create-security-group --group-name $SGGroupName --description "$SGGroupDescription" --vpc-id $vpcIdDestino --tag-specifications file://tags.json --profile $profile_aws --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 3306 --cidr 10.0.0.0/8 --profile $profile_aws

aws ec2 describe-security-groups --filters Name=group-id,Values=$SgId --profile $profile_aws --query 'SecurityGroups[*].{GroupName:GroupName, IpPermissions:IpPermissions, IpPermissionsEgress:IpPermissionsEgress}' --output json

# Criar roles para migração
### Consultar: https://docs.aws.amazon.com/dms/latest/userguide/security-iam.html#CHAP_Security.APIRole
aws iam create-role --role-name dms-vpc-role --assume-role-policy-document file://trust.json --profile $profile_aws

aws iam attach-role-policy --role-name dms-vpc-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole --profile $profile_aws

# Criar role para Cloud Watch
aws iam create-role --role-name dms-cloudwatch-logs-role --assume-role-policy-document file://trust.json --profile $profile_aws

aws iam attach-role-policy --role-name dms-cloudwatch-logs-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole  --profile $profile_aws

# Listar as subnets
$subnetIds = (aws ec2 describe-subnets --profile $profile_aws --output text --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*") -join " "

# depois criar o replication subnet group
$replicationGroupId = "replication-subnet-group-db-pep"
$replicationGroupDescription = "Replication subnet group para migracao banco DB-PEP"
aws dms create-replication-subnet-group --replication-subnet-group-identifier $replicationGroupId --replication-subnet-group-description $replicationGroupDescription  --subnet-ids $subnetIds --tags file://tags-replication.json --profile $profile_aws

$replicationInstanceId = "replication-instance-DB-PEP"
# Finalmente criar a instância de replicação

$replicationInstanceArn = (aws dms create-replication-instance --replication-instance-identifier $replicationInstanceId --replication-instance-class "dms.c6i.large" --allocated-storage 5 --vpc-security-group-ids $SgId --replication-subnet-group-identifier $replicationGroupId --no-multi-az --tags file://tags-replication.json --no-publicly-accessible --profile $profile_aws --query 'ReplicationInstance.ReplicationInstanceArn' --output text)


# Criar replicação para cada banco de dados
$banco = "db-pep"
$sourceEndpointIdentifier = "source-$banco"
$sourceUsername = "new_info"
$sourcePassword = 'c7RNn1o4KhQpg9WnME1z'
$sourceServerName = "experian-newinfo-rds.cluster-csrf6dwrcmnh.sa-east-1.rds.amazonaws.com"
$sourceDatabaseName = "db_pep"
$targetEndpointIdentifier = "target-$banco"
$targetUsername = "admin"
$targetPassword = 'BsM!12:.pW[J:vOo|>$Yp]0rK[5>'
$targetServerName = "eec-aws-br-eits-datahub-prod-pep-aurora.cluster-cpvfmbpitn3a.sa-east-1.rds.amazonaws.com"
$targetDatabaseName = "db_pep"

$sourceEndpointArn = (aws dms create-endpoint --endpoint-identifier $sourceEndpointIdentifier --endpoint-type "source" --engine-name "mysql" --username $sourceUsername --password $sourcePassword --server-name $sourceServerName --port 3306 --database-name $sourceDatabaseName --profile $profile_aws --query 'Endpoint.EndpointArn' --output text)

$targetEndpointArn = (aws dms create-endpoint --endpoint-identifier $targetEndpointIdentifier --endpoint-type "target" --engine-name "mysql" --username $targetUsername --password $targetPassword --server-name $targetServerName --port 3306 --database-name $targetDatabaseName --profile $profile_aws --query 'Endpoint.EndpointArn' --output text)

# Precisei alterar o usuário. seguem comandos de banco:
CREATE USER 'dms_user'@'%' IDENTIFIED BY 'c7RNn1o4KhQpg9WnME1z';
Query OK, 0 rows affected (0.01 sec)

mysql> GRANT ALTER, CREATE, DROP, INDEX, INSERT, UPDATE, DELETE, SELECT ON db_pep.* TO 'admin'@'%';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT ALL PRIVILEGES ON awsdms_control.* TO 'admin'@'%';
Query OK, 0 rows affected (0.01 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.01 sec)

# Alterar o target endpoint para o novo usuário
$targetPassword = 'c7RNn1o4KhQpg9WnME1z'
$targetUsername = "admin"
$targetPassword = 'BsM!12:.pW[J:vOo|>$Yp]0rK[5>'

aws dms modify-endpoint --endpoint-arn $targetEndpointArn --username $targetUsername --password $targetPassword --extra-connection-attributes "Initstmt=SET FOREIGN_KEY_CHECKS=0;" --profile $profile_aws

# Testar a conexão para os endpoints
aws dms test-connection --replication-instance-arn $replicationInstanceArn --endpoint-arn $sourceEndpointArn --profile $profile_aws
aws dms test-connection --replication-instance-arn $replicationInstanceArn --endpoint-arn $targetEndpointArn --profile $profile_aws

aws dms describe-connections --filter Name=endpoint-arn,Values=$sourceEndpointArn --profile $profile_aws
aws dms describe-connections --filter Name=endpoint-arn,Values=$targetEndpointArn --profile $profile_aws

$replicationTaskId = "task-migracao-$banco"

$replicationTaskArn = (aws dms create-replication-task --replication-task-identifier $replicationTaskId --source-endpoint-arn $sourceEndpointArn --target-endpoint-arn $targetEndpointArn --migration-type "full-load" --table-mappings file://table-mappings.json --replication-task-settings file://task-settings.json --replication-instance-arn $replicationInstanceArn --profile $profile_aws --query 'ReplicationTask.ReplicationTaskArn' --output text)

$bucketName = "dms-migration-$banco"
aws s3 mb s3://$bucketName --profile $profile_aws
aws s3api put-bucket-tagging --bucket $bucketName --tagging file://tags-bucket.json --profile $profile_aws
aws s3api put-bucket-tagging --bucket $bucketName --tagging file://tags-bucket.json --profile $profile_aws
aws iam put-role-policy --role-name dms-vpc-role --policy-name S3AccessPolicy --policy-document file://policy.json --profile $profile_aws

aws dms delete-replication-task-assessment-run --replication-task-assessment-run-arn <assessment-run-arn> --profile $profile_aws
aws dms start-replication-task-assessment-run --replication-task-arn $replicationTaskArn --service-access-role-arn arn:aws:iam::415071355886:role/dms-vpc-role --result-location-bucket $bucketName --result-location-folder migration --assessment-run-name "avaliacao-inicial-2"  --profile $profile_aws

k config use-context arn:aws:eks:sa-east-1:415071355886:cluster/datahub-prod
aws secretsmanager get-secret-value --secret-id "rds!cluster-36ec8ef7-ad01-4034-93a2-61c17675d8e3" --profile datahubprod
k exec -it ubuntu-pod -- bash
# mysql -u admin -p -h eec-aws-br-eits-datahub-prod-pep-aurora.cluster-cpvfmbpitn3a.sa-east-1.rds.amazonaws.com -P 3306

# Antes da migração:
aws rds modify-db-cluster-parameter-group --db-cluster-parameter-group-name eec-aws-br-eits-datahub-prod-pep-aurora-pg --parameters "ParameterName=net_read_timeout,ParameterValue=300,ApplyMethod=immediate" "ParameterName=net_write_timeout,ParameterValue=300,ApplyMethod=immediate" "ParameterName=wait_timeout,ParameterValue=300,ApplyMethod=immediate" "ParameterName=local_infile,ParameterValue=1,ApplyMethod=immediate" --profile $profile_aws

# Depois da migração:
aws rds modify-db-cluster-parameter-group --db-cluster-parameter-group-name eec-aws-br-eits-datahub-prod-pep-aurora-pg --parameters "ParameterName=innodb_autoinc_lock_mode,ParameterValue=1,ApplyMethod=pending-reboot" --profile $profile_aws

aws rds reboot-db-instance --db-instance-identifier eec-aws-br-eits-datahub-prod-pep-aurora-0 --profile $profile_aws
aws rds reboot-db-instance --db-instance-identifier eec-aws-br-eits-datahub-prod-pep-aurora-1 --profile $profile_aws

CREATE TABLE parent_table (
  id INT PRIMARY KEY,
  name VARCHAR(255)
);

CREATE TABLE child_table (
  id INT PRIMARY KEY,
  parent_id INT,
  name VARCHAR(255),
  FOREIGN KEY (parent_id) REFERENCES parent_table(id)
);

DELIMITER //

CREATE TRIGGER after_delete_trigger
AFTER DELETE ON parent_table
FOR EACH ROW
BEGIN
  DELETE FROM child_table WHERE parent_id = OLD.id;
END//

DELIMITER ;

aws dms start-replication-task-assessment-run --replication-task-arn $replicationTaskArn --service-access-role-arn arn:aws:iam::415071355886:role/dms-vpc-role --result-location-bucket $bucketName --result-location-folder migration --assessment-run-name "avaliacao-inicial-4"  --profile $profile_aws

$replicationTaskArn = 'arn:aws:dms:sa-east-1:415071355886:task:EFW6MEHXWZCTLOHG4GP3WRCWEY'
aws dms start-replication-task  --replication-task-arn $replicationTaskArn --start-replication-task-type start-replication --profile $profile_aws
aws dms start-replication-task --replication-task-arn $replicationTaskArn --start-replication-task-type reload-target --profile $profile_aws

# Após a migração será necessário recriar as constraints do banco
ALTER TABLE pep_titulares_mandatos_silver
ADD CONSTRAINT co_cargo_0
FOREIGN KEY (co_cargo)
REFERENCES pep_cargos(co_cargo)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE pep_titulares_mandatos_silver
ADD CONSTRAINT co_orgao_0
FOREIGN KEY (co_orgao)
REFERENCES pep_orgaos(co_orgao)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE db_pep.pep_titulares_mandatos_silver MODIFY id BIGINT AUTO_INCREMENT;