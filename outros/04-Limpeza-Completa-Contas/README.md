# Remover tudo

## 📌 Descrição

Pasta: `Remover tudo`

**Roteiro de execução disponível**

## 🚀 Como Executar (roteiro.sh)

Este script executa os seguintes passos:

1. `$clusterName = "datahub-dev"`
2. `$profileAws = "datahubdev"`
3. `$region = "us-east-1"`
4. `$clusterDetails = aws eks describe-cluster --name $clusterName --region $region --profile $profileAws | ConvertFrom-Json`
5. `$securityGroup = $clusterDetails.cluster.resourcesVpcConfig.securityGroupIds[0]`
6. `$roleArn = $clusterDetails.cluster.roleArn`
7. `$roleName = $roleArn.Split('/')[-1]`
8. `$loadbalancers = aws elbv2 --region $region --profile $profileAws describe-load-balancers | ConvertFrom-Json`
9. `foreach ($loadbalancer in $loadbalancers.LoadBalancers.LoadBalancerArn) {`
10. `Write-Host "Removendo Load Balancer: $loadbalancer"`
11. `aws elbv2 --region $region --profile $profileAws delete-load-balancer --load-balancer-arn $loadbalancer`
12. `}`
13. `$loadbalancers = aws elb --region $region --profile $profileAws describe-load-balancers | ConvertFrom-Json`
14. `foreach ($loadbalancer in $loadbalancers.LoadBalancers.LoadBalancerArn) {`
15. `Write-Host "Removendo Load Balancer: $loadbalancer"`

... e mais 116 passos

**Como executar:**
```bash
cd /caminho/para/pasta
bash roteiro.sh
```

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
