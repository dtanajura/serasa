# permissões para deployments

## 📌 Descrição

Pasta: `permissões para deployments`

**Roteiro de execução disponível**

## 🚀 Como Executar (roteiro.sh)

Este script executa os seguintes passos:

1. `cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\permissões para deployments"`
2. `saml2aws.exe login -a eec-aws-br-nike-ss-sandbox`
3. `$profile_aws = "nike-ss-sandbox"`
4. `$cluster_name=aws eks list-clusters --profile $profile_aws --output text --query "clusters"`
5. `aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text --profile $profile_aws`
6. `aws iam create-role --role-name BURoleForAppsEKS --assume-role-policy-document file://trust.json --profile $profile_aws`
7. `aws iam attach-role-policy --role-name BURoleForAppsEKS --policy-arn arn:aws:iam::087086536124:policy/BUPolicyForAppsNike --profile $profile_aws`
8. `aws eks update-kubeconfig --region sa-east-1 --name $cluster_name --profile $profile_aws`
9. `kubectl create -f service-account-chronos-dev.yaml`
10. `kubectl create -f service-account-ssbl-dev.yaml`
11. `kubectl create -f service-account-ssbl-qa.yaml`
12. `kubectl get deploy -n chronos-dev`
13. `kubectl delete -f service-account-chronos-dev.yaml`
14. `kubectl delete -f service-account-ssbl-dev.yaml`
15. `kubectl delete -f service-account-ssbl-qa.yaml`

**Como executar:**
```bash
cd /caminho/para/pasta
bash roteiro.sh
```

## ⚙️ Arquivos de Configuração

**JSON:**
- `trust.json`

**YAML:**
- `service-account-chronos-dev.yaml`
- `service-account-ssbl-dev.yaml`
- `service-account-ssbl-qa.yaml`

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
