# Rotina Lambda

## 📌 Visão Geral

**Scripts Python:** `lambda.py`, `tag-teste-profile.py`, `tags-instancescheduler.py`

**Roteiro:** `roteiro.sh`

## 🚀 Roteiro de Execução

Este script executa automaticamente os seguintes passos:

1. `$env:AWS_CA_BUNDLE="c:\tmp\serasa.pem"`
2. Executa: `$env:PATH += ";C:\tmp;C:\Program Files\Python38;C:\Program Files\Python38\Script`
3. `function global:prompt {`
4. `$dirSep = [IO.Path]::DirectorySeparatorChar`
5. `$pathComponents = $PWD.Path.Split($dirSep)`
6. `$displayPath = if ($pathComponents.Count -le 3) {$PWD.Path`
7. `} else {`
8. `'…{0}{1}' -f $dirSep, ($pathComponents[-2,-1] -join $dirSep)`
9. `"PS {0}$('>' * ($nestedPromptLevel + 1)) " -f $displayPath`
10. `Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\Rotina Lambda"`
11. Autenticação: `saml2aws.exe login -a eec-aws-br-eits-dx-lab01-sandbox`
12. Autenticação: `saml2aws.exe login -a eec-aws-br-eits-dx-lab02-sandbox`
13. Autenticação: `saml2aws.exe login -a eec-aws-br-eits-dx-lab03-sandbox`
14. Autenticação: `saml2aws.exe login -a eec-aws-br-eits-dx-lab04-sandbox`
15. Autenticação: `saml2aws.exe login -a eec-aws-br-eits-dx-lab05-sandbox`
16. `$perfis = @("lab01","lab02", "lab03", "lab04", "lab05")`
17. `foreach ($profile in $perfis) {`
18. `Write-Host "Criando função para o perfil $profile"`
19. `aws iam create-role --role-name BURoleForLambdaTagInstanceScheduler --assume-rol`
20. `$policy_arn = aws iam create-policy --policy-name BUPolicyForLambdaTagInstanceSc`
21. `aws iam attach-role-policy  --role-name BURoleForLambdaTagInstanceScheduler  --p`
22. `aws iam attach-role-policy  --role-name BURoleForLambdaTagInstanceScheduler  --p`
23. `$perfis = @("lab03", "lab04", "lab05")`
24. `foreach ($profile in $perfis) {`
25. `Write-Host "Copiando arquivo da função lambda para s3://tfstate-$profile"`

... mais 11 passos ...

**Total: 36 passos**

**Como executar:**
```bash
bash roteiro.sh
```

## 🐍 Scripts Python

### `lambda.py`

**Função:** Script Python

**Como usar:**
```bash
python lambda.py
```

**Bibliotecas:**
- `boto3`

**Retorna:**
- Resultado impresso no console
- Interação com AWS via Boto3

### `tag-teste-profile.py`

**Função:** Script Python

**Como usar:**
```bash
python tag-teste-profile.py
```

**Bibliotecas:**
- `boto3`

**Retorna:**
- Resultado impresso no console
- Interação com AWS via Boto3

### `tags-instancescheduler.py`

**Função:** Script Python

**Como usar:**
```bash
python tags-instancescheduler.py
```

**Bibliotecas:**
- `boto3`

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

**Usar lambda.py:**
```bash
python lambda.py
```

**Usar tag-teste-profile.py:**
```bash
python tag-teste-profile.py
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
