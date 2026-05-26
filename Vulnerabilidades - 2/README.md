# Vulnerabilidades - 2

## 📌 Visão Geral

**Roteiro:** `roteiro.sh`

## 🚀 Roteiro de Execução

Este script executa automaticamente os seguintes passos:

1. `$crds = kubectl get crds -l chart=istio -o name`
2. `foreach ($crd in $crds) {`
3. `kubectl label $crd "app.kubernetes.io/managed-by=Helm" --overwrite`
4. `kubectl annotate $crd "meta.helm.sh/release-name=istio-base" --overwrite`
5. `kubectl annotate $crd "meta.helm.sh/release-namespace=istio-system" --overwrite`
6. `notepad istiod_values.yaml`
7. `notepad istiobase_values.yaml`
8. `notepad istioingress_values.yaml`
9. `087086536124 - eec-aws-br-nike-ss-sandbox - ok`
10. `109804294614 - eec-aws-us-eits-positivo-dev - ok`
11. `146737708860 - eec-aws-br-ds-dataservices-stage - ok`
12. `187739130313 - eec-aws-br-nike-architecture-sandbox - ok`
13. `300374333803 - eec-aws-us-eits-negativo-dev - ok`
14. `306716481758 - eec-aws-br-nike-ssrm-dev - ok`
15. `415071355886 - eec-aws-br-eits-datahub-prod - pendente (1.23)`
16. `530914589075 - eec-aws-br-ds-dataservices-dev - ok`
17. `564593125549 - eec-aws-br-nike-corporate-prod - pendente (1.17 e 1.23)`
18. `662860092544 - eec-aws-br-ds-dataservices-prod - pendente (1.23)`
19. `730335661246 - eec-aws-br-eits-datahub-dev - ok`
20. `877001948254 - eec-aws-br-nike-sales-prod - sales-eks-01-prod - pendente (1.18 e`
21. `877001948254 - eec-aws-br-nike-sales-prod - sales-eks-01-uat - ok`

**Total: 21 passos**

**Como executar:**
```bash
bash roteiro.sh
```

## 📋 Pré-requisitos

**AWS:**
- AWS CLI v2
- Credenciais configuradas
- Permissões apropriadas

## 💡 Exemplos

**Executar roteiro completo:**
```bash
bash roteiro.sh
```

## 🐛 Troubleshooting

| Erro | Solução |
|------|----------|
| Erro de autenticação | `saml2aws login -a <account>` |
| ModuleNotFoundError | `pip install boto3` |
| Acesso negado | Verificar permissões IAM |

## ⚠️ Importante

- ✅ Testar em DEV antes de PROD
- ✅ Revisar scripts antes de executar
- ✅ Fazer backup de dados sensíveis
- ❌ Nunca commitar credenciais AWS

---
*Última atualização: 2026-05-26*
