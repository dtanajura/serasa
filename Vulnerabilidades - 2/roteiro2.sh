kubectl config get-contexts


arn:aws:eks:sa-east-1:415071355886:cluster/datahub-prod
arn:aws:eks:sa-east-1:564593125549:cluster/eks-nike-tech-01-prod
arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod
arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-prod
arn:aws:eks:sa-east-1:916546429908:cluster/do-eks-01-dev
arn:aws:eks:us-east-1:975050357449:cluster/consentiment-prod
arn:aws:eks:us-east-1:992382670558:cluster/consentimento-dev

# 087086536124 - eec-aws-br-nike-ss-sandbox - ok
k config use-context arn:aws:eks:sa-east-1:087086536124:cluster/ssrm-eks-01-sandbox
kubectl config set-context --current --namespace=istio-system
helm list
mkdir ~/eec-aws-br-nike-ss-sandbox
cd ~/eec-aws-br-nike-ss-sandbox
helm get values istiod > istiod_values.yaml
helm get values istio-base > istiobase_values.yaml
helm get values istio-ingress > istioingress_values.yaml

notepad.exe istiod_values.yaml
<#
Pessoal o values do istiod deve ser 
global:
  proxy:
    resources:
      limits:
        cpu: 1000m
        memory: 512Mi
      requests:
        cpu: 50m
        memory: 128Mi
  proxy_init:
    image: istio-proxy
pilot:
  nodeSelector:
    Worker: infra
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 100m
      memory: 512Mi
  tolerations:
  - effect: NoSchedule
    key: dedicated
    operator: Equal
    value: infra
#>
notepad.exe istioingress_values.yaml

# 109804294614 - eec-aws-us-eits-positivo-dev - ok
$conta = "eec-aws-us-eits-positivo-dev"
$contexto = "arn:aws:eks:us-east-1:109804294614:cluster/positivo-us-dev"
k config use-context $contexto
kubectl config set-context --current --namespace=istio-system
helm list
mkdir ~/$conta
cd ~/$conta
helm get values istiod > istiod_values.yaml
helm get values istio-base > istiobase_values.yaml
helm get values istio-ingress > istioingress_values.yaml

notepad.exe istiod_values.yaml
notepad.exe istioingress_values.yaml
helm upgrade istiod istio/istiod --values istiod_values.yaml -n istio-system

$deployments = kubectl get deployments --all-namespaces -o json | ConvertFrom-Json

foreach ($item in $deployments.items) {
    $namespace = $item.metadata.namespace
    $name = $item.metadata.name

    Write-Host "Reiniciando deployment '$name' no namespace '$namespace'..."
    kubectl rollout restart deployment $name -n $namespace
}

# 146737708860 - eec-aws-br-ds-dataservices-stage - ok
$conta = "eec-aws-br-ds-dataservices-stage"
$contexto = "arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat"
k config use-context $contexto
kubectl config set-context --current --namespace=istio-system
helm list
mkdir ~/$conta
cd ~/$conta
helm get values istiod > istiod_values.yaml
helm get values istio-base > istiobase_values.yaml
helm get values istio-ingress > istioingress_values.yaml

notepad.exe istiod_values.yaml
notepad.exe istioingress_values.yaml
helm upgrade istiod istio/istiod --values istiod_values.yaml -n istio-system

# 187739130313 - eec-aws-br-nike-architecture-sandbox - ok
$conta = "eec-aws-br-nike-architecture-sandbox"
$contexto = "arn:aws:eks:sa-east-1:187739130313:cluster/nike-tech-dev"
k config use-context $contexto
kubectl config set-context --current --namespace=istio-system
helm list
mkdir ~/$conta
cd ~/$conta
helm get values istiod > istiod_values.yaml
helm get values istio-base > istiobase_values.yaml
helm get values istio-ingress > istioingress_values.yaml

notepad.exe istiod_values.yaml
notepad.exe istioingress_values.yaml
helm upgrade istiod istio/istiod --values istiod_values.yaml -n istio-system

# 300374333803 - eec-aws-us-eits-negativo-dev - ok
$conta = "eec-aws-us-eits-negativo-dev"
$contexto = "arn:aws:eks:us-east-1:300374333803:cluster/negativo-us-dev"
k config use-context $contexto
kubectl config set-context --current --namespace=istio-system
helm list
mkdir ~/$conta
cd ~/$conta
helm get values istiod > istiod_values.yaml
helm get values istio-base > istiobase_values.yaml
helm get values istio-ingress > istioingress_values.yaml

