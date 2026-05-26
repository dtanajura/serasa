## Procedimento inicial
# Ir para a pasta
Set-Location C:\tmp
# Fazer um clone do repositório
git clone https://code.experian.local/scm/nikesre/gitops-eks-mgmt.git
# Criar uma branch
git checkout -b c96531a/Helm-Update-eec-aws-br-nike-corporate-prod-06.10.25
# Criar uma pasta da conta 
mkdir clusters\564593125549-eec-aws-br-nike-corporate-prod
# Logar na conta
okta-aws-cli web --profile corporateprod --aws-region sa-east-1 --aws-session-duration 36000
# Pegar o contexto do cluster
aws eks list-clusters --profile corporateprod  #Confirmar qual o cluster
kubectl config get-contexts
Kubectl config use-context arn:aws:eks:sa-east-1:564593125549:cluster/eks-nike-tech-01-prod 

<#
helm list -A
NAME                            NAMESPACE                               REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
apigee-microgateway             apigee-system                           4               2023-04-13 23:32:27.014908539 -0300 -03 deployed        apigee-microgateway-3.3.1       3.3.1
aws-efs-csi-driver              kube-system                             1               2023-04-13 20:09:08.009485647 -0300 -03 deployed        aws-efs-csi-driver-2.4.1        1.5.4
aws-vpc-cni-patch               kube-system                             2               2023-04-13 19:10:34.397597692 -0300 -03 deployed        aws-vpc-cni-patch-0.1.5         355
cluster-autoscaler              kube-system                             2               2023-04-13 20:09:07.693632153 -0300 -03 deployed        cluster-autoscaler-9.23.2       1.23.0
dev-hub-portal                  dev-hub-portal-prd                      25              2024-02-29 17:28:32.656016933 -0300 -03 deployed        dev-hub-portal-1.20.0           1.20.0
envoy-monitoring                istio-system                            1               2023-04-13 20:11:42.809934801 -0300 -03 deployed        prometheus-monitoring-1.0.0     1.0.0
external-dns                    kube-system                             4               2024-05-22 22:50:57.243221722 -0300 -03 deployed        external-dns-1.14.4             0.14.1
flagger                         istio-system                            18              2024-05-22 23:15:14.931764211 -0300 -03 deployed        flagger-1.37.0                  1.37.0
flagger-monitoring              istio-system                            1               2023-04-13 20:11:47.368048416 -0300 -03 deployed        prometheus-monitoring-1.0.0     1.0.0
grafana-ingress                 monitoring-system                       1               2023-04-13 20:11:43.150533084 -0300 -03 deployed        istio-integration-1.0.0         1.0.0
istio-base                      istio-system                            5               2024-09-06 16:20:33.955668558 -0300 -03 deployed        base-1.23.0                     1.23.0
istio-ingress                   istio-system                            4               2023-04-13 21:59:07.835804738 -0300 -03 deployed        gateway-1.17.1                  1.17.1
istio-monitoring                istio-system                            1               2023-04-13 20:11:42.810088622 -0300 -03 deployed        prometheus-monitoring-1.0.0     1.0.0
istiod                          istio-system                            5               2024-09-06 16:20:57.688706958 -0300 -03 deployed        istiod-1.23.0                   1.23.0
kafka-dev                       default                                 3               2023-01-24 13:16:05.347424638 +0000 UTC deployed        strimzi-kafka-operator-0.32.0   0.32.0
kube-prometheus-dashboards      monitoring-system                       1               2023-04-13 20:11:43.150348092 -0300 -03 deployed        grafana-dashboards-1.0.0        1.0.0
kube-prometheus-stack           monitoring-system                       21              2024-08-21 19:28:35.1450345 -0300 -03   deployed        kube-prometheus-stack-62.2.0    v0.76.0
logstash                        logstash-nike-smartproxy-infobusca-uat  4               2024-10-17 19:58:56.529338552 -0300 -03 deployed        logstash-8.5.1                  8.5.1
logstash                        logstash-nike-smartproxy-infomais-uat   4               2024-10-17 19:56:03.428536225 -0300 -03 deployed        logstash-8.5.1                  8.5.1
logstash                        logstash-nike-smartproxy-infobusca      9               2024-10-18 18:54:27.688589747 -0300 -03 deployed        logstash-8.5.1                  8.5.1
logstash                        logstash-nike-smartproxy-uat            29              2024-10-17 19:53:43.811217974 -0300 -03 deployed        logstash-8.5.1                  8.5.1
logstash                        logstash-nike-smartproxy-infomais       5               2024-10-17 20:06:43.997233071 -0300 -03 deployed        logstash-8.5.1                  8.5.1
logstash                        logstash-nike-smartproxy                4               2024-10-17 19:52:12.524779918 -0300 -03 deployed        logstash-8.5.1                  8.5.1
metrics-server                  kube-system                             3               2024-05-22 22:49:43.145214283 -0300 -03 deployed        metrics-server-3.12.1           0.7.1
oauth2-proxy                    kube-system                             2               2023-02-28 18:23:37.193052491 -0300 -03 deployed        oauth2-proxy-6.2.7              7.3.0
vpa                             kube-system                             4               2024-07-11 17:00:26.449914457 -0300 -03 deployed        vertical-pod-autoscaler-9.8.2   1.1.2
#>

