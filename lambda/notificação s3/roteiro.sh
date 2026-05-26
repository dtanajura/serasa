Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\_outras tarefas\notificação s3\eec-aws-br-eits-datahub-positivo-mercantil-raw-dev-bucket"

aws lambda add-permission `
  --function-name experian-datahub-mercantil-valida-remessa-dev `
  --principal s3.amazonaws.com `
  --statement-id AllowExecutionFromS3 `
  --action "lambda:InvokeFunction" `
  --source-arn arn:aws:s3:::eec-aws-br-eits-datahub-positivo-mercantil-raw-dev-bucket `
  --profile datahubdev

aws s3api put-bucket-notification-configuration `
    --bucket eec-aws-br-eits-datahub-positivo-mercantil-raw-dev-bucket `
    --notification-configuration file://notification.json `
    --profile datahubdev
