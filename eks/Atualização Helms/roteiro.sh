## Procedimento inicial
# Ir para a pasta
Set-Location C:\tmp
# Fazer um clone do repositório
git clone https://code.experian.local/scm/nikesre/gitops-eks-mgmt.git
# Criar uma branch
git checkout -b c96531a/Helm-Update-eec-aws-us-eits-negativo-dev-30.09.25
# Criar uma pasta da conta 
mkdir 300374333803-eec-aws-us-eits-negativo-dev
# Logar na conta
okta-aws-cli web --profile negativodev
# Pegar o contexto do cluster
aws eks list-clusters --profile negativodev --region us-east-1 #Confirmar qual o cluster
kubectl config get-contexts
Kubectl config use-context arn:aws:eks:us-east-1:300374333803:cluster/negativo-us-dev 

## Verificações
kubectl get nodes #verificar se o cluster está com nodes
aws eks update-nodegroup-config `
  --cluster-name "negativo-us-dev" `
  --nodegroup-name "EKS-negativo-us-dev-NG-infra-20250605122215975700000014" `
  --scaling-config desiredSize=1 `
  --profile negativodev --region us-east-1

aws eks update-nodegroup-config `
  --cluster-name "negativo-us-dev" `
  --nodegroup-name "EKS-negativo-us-dev-NG-large-2025060512273583870000001f" `
  --scaling-config desiredSize=1 `
  --profile negativodev --region us-east-1

## Atualização dos repos do helm
# Listar os repos
helm list -A

# aws-efs-csi-driver
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm search repo aws-efs-csi-driver
helm repo update
mkdir "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\aws-efs-csi-driver"
helm get values aws-efs-csi-driver -n kube-system > "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\aws-efs-csi-driver\aws-efs-csi-driver-values.yaml"
# No arquivo de values comentar campos de image e sidecar

helm upgrade aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver `
  --namespace kube-system `
  --values "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\aws-efs-csi-driver\aws-efs-csi-driver-values.yaml"

## Confirmação da atualização
# aws-efs-csi-driver              kube-system             1               2025-06-05 09:37:47.706123678 -0300 -03 deployed  aws-efs-csi-driver-3.1.9        2.1.8
# aws-efs-csi-driver              kube-system             3               2025-09-30 12:10:31.9815928 -0300 -03   deployed  aws-efs-csi-driver-3.2.3        2.1.12

################### aws-vpc-cni-eniconfigs - não é necessário atualizar apenas o add-on vpc-cni
# Verificar versões disponíveis do add-on - obter a versão mais nova
aws eks describe-addon-versions `
  --addon-name vpc-cni `
   --profile negativodev `
   --query "addons.addonVersions.addonVersion" --output text

# Verificar versão atual instalada no cluster
aws eks describe-addon `
  --cluster-name negativo-us-dev `
  --addon-name vpc-cni `
  --profile negativodev

# Para atualizar o addon vpc-cni, você pode usar o comando:
aws eks update-addon `
  --cluster-name negativo-us-dev `
  --addon-name vpc-cni `
  --addon-version v1.20.3-eksbuild.1 `
  --profile negativodev

aws eks describe-addon `
  --cluster-name negativo-us-dev `
  --addon-name vpc-cni `
  --profile negativodev

################# cluster-autoscaler
# Adicionar (ou atualizar) o repositório do Helm
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update

# Verificar as versões disponíveis
helm search repo autoscaler/cluster-autoscaler --versions

# Manter as configurações atuais
$pack = "cluster-autoscaler"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack"
helm get values $pack -n kube-system > "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"

# Atualizar
helm upgrade $pack autoscaler/cluster-autoscaler `
  --version 9.50.1 `
  -n kube-system `
  -f "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"

# verificar
kubectl -n kube-system logs -l app.kubernetes.io/name=aws-cluster-autoscaler `
  -l app.kubernetes.io/instance=cluster-autoscaler

helm list -A | Select-String $pack
# cluster-autoscaler              kube-system             1               2025-06-05 09:37:39.617441697 -0300 -03 deployed        cluster-autoscaler-9.46.0       1.32.0
# cluster-autoscaler              kube-system             2               2025-09-30 15:04:04.3929309 -0300 -03   deployed        cluster-autoscaler-9.50.1       1.33.0

############ kube-prometheus-stack
# Versão mais atual
helm search repo kube-prometheus-stack --versions
# NAME                                            CHART VERSION   APP VERSION     DESCRIPTION
# prometheus-community/kube-prometheus-stack      77.12.0         v0.85.0         kube-prometheus-stack collects Kubernetes manif...
# prometheus-community/kube-prometheus-stack      77.11.1         v0.85.0         kube-prometheus-stack collects Kubernetes manif...

# Manter as configurações atuais
$pack = "kube-prometheus-stack"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack"
helm get values $pack -n monitoring-system > "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"

# Atualizar
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack `
  --version 77.12.0 `
  -n monitoring-system `
  -f "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"

# kube-prometheus-stack           monitoring-system       2               2025-08-11 13:12:26.9017093 -0300 -03   deployed        kube-prometheus-stack-76.2.1    v0.84.1
# kube-prometheus-stack           monitoring-system       3               2025-09-30 15:43:41.7976339 -0300 -03   deployed        kube-prometheus-stack-77.12.0   v0.85.0


##### external-dns
# Repositório
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/

# Versão mais atual
helm search repo external-dns/external-dns --versions