aws eks list-addons --cluster-name eks-nike-tech-01-prod  --profile corporateprod 
## Verificações
kubectl get nodes #verificar se o cluster está com nodes

## Atualização dos repos do helm
# Listar os repos
helm list -A


################# cluster-autoscaler
# Adicionar (ou atualizar) o repositório do Helm
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update

# Verificar as versões disponíveis
helm search repo autoscaler/cluster-autoscaler --versions

# Manter as configurações atuais
$pack = "cluster-autoscaler"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n kube-system > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade $pack autoscaler/cluster-autoscaler `
  --version 9.50.1 `
  -n kube-system `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# verificar
kubectl -n kube-system logs -l app.kubernetes.io/name=aws-cluster-autoscaler `
  -l app.kubernetes.io/instance=cluster-autoscaler

helm list -A | Select-String $pack
# cluster-autoscaler                      kube-system                     10              2025-04-01 10:40:13.806472463 -0300 -03 deployed        cluster-autoscaler-9.46.6                               1.32.0   
# cluster-autoscaler                      kube-system                     11              2025-10-02 10:54:31.9948354 -0300 -03   deployed        cluster-autoscaler-9.50.1                               1.33.0

############ kube-prometheus-stack
# Versão mais atual
helm search repo kube-prometheus-stack --versions
# NAME                                            CHART VERSION   APP VERSION     DESCRIPTION
# prometheus-community/kube-prometheus-stack      77.12.0         v0.85.0         kube-prometheus-stack collects Kubernetes manif...
# prometheus-community/kube-prometheus-stack      77.11.1         v0.85.0         kube-prometheus-stack collects Kubernetes manif...

# Manter as configurações atuais
$pack = "kube-prometheus-stack"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n monitoring-system > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack `
  --version 77.12.0 `
  -n monitoring-system `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# kube-prometheus-stack                   monitoring-system               1               2025-03-31 15:44:28.510648326 -0300 -03 deployed        kube-prometheus-stack-70.3.0                            v0.81.0
# kube-prometheus-stack                   monitoring-system               2               2025-10-02 10:59:56.5296089 -0300 -03   deployed        kube-prometheus-stack-77.12.0                           v0.85.0  


##### external-dns
# Repositório
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/

# Versão mais atual
helm search repo external-dns/external-dns --versions

# Manter as configurações atuais
$pack = "external-dns"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n kube-system > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade external-dns external-dns/external-dns `
  --version 1.19.0 `
  -n kube-system `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

kubectl get pods -n kube-system | Select-String $pack
kubectl describe pod external-dns-5989477b57-lhzn4 -n kube-system | Select-String "image"

