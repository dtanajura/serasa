# Setar variáveis de ambiente no powershell
$env:AWS_CA_BUNDLE="c:\tmp\serasa.pem"
$env:PATH += ";C:\tmp"

# Configuração do Prompt no PowerShell
function global:prompt {
    $dirSep = [IO.Path]::DirectorySeparatorChar
    $pathComponents = $PWD.Path.Split($dirSep)
    $displayPath = if ($pathComponents.Count -le 3) {
      $PWD.Path
    } else {
      '…{0}{1}' -f $dirSep, ($pathComponents[-2,-1] -join $dirSep)
    }
    "PS {0}$('>' * ($nestedPromptLevel + 1)) " -f $displayPath
  }

Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\Onboarding contas devexperience\_outras tarefas\cert_wildcard"

# Logar nas contas
saml2aws.exe login -a eec-aws-br-eits-devexperience-sandbox
aws ssm start-session --target  i-08dcdf0f9056eb152 --profile devexperience-sandbox 
hostname -I
# 10.120.128.75

ssh-keygen -t rsa -b 2048

openssl pkcs12 -in lab01.br.experian.eeca.pfx -out lab01.br.experian.eeca.pem



sudo su -

openssl pkcs12  -in prd-devhub.br.experian.eeca.pfx -out prd-devhub.br.experian.eeca.pem
openssl pkcs12  -in dev-devhub.br.experian.eeca.pfx -out dev-devhub.br.experian.eeca.pem
openssl pkcs12  -in qa-devhub.br.experian.eeca.pfx -out qa-devhub.br.experian.eeca.pem
openssl pkcs12  -in lab01.br.experian.eeca.pfx -out lab01.br.experian.eeca.pem
openssl pkcs12  -in lab02.br.experian.eeca.pfx -out lab02.br.experian.eeca.pem
openssl pkcs12  -in lab03.br.experian.eeca.pfx -out lab03.br.experian.eeca.pem
openssl pkcs12  -in lab04.br.experian.eeca.pfx -out lab04.br.experian.eeca.pem
openssl pkcs12  -in lab05.br.experian.eeca.pfx -out lab05.br.experian.eeca.pem

aws acm import-certificate --certificate fileb://snd-devhub.br.experian.eeca.pem --certificate-chain fileb://chain-snd-devhub.br.experian.eeca.pem --private-key fileb://snd-devhub.br.experian.eeca.key --profile devexperience-sandbox

openssl pkcs12 -in snd-devhub.br.experian.eeca.pfx -clcerts -nokeys -out snd-devhub.br.experian.eeca.crt
openssl pkcs12 -in snd-devhub.br.experian.eeca.pfx -nocerts -nodes -out snd-devhub.br.experian.eeca.pem

openssl pkcs12 -in lab01.br.experian.eeca.pfx -clcerts -nokeys -out lab01.br.experian.eeca.crt
openssl pkcs12 -in lab01.br.experian.eeca.pfx -nocerts -nodes -out lab01.br.experian.eeca.pem

openssl pkcs12 -in lab02.br.experian.eeca.pfx -clcerts -nokeys -out lab02.br.experian.eeca.crt
openssl pkcs12 -in lab02.br.experian.eeca.pfx -nocerts -nodes -out lab02.br.experian.eeca.pem

openssl pkcs12 -in lab03.br.experian.eeca.pfx -clcerts -nokeys -out lab03.br.experian.eeca.crt
openssl pkcs12 -in lab03.br.experian.eeca.pfx -nocerts -nodes -out lab03.br.experian.eeca.pem

openssl pkcs12 -in lab04.br.experian.eeca.pfx -clcerts -nokeys -out lab04.br.experian.eeca.crt
openssl pkcs12 -in lab04.br.experian.eeca.pfx -nocerts -nodes -out lab04.br.experian.eeca.pem

openssl pkcs12 -in lab05.br.experian.eeca.pfx -clcerts -nokeys -out lab05.br.experian.eeca.crt
openssl pkcs12 -in lab05.br.experian.eeca.pfx -nocerts -nodes -out lab05.br.experian.eeca.pem

openssl pkcs12 -in qa-devhub.br.experian.eeca.pfx -clcerts -nokeys -out qa-devhub.br.experian.eeca.crt
openssl pkcs12 -in qa-devhub.br.experian.eeca.pfx -nocerts -nodes -out qa-devhub.br.experian.eeca.pem

openssl pkcs12 -in dev-devhub.br.experian.eeca.pfx -clcerts -nokeys -out dev-devhub.br.experian.eeca.crt
openssl pkcs12 -in dev-devhub.br.experian.eeca.pfx -nocerts -nodes -out dev-devhub.br.experian.eeca.pem

openssl pkcs12 -in prd-devhub.br.experian.eeca.pfx -clcerts -nokeys -out prd-devhub.br.experian.eeca.crt
openssl pkcs12 -in prd-devhub.br.experian.eeca.pfx -nocerts -nodes -out prd-devhub.br.experian.eeca.pem

saml2aws.exe login -a eec-aws-br-eits-devexperience-prod
aws acm import-certificate --certificate fileb://prd-devhub.br.experian.eeca.crt --private-key fileb://prd-devhub.br.experian.eeca.pem --profile devexperience-prod
aws acm describe-certificate --profile devexperience-prod --certificate-arn arn:aws:acm:sa-east-1:562223391796:certificate/279050ce-211d-442d-97fb-f64e1a6a6748

saml2aws.exe login -a eec-aws-br-eits-devexperience-dev
aws acm import-certificate --certificate fileb://dev-devhub.br.experian.eeca.crt --private-key fileb://dev-devhub.br.experian.eeca.pem --profile devexperience-dev
aws acm describe-certificate --profile devexperience-dev --certificate-arn "arn:aws:acm:sa-east-1:015334905722:certificate/9bef198a-3a16-442a-a1c6-6a44d5f08ecb"

saml2aws.exe login -a eec-aws-br-eits-devexperience-uat
aws acm import-certificate --certificate fileb://qa-devhub.br.experian.eeca.crt --private-key fileb://qa-devhub.br.experian.eeca.pem --profile devexperience-uat

saml2aws.exe login -a eec-aws-br-eits-dx-lab01-sandbox
aws acm import-certificate --certificate fileb://lab01.br.experian.eeca.crt --private-key fileb://lab01.br.experian.eeca.pem --profile lab01

saml2aws.exe login -a eec-aws-br-eits-dx-lab02-sandbox
aws acm import-certificate --certificate fileb://lab02.br.experian.eeca.crt --private-key fileb://lab02.br.experian.eeca.pem --profile lab02

saml2aws.exe login -a eec-aws-br-eits-dx-lab03-sandbox
aws acm import-certificate --certificate fileb://lab03.br.experian.eeca.crt --private-key fileb://lab03.br.experian.eeca.pem --profile lab03

saml2aws.exe login -a eec-aws-br-eits-dx-lab04-sandbox
aws acm import-certificate --certificate fileb://lab04.br.experian.eeca.crt --private-key fileb://lab04.br.experian.eeca.pem --profile lab04

saml2aws.exe login -a eec-aws-br-eits-dx-lab05-sandbox
aws acm import-certificate --certificate fileb://lab05.br.experian.eeca.crt --private-key fileb://lab05.br.experian.eeca.pem --profile lab05
