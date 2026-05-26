$profiles = @(
  "corporateprod",
  "arcsandbox",
  "ssrmdev",
  "ssrmsandbox",
  "ssrmprod",
  "corporatedev",
  "sredev",
  "dsstage",
  "dsprod",
  "dsdev",
  "datahubdev",
  "datahubprod",
  "consentdev",
  "consentprod"
)

# monitoring-system   prometheus-kube-prometheus-stack-prometheus-0                     1/2     CrashLoopBackOff   6 (3m15s ago)    8m59s
# ssbl-dev            ebisys-billing-dw-charging-legacy-api-74b6dd7f7c-x69z8            1/2     CrashLoopBackOff   15 (2m7s ago)    73m
# ssbl-qa             ebisys-billing-dw-charging-legacy-api-c6787cd8-57r86              1/2     CrashLoopBackOff   15 (2m3s ago)    73m

# logar na conta
Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\vulnerabilidades"

# Atualização do cluster
$profile_aws="ssrmprod"
$versao = "1.29"
# Listar os clusters - ver se tem mais de um cluster na conta
aws eks list-clusters --profile $profile_aws --output text

# Nesse caso estou realizando a operação no primeiro cluster, o cluster[0]
$cluster_name = aws eks list-clusters --profile $profile_aws --query "clusters[0]" --output text

# Pegar o contexto do kubectl nesse cluster, lembrar de ajustar a região onde o cluster está
aws eks update-kubeconfig --name $cluster_name --profile $profile_aws

kubectl get pods -A4 | Select-String -Pattern "CrashLoopBackOff"

# Verificar a versão atual e atualizar o cluster
aws eks describe-cluster --name $cluster_name --profile $profile_aws --query "cluster.version"

# Atualiza a versão do Cluster
aws eks update-cluster-version --name $cluster_name --profile $profile_aws --kubernetes-version $versao
# Aguarda a atualização do cluster
do {
    Start-Sleep -Seconds 10
    $status = aws eks describe-cluster --name $cluster_name --profile $profile_aws --query "cluster.status" --output text
    Write-Host $status
}
while ($status -ne "ACTIVE")
Write-Host "Cluster $cluster_name atualizado."


$images = aws ec2 describe-images --filters Name=architecture,Values=x86_64 Name=is-public,Values=false Name=name,Values="eec_aws_eks_amzn-lnx_2_$versao*" Name=state,Values=available --profile $profile_aws | ConvertFrom-Json
$sortedImages = $images.Images | Sort-Object -Property @{Expression = {($_.ImageLocation.Substring(41,10))}} -Descending
$novaAmi = $sortedImages.ImageId[0]
$dateStr = Get-Date
$dateStr = $dateStr.ToString("dd.MM.yy")

