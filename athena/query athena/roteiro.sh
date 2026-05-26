# Lista databases
aws glue get-databases --profile dsprod --query "DatabaseList[*].Name"

# Lista de databases (você pode substituir por uma chamada dinâmica se quiser)
$databases = @(
    "cep", "datahub", "datahub_contatos", "datahubcafir", "default",
    "fpv_contatos_bronze", "fpv_contatos_silver", "iceberg_blog_default",
    "kafkalog", "migrate", "pep_ingestion", "replicacao", "reports", "s3_access_logs_db"
)

### Buscar tabela
# Nome da tabela que você quer encontrar
$tabelaProcurada = "nlb_eks_logs"

# Perfil AWS CLI
$awsProfile = "dsprod"

# Loop pelos databases
foreach ($db in $databases) {
    Write-Host "Verificando no database: $db"

    $resultado = aws glue get-tables `
        --database-name $db `
        --profile $awsProfile `
        --query "TableList[?Name=='$tabelaProcurada'].Name" `
        --output text

    if ($resultado -eq $tabelaProcurada) {
        Write-Host "✅ Tabela '$tabelaProcurada' encontrada no database: $db"
    }
}

# Verificar se a query já foi executada
aws athena list-query-executions --profile dsprod

# Query
aws athena start-query-execution `
  --query-string "SELECT * FROM nlb_eks_logs WHERE domain_name = 'experian-log-services.prod-ds.br.experian.eeca' AND time >= '2025-10-14';" `
  --query-execution-context Database=cep `
  --result-configuration OutputLocation="s3://aws-athena-query-results-662860092544-sa-east-1/" `
  --profile dsprod

$executionId = "35010b7e-4a03-4b4b-8a0c-b765d1ff9b81"
$profileaws = "dsprod"
$state = "RUNNING"

Write-Host "Monitorando execução da query Athena: $executionId..."

while ($state -eq "RUNNING" -or $state -eq "QUEUED") {
    $state = aws athena get-query-execution `
        --query-execution-id $executionId `
        --profile $profileaws `
        --query "QueryExecution.Status.State" `
        --output text

    Write-Host "Status atual: $state"
    Start-Sleep -Seconds 5
}

Write-Host "Execução finalizada com status: $state"