# external-dns                            kube-system                     23              2025-06-25 16:03:43.908085479 -0300 -03 deployed        external-dns-1.14.5                                     0.14.2   
# external-dns                            kube-system                     24              2025-10-02 11:16:25.8659456 -0300 -03   deployed        external-dns-1.19.0                                     0.19.0   


######### kube-prometheus-dashboards, grafana-ingress, prometheus-ingress, setup-rbac, envoy-monitoring, 
######### flagger-monitoring, istio-monitoring
# Não faz atualização

############ istio-base
# Versão mais atual
$repo = "istio/base"
helm search repo $repo --versions
# istio/base                              1.27.1          1.27.1          Helm chart for deploying Istio cluster resource...

# Manter as configurações atuais
$pack = "istio-base"
$namespace = "istio-system"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade $pack $repo `
  --version 1.27.1 `
  -n $namespace 

# istio-base                              istio-system                    10              2025-08-07 11:10:57.306407555 -0300 -03 deployed        base-1.26.3                                             1.26.3
# istio-base                              istio-system                    11              2025-10-02 11:27:23.3250705 -0300 -03   deployed        base-1.27.1                                             1.27.1

######## istio-ingress
$repo = "istio/gateway"
helm search repo $repo --versions
# istio/gateway                           1.27.1          1.27.1          Helm chart for deploying Istio gateways

# Manter as configurações atuais
$pack = "istio-ingress"
$namespace = "istio-system"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade istio-ingress istio/gateway `
  --namespace istio-system `
  --version 1.27.1 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

# istio-ingress                           istio-system                    13              2025-10-02 11:34:33.2155225 -0300 -03   deployed        gateway-1.27.1                                          1.27.1   

####### istiod
$repo = "istio/istiod"
helm search repo $repo --versions
# istio/istiod            1.27.1          1.27.1          Helm chart for istio control plane

# Manter as configurações atuais
$pack = "istiod"
$namespace = "istio-system"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade istiod istio/istiod `
  --namespace istio-system `
  --version 1.27.1 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

# istiod                                  istio-system                    15              2025-08-08 16:47:46.7252706 -0300 -03   deployed        istiod-1.26.3                                           1.26.3
# istiod                                  istio-system                    16              2025-10-02 11:37:46.6841881 -0300 -03   deployed        istiod-1.27.1                                           1.27.1   

##### metrics-server
$repo = "metrics-server/metrics-server"
helm search repo $repo --versions
# metrics-server/metrics-server   3.13.0          0.8.0           Metrics Server is a scalable, efficient source ...

# Manter as configurações atuais
$pack = "metrics-server"
$namespace = "kube-system"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade $pack $repo `
  --namespace $namespace `
  --version 3.13.0 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

# metrics-server                          kube-system                     13              2024-08-21 16:56:18.865689367 -0300 -03 deployed        metrics-server-3.12.1                                   0.7.1
# metrics-server                          kube-system                     14              2025-10-02 11:42:18.4146901 -0300 -03   deployed        metrics-server-3.13.0                                   0.8.0    

##### argo-cd
helm repo add argo https://argoproj.github.io/argo-helm
$repo = "argo/argo-cd"
helm search repo $repo --versions
argo/argo-cd                    8.5.8           v3.1.8                  A Helm chart for Argo CD, a declarative, GitOps...

# Manter as configurações atuais
$pack = "argo-cd"
$namespace = "argocd"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade $pack $repo `
  --namespace $namespace `
  --version 8.5.8 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

helm upgrade $pack $repo --namespace $namespace --version 8.5.8 -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

$pack = "argocd"
$namespace = "argocd"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade $pack $repo `
  --namespace $namespace `
  --version 8.5.8 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

# argo-cd                                 argocd                          1               2025-03-18 16:21:52.715096853 -0300 -03 failed          argo-cd-7.8.12                                          v2.14.6  
# argocd                                  argocd                          1               2025-03-18 16:23:03.146563157 -0300 -03 deployed        argo-cd-7.8.12                                          v2.14.6  
# argo-cd                                 argocd                          2               2025-10-02 14:21:53.1683094 -0300 -03   deployed        argo-cd-8.5.8                                           v3.1.8
# argocd                                  argocd                          2               2025-10-02 14:31:14.7658008 -0300 -03   deployed        argo-cd-8.5.8                                           v3.1.8