notepad.exe istiod_values.yaml
notepad.exe istioingress_values.yaml
helm upgrade istiod istio/istiod --values istiod_values.yaml -n istio-system


$deployments = kubectl get deployments --all-namespaces -o json | ConvertFrom-Json

foreach ($item in $deployments.items) {
    $namespace = $item.metadata.namespace
    $name = $item.metadata.name

    Write-Host "Reiniciando deployment '$name' no namespace '$namespace'..."
    kubectl rollout restart deployment $name -n $namespace
}


# 306716481758 - eec-aws-br-nike-ssrm-dev - pendente
$conta = "eec-aws-br-nike-ssrm-dev"
$contexto = "arn:aws:eks:sa-east-1:306716481758:cluster/sales-eks-01-uat"
k config use-context $contexto
kubectl config set-context --current --namespace=istio-system
helm list
mkdir ~/$conta
cd ~/$conta
helm get values istiod > istiod_values.yaml
helm get values istio-base > istiobase_values.yaml
helm get values istio-ingress > istioingress_values.yaml

notepad.exe istiod_values.yaml
notepad.exe istioingress_values.yaml
helm upgrade istiod istio/istiod --values istiod_values.yaml -n istio-system

# 530914589075 - eec-aws-br-ds-dataservices-dev - ok
$conta = "eec-aws-br-ds-dataservices-dev"
$contexto = "arn:aws:eks:sa-east-1:530914589075:cluster/ds-eks-01-dev"
k config use-context $contexto
kubectl config set-context --current --namespace=istio-system
helm list
mkdir ~/$conta
cd ~/$conta
helm get values istiod > istiod_values.yaml
helm get values istio-base > istiobase_values.yaml
helm get values istio-ingress > istioingress_values.yaml

notepad.exe istiod_values.yaml
notepad.exe istioingress_values.yaml
helm upgrade istiod istio/istiod --values istiod_values.yaml -n istio-system

# 730335661246 - eec-aws-br-eits-datahub-dev - ok
$conta = "eec-aws-br-eits-datahub-dev"
$contexto = "arn:aws:eks:sa-east-1:730335661246:cluster/datahub-dev"
k config use-context $contexto
kubectl config set-context --current --namespace=istio-system
helm list
mkdir ~/$conta
cd ~/$conta
helm get values istiod > istiod_values.yaml
helm get values istio-base > istiobase_values.yaml
helm get values istio-ingress > istioingress_values.yaml

notepad.exe istiod_values.yaml
notepad.exe istioingress_values.yaml
helm upgrade istiod istio/istiod --values istiod_values.yaml -n istio-system

# 877001948254 - eec-aws-br-nike-sales-prod - sales-eks-01-uat - pendente
$conta = "eec-aws-br-nike-sales-prod-cluster-uat"
$contexto = "arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-uat"
k config use-context $contexto
kubectl config set-context --current --namespace=istio-system
helm list
mkdir ~/$conta
cd ~/$conta
helm get values istiod > istiod_values.yaml
helm get values istio-base > istiobase_values.yaml
helm get values istio-ingress > istioingress_values.yaml

notepad.exe istiod_values.yaml
notepad.exe istioingress_values.yaml
helm upgrade istiod istio/istiod --values istiod_values.yaml -n istio-system

arn:aws:eks:sa-east-1:484240119361:cluster/do-eks-01-uat

# Tratamento dos containers zabbix
helm repo add zabbix-community https://zabbix-community.github.io/helm-zabbix
helm repo update

# eec-aws-br-ds-dataservices-stage (146737708860)
$conta = "eec-aws-br-ds-dataservices-stage"
$contexto = "arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat"
k config use-context $contexto
kubectl config set-context --current --namespace=zabbix
helm list
mkdir ~/$conta
cd ~/$conta
helm get values zabbix-sre > zabbix-sre_values.yaml

helm upgrade zabbix-sre zabbix-community/zabbix --version 7.0.12 -n zabbix
$deployments = kubectl get deployments -o json | ConvertFrom-Json

foreach ($item in $deployments.items) {
    $namespace = $item.metadata.namespace
    $name = $item.metadata.name

    Write-Host "Reiniciando deployment '$name' no namespace '$namespace'..."
    kubectl rollout restart deployment $name -n $namespace
}

<#
 k config get-contexts
