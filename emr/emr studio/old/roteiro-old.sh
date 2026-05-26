# Setar variáveis de ambiente no powershell
$env:AWS_CA_BUNDLE="c:\tmp\serasa.pem"
$env:PATH += ";C:\tmp"

# Setar variáveis de ambiente no linux
export AWS_CA_BUNDLE=/drives/c/tmp/serasa.pem
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
Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\emr studio"

profile = "devhub-legada-sandbox"

git config --global user.name "Davi Tanajura"
git config --global user.email "davi.tanajura@br.experian.com"

git clone https://code.br.experian.local/scm/nikesre/terraform-s3.git
# usar o login placa de carro

terraform init

Módulo do EMR: https://code.experian.local/projects/DATASTRATE/repos/terraform-modules/browse/emr-studio?at=emr-studio-v0.0.11
Módulo do S3: https://code.experian.local/projects/NIKESRE/repos/terraform-s3/browse
