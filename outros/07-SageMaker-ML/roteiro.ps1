# Setar variáveis de ambiente no powershell
$env:AWS_CA_BUNDLE="c:\tmp\serasa.pem"
$env:PATH += ";C:\tmp"

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

# logar na conta
saml2aws.exe login -a eec-aws-br-eits-devhub-sandbox

# listar
aws sagemaker list-notebook-instances --profile $profile_conta

# Reiniciar instância do Jupyter Notebook
$profile_conta = "devhub-sandbox"
$notebookInstance = "devhub-new"
$maxAttempts = 100
$attempt = 1

# Parar
aws sagemaker stop-notebook-instance --notebook-instance-name $notebookInstance --profile $profile_conta

# Wait until the instance is stopped or max attempts reached
do {
    Start-Sleep -Seconds 10
    Write-Host "Attempt # $attempt" 
    $status = aws sagemaker describe-notebook-instance --profile $profile_conta --notebook-instance-name $notebookInstance --query NotebookInstanceStatus --output text
    $attempt++
} while ($status -eq "Stopping" -and $attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "Error: Maximum number of attempts reached. The stack deletion is still in progress."
} else {
    # Iniciar
    aws sagemaker start-notebook-instance --notebook-instance-name $notebookInstance --profile $profile_conta
}

$attempt = 1
do {
  Start-Sleep -Seconds 10
  Write-Host "Attempt # $attempt" 
  $status = aws sagemaker describe-notebook-instance --profile $profile_conta --notebook-instance-name $notebookInstance --query NotebookInstanceStatus --output text
  $attempt++
} while ($status -eq "Pending" -and $attempt -lt $maxAttempts)
Write-Host "Instância iniciada com status: $status"


##### Criação do Jupyter Notebook
## Logar na conta
saml2aws.exe login -a eec-aws-br-eits-devexperience-sandbox
$profile_conta = "devexperience-sandbox"

## Criar a ROLE
aws iam create-role --role-name BURoleForSageMakerJupyterInstances --assume-role-policy-document file://trust-policy.json --profile $profile_conta

aws iam attach-role-policy --role-name BURoleForSageMakerJupyterInstances --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess  --profile $profile_conta

# Obtenha o ARN da função
$role_arn = aws iam get-role --role-name BURoleForSageMakerJupyterInstances --query 'Role.Arn' --output text --profile $profile_conta

## Criar Security Group
$vpcid = aws ec2 describe-vpcs --query "Vpcs[].[VpcId]" --profile $profile_conta --output text
$sg = aws ec2 create-security-group --group-name SG-Jupyter-Notebooks --description "SG for SageMaker Jupyter Notebook" --vpc-id $vpcid --profile $profile_conta --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=SG-Jupyter-Notebooks},{Key=CostString,Value=1800.BR.seucc},{Key=AppID,Value=20274},{Key=Environment,Value=sbx}]' --query 'GroupId' --output text

# Autorizar o tráfego de entrada no grupo de segurança
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 443 --cidr 10.0.0.0/8 --profile $profile_conta
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 8888 --cidr 10.0.0.0/8 --profile $profile_conta
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 22 --cidr 10.0.0.0/8 --profile $profile_conta


# Pegar o valor de uma subnet-id
# Executa o comando AWS CLI para obter os IDs das sub-redes
$subnets = aws ec2 describe-subnets --profile $profile_conta --output text --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*"
# Divide a saída em linhas
$subnetIds = $subnets -split "`n"
# Escolhe um valor aleatório da lista de IDs de sub-rede
$subnetId = Get-Random -InputObject $subnetIds


# Criar instância do Jupyter Notebook
aws ec2 describe-subnets  --profile $profile_conta --output text --query "Subnets[].[SubnetId]" --filters "Name=tag:Name,Values=aws*" 

aws sagemaker create-notebook-instance --notebook-instance-name DevHub-Notebook --instance-type ml.t3.medium  --role-arn $role_arn --security-group-ids $sg --subnet-id $subnetId --profile $profile_conta





