# Permissão BUUserForDevSecOpsPiaaS

## 📌 Descrição

Pasta: `Permissão BUUserForDevSecOpsPiaaS`

**Roteiro de execução disponível**

## 🚀 Como Executar (roteiro.sh)

Este script executa os seguintes passos:

1. `aws iam list-policies \`
2. `--scope Local \`
3. `--query "Policies[?PolicyName=='BUPolicyForDevSecOpsPiaaS'].Arn" \`
4. `--output text \`
5. `--profile nikedataserviceuat`
6. `aws iam list-policy-versions \`
7. `--policy-arn arn:aws:iam::713881783816:policy/BUPolicyForDevSecOpsPiaaS \`
8. `--profile nikedataserviceuat`
9. `aws iam delete-policy-version \`
10. `--policy-arn arn:aws:iam::713881783816:policy/BUPolicyForDevSecOpsPiaaS \`
11. `--version-id v3 \`
12. `--profile nikedataserviceuat`
13. `aws iam create-policy-version \`
14. `--policy-arn arn:aws:iam::713881783816:policy/BUPolicyForDevSecOpsPiaaS \`
15. `--policy-document file://policy.json \`

... e mais 2 passos

**Como executar:**
```bash
cd /caminho/para/pasta
bash roteiro.sh
```

## ⚙️ Arquivos de Configuração

**JSON:**
- `policy.json`

## 📋 Pré-requisitos

- AWS CLI configurada
- Credenciais AWS com permissões apropriadas

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
