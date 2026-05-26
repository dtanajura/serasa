# zabbix

## 📌 Descrição

Pasta: `zabbix`

**Roteiro de execução disponível**

## 🚀 Como Executar (roteiro.sh)

Este script executa os seguintes passos:

1. `kubectl config get-contexts`
2. `k config use-context arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat`
3. `kubectl create namespace zabbix`
4. `helm install zabbix-sre zabbix-community/zabbix --namespace zabbix`
5. `k get gw -n monitoring-system grafana-gateway -o yaml`
6. `k get vs -n monitoring-system grafana-virtual-service -o yaml`
7. `k create -f .\gateway.yaml`
8. `k create -f .\vs.yaml`

**Como executar:**
```bash
cd /caminho/para/pasta
bash roteiro.sh
```

## ⚙️ Arquivos de Configuração

**YAML:**
- `gateway.yaml`
- `vs.yaml`

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
