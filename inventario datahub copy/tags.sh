
aws acm add-tags-to-certificate `
    --certificate-arn arn:aws:acm:sa-east-1:730335661246:certificate/1691277f-da78-4504-b42d-bff99988dcf5 `
    --tags file://tags.json `
    --profile datahubdev


aws acm add-tags-to-certificate `
    --certificate-arn arn:aws:acm:sa-east-1:730335661246:certificate/e51dd6c1-83ae-46fc-ae3a-69cfe675faad `
    --tags file://tags.json `
    --profile datahubdev




# Lista de ARNs dos Auto Scaling Groups
$asgArns = @(
    "arn:aws:autoscaling:sa-east-1:730335661246:autoScalingGroup:1c3ae9e0-50ae-4469-ae9f-e8d904727c43:autoScalingGroupName/eks-EKS-datahub-dev-NG-infra-20240626184642173200000001-c4c82aef-8bb1-abe7-81b9-23d9e38e3f8b",
    "arn:aws:autoscaling:sa-east-1:730335661246:autoScalingGroup:955c70e4-ad76-4823-a8e1-7d6254fe367d:autoScalingGroupName/eks-EKS-datahub-dev-NG-large-1acac540-a5c7-0bec-7335-bb809886ac61",
    "arn:aws:autoscaling:sa-east-1:730335661246:autoScalingGroup:c58d2b8e-ec30-4b8a-be61-4d5957634dd4:autoScalingGroupName/eks-EKS-datahub-dev-NG-spot-2024062523245244660000003a-d2c828db-b3d3-3eb7-f6ab-ca5bbf392223",
    "arn:aws:autoscaling:sa-east-1:730335661246:autoScalingGroup:e14656da-6e43-46e7-a953-4300bdf38c7a:autoScalingGroupName/eks-EKS-datahub-dev-NG-medium-2024062523245245430000003e-42c828db-b3d3-752c-6fc3-8e04f38b8c2f",
    "arn:aws:autoscaling:sa-east-1:730335661246:autoScalingGroup:f9ee961b-4502-4b3b-b95b-417665020a0f:autoScalingGroupName/eks-EKS-datahub-dev-NG-small-20240625232452457500000040-66c828db-b3d3-744a-8f7a-ab065b607d7e"
)

# Perfil AWS CLI
$profileaws = "datahubdev"

