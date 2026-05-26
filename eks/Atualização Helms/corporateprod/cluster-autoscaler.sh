<#
    Script PowerShell para ATUALIZAR AUTOMATICAMENTE o Helm chart para a versão mais recente encontrada.
#>

# --- Configuração de Variáveis ---
$pack      = "cluster-autoscaler"
$namespace = "kube-system"
$repoName  = "autoscaler"
$repoUrl   = "https://kubernetes.github.io/autoscaler"
$chartName = "autoscaler/cluster-autoscaler"

# Diretório base para salvar os values.yaml
$baseValuesDir = "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod"
$packValuesDir = Join-Path -Path $baseValuesDir -ChildPath $pack
$valuesFile = Join-Path -Path $packValuesDir -ChildPath "values.yaml"

# --- Início do Script ---
Write-Host "Iniciando a atualização do Helm chart: $pack"

# 1. Adicionar e atualizar o repositório Helm
Write-Host "Adicionando o repositório Helm '$repoName' de $repoUrl"
helm repo add $repoName $repoUrl
Write-Host "Atualizando repositórios Helm..."
# helm repo update

# 2. Buscar e extrair a versão mais recente
Write-Host "Buscando as versões disponíveis para $chartName..."
$searchOutput = helm search repo $chartName

# Processa a saída:
# 1. Select-Object -Skip 1 (Pula a linha do cabeçalho: "NAME CHART VERSION...")
# 2. Select-Object -First 1 (Pega a primeira linha de resultado, que é a mais recente)
$latestVersionLine = $searchOutput | Select-Object -Skip 1 | Select-Object -First 1

if ($null -eq $latestVersionLine) {
    Write-Error "Não foi possível encontrar nenhuma versão para o chart $chartName."
    # Interrompe o script se não encontrar a versão
    return
}

# Divide a linha em colunas. Split() remove espaços em branco extras.
$columns = $latestVersionLine.Split([char[]]' ', [System.StringSplitOptions]::RemoveEmptyEntries)

# A versão do Chart é a segunda coluna (Índice 1, pois a contagem começa em 0)
$chartVersion = $columns[1]

Write-Host "Versão mais recente detectada: $chartVersion" -ForegroundColor Green

# 3. Manter as configurações atuais (Backup dos Values)
Write-Host "Preparando para salvar os valores atuais..."
if (-not (Test-Path -Path $packValuesDir)) {
    Write-Host "Criando diretório: $packValuesDir"
    mkdir $packValuesDir
} else {
    Write-Host "Diretório já existe: $packValuesDir"
}

Write-Host "Salvando valores atuais de $pack (namespace: $namespace) para $valuesFile"
helm get values $pack -n $namespace > $valuesFile
Write-Host "Valores salvos com sucesso."

code $valuesFile







# 4. Atualizar o Helm Chart (usando a $chartVersion detectada)
Write-Host "Atualizando $pack para a versão $chartVersion..."
helm upgrade $pack $chartName `
  --version $chartVersion `
  -n $namespace `
  -f $valuesFile

Write-Host "Upgrade do $pack concluído."

# 5. Verificar a atualização
Write-Host "--- Verificação Pós-Atualização ---"
Write-Host "Listando a versão do Helm para {$pack}:"
helm list -A | Select-String $pack

Write-Host "Verificando os logs do {$pack}:"
kubectl -n $namespace logs -l app.kubernetes.io/name=aws-cluster-autoscaler `
  -l app.kubernetes.io/instance=cluster-autoscaler

Write-Host "--- Script finalizado ---"