###### env0-agent
helm repo add env0-agent https://env0.github.io/self-hosted
helm repo update
$repo = "env0-agent"
helm search repo $repo --versions
# env0-agent/env0-agent   v3.0.1172       v3.0.1172       A Helm chart for deploying env0 agent onto Kube...

# Manter as configurações atuais
$pack = "env0-agent"
$namespace = "env0"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade $pack $repo `
  --namespace $namespace `
  --version v3.0.1172 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

# env0-agent                              env0                            3               2025-02-18 10:37:36.424164097 -0300 -03 deployed        env0-agent-v3.0.1010                                    v3.0.1010
# env0-agent                              env0                            4               2025-10-02 14:40:05.2491657 -0300 -03   deployed        env0-agent-v3.0.1172                                    v3.0.1172

##### external-secrets

helm repo add external-secrets https://charts.external-secrets.io
helm repo update
$repo = "external-secrets/external-secrets"
helm search repo $repo --versions
# external-secrets/external-secrets       0.20.1          v0.20.1         External secrets management for Kubernetes

# Manter as configurações atuais
$pack = "external-secrets"
$namespace = "external-secrets"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

helm upgrade $pack $repo `
  --namespace $namespace `
  --version 0.20.1 

# external-secrets                        external-secrets                1               2025-04-29 21:52:56.481489724 -0300 -03 deployed        external-secrets-0.16.1                                 v0.16.1  
# external-secrets                        external-secrets                2               2025-10-02 14:48:10.0166567 -0300 -03   deployed        external-secrets-0.20.1                                 v0.20.1

##### karpenter - não funcionou
helm repo add karpenter https://charts.karpenter.sh
helm repo update
$repo = "karpenter/karpenter"
helm search repo $repo --versions
# karpenter/karpenter     0.16.3          0.16.3          A Helm chart for Karpenter, an open-source node...

# Manter as configurações atuais
$pack = "karpenter"
$namespace = "kube-system"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade $pack $repo `
  --namespace $namespace `
  --version 0.16.3 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

# karpenter                               kube-system                     1               2024-03-20 19:06:27.744354127 -0300 -03 deployed        karpenter-0.35.2                                        0.35.2

######## kubernetes-dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

helm search repo kubernetes-dashboard
# kubernetes-dashboard/kubernetes-dashboard       7.13.0                          General-purpose web UI for Kubernetes clusters

$repo = "kubernetes-dashboard/kubernetes-dashboard"

# Manter as configurações atuais
$pack = "kubernetes-dashboard"
$namespace = "kubernetes-dashboard"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade $pack $repo `
  --namespace $namespace `
  --version  7.13.0 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

# kubernetes-dashboard                    kubernetes-dashboard            1               2024-07-12 11:49:48.932877195 -0300 -03 deployed        kubernetes-dashboard-7.5.0
# kubernetes-dashboard                    kubernetes-dashboard            2               2025-10-02 15:52:55.9781984 -0300 -03   deployed        kubernetes-dashboard-7.13.0

##### loki-stack
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm search repo grafana | Select-String "loki-stack"
# grafana/loki-stack                              2.10.2          v2.9.3          Loki: like Prometheus, but for logs.

$repo = "grafana/loki-stack"

# Manter as configurações atuais
$pack = "loki-stack"
$namespace = "monitoring-system"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

# Atualizar
helm upgrade $pack $repo `
  --namespace $namespace `
  --version  2.10.2 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

# loki-stack                              monitoring-system               43              2025-03-31 16:35:38.700905901 -0300 -03 deployed        loki-stack-2.10.2                                       v2.9.3
# loki-stack                              monitoring-system               45              2025-10-02 16:53:40.5707197 -0300 -03   deployed        loki-stack-2.10.2                                       v2.9.3

