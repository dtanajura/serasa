$profileAws="datahubdev"
# Listar os clusters EKS
$clusterName=aws eks list-clusters --profile $profileAws --output text --query "clusters"
aws eks list-nodegroups --cluster-name $clusterName --profile $profileAws

$nodegroups = aws eks list-nodegroups --cluster-name $clusterName --profile $profileAws | ConvertFrom-Json

foreach ($nodegroup in $nodegroups.nodegroups) {
    Write-Host "Verificando nodegroup $($nodegroup)"
    $resultado = aws eks describe-nodegroup  --profile $profileAws --cluster-name $clusterName --nodegroup-name $nodegroup --query 'nodegroup.resources.autoScalingGroups[0].name' --output text
    # aws eks describe-nodegroup --cluster-name $clusterName --profile $profileAws --nodegroup-name  EKS-datahub-dev-NG-infra-20240626184642173200000001 --query "nodegroup.scalingConfig"
    # Write-Host $resultado
    aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $resultado --query 'AutoScalingGroups[0].Instances' --profile $profileAws 
}

aws eks update-nodegroup-config --profile $profileAws --cluster-name $clusterName --nodegroup-name EKS-datahub-dev-NG-large-2024062523245244970000003c --scaling-config minSize=1,maxSize=3,desiredSize=2

aws eks update-nodegroup-config --profile $profileAws --cluster-name $clusterName --nodegroup-name EKS-datahub-dev-NG-spot-2024062523245244660000003a --scaling-config minSize=1,maxSize=3,desiredSize=1

aws eks describe-nodegroup  --cluster-name $clusterName
    --nodegroup-name <nome-do-nodegroup> \
    --query 'nodegroup.resources.autoScalingGroups[0].name' \
    --output text


$profileAws = "datahubprod"
$clusterName = "datahub-prod"
$nodegroupName = "EKS-datahub-prod-NG-large-20240321140228057000000046"

aws eks update-nodegroup-config --profile $profileAws --cluster-name $clusterName --nodegroup-name $nodegroupName --scaling-config minSize=1,maxSize=10,desiredSize=6

k config use-context arn:aws:eks:sa-east-1:415071355886:cluster/datahub-prod
# Switched to context "arn:aws:eks:sa-east-1:415071355886:cluster/datahub-prod".
PS â€¦\_outras tarefas\dms db-pep> k get nodes
# NAME                                           STATUS   ROLES    AGE     VERSION
# ip-10-120-173-10.sa-east-1.compute.internal    Ready    <none>   2m15s   v1.30.6-eks-94953ac
# ip-10-120-173-112.sa-east-1.compute.internal   Ready    <none>   2m13s   v1.30.6-eks-94953ac
# ip-10-120-173-120.sa-east-1.compute.internal   Ready    <none>   2m15s   v1.30.6-eks-94953ac
# ip-10-120-173-160.sa-east-1.compute.internal   Ready    <none>   2m16s   v1.30.6-eks-94953ac
# ip-10-120-173-166.sa-east-1.compute.internal   Ready    <none>   13d     v1.30.6-eks-94953ac
# ip-10-120-173-17.sa-east-1.compute.internal    Ready    <none>   5h37m   v1.30.6-eks-94953ac
# ip-10-120-173-171.sa-east-1.compute.internal   Ready    <none>   13d     v1.30.6-eks-94953ac
# ip-10-120-173-185.sa-east-1.compute.internal   Ready    <none>   13d     v1.30.6-eks-94953ac
# ip-10-120-173-57.sa-east-1.compute.internal    Ready    <none>   13d     v1.30.6-eks-94953ac
# ip-10-120-173-79.sa-east-1.compute.internal    Ready    <none>   13d     v1.30.6-eks-94953ac
# ip-10-120-173-89.sa-east-1.compute.internal    Ready    <none>   13d     v1.30.6-eks-94953ac

$nodegroupName = "EKS-datahub-prod-NG-medium-20240321140228052800000040"

aws eks update-nodegroup-config --profile $profileAws --cluster-name $clusterName --nodegroup-name $nodegroupName --scaling-config minSize=0,maxSize=10,desiredSize=0

$nodegroupName = "EKS-datahub-prod-NG-small-20240321140228055400000044"

aws eks update-nodegroup-config --profile $profileAws --cluster-name $clusterName --nodegroup-name $nodegroupName --scaling-config minSize=0,maxSize=10,desiredSize=0
