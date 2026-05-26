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
saml2aws.exe login -a eec-aws-br-nike-architecture-sandbox
Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\inventario\producao"
$profileaws  = "arcsandbox"

# todas contas:
saml2aws.exe login -a eec-aws-br-nike-corporate-prod # ok
saml2aws.exe login -a eec-aws-br-nike-architecture-sandbox # ok
saml2aws.exe login -a eec-aws-br-nike-ssrm-dev # ok
saml2aws.exe login -a eec-aws-br-nike-ss-sandbox # ok
saml2aws.exe login -a eec-aws-br-nike-sales-prod # ok
saml2aws.exe login -a eec-aws-br-nike-corporate-dev # ok
saml2aws.exe login -a eec-aws-br-eits-nike-sre-management-dev # ok
saml2aws.exe login -a eec-aws-br-ds-dataservices-stage # ok
saml2aws.exe login -a eec-aws-br-ds-dataservices-prod # ok
saml2aws.exe login -a eec-aws-br-ds-dataservices-dev # Failed to assume role
saml2aws.exe login -a eec-aws-us-eits-datahub-dev # ok
saml2aws.exe login -a eec-aws-br-eits-datahub-prod # ok 
saml2aws.exe login -a eec-aws-us-eits-consent-dev # ok
saml2aws.exe login -a eec-aws-us-eits-consent-prod # ok

# Nomes das contas usadas por Bahia
corporateprod-564593125549
arcsandbox-187739130313
ssrmdev-306716481758
ssrmsandbox-087086536124
ssrmprod-877001948254
corporatedev-153056696998
sredev-504195663072
dsstage-146737708860
dsprod-662860092544
dsdev-530914589075
datahubdev-353091569218
datahubprod-415071355886
consentdev-992382670558
consentprod-975050357449

# Profiles
$profiles = @(
  "corporateprod",
  "arcsandbox",
  "ssrmdev",
  "ssrmsandbox",
  "ssrmprod",
  "corporatedev",
  "sredev",
  "dsstage",
  "dsprod",
  "dsdev",
  "datahubdev",
  "datahubdevus",
  "datahubprod",
  "consentdev",
  "consentprod"
)
foreach ($profileaws  in $profiles) {
    python .\teste.py $profileaws 
}
foreach ($profileaws  in $profiles) {
    python .\inventory.py $profileaws 
}

foreach ($profileaws  in $profiles) {
    aws ce list-cost-allocation-tags --profile $profileaws 
}


foreach ($profileaws  in $profiles) {
    python .\accounts.py $profileaws 
}

https://grafana.nikeeksdev.br.experian.eeca/
usr: admin
pwd: jbbHyhpTwV5GUV8D

aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId,State.Name,Tags[?Key=='Name'].Value]" --profile $profileaws 

$profileaws ="arcsandbox"
aws ssm start-session --target  i-0195bb949e335b724 --profile $profileaws 

# conectar no banco de origem
psql -h dev-hub-portal-qa.cbjrpisgumc2.sa-east-1.rds.amazonaws.com -p 5432 -U postgres -W -d postgres -W
mZDqS3XAM7LZATn

# listar bancos 
\l
# conectar ao banco inventario
\c inventario
mZDqS3XAM7LZATn
#listar todas as tabelas
\dt
# listar campos da tabela resources
\d+ resources



Acesso ao Tower:
https://aap/#/login
Login com placa de carro
Para atualizar o Tower com o meu repositório, ou espera a proxima atualização ou roda a automação menu job - "NIKE-SRE-AUTOMATION" que faz o git pull do repositório
O template "NIKE - AWS DISCOVERY RESOURCES" executa o python inventory.py