##### oauth2-proxy

helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests

helm search repo oauth2-proxy
# oauth2-proxy/oauth2-proxy       8.3.0           7.12.0          A reverse proxy that provides authentication wi...
$repo = "oauth2-proxy/oauth2-proxy"

# Manter as configurações atuais
$pack = "oauth2-proxy"
$namespace = "kubernetes-dashboard"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

helm upgrade $pack $repo `
  --namespace $namespace `
  --version  8.3.0 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

# oauth2-proxy                            kubernetes-dashboard            4               2024-07-23 16:37:26.957769595 -0300 -03 deployed        oauth2-proxy-7.7.9                                      7.6.0
# oauth2-proxy                            kubernetes-dashboard            5               2025-10-03 13:58:49.9227931 -0300 -03   deployed        oauth2-proxy-8.3.0                                      7.12.0   

####### opentelemetry
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update
helm search repo open-telemetry
# open-telemetry/opentelemetry-collector          0.136.1         0.136.0         OpenTelemetry Collector Helm chart for Kubernetes
# open-telemetry/opentelemetry-operator           0.97.1          0.136.0         OpenTelemetry Operator Helm chart for Kubernetes

$repo = "open-telemetry/opentelemetry-collector"

# Manter as configurações atuais
$pack = "opentelemetry-collector"
$namespace = "default"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

helm upgrade $pack $repo `
  --namespace $namespace `
  --version  0.136.1 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

$repo = "open-telemetry/opentelemetry-operator"

# Manter as configurações atuais
$pack = "opentelemetry-operator"
$namespace = "observability"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

helm upgrade $pack $repo `
  --namespace $namespace `
  --version  0.97.1 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

# opentelemetry-collector                 default                         2               2024-12-23 15:57:57.743750558 -0300 -03 deployed        opentelemetry-collector-0.111.0                         0.115.1
# opentelemetry-operator                  observability                   1               2024-12-23 15:41:07.037093321 -0300 -03 deployed        opentelemetry-operator-0.75.1                           0.114.1
# opentelemetry-collector                 default                         3               2025-10-03 14:10:16.5799883 -0300 -03   deployed        opentelemetry-collector-0.136.1                         0.136.0
# opentelemetry-operator                  observability                   2               2025-10-03 14:16:31.6400095 -0300 -03   deployed        opentelemetry-operator-0.97.1                           0.136.0

# pinot
kubectl get pods -n pinot
# NAME                                      READY   STATUS                       RESTARTS            AGE
# pinot-broker-0                            0/1     CreateContainerConfigError   0                   18h
# pinot-controller-0                        0/1     CrashLoopBackOff             9549 (3m20s ago)    41d
# pinot-minion-stateless-65845c774d-49jrb   0/1     CreateContainerConfigError   0                   18h
# pinot-minion-stateless-6c4d8649d7-w6t4n   0/1     CrashLoopBackOff             10508 (3m48s ago)   43d
# pinot-server-0                            0/1     CrashLoopBackOff             10031 (106s ago)    43d
# pinot-zookeeper-0                         0/1     ContainerCreating            0                   43d

helm repo add pinot https://raw.githubusercontent.com/apache/pinot/master/kubernetes/helm
helm search repo pinot
# NAME            CHART VERSION   APP VERSION     DESCRIPTION
# pinot/pinot     0.3.4           1.0.0           Apache Pinot is a realtime distributed OLAP dat...
$repo = "pinot/pinot"

# Manter as configurações atuais
$pack = "pinot"
$namespace = "pinot"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

helm upgrade $pack $repo `
  --namespace $namespace `
  --version  0.3.4 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

# pinot   pinot           3               2025-03-26 20:57:46.548013336 -0300 -03 failed          pinot-0.4.0     1.0.0
# pinot   pinot           1               2025-10-03 14:42:37.8159709 -0300 -03   deployed        pinot-0.3.4     1.0.0

