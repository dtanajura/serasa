# Pinot

## 📌 Descrição

Pasta: `Pinot`

**Roteiro de execução disponível**

## 🚀 Como Executar (roteiro.sh)

Este script executa os seguintes passos:

1. `k config use-context arn:aws:eks:sa-east-1:087086536124:cluster/ssrm-eks-01-sandbox`
2. `k create namespace pinot`
3. `namespace/pinot created`
4. `kubectl annotate namespace pinot meta.helm.sh/release-name=pinot`
5. `kubectl annotate namespace pinot meta.helm.sh/release-namespace=pinot`
6. `kubectl label namespace pinot app.kubernetes.io/managed-by=Helm`
7. `helm install pinot pinot/pinot -n pinot --set cluster.name=pinot-ssrm-sandbox --set server.replicaCount=2`
8. `k config set-context --current --namespace=pinot`

**Como executar:**
```bash
cd /caminho/para/pasta
bash roteiro.sh
```

## ⚙️ Arquivos de Configuração

**YAML:**
- `values.yaml`

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
