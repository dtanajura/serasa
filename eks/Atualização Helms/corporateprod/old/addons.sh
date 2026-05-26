$ClusterName = "eks-nike-tech-01-prod"
$Profile_aws = "corporateprod"

Write-Host "🔍 Obtendo versão do Kubernetes do cluster..."
$K8sVersion = aws eks describe-cluster `
    --name $ClusterName `
    --profile $Profile_aws `
    --query "cluster.version" `
    --output text

Write-Host "📦 Listando add-ons instalados..."
$Addons = aws eks list-addons `
    --cluster-name $ClusterName `
    --profile $Profile_aws `
    --query "addons" `
    --output text

$AddonList = $Addons -split "`t"
Write-Host "`n Lista de add-ons: ${AddonList} "  

foreach ($Addon in $AddonList) {
    Write-Host "`n🔄 Verificando versão atual e versão mais recente compatível para: ${Addon}"

    # Versão atualmente instalada
    $CurrentVersion = aws eks describe-addon `
        --cluster-name $ClusterName `
        --addon-name $Addon `
        --profile $Profile_aws `
        --query "addon.addonVersion" `
        --output text

    Write-Host "🟡 Versão atual instalada: $CurrentVersion"

    
    # Versões disponíveis (JSON)
    $VersionsJson = aws eks describe-addon-versions `
        --addon-name $Addon `
        --kubernetes-version $K8sVersion `
        --profile $Profile_aws `
        --output json

    $Parsed = $VersionsJson | ConvertFrom-Json
    $AddonVersions = $Parsed.addons[0].addonVersions
    $LatestVersion = $AddonVersions[0].addonVersion
    Write-Host "📌 Versão mais recente compatível: $LatestVersion"  
    
if ($LatestVersion -and $LatestVersion -ne $CurrentVersion) {
        Write-Host "🟢 Atualizando ${Addon} para versão: $LatestVersion"
        # Descomente a linha abaixo para executar a atualização
        # aws eks update-addon `
        #     --cluster-name $ClusterName `
        #     --addon-name $Addon `
        #     --addon-version $LatestVersion `
        #     --resolve-conflicts OVERWRITE `
        #     --profile $Profile_aws
    } elseif ($LatestVersion -eq $CurrentVersion) {
        Write-Host "✅ ${Addon} já está na versão mais recente: $CurrentVersion"
    } else {
        Write-Host "⚠️ Nenhuma versão encontrada para ${Addon}"
    }
}

Write-Host "`n🏁 Atualização concluída!"