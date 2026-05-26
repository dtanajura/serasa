# Monitoramento eec-aws-br-nike-ss-sandbox

## 📌 Descrição

Pasta: `Monitoramento eec-aws-br-nike-ss-sandbox`

**Roteiro de execução disponível**

## 🚀 Como Executar (roteiro.sh)

Este script executa os seguintes passos:

1. `saml2aws.exe login -a eec-aws-br-nike-ss-sandbox`
2. `saml2aws.exe console -a eec-aws-br-nike-ss-sandbox`
3. `$profile_aws = "ssrmsandbox"`
4. `aws emr list-clusters --profile $profile_aws --active --query "Clusters[].Name"`
5. `$eks_cluster_name=aws eks list-clusters --profile $profile_aws --output text --query "clusters"`
6. `aws eks update-kubeconfig --region sa-east-1 --name $eks_cluster_name --profile $profile_aws`
7. `k get pods -n monitoring-system`
8. `aws route53 list-hosted-zones --profile $profile_aws`
9. `$hosted_zone_id=aws route53 list-hosted-zones --profile $profile_aws --query "HostedZones[].Id" --output text`
10. `aws route53 list-resource-record-sets --hosted-zone-id $hosted_zone_id --profile $profile_aws --query  "ResourceRecordSets[].Name" | Select-String -Pattern "grafana"`
11. `k get pods -n monitoring-system`
12. `k get pods kube-prometheus-stack-grafana-6b7c9bf4b7-xv5x6 -n monitoring-system -o yaml`
13. `k get secrets kube-prometheus-stack-grafana -n monitoring-system -o yaml`

**Como executar:**
```bash
cd /caminho/para/pasta
bash roteiro.sh
```

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