# Manter as configurações atuais
$pack = "external-dns"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack"
helm get values $pack -n kube-system > "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"

# Atualizar
helm upgrade external-dns external-dns/external-dns `
  --version 1.19.0 `
  -n kube-system 

# external-dns                    kube-system             1               2025-06-05 09:38:16.065607618 -0300 -03 deployed        external-dns-1.15.2             0.15.1
# external-dns                    kube-system             7               2025-09-30 16:07:37.7011828 -0300 -03   deployed        external-dns-1.19.0             0.19.0

kubectl get pods -n kube-system | Select-String $pack
kubectl describe pod external-dns-5989477b57-lhzn4 -n kube-system | Select-String "image"


######### kube-prometheus-dashboards, grafana-ingress, prometheus-ingress, setup-rbac
# Não faz atualização

############ istio-base
# Versão mais atual
$repo = "istio/base"
helm search repo $repo --versions
# istio/base                              1.27.1          1.27.1          Helm chart for deploying Istio cluster resource...

# Manter as configurações atuais
$pack = "istio-base"
$namespace = "istio-system"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"

# Atualizar
helm upgrade $pack $repo `
  --version 1.27.1 `
  -n $namespace 

# istio-base                      istio-system            2               2025-08-07 15:05:33.6085885 -0300 -03   deployedbase-1.26.3                     1.26.3
# istio-base              istio-system    3               2025-09-30 17:41:54.831846 -0300 -03    deployed        base-1.27.1                     1.27.1

######## istio-ingress
$repo = "istio/gateway"
helm search repo $repo --versions
# istio/gateway                           1.27.1          1.27.1          Helm chart for deploying Istio gateways

# Manter as configurações atuais
$pack = "istio-ingress"
$namespace = "istio-system"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"

# Atualizar
helm upgrade istio-ingress istio/gateway `
  --namespace istio-system `
  --version 1.27.1 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml" 

# istio-ingress      istio-system    2               2025-08-07 15:11:47.898032 -0300 -03    deployed        gateway-1.26.3                  1.26.3
# istio-ingress      istio-system    3               2025-09-30 18:01:25.7894993 -0300 -03   deployed        gateway-1.27.1                  1.27.1

####### istiod
$repo = "istio/istiod"
helm search repo $repo --versions
# istio/istiod            1.27.1          1.27.1          Helm chart for istio control plane

# Manter as configurações atuais
$pack = "istiod"
$namespace = "istio-system"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"

# Atualizar
helm upgrade istiod istio/istiod `
  --namespace istio-system `
  --version 1.27.1 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml" 

# istiod                  istio-system    3               2025-08-08 16:52:10.4176317 -0300 -03   deployed   istiod-1.26.3                   1.26.3
# istiod                  istio-system    4               2025-09-30 18:08:44.1103124 -0300 -03   deployed   istiod-1.27.1                   1.27.1

##### metrics-server
$repo = "metrics-server/metrics-server"
helm search repo $repo --versions
# metrics-server/metrics-server   3.13.0          0.8.0           Metrics Server is a scalable, efficient source ...

# Manter as configurações atuais
$pack = "metrics-server"
$namespace = "kube-system"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"

# Atualizar
helm upgrade $pack $repo `
  --namespace $namespace `
  --version 3.13.0 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml" 


# metrics-server                  kube-system             1               2025-06-05 09:34:22.77464688 -0300 -03  deployed  metrics-server-3.12.2           0.7.2
# metrics-server                  kube-system             2               2025-09-30 18:15:12.4435452 -0300 -03   deployed  metrics-server-3.13.0           0.8.0

####### velero
$repo = "velero/velero"
helm search repo $repo --versions
# velero/velero   11.0.0          1.17.0          A Helm chart for velero

# Manter as configurações atuais
$pack = "velero"
$namespace = "velero"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml"

# Atualizar
helm upgrade $pack $repo `
  --namespace $namespace `
  --version 11.0.0 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\300374333803-eec-aws-us-eits-negativo-dev\$pack\values.yaml" 

# velero         velero       1       2025-06-05 09:38:00.239242898 -0300 -03 deployed   velero-8.4.0       1.15.2
# velero         velero       4       2025-09-30 18:48:43.7571519   -0300 -03 deployed   velero-11.0.0      1.17.0



# Obter todos os deployments em todos os namespaces
$deployments = kubectl get deployments --all-namespaces -o json | ConvertFrom-Json

foreach ($item in $deployments.items) {
    $name = $item.metadata.name
    $namespace = $item.metadata.namespace

    Write-Host "Reiniciando deployment '$name' no namespace '$namespace'..."
    kubectl rollout restart deployment $name -n $namespace
}


# Obter todos os ReplicaSets em formato JSON
$rs_json = kubectl get rs -A -o json | ConvertFrom-Json

# Iterar sobre os itens
foreach ($rs in $rs_json.items) {
    $desired = $rs.spec.replicas
    $current = $rs.status.replicas
    $ready = $rs.status.readyReplicas

    # Tratar valores nulos como 0
    if (-not $desired) { $desired = 0 }
    if (-not $current) { $current = 0 }
    if (-not $ready) { $ready = 0 }

    # Verificar se todos são zero
    if ($desired -eq 0 -and $current -eq 0 -and $ready -eq 0) {
        $name = $rs.metadata.name
        $namespace = $rs.metadata.namespace
        Write-Host "Apagando ReplicaSet: $name no namespace: $namespace"
        kubectl delete rs $name -n $namespace
    }
}