if ($novaAmi -ne "") {
  $amis = [System.Collections.ArrayList]::new()
  $launchTemplateIds = [System.Collections.ArrayList]::new()
  $launchTemplateVersions = [System.Collections.ArrayList]::new()

  $nodegroups = aws eks list-nodegroups --cluster-name $cluster_name --profile $profile_aws | ConvertFrom-Json

  foreach ($nodegroup in $nodegroups.nodegroups) {
    Write-Host "Verificando imagem $($nodegroup)"
    $resultado = aws eks describe-nodegroup --cluster-name $cluster_name --profile $profile_aws --nodegroup-name $nodegroup --query nodegroup.releaseVersion --output text
    $amis.add($resultado)
    $resultado = aws eks describe-nodegroup --cluster-name $cluster_name --profile $profile_aws --nodegroup-name $nodegroup --query nodegroup.launchTemplate.id --output text
    $launchTemplateIds.add($resultado)
    $resultado = aws eks describe-nodegroup --cluster-name $cluster_name --profile $profile_aws --nodegroup-name $nodegroup --query nodegroup.launchTemplate.version --output text
    $launchTemplateVersions.add($resultado)
  }

  $launchTemplateData = @{
      ImageId = $novaAmi
  }

  $launchTemplateData = $launchTemplateData | ConvertTo-Json 
  $launchTemplateData = $launchTemplateData -replace '"','""'

  for ($i = 0; $i -lt $launchTemplateIds.count; $i++) {
    if ($novaAmi -ne $amis[$i]) {
      Write-Host $nodegroups.nodegroups[$i]
      $response = aws ec2 create-launch-template-version --launch-template-id $launchTemplateIds[$i] --profile $profile_aws --source-version $launchTemplateVersions[$i]  --launch-template-data $launchTemplateData --version-description "AWS UPDATE EKS AMI FROM $($amis[$i]) TO $novaami - $dateStr" | ConvertFrom-Json
      $VersionNumber = $response.LaunchTemplateVersion.VersionNumber
      $launchTemplateName = $response.LaunchTemplateVersion.LaunchTemplateName
      aws ec2 modify-launch-template --launch-template-id $launchTemplateIds[$i] --profile $profile_aws --default-version $VersionNumber
      aws eks update-nodegroup-version --cluster-name $cluster_name --profile $profile_aws --nodegroup-name $nodegroups.nodegroups[$i] --launch-template name=$launchTemplateName,version=$VersionNumber --force
      do {
        Start-Sleep -Seconds 10
        $status = aws eks describe-nodegroup --cluster-name $cluster_name --profile $profile_aws --nodegroup-name $nodegroups.nodegroups[$i] --query "nodegroup.status" --output text
        Write-Host $status
      }
      while ($status -ne "ACTIVE")
      Write-Host "Nodegroup $nodegroups.nodegroups[$i] atualizado."
    }
  }
}
# ************************************************
# Atualização dos Add-ons
# ************************************************

# Obtendo a versão do Kubernetes do cluster
$clusterInfo = aws eks describe-cluster --name $cluster_name --profile $profile_aws | ConvertFrom-Json
$kubernetesVersion = $clusterInfo.cluster.version

# Listando todos os add-ons do cluster
$addons = aws eks list-addons --cluster-name $cluster_name --profile $profile_aws | ConvertFrom-Json


foreach ($addon in $addons.addons) {
  # Listando a versão instalada atualmente
  Write-Host ""
  Write-Host "**********************"
  aws eks describe-addon --cluster-name $cluster_name --profile $profile_aws --addon-name $addon --query "addon.[addonName,addonVersion]" --output text

  # Descrevendo as versões do add-on
  $addonVersions = aws eks describe-addon-versions --addon-name $addon --kubernetes-version $kubernetesVersion --profile $profile_aws | ConvertFrom-Json

  # Filtrando versões que são compatíveis com a versão do cluster
  $compatibleVersions = $addonVersions.addons[0].addonVersions | Where-Object {
      $_.compatibilities[0].clusterVersion -eq $kubernetesVersion
  }

  # Ordenando as versões de forma descendente (supondo que o número da versão faz parte do addonVersion)
  $sortedVersions = $compatibleVersions | Sort-Object { [Version]($_.addonVersion -replace "[^0-9.]", "") } -Descending

  # Selecionando a última versão compatível do add-on
  $latestVersion = $sortedVersions | Select-Object -First 1

  if ($latestVersion) {
    # Atualizando o add-on para a última versão compatível
    aws eks update-addon --cluster-name $cluster_name --addon-name $addon --addon-version $latestVersion.addonVersion --profile $profile_aws
    Write-Host "Atualizando $addon para a versão $($latestVersion.addonVersion). Aguardando conclusão..."
    
    # Aguardando até que a atualização seja concluída
    $status = "Updating"
    while ($status -eq "Updating") {
        Start-Sleep -Seconds 10  # Aguarda 10 segundos antes de verificar novamente
        $addonStatus = aws eks describe-addon --cluster-name $cluster_name --addon-name $addon --profile $profile_aws | ConvertFrom-Json
        $status = $addonStatus.addon.status
        Write-Host "Status da atualização de $addon : $status"
    }
    Write-Host "Atualização de $addon concluída."
  } else {
    Write-Host "Nenhuma versão compatível encontrada para $addon."
  }
}


aws eks update-nodegroup-config --cluster-name ds-eks-01-prod --nodegroup-name node_group_on_demand_large-2023121401491510520000002e --scaling-config minSize=1,maxSize=30,desiredSize=18 --profile dsprod


