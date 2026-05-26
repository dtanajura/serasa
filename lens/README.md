# lens

## 📌 Descrição

Pasta: `lens`

**Roteiro de execução disponível**

## 🚀 Como Executar (roteiro.sh)

Este script executa os seguintes passos:

1. `cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\lens"`
2. `$profile_aws = "dsstage"`
3. `aws iam list-roles --profile $profile_aws --query "Roles[].RoleName" | Select-String -Pattern "BURoleForDatahub"`
4. `$role_name = "BURoleForDatahub"`
5. `$policy_arn = aws iam create-policy --policy-name BUPolicyForEKSAcess --policy-document file://BUPolicyForEKSAccess.json --profile $profile_aws --query "Policy.Arn" --output text`
6. `aws iam list-policies --scope Local --profile $profile_aws | Select-String -Pattern "BUPolicyForEKSAcess"`
7. `$policy_arn = "arn:aws:iam::662860092544:policy/BUPolicyForEKSAcess"`
8. `aws iam attach-role-policy  --role-name $role_name  --policy-arn $policy_arn --profile $profile_aws`
9. `aws iam get-role-policy  --role-name $role_name --policy-name BUPolicyForEKSAcess --profile $profile_aws`
10. `aws iam update-role --role-name $role_name --max-session-duration 36000 --profile $profile_aws`
11. `aws iam update-assume-role-policy --role-name $role_name --policy-document file://trust.json --profile $profile_aws`
12. `aws iam get-role  --role-name $role_name --profile $profile_aws`
13. `aws iam list-attached-role-policies --role-name $role_name --profile $profile_aws`
14. `aws eks list-clusters  --profile $profile_aws`
15. `$cluster_name=aws eks list-clusters --profile $profile_aws --output text --query "clusters[1]"`

... e mais 217 passos

**Como executar:**
```bash
cd /caminho/para/pasta
bash roteiro.sh
```

## ⚙️ Arquivos de Configuração

**JSON:**
- `BUPolicyForEKSAccess.json`
- `provision-parameters-CustomADGroup.json`
- `trust-old.json`
- `trust.json`

**YAML:**
- `aws-auth.yaml`
- `ClusterRole-listns.yaml`
- `ClusterRole.yaml`
- `ClusterRoleBinding-listns.yaml`
- `ClusterRoleBinding.yaml`
- `ClusterRoleBindingDeveloper.yaml`
- `ClusterRoleDeveloper.yaml`
- `clusterroledevs-2.yaml`
- `clusterroleDevs.yaml`
- `pod.yaml`

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
