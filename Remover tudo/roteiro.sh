# Define o nome do cluster e o perfil AWS
$clusterName = "datahub-dev"
$profileAws = "datahubdev"
$region = "us-east-1"
# Descrever o cluster para obter detalhes do Security Group e da IAM Role
$clusterDetails = aws eks describe-cluster --name $clusterName --region $region --profile $profileAws | ConvertFrom-Json
$securityGroup = $clusterDetails.cluster.resourcesVpcConfig.securityGroupIds[0]
$roleArn = $clusterDetails.cluster.roleArn
$roleName = $roleArn.Split('/')[-1]  # Extrai o nome da role a partir do ARN


# ******************************************
# Removendo Load balancers
$loadbalancers = aws elbv2 --region $region --profile $profileAws describe-load-balancers | ConvertFrom-Json

foreach ($loadbalancer in $loadbalancers.LoadBalancers.LoadBalancerArn) {
    Write-Host "Removendo Load Balancer: $loadbalancer"
    aws elbv2 --region $region --profile $profileAws delete-load-balancer --load-balancer-arn $loadbalancer
}
$loadbalancers = aws elb --region $region --profile $profileAws describe-load-balancers | ConvertFrom-Json

foreach ($loadbalancer in $loadbalancers.LoadBalancers.LoadBalancerArn) {
    Write-Host "Removendo Load Balancer: $loadbalancer"
    aws elb --region $region --profile $profileAws delete-load-balancer --load-balancer-arn $loadbalancer
}

# ******************************************
# Removendo certificados
$certificates = aws acm --region $region --profile $profileAws list-certificates | ConvertFrom-Json

foreach ($certificate in $certificates.CertificateSummaryList.CertificateArn) {
    Write-Host "Removendo Certificate: $certificate"
    aws acm --region $region --profile $profileAws delete-certificate --certificate-arn $certificate
}

# ******************************************
# Removendo tabelas Cassandra
$keyspaces = aws keyspaces --region $region --profile $profileAws list-keyspaces | ConvertFrom-Json

foreach ($keyspace in $keyspaces.keyspaces.keyspaceName) {
    Write-Host "Removendo Keyspace: $keyspace"
    aws keyspaces --region $region --profile $profileAws delete-keyspace --keyspace-name $keyspace
}


# {
#     "BackupVaultList": [
#         {
#             "BackupVaultName": "aws/efs/automatic-backup-vault",
#             "BackupVaultArn": "arn:aws:backup:us-east-1:353091569218:backup-vault:aws/efs/automatic-backup-vault",
#             "CreationDate": "2024-02-22T12:01:09.114000-03:00",
#             "EncryptionKeyArn": "arn:aws:kms:us-east-1:353091569218:key/2a85d3e3-7be6-41ee-b658-fc416faf5958",
#             "CreatorRequestId": "aws/efs/automatic-backup-353091569218-us-east-1",
#             "NumberOfRecoveryPoints": 105,
#             "Locked": false
#         }
#     ]
# }

# ******************************************
# Removendo Cluster EKS

# Lista todos os NodeGroups do cluster
$nodeGroups = aws eks list-nodegroups --cluster-name $clusterName --region $region --profile $profileAws | ConvertFrom-Json

# Loop para remover cada NodeGroup
foreach ($nodeGroup in $nodeGroups.nodegroups) {
    Write-Host "Removendo NodeGroup: $nodeGroup"
    aws eks delete-nodegroup --cluster-name $clusterName --nodegroup-name $nodeGroup --region $region --profile $profileAws
    # Aguarda a remoção do NodeGroup
    do {
        Start-Sleep -Seconds 10
        $status = aws eks describe-nodegroup --cluster-name $clusterName --nodegroup-name $nodeGroup --region $region --profile $profileAws | ConvertFrom-Json
        Write-Host $status
    }
    while ($status.nodegroup.status -ne "DELETED" -and $status.nodegroup.status -ne $null)
    Write-Host "NodeGroup $nodeGroup removido."
}

# Lista o nome do cluster
Write-Host "Nome do Cluster: $clusterName"

# Remove o cluster
Write-Host "Removendo o cluster: $clusterName"
aws eks delete-cluster --name $clusterName --region $region --profile $profileAws

# Aguarda a remoção do cluster
do {
    Start-Sleep -Seconds 10
    $clusterStatus = aws eks describe-cluster --name $clusterName --region $region --profile $profileAws | ConvertFrom-Json
}
while ($clusterStatus.cluster.status -ne "DELETED" -and $clusterStatus.cluster.status -ne $null)
Write-Host "Cluster $clusterName removido."

