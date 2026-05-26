# Limpar arquivos soltos na raiz do repositorio
$basePath = "C:\tmp\serasa"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  LIMPADOR DE ARQUIVOS SOLTOS NA RAIZ" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Arquivos encontrados na raiz:" -ForegroundColor Yellow
Write-Host "  - Documentacao (7 arquivos)"
Write-Host "  - Scripts Python (4 arquivos)"
Write-Host "  - Imagens (2 arquivos)"
Write-Host "  - Scripts shell (2 arquivos)"
Write-Host "  - Arquivos temporarios (2 arquivos)"
Write-Host ""

$confirm = Read-Host "Deseja organiza-los? (S/N)"
if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Host "Operacao cancelada." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Criando pastas..." -ForegroundColor Cyan

# Criar pastas
New-Item -ItemType Directory -Path "$basePath\docs" -Force | Out-Null
New-Item -ItemType Directory -Path "$basePath\scripts" -Force | Out-Null
New-Item -ItemType Directory -Path "$basePath\images" -Force | Out-Null

Write-Host "[OK] Pastas criadas: docs/, scripts/, images/" -ForegroundColor Green
Write-Host ""

# Mover documentacao
Write-Host "Movendo documentacao..." -ForegroundColor Cyan
$docFiles = @(
    "PLANO_ORGANIZACAO_SERASA.md",
    "PROXIMAS_ACOES.md",
    "SUMARIO_EXECUTIVO.md",
    "MAPEAMENTO_REORGANIZACAO.txt",
    "MAPA_RENOMEACAO_COMPLETO.txt",
    "ESTATISTICAS_REPOSITORIO.txt",
    "analise_estrutura.txt"
)

$docFiles | ForEach-Object {
    if (Test-Path "$basePath\$_") {
        Move-Item "$basePath\$_" "$basePath\docs\" -Force
        Write-Host "  [MOVED] $_ -> docs/"
    }
}

# Mover scripts Python
Write-Host ""
Write-Host "Movendo scripts Python..." -ForegroundColor Cyan
$pyFiles = @(
    "criar_readmes.py",
    "criar_readmes_v2.py",
    "gerar_readmes_detalhados.py",
    "melhorar_readme.py"
)

$pyFiles | ForEach-Object {
    if (Test-Path "$basePath\$_") {
        Move-Item "$basePath\$_" "$basePath\scripts\" -Force
        Write-Host "  [MOVED] $_ -> scripts/"
    }
}

# Mover scripts shell
Write-Host ""
Write-Host "Movendo scripts shell..." -ForegroundColor Cyan
$shFiles = @(
    "limpa.sh",
    "logon.sh"
)

$shFiles | ForEach-Object {
    if (Test-Path "$basePath\$_") {
        Move-Item "$basePath\$_" "$basePath\scripts\" -Force
        Write-Host "  [MOVED] $_ -> scripts/"
    }
}

# Mover imagens
Write-Host ""
Write-Host "Movendo imagens..." -ForegroundColor Cyan
$imgFiles = @(
    "arquitetura.png",
    "arquitetura.pptx"
)

$imgFiles | ForEach-Object {
    if (Test-Path "$basePath\$_") {
        Move-Item "$basePath\$_" "$basePath\images\" -Force
        Write-Host "  [MOVED] $_ -> images/"
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  LIMPEZA CONCLUIDA!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estrutura final:" -ForegroundColor Yellow
Write-Host "  C:\tmp\serasa\docs\          - Documentacao de projeto"
Write-Host "  C:\tmp\serasa\scripts\       - Scripts Python e Shell"
Write-Host "  C:\tmp\serasa\images\        - Imagens e diagramas"
Write-Host "  C:\tmp\serasa\[10 categorias]/ - Pastas de atividades"
Write-Host ""
Write-Host "Proximas acoes:" -ForegroundColor Cyan
Write-Host "  1. git add -A"
Write-Host "  2. git commit -m 'Organizar arquivos soltos em pastas'"
Write-Host "  3. git push"
Write-Host ""
Read-Host "Pressione ENTER para fechar"
