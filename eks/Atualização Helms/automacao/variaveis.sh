<#
.SYNOPSIS
    Script para carregar as variáveis de todos os Helm charts conhecidos.

.DESCRIPTION
    Este script transforma o arquivo 'Variaveis_Helm_Charts.md' em uma função do PowerShell
    chamada Get-HelmChartVariables, que retorna um objeto com todos os charts categorizados.

.EXAMPLE
    # 1. Carregue o script na sua sessão (note o ponto no início):
    . .\Get-HelmChartVariables.ps1
    
    # 2. Chame a função:
    $charts = Get-HelmChartVariables
    
    # 3. Acesse as listas de charts:
    
    # Ver charts que estão no roteiro
    $charts.NoRoteiro | Format-Table

    # Ver charts que não são atualizados pelo roteiro
    $charts.NaoAtualizados | Format-Table
    
    # Ver charts extras (não incluídos no roteiro)
    $charts.Extras | Format-Table

    # Ver todos os charts que podem ser atualizados (Roteiro + Extras)
    $charts.TodosOsCharts | Format-Table
    
    # Iterar sobre os charts do roteiro
    foreach ($chart in $charts.NoRoteiro) {
        Write-Host "Processando $($chart.Pack) no namespace $($chart.Namespace)..."
        # Aqui você pode adicionar sua lógica de 'helm upgrade'
    }
#>
function Get-HelmChartVariables {

    # 1. Pacotes com Informações Encontradas no Roteiro
    $ChartsNoRoteiro = @(
        @{
            Pack      = "cluster-autoscaler"
            Namespace = "kube-system"
            RepoName  = "autoscaler"
            RepoUrl   = "https://kubernetes.github.io/autoscaler"
            ChartName = "autoscaler/cluster-autoscaler"
        },
        @{
            Pack      = "external-dns"
            Namespace = "kube-system"
            RepoName  = "external-dns"
            RepoUrl   = "https://kubernetes-sigs.github.io/external-dns/"
            ChartName = "external-dns/external-dns"
        },
        @{
            Pack      = "istio-base"
            Namespace = "istio-system"
            RepoName  = "istio"
            RepoUrl   = "https://istio-release.storage.googleapis.com/charts"
            ChartName = "istio/base"
        },
        @{
            Pack      = "istio-ingress"
            Namespace = "istio-system"
            RepoName  = "istio"
            RepoUrl   = "https://istio-release.storage.googleapis.com/charts"
            ChartName = "istio/gateway" # Note que o nome do chart é diferente do nome do release/pack
        },
        @{
            Pack      = "istiod"
            Namespace = "istio-system"
            RepoName  = "istio"
            RepoUrl   = "https://istio-release.storage.googleapis.com/charts"
            ChartName = "istio/istiod"
        },
        @{
            Pack      = "kube-prometheus-stack"
            Namespace = "monitoring-system"
            RepoName  = "prometheus-community"
            RepoUrl   = "https://prometheus-community.github.io/helm-charts"
            ChartName = "prometheus-community/kube-prometheus-stack"
        },
        @{
            Pack      = "metrics-server"
            Namespace = "kube-system"
            RepoName  = "metrics-server"
            RepoUrl   = "https://kubernetes-sigs.github.io/metrics-server/"
            ChartName = "metrics-server/metrics-server"
        },
        @{
            Pack      = "oauth2-proxy"
            Namespace = "kube-system" # Nota: O 'helm list' original mostra 'kube-system'
            RepoName  = "oauth2-proxy"
            RepoUrl   = "https://oauth2-proxy.github.io/manifests"
            ChartName = "oauth2-proxy/oauth2-proxy"
        },
        @{
            Pack      = "vpa"
            Namespace = "kube-system"
            RepoName  = "vpa"
            RepoUrl   = "https://charts.fairwinds.com/stable"
            ChartName = "vpa/vpa"
        }
    )

    # 2. Pacotes Não Atualizados Pelo Roteiro
    $ChartsNaoAtualizados = @(
        @{ Pack = "envoy-monitoring"; Namespace = "istio-system"; Info = "Não atualizável individualmente" },
        @{ Pack = "flagger-monitoring"; Namespace = "istio-system"; Info = "Não atualizável individualmente" },
        @{ Pack = "grafana-ingress"; Namespace = "monitoring-system"; Info = "Não atualizável individualmente" },
        @{ Pack = "istio-monitoring"; Namespace = "istio-system"; Info = "Não atualizável individualmente" },
        @{ Pack = "kube-prometheus-dashboards"; Namespace = "monitoring-system"; Info = "Não atualizável individualmente" }
    )

    # 3. Pacotes Encontrados (Mas Não Incluídos no Roteiro)
    $ChartsExtras = @(
        @{
            Pack      = "apigee-microgateway"
            Namespace = "apigee-system"
            RepoName  = "apigee"
            RepoUrl   = "https://apigee.github.io/charts/"
            ChartName = "apigee/apigee-microgateway"
        },
        @{
            Pack      = "aws-efs-csi-driver"
            Namespace = "kube-system"
            RepoName  = "aws-efs-csi-driver"
            RepoUrl   = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
            ChartName = "aws-efs-csi-driver/aws-efs-csi-driver"
        },
        @{
            Pack      = "aws-vpc-cni-patch"
            Namespace = "kube-system"
            RepoName  = "eks"
            RepoUrl   = "https://aws.github.io/eks-charts"
            ChartName = "eks/aws-vpc-cni" # Nota: Pode ser um addon do EKS
        },
        @{
            Pack      = "dev-hub-portal"
            Namespace = "dev-hub-portal-prd"
            RepoName  = "INTERNO"
            RepoUrl   = "INTERNO"
            ChartName = "INTERNO" # Provavelmente um repositório privado
        },
        @{
            Pack      = "flagger"
            Namespace = "istio-system"
            RepoName  = "flagger"
            RepoUrl   = "https://flagger.app"
            ChartName = "flagger/flagger"
        },
        @{
            Pack      = "kafka-dev"
            Namespace = "default"
            RepoName  = "strimzi"
            RepoUrl   = "https://strimzi.io/charts/"
            ChartName = "strimzi/strimzi-kafka-operator" # O release 'kafka-dev' foi instalado a partir deste chart
        },
        @{
            Pack      = "logstash"
            Namespace = "vários" # O helm list original mostra vários namespaces
            RepoName  = "elastic"
            RepoUrl   = "https://helm.elastic.co"
            ChartName = "elastic/logstash"
        }
    )

    # Retorna um objeto com todas as listas
    return [PSCustomObject]@{
        NoRoteiro      = $ChartsNoRoteiro
        NaoAtualizados = $ChartsNaoAtualizados
        Extras         = $ChartsExtras
        TodosOsCharts  = $ChartsNoRoteiro + $ChartsExtras
    }
}

# --- Fim da definição da função ---

Write-Host "Função Get-HelmChartVariables definida." -ForegroundColor Green
Write-Host "Para usar, primeiro carregue o script com 'dot-sourcing':"
Write-Host "PS> . .\Get-HelmChartVariables.ps1" -ForegroundColor Yellow
Write-Host "Depois chame a função:"
Write-Host "PS> \$charts = Get-HelmChartVariables" -ForegroundColor Yellow
Write-Host "PS> \$charts.NoRoteiro | Format-Table" -ForegroundColor Yellow
