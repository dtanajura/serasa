# Listar os snapshots:
aws rds  describe-db-cluster-snapshots --profile datahubprod --query "DBClusterSnapshots[].DBClusterSnapshotIdentifier"

# Pegar detalhes do snapshot para restaurar:
aws rds  describe-db-cluster-snapshots --profile datahubprod --db-cluster-snapshot-identifier snapshot-antes-da-chg2523671

# lista os clusters:
aws rds describe-db-clusters --profile datahubprod --query "DBClusters[].DBClusterIdentifier"

# Ver caracteristicas do cluster existente:
aws rds describe-db-clusters --profile datahubprod --db-cluster-identifier "eec-aws-br-eits-datahub-prod-pep-aurora"

# Restaure o snapshot para um novo cluster de banco de dados:
aws rds restore-db-cluster-from-snapshot --db-cluster-identifier eec-aws-br-eits-datahub-prod-pep-aurora-new --snapshot-identifier snapshot-antes-da-chg2523671 --engine aurora-mysql --engine-version 8.0.mysql_aurora.3.05.2 --vpc-security-group-ids sg-01f7bcb2a25f028b4 --db-subnet-group-name eec-aws-br-eits-datahub-prod-pep-aurora-subnet --kms-key-id arn:aws:kms:sa-east-1:415071355886:key/2fc81dca-f375-4deb-b018-ccb558810df0 --database-name db_pep --profile datahubprod

# Monitora a criação
$status = "creating"
while ($status -eq "available") {
    $status = aws rds describe-db-clusters --profile datahubprod --db-cluster-identifier "eec-aws-br-eits-datahub-prod-pep-aurora-new" --query "DBClusters[].Status" --output text
    Write-Host "Status atual: $status"
    Start-Sleep -Seconds 30
}


# Crie uma nova instância de banco de dados no cluster restaurado:
aws rds create-db-instance --db-instance-identifier eec-aws-br-eits-datahub-prod-pep-aurora-new-0 --db-cluster-identifier eec-aws-br-eits-datahub-prod-pep-aurora-new --db-instance-class db.r7g.xlarge --engine aurora-mysql --profile datahubprod

# Monitora a criação
$status = "creating"
while ($status -ne "creating") {
    $status = aws rds describe-db-instances --db-instance-identifier eec-aws-br-eits-datahub-prod-pep-aurora-new-0 --profile datahubprod --query "DBInstances[].DBInstanceStatus" --output text
    Write-Host "Status atual: $status"
    Start-Sleep -Seconds 30
}

# Mudar a senha
aws rds modify-db-cluster --db-cluster-identifier eec-aws-br-eits-datahub-prod-pep-aurora-new --master-user-password "JRhAEuu.Y!sFl|*s6r#RZKTlovi_" --apply-immediately --profile datahubprod


$status = "pending"
while ($status -eq "pending") {
    Start-Sleep -Seconds 30
    $status = aws ec2 describe-snapshots --profile dsprod --filters Name=description,Values="sre-prod-grafana-pipeobservability-31.03.2025" --query "Snapshots[].State" --output text
    Write-Host "Status atual: $status"
}
