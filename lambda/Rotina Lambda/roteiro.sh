
Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\_outras tarefas\Rotina Lambda"

# Atualizar permissões do usuário de automação
$profile_aws = "datahubdev"

Write-Host "Copiando arquivo da função lambda para s3://tfstate-730335661246-sa-east-1-dev"
aws s3 cp teste.zip s3://tfstate-730335661246-sa-east-1-dev --profile $profile_aws
$role_arn = "arn:aws:iam::730335661246:role/BURoleForConsent"
$account_id = "730335661246"

Write-Host "Criando função Lambda na conta"
aws lambda create-function --function-name Teste --runtime python3.11 --handler teste.lambda_handler --role $role_arn --timeout 120 --code S3Bucket=tfstate-730335661246-sa-east-1-dev,S3Key=teste.zip --profile $profile_aws --vpc-config SubnetIds=subnet-0ba523237a46d6cbe,SecurityGroupIds=sg-0459482c0163373de
aws lambda invoke --function-name Teste --payload '{}' --profile $profile_aws output.json

aws lambda delete-function --function-name Teste --profile $profile_aws

aws lambda update-function-code --function-name Teste --s3-bucket tfstate-730335661246-sa-east-1-dev --s3-key teste.zip --profile $profile_aws
aws lambda update-function-configuration --function-name Teste --handler teste.lambda_handler --profile $profile_aws