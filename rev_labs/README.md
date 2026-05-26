# rev_labs

## 📌 Descrição

Pasta: `rev_labs`

**Roteiro de execução disponível**

## 🚀 Como Executar (roteiro.sh)

Este script executa os seguintes passos:

1. `$env:AWS_CA_BUNDLE="c:\tmp\serasa.pem"`
2. `$env:PATH += ";C:\tmp;C:\Program Files\Python38"`
3. `$env:PATH += ";C:\Program Files\Python38\Scripts"`
4. `function global:prompt {`
5. `$dirSep = [IO.Path]::DirectorySeparatorChar`
6. `$pathComponents = $PWD.Path.Split($dirSep)`
7. `$displayPath = if ($pathComponents.Count -le 3) {$PWD.Path`
8. `} else {`
9. `'…{0}{1}' -f $dirSep, ($pathComponents[-2,-1] -join $dirSep)`
10. `}`
11. `"PS {0}$('>' * ($nestedPromptLevel + 1)) " -f $displayPath`
12. `}`
13. `Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\_outras tarefas\rev_labs"`
14. `saml2aws.exe login -a eec-aws-br-eits-dx-lab01-sandbox`
15. `saml2aws.exe login -a eec-aws-br-eits-dx-lab02-sandbox`

... e mais 268 passos

**Como executar:**
```bash
cd /caminho/para/pasta
bash roteiro.sh
```

## ⚙️ Arquivos de Configuração

**JSON:**
- `BUPolicyForDevSecOpsPiaaS.json`
- `provision-parameters-CustomADGroup.json`
- `provision-parameters-Route53SubDomain-lab01.json`
- `provision-parameters-Route53SubDomain-lab02.json`
- `provision-parameters-Route53SubDomain-lab03.json`
- `provision-parameters-Route53SubDomain-lab04.json`
- `provision-parameters-Route53SubDomain-lab05.json`
- `provision-parameters-Route53SubDomain.json`
- `registry_policy.json`
- `trust-policy.json`

**YAML:**
- `AssumeRole.yml`

## 📋 Pré-requisitos

- `saml2aws` para autenticação AWS
- AWS CLI configurada

## ⚠️ Observações Importantes

- Sempre testar em ambiente DEV antes de executar em PROD
- Revisar o roteiro antes de executar automaticamente
- Fazer backup dos dados antes de operações destrutivas
- Verificar credenciais e permissões necessárias

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique o arquivo `roteiro.sh` ou `roteiro.txt`
2. Consulte os comentários nos scripts Python
3. Revise os arquivos de configuração

---

*Documentação gerada automaticamente - Última atualização: 2026-05-26*
