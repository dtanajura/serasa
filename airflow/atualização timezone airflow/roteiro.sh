Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\_outras tarefas\atualização timezone airflow"

aws mwaa update-environment `
  --name mwaa-warriors-prod `
  --airflow-configuration-options file://timezone.json `
  --profile nikedataprod `
  --region sa-east-1


do {
    $status = aws mwaa get-environment `
        --name mwaa-warriors-prod `
        --profile nikedataprod `
        --region sa-east-1 `
        --no-verify-ssl `
        --query "Environment.LastUpdate.Status" `
        --output text

    Write-Host "Status atual: $status"
    Start-Sleep -Seconds 30
} while ($status -eq "PENDING")
