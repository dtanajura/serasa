# inventario

## 📌 Visão Geral

**Scripts Python:** `inventory.py`

**Roteiro:** `roteiro.sh`

## 🚀 Roteiro de Execução

Este script executa automaticamente os seguintes passos:

1. `$env:AWS_CA_BUNDLE="c:\tmp\serasa.pem"`
2. `$env:PATH += ";C:\tmp"`
3. `function global:prompt {`
4. `$dirSep = [IO.Path]::DirectorySeparatorChar`
5. `$pathComponents = $PWD.Path.Split($dirSep)`
6. `$displayPath = if ($pathComponents.Count -le 3) {$PWD.Path`
7. `} else {`
8. `'…{0}{1}' -f $dirSep, ($pathComponents[-2,-1] -join $dirSep)`
9. `"PS {0}$('>' * ($nestedPromptLevel + 1)) " -f $displayPath`
10. Autenticação: `saml2aws.exe login -a eec-aws-br-nike-architecture-sandbox`
11. `Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\Ambiente LAB\in`
12. `~/set_eks.sh`
13. Autenticação: `saml2aws login -a arcsandbox`
14. `cd /home/c96531a/inventario/aws-inventory`
15. Executa: `python3.11`
16. `BUPolicyForAWSInventory_01`

**Total: 16 passos**

**Como executar:**
```bash
bash roteiro.sh
```

## 🐍 Scripts Python

### `inventory.py`

**Função:** Script Python

**Como usar:**
```bash
python inventory.py
```

**Bibliotecas:**
- `boto3`
- `botocore`
- `collections`
- `config`
- `csv`
- `logging`
- `pprint`
- `res`
- `smtplib`
- `time`

**Retorna:**
- Resultado impresso no console
- Interação com AWS via Boto3

## 📋 Pré-requisitos

**Python 3.6+** com bibliotecas:
```bash
pip install boto3 pandas openpyxl
```

**Autenticação:**
- `saml2aws` instalado
- Perfis AWS configurados
- `saml2aws login -a <account>`

**AWS:**
- AWS CLI v2
- Credenciais configuradas
- Permissões apropriadas

## 💡 Exemplos

**Usar inventory.py:**
```bash
python inventory.py
```

**Executar roteiro completo:**
```bash
bash roteiro.sh
```

## 🐛 Troubleshooting

| Erro | Solução |
|------|----------|
| Erro de autenticação | `saml2aws login -a <account>` |
| ModuleNotFoundError | `pip install boto3` |
| Acesso negado | Verificar permissões IAM |

## ⚠️ Importante

- ✅ Testar em DEV antes de PROD
- ✅ Revisar scripts antes de executar
- ✅ Fazer backup de dados sensíveis
- ❌ Nunca commitar credenciais AWS

---
*Última atualização: 2026-05-26*
