# logar na conta
Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\vulnerabilidades"

saml2aws.exe login -a eec-aws-br-eits-dx-lab05-sandbox
aws eks list-clusters --profile arcsandbox
aws eks update-kubeconfig --region sa-east-1 --name nike-tech-dev --profile arcsandbox
kubectl get namespaces
NAME                STATUS   AGE
apigee-system       Active   67d
default             Active   68d
istio-system        Active   67d
kube-node-lease     Active   68d
kube-public         Active   68d
kube-system         Active   68d
monitoring-system   Active   67d
velero              Active   67d

# atualização do metric-server
helm list -n kube-system
helm get values metrics-server  -n kube-system -o yaml > metrics-server-values.yaml
cat .\metrics-server-values.yaml
helm upgrade metrics-server --version 3.12.1 metrics-server/metrics-server -n kube-system

# atualização do kubecost
kubectl get namespaces
# ...
# monitoring-system   Active   68d
# ...

helm list -n monitoring-system
# ...
# kubecost                        monitoring-system       1               2024-02-22 15:40:02.699685317 -0300 -03 deployed        cost-analyzer-1.100.2             1.100.2
# ...

helm get values kubecost -n monitoring-system -o yaml > kubecost-values.yaml
cat .\kubecost-values.yaml

helm repo add kubecost https://kubecost.github.io/cost-analyzer/

# DevSecOps
helm upgrade --reuse-values kubecost --version 2.2.3 -n monitoring-system --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer --set kubecostToken="aGVsbUBrdWJlY29zdC5jb20=xm343yadf98" --set global.gcpstore.enabled=false --set global.gmp.enabled=false --set kubecostFrontend.livenessProbe.enabled=false

# ChatGpt
helm upgrade --reuse-values kubecost --version 2.0.0 -n monitoring-system --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer --set kubecostToken="aGVsbUBrdWJlY29zdC5jb20=xm343yadf98" --set global.gcpstore.enabled=false --set global.gmp.enabled=false --set kubecostFrontend.livenessProbe.enabled=false --set kubecostModel.plugins.enabled=false

# Funcionou assim
helm upgrade kubecost --version 2.2.3 -n monitoring-system --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer --set kubecostToken="aGVsbUBrdWJlY29zdC5jb20=xm343yadf98" 

# Atualização do Kiali 
helm list -n istio-system
# ...
# kiali                   istio-system    1               2024-02-22 15:40:08.549741604 -0300 -03 deployed        kiali-server-1.63.2             v1.63.2
# ...
helm get values kiali -n istio-system -o yaml > kiali-values.yaml
cat .\kiali-values.yaml

helm search repo https://kiali.org/helm-charts/ kiali-server --versions --devel

helm upgrade kiali --reuse-values --version v1.73.0 --namespace istio-system --set auth.strategy=anonymous --set deployment.image_version=v1.73.0 --set external_services.prometheus.url=http://kube-prometheus-stack-prometheus.monitoring-system:9090 --set kiali_feature_flags.clustering.autodetect_secrets.enabled=false --repo https://kiali.org/helm-charts/ kiali-server

helm upgrade kiali --reuse-values --version v1.84.0 --namespace istio-system --set auth.strategy=anonymous --set deployment.image_version=v1.83.0 --set external_services.prometheus.url=http://kube-prometheus-stack-prometheus.monitoring-system:9090 --set clustering.autodetect_secrets.enabled=false --set=server.observability.metrics.enabled=false --repo https://kiali.org/helm-charts/ kiali-server

# Em nosso caso, nosso cluster estava na v1.63.2 e foi necessário atualizar para a 1.73.0 e depois para a 1.80, por conta de um parâmetro que foi alterado (clustering.autodetect_secrets.enabled)

# Atualização do Prometheus
helm list -n monitoring-system
# ...
# kube-prometheus-stack           monitoring-system       1               2024-02-22 15:38:24.615605827 -0300 -03 deployed        kube-prometheus-stack-35.6.2      0.56.3
# ...
helm get values kube-prometheus-stack -n monitoring-system -o yaml > kube-prometheus-stack-values.yaml
cat .\kube-prometheus-stack-values.yaml

# Instalando repositório Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 76 --dependency-update --namespace monitoring-system
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 37 --dependency-update --namespace monitoring-system
kubectl --namespace monitoring-system get daemonset
kubectl --namespace monitoring-system delete daemonset kube-prometheus-stack-prometheus-node-exporter
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 40 --dependency-update --values kube-prometheus-stack-values.yaml --namespace monitoring-system
# Para remover, edite o values que foi gerado no "Procedimentos de segurança" e busque pela lista "resources" e remova o verticalpodautoscalers dela.
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 46 --dependency-update --values kube-prometheus-stack-values.yaml --namespace monitoring-system
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 58.4.0 --dependency-update --values kube-prometheus-stack-values.yaml --namespace monitoring-system

# Flagger
helm list -n istio-system
# ...
# flagger                 istio-system    1               2024-02-22 15:40:05.160450213 -0300 -03 deployed        flagger-1.36.0                  1.36.0
# ...
helm get values flagger -n istio-system -o yaml > flagger-values.yaml
cat .\flagger-values.yaml

helm upgrade flagger --namespace istio-system --version 1.37.0 --set meshProvider=istio --set metricsServer=http://kube-prometheus-stack-prometheus.monitoring-system:9090 --repo https://flagger.app/ flagger


# Istio
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

# O prometheus atualiza esse pacote


saml2aws.exe login -a eec-aws-br-eits-dx-lab05-sandbox
# Atualização do cluster
$profile_aws="arcsandbox"
$versao = "1.29"
# Listar os clusters - ver se tem mais de um cluster na conta
aws eks list-clusters --profile $profile_aws --output text

# Nesse caso estou realizando a operação no primeiro cluster, o cluster[0]
$cluster_name = aws eks list-clusters --profile $profile_aws --query "clusters[0]" --output text

# Pegar o contexto do kubectl nesse cluster, lembrar de ajustar a região onde o cluster está
aws eks update-kubeconfig --region sa-east-1 --name $cluster_name --profile $profile_aws

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
$sortedImages = $images | Sort-Object -Property @{Expression = {($_.Images.ImageLocation -split '_',-1)}} -Descending
$novaAmi = $sortedImages.Images.ImageId[0]

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
    Write-Host $nodegroups.nodegroups[$i]
    $response = aws ec2 create-launch-template-version --launch-template-id $launchTemplateIds[$i] --profile $profile_aws --source-version $launchTemplateVersions[$i]  --launch-template-data $launchTemplateData --version-description "AWS UPDATE EKS AMI FROM $($amis[$i]) TO $novaami" | ConvertFrom-Json
    $VersionNumber = $response.LaunchTemplateVersion.VersionNumber
    $launchTemplateName = $response.LaunchTemplateVersion.LaunchTemplateName
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
