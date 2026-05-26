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
Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\Ambiente LAB\inventario"

# Conectar via mobaterm:
### Open Local Terminal
### ssh c96531a@spobrnikeworker
~/set_eks.sh

saml2aws login -a arcsandbox

cd /home/c96531a/inventario/aws-inventory
# Executar Python
python3.11 
BUPolicyForAWSInventory_01