# ******************************************
# Removendo Roles do IAM relacionadas ao Cluster
foreach ($role in aws iam list-roles --profile $profileaws --region $region --query "Roles[].Arn")
{
    if ($role.IndexOf($clusterName,0,$role.Length) -ne -1) {
        $role = $role.Replace('"','')
        $role = $role.Replace(' ','')
        $role = $role.Replace(',','')
 
        $roleName = $role.Split('/')[-1]  # Extrai o nome da role a partir do ARN
        Write-Host "Excluindo Role: $roleName"
        Write-Host "************************"
        Write-Host "aws iam list-attached-role-policies --role-name $roleName --region $region --profile $profileAws"
        $policies = aws iam list-attached-role-policies --role-name $roleName --region $region --profile $profileAws | ConvertFrom-Json
        foreach ($policy in $policies.AttachedPolicies) {
            Write-Host "Desassociando política $($policy.PolicyArn)"
            Write-Host "aws iam detach-role-policy --role-name $roleName --policy-arn $($policy.PolicyArn) --region $region --profile $profileAws"
            aws iam detach-role-policy --role-name $roleName --policy-arn $($policy.PolicyArn) --region $region --profile $profileAws
            Write-Host "aws iam delete-policy --policy-arn $($policy.PolicyArn) --region $region --profile $profileAws"
            aws iam delete-policy --policy-arn $($policy.PolicyArn) --region $region --profile $profileAws
            }
        Write-Host "aws iam list-role-policies --role-name $roleName --profile $profileaws --query \"PolicyNames\" --output text"
        $inlinePolicy= aws iam list-role-policies --role-name $roleName --profile $profileaws --query "PolicyNames" --output text
        Write-Host "aws iam delete-role-policy --role-name $roleName --policy-name $inlinePolicy --region $region --profile $profileAws"
        aws iam delete-role-policy --role-name $roleName --policy-name $inlinePolicy --region $region --profile $profileAws
 
        # Excluir a IAM Role
        Write-Host "aws iam delete-role --role-name $roleName --region $region --profile $profileAws"
        aws iam delete-role --role-name $roleName --region $region --profile $profileAws
 
    }
}
 

# ******************************************
# Excluir buckets relacionadas ao Cluster
$bucketNames=(aws s3 ls --region $region --profile $profileAws) | ForEach-Object {($_ -split ' ')[2]}
foreach ($bucket in $bucketNames)
{
    if ($bucket.IndexOf($clusterName,0,$bucket.Length) -ne -1) {
      
        Write-Host "Excluindo Bucket: $bucket"
        aws s3 rb s3://$bucket --force --region $region --profile $profileAws
        Write-Host "************************"
    }
}

# ******************************************
# Excluir EFS relacionadas ao Cluster
$filesystems=(aws efs describe-file-systems --region $region --profile $profileAws --query "FileSystems[].[FileSystemId,Tags[?Key=='ClusterName'].Value]" --output text)
foreach ($efs in $filesystems) {
    $name=""
    if ($efs.IndexOf("fs-") -eq -1) {$name=$efs} else {$id=$efs}  #,0,$efs.Length
    if ($name -eq $clusterName) {
        # Excluir os Access Points do EFS
        $accessPoints = aws efs describe-access-points --file-system-id $id --region $region --profile $profileAws | ConvertFrom-Json
        foreach ($ap in $accessPoints.AccessPoints) {
            Write-Host "Excluindo Access Point: $($ap.AccessPointId)"
            aws efs delete-access-point --access-point-id $ap.AccessPointId --region $region --profile $profileAws
        }
        Write-Host "linha $name e $id"
        # Excluir os Mount Targets do EFS
        $mountTargets = aws efs describe-mount-targets --file-system-id $id --region $region --profile $profileAws --query "MountTargets[].MountTargetId" --output text
        if ($mountTargets -ne "") {$mountTargets = $mountTargets.Split()}
        foreach ($mt in $mountTargets) {
            Write-Host "Excluindo Mount Target: $mt"
            aws efs delete-mount-target --mount-target-id $mt --region $region --profile $profileAws
        }
        # Excluir o EFS File System (deve esperar que todos os Access Points sejam excluídos)
        Write-Host "Excluindo EFS File System: $id"
        Start-Sleep -Seconds 10
        aws efs delete-file-system --file-system-id $id --region $region --profile $profileAws
    }
}


# ******************************************
# Excluir SGs relacionadas ao Cluster
$securityGroups=(aws ec2 describe-security-groups --query "SecurityGroups[*].[GroupId,GroupName]"  --profile=$profileAws --output text)
foreach ($sg in $securityGroups)
{
    if ($sg.IndexOf($clusterName,0,$sg.Length) -ne -1) {
        $id,$name = $sg.Split()
        Write-Host "Excluindo Security Group: $name"
        # Remover regras de inbound e outbound do Security Group
        $inboundRules = aws ec2 describe-security-group-rules --filters Name=group-id,Values=$id --region $region --profile $profileAws | ConvertFrom-Json
        foreach ($rule in $inboundRules.SecurityGroupRules) {
            Write-Host "Removendo regra de inbound: $($rule.SecurityGroupRuleId)"
            aws ec2 revoke-security-group-ingress --group-id $id --security-group-rule-ids $rule.SecurityGroupRuleId --region $region --profile $profileAws
        }
        $outboundRules = aws ec2 describe-security-group-rules --filters Name=group-id,Values=$id --region $region --profile $profileAws | ConvertFrom-Json
        foreach ($rule in $outboundRules.SecurityGroupRules) {
            Write-Host "Removendo regra de outbound: $($rule.SecurityGroupRuleId)"
            aws ec2 revoke-security-group-egress --group-id $id --security-group-rule-ids $rule.SecurityGroupRuleId --region $region --profile $profileAws
        }
        Write-Host "Excluindo Security Group: $id"
        aws ec2 delete-security-group --group-id $id --region $region --profile $profileAws
    }
}


do {
    Start-Sleep -Seconds 10
    $snapshotStatus = aws rds describe-db-cluster-snapshots --db-cluster-snapshot-identifier snapshot-eec-aws-br-eits-datahub-prod-pep-aurora-2024-10-10 --profile datahubprod --query "DBClusterSnapshots[].Status" --output text
}
while ($snapshotStatus -ne "creating")
Write-Host "Status $snapshotStatus"
