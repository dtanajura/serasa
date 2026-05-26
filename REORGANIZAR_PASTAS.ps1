# PowerShell Script para Reorganizar Pastas SERASA
$basePath = "C:\tmp\serasa"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  REORGANIZADOR DE PASTAS SERASA" -ForegroundColor Cyan
Write-Host "  Estruturando por categoria" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

function EnsureDir {
    param([string]$path)
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        return $true
    }
    return $false
}

function MoveFolder {
    param([string]$source, [string]$destination)
    if (Test-Path "$basePath\$source") {
        $destDir = "$basePath\$destination"
        $destParent = Split-Path $destDir
        EnsureDir $destParent | Out-Null
        Move-Item "$basePath\$source" "$destDir" -Force
        Write-Host "[OK] $source -> $destination" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] Nao encontrado: $source" -ForegroundColor Yellow
    }
}

Write-Host "Esta acao vai reorganizar 40 pastas em 10 categorias" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Deseja continuar? (S/N)"
if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Host "Operacao cancelada." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Iniciando reorganizacao..." -ForegroundColor Cyan
Write-Host ""

Write-Host "PASSO 1: Criando estrutura de categorias..." -ForegroundColor Cyan

@("certificados", "contas-ambientes", "backup", "eks", "emr", "lambda", "roles", "s3-buckets", "tags", "outros") | ForEach-Object {
    if (EnsureDir "$basePath\$_") {
        Write-Host "  [NOVO] Criada pasta: $_"
    }
}

Write-Host ""
Write-Host "PASSO 2: Movendo pastas para suas categorias..." -ForegroundColor Cyan
Write-Host ""

Write-Host "== CERTIFICADOS ==" -ForegroundColor Magenta
MoveFolder "Lista certificados" "certificados\01-AWS-ACM-Certificados"
MoveFolder "Solicitacao de certificados" "certificados\02-Solicitacao-Certificados"

Write-Host ""
Write-Host "== CONTAS E AMBIENTES ==" -ForegroundColor Magenta
MoveFolder "Ambiente LAB" "contas-ambientes\01-Ambiente-LAB-DEV-Experience"
MoveFolder "ambiente lab - dev experience" "contas-ambientes\02-Ambiente-Lab-Dev"
MoveFolder "Levantamento do ambiente" "contas-ambientes\03-Levantamento-Ambiente"
MoveFolder "levantamento volumes" "contas-ambientes\04-Levantamento-Volumes-EBS"
MoveFolder "Migracao de contas DEV-HUB" "contas-ambientes\05-Migracao-Contas-DevHub"
MoveFolder "Onboard contas positivo e negativo" "contas-ambientes\06-Onboarding-Positivo-Negativo"
MoveFolder "Onboarding conta SRE DEV" "contas-ambientes\07-Onboarding-SRE-DEV"
MoveFolder "Onboarding contas devhub" "contas-ambientes\08-Onboarding-DevHub-Completo"
MoveFolder "usuario BUUserForPositivoMercantil" "contas-ambientes\09-Usuario-Positivo-Mercantil"
MoveFolder "negativos-privados" "contas-ambientes\10-Contas-Negativo-Privadas"
MoveFolder "Permissao BUUserForDevSecOpsPiaaS" "contas-ambientes\11-Permissoes-DevSecOps-PiaaS"
MoveFolder "Monitoramento eec-aws-br-nike-ss-sandbox" "contas-ambientes\12-Monitoramento-Sandbox"

Write-Host ""
Write-Host "== BACKUP ==" -ForegroundColor Magenta
MoveFolder "backup" "backup\01-Backup-Configuration"

Write-Host ""
Write-Host "== KUBERNETES (EKS) ==" -ForegroundColor Magenta
MoveFolder "Listar Roles dos Node Groups" "eks\01-EKS-Node-Groups-Roles"
MoveFolder "Remover cluster eks" "eks\02-Remocao-EKS-Cluster"
MoveFolder "ligar e desligar eks" "eks\03-EKS-Start-Stop-Script"

Write-Host ""
Write-Host "== EMR ==" -ForegroundColor Magenta
MoveFolder "Migracao-mongo" "emr\01-Migracao-MongoDB"
MoveFolder "Tratamento Mongo" "emr\02-Tratamento-MongoDB"

Write-Host ""
Write-Host "== LAMBDA ==" -ForegroundColor Magenta
MoveFolder "Rotina Lambda" "lambda\01-Lambda-Automation"

Write-Host ""
Write-Host "== ROLES ==" -ForegroundColor Magenta
MoveFolder "permissoes para deployments" "roles\01-Permissoes-Deployment"

Write-Host ""
Write-Host "== S3 E BUCKETS ==" -ForegroundColor Magenta
MoveFolder "inventario datahub" "s3-buckets\01-Inventario-DataHub-Tags"
MoveFolder "inventario" "s3-buckets\02-Inventario-Geral-AWS"

Write-Host ""
Write-Host "== OUTROS ==" -ForegroundColor Magenta
MoveFolder "AWS CLI Diversos" "outros\01-AWS-CLI-Diversos"
MoveFolder "Hackaton" "outros\02-Hackathon-Nike"
MoveFolder "Pinot" "outros\03-Pinot-Analytics"
MoveFolder "Remover tudo" "outros\04-Limpeza-Completa-Contas"
MoveFolder "roteiros" "outros\05-Roteiros-Centralizados"
MoveFolder "rev_labs" "outros\06-Review-Laboratorios"
MoveFolder "sagemaker" "outros\07-SageMaker-ML"
MoveFolder "system manager" "outros\08-AWS-Systems-Manager"
MoveFolder "terragrunt" "outros\09-Terragrunt-IaC"
MoveFolder "lens" "outros\10-Lens-Kubernetes-UI"
MoveFolder "Tasks" "outros\11-Tasks-Rastreamento"
MoveFolder "Vulnerabilidades - 2" "outros\12-Analise-Vulnerabilidades-v2"
MoveFolder "vulnerabilidades" "outros\13-Analise-Vulnerabilidades-v1"
MoveFolder "_outras tarefas" "outros\14-Tarefas-Diversas"
MoveFolder "zabbix" "outros\15-Zabbix-Monitoring"
MoveFolder "atualização cliente zabbix" "outros\15-Zabbix-Monitoring\Cliente-Update"

Write-Host ""
Write-Host "PASSO 3: Limpando duplicatas..." -ForegroundColor Cyan
if (Test-Path "$basePath\inventario datahub copy") {
    Remove-Item "$basePath\inventario datahub copy" -Recurse -Force
    Write-Host "[REMOVIDO] inventario datahub copy (duplicata)"
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  REORGANIZACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Resumo:" -ForegroundColor Yellow
Write-Host "  - Estrutura criada: 10 categorias"
Write-Host "  - Pastas movidas: ~38"
Write-Host "  - Duplicatas removidas: 1"
Write-Host ""
Write-Host "Proximas acoes:" -ForegroundColor Cyan
Write-Host "  1. git add -A"
Write-Host "  2. git commit -m 'Reorganizar pastas por categoria'"
Write-Host "  3. git push"
Write-Host ""
Read-Host "Pressione ENTER para fechar"
