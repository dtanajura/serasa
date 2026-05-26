# Remover cluster eks

## 📌 Descrição

Pasta: `Remover cluster eks`

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
8. `$nodeGroups = aws eks list-nodegroups --cluster-name $clusterName --region $region --profile $profileAws | ConvertFrom-Json`
9. `foreach ($nodeGroup in $nodeGroups.nodegroups) {`
10. `Write-Host "Removendo NodeGroup: $nodeGroup"`
11. `aws eks delete-nodegroup --cluster-name $clusterName --nodegroup-name $nodeGroup --region $region --profile $profileAws`
12. `do {`
13. `Start-Sleep -Seconds 10`
14. `$status = aws eks describe-nodegroup --cluster-name $clusterName --nodegroup-name $nodeGroup --region $region --profile $profileAws | ConvertFrom-Json`
15. `Write-Host $status`

... e mais 90 passos

**Como executar:**
```bash
cd /caminho/para/pasta
bash roteiro.sh
```

## ⚙️ Arquivos de Configuração

**JSON:**
- `corrected-replication-config.json`
- `replication-config-utf8.json`
- `replication-config.json`

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
