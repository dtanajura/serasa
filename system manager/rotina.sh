Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\system manager"

# Crie o documento do Systems Manager:
aws ssm create-document --name "ColetarMetricas" --document-type "Command" --content file://rotina.json --region sa-east-1 --profile dsstage
# Execute o documento criado:
aws ssm send-command --document-name "ObterMetricas" --targets "Key=instanceIds,Values=i-0f0fcadb6c5ce1d46" --region sa-east-1 --profile dsstage
# Verifique o status do documento com o seguinte comando:
aws ssm describe-document --name "ColetarMetricas" --region sa-east-1 --profile dsstage
# Parece que o comando foi enviado e está no status "Pending". Vamos verificar o progresso e os resultados do comando. Você pode usar o comando list-command-invocations para obter o status e a saída do comando:
aws ssm list-command-invocations --command-id "59e701fd-c4d4-4457-928b-3f96f7d1c74a" --details --region sa-east-1 --profile dsstage

# Atualizar permissões do usuário de automação
$profile_aws = "dsstage"
# Verificar o nome do bucket para gravar p zip
aws s3 ls --profile $profile_aws
# tfstate-146737708860-sa-east-1-uat

aws s3 cp lambda_function.zip s3://tfstate-146737708860-sa-east-1-uat --profile $profile_aws
aws ec2 describe-subnets  --profile $profile_aws --output text --query "Subnets[].[SubnetId,AvailableIpAddressCount,AvailabilityZone]" --filters "Name=tag:Name,Values=aws*"
# subnet-0121f680e74d654a8        10      sa-east-1b
# subnet-0690b59c6b1e124e2        52      sa-east-1b
# subnet-08e6a67b3b6d4aa4c        10      sa-east-1a
# subnet-08be458785508e32c        30      sa-east-1c

$profile_aws = "dsstage"
$role_arn = aws iam list-roles --query 'Roles[?RoleName==`BURoleForLambdaObservability`].Arn' --output text --profile $profile_aws
$account_id = aws sts get-caller-identity --profile $profile_aws --query Account --output text
$subnet_id = "subnet-0690b59c6b1e124e2" # Selecionei a que tem mais ips disponíveis
$SgId = "sg-0479c1bcbd0a92bba"

aws ec2 describe-security-groups --filters Name=group-id,Values=$SgId --profile $profile_aws --query 'SecurityGroups[*].{GroupName:GroupName, IpPermissions:IpPermissions, IpPermissionsEgress:IpPermissionsEgress}' --output json

aws lambda create-function --function-name ColetaDadosObservabilidade --runtime python3.11 --handler coleta.lambda_handler --role $role_arn --timeout 300 --code S3Bucket=tfstate-146737708860-sa-east-1-uat,S3Key=lambda_function.zip --profile $profile_aws --vpc-config SubnetIds=$subnet_id,SecurityGroupIds=$SgId

aws lambda update-function-configuration --function-name ColetaDadosObservabilidade --environment "Variables={DB_HOST=observabilidade-0.cwhrk1jkkma0.sa-east-1.rds.amazonaws.com,DB_USER=app-user,DB_PASSWORD=123Trocar$,DB_NAME=custos_nike}" --profile $profile_aws 

aws events put-rule --name "ExecutarLambdaObservabilidade" --schedule-expression "rate(10 minutes)" --region sa-east-1 --profile $profile_aws

aws lambda add-permission --function-name ColetaDadosObservabilidade --statement-id "EventBridgeInvoke" --action "lambda:InvokeFunction" --principal "events.amazonaws.com" --source-arn "arn:aws:events:sa-east-1:146737708860:rule/ExecutarLambdaObservabilidade" --region sa-east-1 --profile $profile_aws

aws events put-targets --rule ExecutarLambdaObservabilidade --targets file://eventbridge_target.json --profile $profile_aws

aws lambda invoke --function-name ColetaDadosObservabilidade --payload '{}' --profile $profile_aws output.json

aws lambda delete-function --function-name Teste --profile $profile_aws

aws lambda update-function-code --function-name Teste --s3-bucket tfstate-730335661246-sa-east-1-dev --s3-key teste.zip --profile $profile_aws
aws lambda update-function-configuration --function-name Teste --handler teste.lambda_handler --profile $profile_aws

