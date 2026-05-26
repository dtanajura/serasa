# usuario BUUserForPositivoMercantil

## 📌 Descrição

Pasta: `usuario BUUserForPositivoMercantil`

**Roteiro de execução disponível**

## 🚀 Como Executar (roteiro.sh)

Este script executa os seguintes passos:

1. `aws servicecatalog describe-product --name "EEC IAM User" --output text --profile datahubstage --query "ProductViewSummary.[ProductId,Name]"`
2. `aws servicecatalog describe-product --name "EEC IAM User" --output text --profile datahubstage --query "ProvisioningArtifacts[].Id"`
3. `aws servicecatalog describe-product --name "EEC IAM User" --output text --profile datahubstage --output text --query LaunchPaths[].Id`
4. `aws servicecatalog describe-provisioning-parameters --product-name "EEC IAM User" --provisioning-artifact-id pa-iuvxtr2orh2yk --path-id lpv3-qp3cvfasgkl4y --profile datahubstage`
5. `aws servicecatalog provision-product  --product-name "EEC IAM User"  --provisioning-artifact-id pa-iuvxtr2orh2yk --provisioned-product-name EECIAMUser-datahubstage  --provisioning-parameters file://provision-parameters.json  --profile datahubstage`
6. `aws servicecatalog describe-product --name "EEC IAM User" --output text --profile positivodev --query "ProductViewSummary.[ProductId,Name]"`
7. `aws servicecatalog describe-product --name "EEC IAM User" --output text --profile positivodev --query "ProvisioningArtifacts[].Id"`
8. `aws servicecatalog describe-product --name "EEC IAM User" --output text --profile positivodev --output text --query LaunchPaths[].Id`
9. `aws servicecatalog describe-provisioning-parameters --product-name "EEC IAM User" --provisioning-artifact-id pa-dd46akq5b24au --path-id lpv3-qp3cvfasgkl4y --profile positivodev`
10. `aws servicecatalog provision-product  --product-name "EEC IAM User"  --provisioning-artifact-id pa-w4c7z3lnnkslw --provisioned-product-name EECIAMUser-positivodev-2  --provisioning-parameters file://provision-parameters-positivodev-3.json  --profile positivodev`
11. `aws servicecatalog terminate-provisioned-product  --provisioned-product-name EECIAMUser-positivodev --profile positivodev`
12. `aws iam create-group --group-name BUGroupForDevSecOpsPiaaS  --profile positivodev`
13. `aws servicecatalog provision-product  --product-name "EEC IAM User"  --provisioning-artifact-id pa-dd46akq5b24au --provisioned-product-name EECIAMUser-positivodev-2  --provisioning-parameters file://provision-parameters-positivodev-3.json  --profile positivodev`
14. `$status = "IN_PROGRESS"`
15. `while ($status -eq "IN_PROGRESS") {`

... e mais 82 passos

**Como executar:**
```bash
cd /caminho/para/pasta
bash roteiro.sh
```

## ⚙️ Arquivos de Configuração

**JSON:**
- `provision-parameters.json`

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