foreach ($arn in $asgArns) {
    # Extrai o nome do Auto Scaling Group (depois de 'autoScalingGroupName/')
    $asgName = $arn.Split("/")[-1]

    Write-Host "Aplicando tags no Auto Scaling Group: $asgName"

    try {
        aws autoscaling create-or-update-tags `
            --tags `
            ResourceId=$asgName,ResourceType=auto-scaling-group,Key=AppID,Value=23008,PropagateAtLaunch=true `
            ResourceId=$asgName,ResourceType=auto-scaling-group,Key=CostString,Value=1800.BR.134.602018,PropagateAtLaunch=true `
            ResourceId=$asgName,ResourceType=auto-scaling-group,Key=Environment,Value=dev,PropagateAtLaunch=true `
            --profile $profileaws

        Write-Host "✅ Sucesso: $asgName" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Erro ao aplicar tags no Auto Scaling Group: $asgName" -ForegroundColor Red
    }
}



aws ec2 create-tags `
    --resources vol-01733cd9506695586 `
    --tags file://tags.json `
    --profile datahubdev

aws ec2 create-tags `
    --resources vol-072607d7be4e61d2c `
    --tags file://tags.json `
    --profile datahubdev

aws ec2 create-tags `
    --resources vol-0f53f74bb8308ecb9 `
    --tags file://tags.json `
    --profile datahubdev


aws elbv2 add-tags `
    --resource-arns arn:aws:elasticloadbalancing:sa-east-1:730335661246:loadbalancer/app/airflow-alb/02e89c57f9a2ac82 `
    --tags file://tags.json `
    --profile datahubdev

aws elbv2 add-tags `
    --resource-arns arn:aws:elasticloadbalancing:sa-east-1:730335661246:loadbalancer/app/mwaalb/8beea6943060e137 `
    --tags file://tags.json `
    --profile datahubdev


aws rds describe-db-snapshots `
    --db-snapshot-identifier eec-aws-br-eits-datahub-dev-infonext-2025-11-20-01-21 `
    --region sa-east-1 `
    --profile datahubdev


aws rds modify-db-instance `
    --db-instance-identifier eec-aws-br-eits-datahub-dev-infonext `
    --copy-tags-to-snapshot `
    --apply-immediately `
    --region sa-east-1 `
    --profile datahubdev


# Lista de snapshots
$snapshots = @(
    "arn:aws:rds:sa-east-1:730335661246:snapshot:rds:eec-aws-br-eits-datahub-dev-infonext-2025-11-23-01-21",
    "arn:aws:rds:sa-east-1:730335661246:snapshot:rds:eec-aws-br-eits-datahub-dev-infonext-2025-11-25-01-15",
    "arn:aws:rds:sa-east-1:730335661246:snapshot:rds:eec-aws-br-eits-datahub-dev-infonext-2025-11-26-01-20",
    "arn:aws:rds:sa-east-1:730335661246:snapshot:rds:eec-aws-br-eits-datahub-dev-infonext-2025-11-27-01-20",
    "arn:aws:rds:sa-east-1:730335661246:snapshot:rds:eec-aws-br-eits-datahub-dev-infonext-2025-11-28-01-20",
    "arn:aws:rds:sa-east-1:730335661246:snapshot:rds:eec-aws-br-eits-datahub-dev-infonext-2025-11-29-01-20",
    "arn:aws:rds:sa-east-1:730335661246:snapshot:rds:eec-aws-br-eits-datahub-dev-infonext-2025-11-30-01-21",
    "arn:aws:rds:sa-east-1:730335661246:snapshot:rds:eec-aws-br-eits-datahub-dev-infonext-2025-12-01-01-21"
)

$profileaws = "datahubdev"
$tagsFile = ".`tags.json"

foreach ($snap in $snapshots) {
    $arn = $snap
    $snap = $arn.Split(":")[-1]
    Write-Host "Aplicando tags no snapshot: $arn"
    try {
        aws rds add-tags-to-resource `
            --resource-name $arn `
            --tags file://$tagsFile `
            --profile $profileaws
        Write-Host "✅ Sucesso: $snap" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Erro ao aplicar tags no snapshot: $snap" -ForegroundColor Red
    }
}


aws s3api put-bucket-tagging `
    --bucket aws-logs-730335661246-sa-east-1 `
    --tagging file://tags.json `
    --profile datahubdev

aws s3api put-bucket-tagging `
    --bucket cf-templates-ifp6h6qckzov-sa-east-1 `
    --tagging file://tags.json `
    --profile datahubdev

aws s3api put-bucket-tagging `
    --bucket experian-datahub-comporta-serverlessdeploymentbuck-h3k6lt8hyr7a `
    --tagging file://tags.json `
    --profile datahubdev

aws s3api put-bucket-tagging `
    --bucket rulextract-ai `
    --tagging file://tags.json `
    --profile datahubdev

aws s3api put-bucket-tagging `
    --bucket tfstate-730335661246-sa-east-1-prd `
    --tagging file://tags.json `
    --profile datahubdev


aws s3api get-bucket-tagging `
    --bucket experian-datahub-comporta-serverlessdeploymentbuck-h3k6lt8hyr7a `
    --profile datahubdev

### Datahub Stage
aws acm add-tags-to-certificate `
    --certificate-arn arn:aws:acm:sa-east-1:527623259369:certificate/65d40cfb-0dee-450b-ba0d-8ddbe5344356 `
    --tags file://tags.json `
    --profile datahubstage


# Lista de ARNs dos Auto Scaling Groups
$asgArns = @(
    "arn:aws:autoscaling:sa-east-1:527623259369:autoScalingGroup:0bd4a02f-3d3e-4e84-a2cc-5fb63dcbcf1d:autoScalingGroupName/eks-EKS-datahub-uat-uat-NG-large-20251112195413977900000014-d2cd3cd1-054b-161c-7cbd-31ae3d087dc9",
    "arn:aws:autoscaling:sa-east-1:527623259369:autoScalingGroup:49b7a6c2-68cb-4079-9086-885aa7f143e0:autoScalingGroupName/eks-EKS-datahub-uat-uat-NG-infra-20251112195146088900000004-cacd3ccf-e482-a434-5cf9-d0f3a60b753e",
    "arn:aws:autoscaling:sa-east-1:527623259369:autoScalingGroup:50e8af6f-8386-434e-8a50-375fda34e0ed:autoScalingGroupName/eks-EKS-datahub-uat-uat-NG-spot-20251112195413976100000012-66cd3cd1-054b-b35c-3e7d-741c5ede8126",
    "arn:aws:autoscaling:sa-east-1:527623259369:autoScalingGroup:e1166636-3570-4bee-857d-00aaca3d8910:autoScalingGroupName/eks-EKS-datahub-uat-uat-NG-small-20251112195413973400000010-0ecd3cd1-0546-4d8a-8443-3f7eaf128aa5",
    "arn:aws:autoscaling:sa-east-1:527623259369:autoScalingGroup:f9a694d6-24e3-4eff-808f-40d701b97c28:autoScalingGroupName/eks-EKS-datahub-uat-uat-NG-medium-2025111219541396210000000e-b4cd3cd1-0543-0d4b-8a4c-d00a173e9cc1"
)

# Perfil AWS CLI
$profileaws = "datahubstage"

foreach ($arn in $asgArns) {
    # Extrai o nome do Auto Scaling Group (depois de 'autoScalingGroupName/')
    $asgName = $arn.Split("/")[-1]

    Write-Host "Aplicando tags no Auto Scaling Group: $asgName"

    try {
        aws autoscaling create-or-update-tags `
            --tags `
            ResourceId=$asgName,ResourceType=auto-scaling-group,Key=AppID,Value=23008,PropagateAtLaunch=true `
            ResourceId=$asgName,ResourceType=auto-scaling-group,Key=CostString,Value=1800.BR.134.602018,PropagateAtLaunch=true `
            ResourceId=$asgName,ResourceType=auto-scaling-group,Key=Environment,Value=dev,PropagateAtLaunch=true `
            --profile $profileaws

        Write-Host "✅ Sucesso: $asgName" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Erro ao aplicar tags no Auto Scaling Group: $asgName" -ForegroundColor Red
    }
}
