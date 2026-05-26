# Setar variáveis de ambiente no powershell
$env:AWS_CA_BUNDLE="c:\tmp\serasa.pem"
$env:PATH += ";C:\tmp;C:\Program Files\Python38;C:\Program Files\Python38\Scripts"

# Configuração do Prompt no PowerShell
function global:prompt {
    $dirSep = [IO.Path]::DirectorySeparatorChar
    $pathComponents = $PWD.Path.Split($dirSep)
    $displayPath = if ($pathComponents.Count -le 3) {$PWD.Path
    } else {
      '…{0}{1}' -f $dirSep, ($pathComponents[-2,-1] -join $dirSep)
    }
    "PS {0}$('>' * ($nestedPromptLevel + 1)) " -f $displayPath
  }

Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\Rotina Lambda"

# Logar nas contas
saml2aws.exe login -a eec-aws-br-eits-dx-lab01-sandbox
saml2aws.exe login -a eec-aws-br-eits-dx-lab02-sandbox
saml2aws.exe login -a eec-aws-br-eits-dx-lab03-sandbox
saml2aws.exe login -a eec-aws-br-eits-dx-lab04-sandbox
saml2aws.exe login -a eec-aws-br-eits-dx-lab05-sandbox

# Atualizar permissões do usuário de automação
$perfis = @("lab01","lab02", "lab03", "lab04", "lab05")

# Itere sobre cada perfil e crie a função
foreach ($profile in $perfis) {
    Write-Host "Criando função para o perfil $profile"
    aws iam create-role --role-name BURoleForLambdaTagInstanceScheduler --assume-role-policy-document file://trust.json --profile $profile
    $policy_arn = aws iam create-policy --policy-name BUPolicyForLambdaTagInstanceScheduler --policy-document file://policy.json --profile $profile --query "Policy.Arn" --output text
    aws iam attach-role-policy  --role-name BURoleForLambdaTagInstanceScheduler  --policy-arn $policy_arn --profile $profile
    aws iam attach-role-policy  --role-name BURoleForLambdaTagInstanceScheduler  --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" --profile $profile
}

$perfis = @("lab03", "lab04", "lab05")
foreach ($profile in $perfis) {
  Write-Host "Copiando arquivo da função lambda para s3://tfstate-$profile"
  aws s3 cp lambda.zip s3://tfstate-$profile --profile $profile
  $role_arn = aws iam get-role --role-name BURoleForLambdaTagInstanceScheduler --profile $profile --query Role.Arn --output text
  $account_id = aws sts get-caller-identity --profile $profile --query Account --output text
  
  Write-Host "Criando função Lambda na conta"
  aws lambda create-function --function-name Tag-InstanceScheduler --runtime python3.11 --handler lambda.lambda_handler --role $role_arn  --timeout 120 --code S3Bucket=tfstate-$profile,S3Key=lambda.zip --profile $profile
  
  Write-Host "Criando evento para agendar a execução da função na conta"
  aws events put-rule --name Tag-InstanceSchedulerRule --schedule-expression "cron(0 6 * * ? *)" --state ENABLED  --profile $profile
  $lambda_arn = aws lambda get-function --function-name Tag-InstanceScheduler --profile $profile --query "Configuration.FunctionArn" --output text
  aws events put-targets --rule Tag-InstanceSchedulerRule --targets "Id=1,Arn=$lambda_arn" --profile $profile
  
  Write-Host "Configurando o invoke para eventos assincronos na função"
  aws lambda invoke --function-name Tag-InstanceScheduler --invocation-type Event --payload '{}' output.txt --profile $profile
}