CURRENT   NAME                                                               CLUSTER
                    AUTHINFO                                                           NAMESPACE
          arn:aws:eks:sa-east-1:087086536124:cluster/ssrm-eks-01-sandbox     arn:aws:eks:sa-east-1:087086536124:cluster/ssrm-eks-01-sandbox     arn:aws:eks:sa-east-1:087086536124:cluster/ssrm-eks-01-sandbox     istio-system
*         arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat           arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat           arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat           zabbix
          arn:aws:eks:sa-east-1:187739130313:cluster/nike-tech-dev           arn:aws:eks:sa-east-1:187739130313:cluster/nike-tech-dev           arn:aws:eks:sa-east-1:187739130313:cluster/nike-tech-dev           istio-system
          arn:aws:eks:sa-east-1:258050508433:cluster/lab05-sandbox           arn:aws:eks:sa-east-1:258050508433:cluster/lab05-sandbox           arn:aws:eks:sa-east-1:258050508433:cluster/lab05-sandbox
          arn:aws:eks:sa-east-1:306716481758:cluster/sales-eks-01-uat        arn:aws:eks:sa-east-1:306716481758:cluster/sales-eks-01-uat        arn:aws:eks:sa-east-1:306716481758:cluster/sales-eks-01-uat        istio-system
          arn:aws:eks:sa-east-1:415071355886:cluster/datahub-prod            arn:aws:eks:sa-east-1:415071355886:cluster/datahub-prod            arn:aws:eks:sa-east-1:415071355886:cluster/datahub-prod            istio-system
          arn:aws:eks:sa-east-1:484240119361:cluster/do-eks-01-uat           arn:aws:eks:sa-east-1:484240119361:cluster/do-eks-01-uat           arn:aws:eks:sa-east-1:484240119361:cluster/do-eks-01-uat
          arn:aws:eks:sa-east-1:530914589075:cluster/ds-eks-01-dev           arn:aws:eks:sa-east-1:530914589075:cluster/ds-eks-01-dev           arn:aws:eks:sa-east-1:530914589075:cluster/ds-eks-01-dev           istio-system
          arn:aws:eks:sa-east-1:564593125549:cluster/eks-nike-tech-01-prod   arn:aws:eks:sa-east-1:564593125549:cluster/eks-nike-tech-01-prod   arn:aws:eks:sa-east-1:564593125549:cluster/eks-nike-tech-01-prod   istio-system
          arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod          arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod          arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod          istio-system
          arn:aws:eks:sa-east-1:730335661246:cluster/datahub-dev             arn:aws:eks:sa-east-1:730335661246:cluster/datahub-dev             arn:aws:eks:sa-east-1:730335661246:cluster/datahub-dev             istio-system
          arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-prod       arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-prod       arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-prod       istio-system
          arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-uat        arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-uat        arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-uat        istio-system
          arn:aws:eks:sa-east-1:916546429908:cluster/do-eks-01-dev           arn:aws:eks:sa-east-1:916546429908:cluster/do-eks-01-dev           arn:aws:eks:sa-east-1:916546429908:cluster/do-eks-01-dev
          arn:aws:eks:us-east-1:109804294614:cluster/positivo-us-dev         arn:aws:eks:us-east-1:109804294614:cluster/positivo-us-dev         arn:aws:eks:us-east-1:109804294614:cluster/positivo-us-dev         istio-system
          arn:aws:eks:us-east-1:300374333803:cluster/negativo-us-dev         arn:aws:eks:us-east-1:300374333803:cluster/negativo-us-dev         arn:aws:eks:us-east-1:300374333803:cluster/negativo-us-dev         istio-system
          arn:aws:eks:us-east-1:975050357449:cluster/consentiment-prod       arn:aws:eks:us-east-1:975050357449:cluster/consentiment-prod       arn:aws:eks:us-east-1:975050357449:cluster/consentiment-prod
          arn:aws:eks:us-east-1:992382670558:cluster/consentimento-dev       arn:aws:eks:us-east-1:992382670558:cluster/consentimento-dev       arn:aws:eks:us-east-1:992382670558:cluster/consentimento-dev
PS â€¦\c96531a\eec-aws-br-ds-dataservices-stage>
#>

# Instalando repositório Grafana
helm repo delete prometheus-community
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm search repo prometheus-community/kube-prometheus-stack --versions

# NAME                                            CHART VERSION   APP VERSION     DESCRIPTION