###### stormforge
helm repo add stormforge https://charts.stormforge.io
helm search repo stormforge
helm upgrade stormforge-agent oci://registry.stormforge.io/library/stormforge-agent `
  --namespace stormforge-system `
  --set enableCostMetrics=false `
  --reuse-values

helm install stormforge-agent oci://registry.stormforge.io/library/stormforge-agent `
  --namespace stormforge-system `
  --set authorization.clientID=07d023d3f66341179a01dc0d4df9dbbc `
  --set authorization.clientSecret=B6Jcbc.6w_ka0K5tWJQG_e_ArQ `
  --set authorization.issuer=https://api.stormforge.io/ `
  --set clusterName=nike-tech-dev `
  --set enableCostMetrics=false

helm upgrade stormforge-applier oci://registry.stormforge.io/library/stormforge-applier `
  --namespace stormforge-system `
  --reuse-values `
  --set webhook.enabled=false


# stormforge-agent        stormforge-system       1               2024-07-26 08:42:53.53989546 -0300 -03  deployed        stormforge-agent-2.13.0        2.13.0
# stormforge-applier      stormforge-system       1               2024-09-02 13:40:32.863881131 -0300 -03 deployed        stormforge-applier-2.5.0       2.5.0
# stormforge-agent        stormforge-system       1               2025-10-03 16:26:54.8653044 -0300 -03   deployed        stormforge-agent-2.23.5         2.23.5
# stormforge-applier      stormforge-system       2               2025-10-03 16:32:39.8641087 -0300 -03   deployed        stormforge-applier-2.9.2        2.9.2

####### vpa
helm repo add vpa https://charts.fairwinds.com/stable
helm search repo vpa
# vpa/vpa                                 4.9.0           1.4.1           A Helm chart for Kubernetes Vertical Pod Autosc...
$repo = "vpa/vpa"

# Manter as configurações atuais
$pack = "vpa"
$namespace = "kube-system"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

helm upgrade $pack $repo `
  --namespace $namespace `
  --version  4.9.0 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

# vpa                     kube-system     16              2024-08-21 16:56:42.23220271 -0300 -03  deployed        vertical-pod-autoscaler-9.8.3   1.1.2
# vpa                     kube-system     17              2025-10-03 16:40:01.2227061 -0300 -03   deployed        vpa-4.9.0                       1.4.1

####### wiz-broker
helm repo add wiz-sec https://wiz-sec.github.io/charts
helm repo update
helm search repo wiz-sec
# wiz-sec/wiz-broker                      2.5.1           2.9             Wiz Broker for tunneling http traffic to Wiz ba...
$repo = "wiz-sec/wiz-broker"

k get pods -n wiz
# NAME                                               READY   STATUS             RESTARTS          AGE
# wiz-kubernetes-connector-broker-79795fc5cf-5f7pg   0/1     CrashLoopBackOff   109 (3m31s ago)   21h

# Manter as configurações atuais
$pack = "wiz-broker"
$namespace = "wiz"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

helm upgrade $pack $repo `
  --namespace $namespace `
  --version  2.5.1 `
  -f "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" `
  --set wizConnector.connectorId="ef29d0e0-83a2-5d2d-8eb3-31d65bc4d3fc" `
  --set wizConnector.connectorToken="cc88b69113473f7494c047dd4fa12b74f8fa067787551c31221b23663f2d020c" `
  --set wizConnector.targetDomain="ef29d0e0-83a2-5d2d-8eb3-31d65bc4d3fc.tunnel.wiz.io" `
  --set wizConnector.tunnelServerDomain="tunnel.us13.app.wiz.io" `
  --set wizConnector.tunnelServerPort=443 `
  --set wizConnector.targetIp="kubernetes.default.svc.cluster.local" `
  --set wizConnector.targetPort=443 `
  --insecure-skip-tls-verify

# wiz-broker      wiz             18              2024-10-09 15:29:42.46340887 -0300 -03  deployed        wiz-kubernetes-connector-2.4.9     2.4
# wiz-broker      wiz             22              2025-10-03 17:43:00.6683367 -0300 -03   deployed        wiz-broker-2.5.1                   2.9