# prometheus-community/kube-prometheus-stack      76.2.1          v0.84.1         kube-prometheus-stack collects Kubernetes manif...

# 087086536124
# eec-aws-br-nike-ss-sandbox (087086536124)
# arn:aws:eks:sa-east-1:087086536124:cluster/ssrm-eks-01-sandbox
$conta = "eec-aws-br-nike-ss-sandbox"
$contexto = "arn:aws:eks:sa-east-1:087086536124:cluster/ssrm-eks-01-sandbox"
k config use-context $contexto
kubectl config set-context --current --namespace=monitoring-system
helm list
# NAME                            NAMESPACE               REVISION        UPDATED                                 STATUS     CHART                            APP VERSION
# grafana-ingress                 monitoring-system       2               2024-03-06 20:11:54.029218022 -0300 -03 deployed   istio-integration-1.0.0          1.0.0
# kube-prometheus-dashboards      monitoring-system       2               2024-03-07 10:39:10.744710547 -0300 -03 deployed   grafana-dashboards-1.0.0         1.0.0
# kube-prometheus-stack           monitoring-system       25              2024-10-29 16:38:27.684443929 -0300 -03 deployed   kube-prometheus-stack-62.2.1     v0.76.0

mkdir ~/$conta
cd ~/$conta
helm get values kube-prometheus-stack -n monitoring-system -o yaml > kube-prometheus-stack-values.yaml
cat .\kube-prometheus-stack-values.yaml
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack --dependency-update --values kube-prometheus-stack-values.yaml

#  Account: eec-aws-br-ds-dataservices-stage (146737708860)
# arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat
$conta = "eec-aws-br-ds-dataservices-stage"
$contexto = "arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat"
k config use-context $contexto
kubectl config set-context --current --namespace=monitoring-system
helm list
# NAME                            NAMESPACE               REVISION        UPDATED                                 STATUS     CHART                            APP VERSION
# grafana-ingress                 monitoring-system       2               2024-03-06 20:11:54.029218022 -0300 -03 deployed   istio-integration-1.0.0          1.0.0
# kube-prometheus-dashboards      monitoring-system       2               2024-03-07 10:39:10.744710547 -0300 -03 deployed   grafana-dashboards-1.0.0         1.0.0
# kube-prometheus-stack           monitoring-system       25              2024-10-29 16:38:27.684443929 -0300 -03 deployed   kube-prometheus-stack-62.2.1     v0.76.0

mkdir ~/$conta
cd ~/$conta
helm get values kube-prometheus-stack -n monitoring-system -o yaml > kube-prometheus-stack-values.yaml
cat .\kube-prometheus-stack-values.yaml
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack --dependency-update --values kube-prometheus-stack-values.yaml

# Account: eec-aws-us-eits-negativo-dev (300374333803)
# arn:aws:eks:us-east-1:300374333803:cluster/negativo-us-dev
$conta = "eec-aws-us-eits-negativo-dev"
$contexto = "arn:aws:eks:us-east-1:300374333803:cluster/negativo-us-dev"

# Account: eec-aws-br-nike-ssrm-dev (306716481758)
# arn:aws:eks:sa-east-1:306716481758:cluster/sales-eks-01-uat
$conta = "eec-aws-br-nike-ssrm-dev"
$contexto = "arn:aws:eks:sa-east-1:306716481758:cluster/sales-eks-01-uat"

## Account: eec-aws-br-ds-dataservices-dev (530914589075)
# arn:aws:eks:sa-east-1:530914589075:cluster/ds-eks-01-dev  
$conta = "eec-aws-br-ds-dataservices-dev"
$contexto = "arn:aws:eks:sa-east-1:530914589075:cluster/ds-eks-01-dev"

# # Account: eec-aws-br-eits-datahub-dev (730335661246)
# arn:aws:eks:sa-east-1:730335661246:cluster/datahub-dev 
$conta = "eec-aws-br-eits-datahub-dev"
$contexto = "arn:aws:eks:sa-east-1:730335661246:cluster/datahub-dev"

$deployments = kubectl get deployments -o json | ConvertFrom-Json

foreach ($item in $deployments.items) {
    $namespace = $item.metadata.namespace
    $name = $item.metadata.name

    Write-Host "Reiniciando deployment '$name' no namespace '$namespace'..."
    kubectl rollout restart deployment $name -n $namespace
}

$contexto = "arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod"
k config use-context $contexto