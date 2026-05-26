# 🚀 Roteiro – Atualização de Helm Charts (EKS / Kubernetes)

## 🎯 Objetivo

Padronizar o processo de atualização de Helm releases garantindo:

* Uso da versão mais recente do chart
* Preservação de configurações (`values.yaml`)
* Compatibilidade com CRDs
* Validação pós-upgrade

***

# 📦 1. Escopo (scripts disponíveis)

Baseado no seu diretório:

* argo-cd
* external-dns
* aws-efs-csi-driver
* aws-vpc-cni
* cluster-autoscaler
* istio (base, ingress, control plane)
* kube-prometheus-stack
* metrics-server

👉 Todos seguem o mesmo padrão de atualização automática

***

# ⚙️ 2. Padrão dos scripts

Seus scripts seguem esse fluxo:

## ✔️ Etapas padrão

1. Adiciona repo Helm
2. Busca última versão disponível
3. Exporta `values.yaml` atual
4. Executa upgrade com valores existentes
5. Valida release

📌 Esse padrão aparece nos três scripts enviados [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/istio-base.sh), [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/atualiza.sh), [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/kube-prometheus-stack.sh)

***

# 🔄 3. Fluxo de atualização (runbook)

## 🔍 3.1 Adicionar repositório

```bash
helm repo add <repo> <url>
# helm repo update (recomendado)
```

👉 Exemplo:

* Istio → `istio-release.storage.googleapis.com`
* Prometheus → `prometheus-community` [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/kube-prometheus-stack.sh)

***

## 🔎 3.2 Obter versão mais recente

```bash
helm search repo <chart>
```

Nos scripts:

* pega a primeira linha (latest)
* extrai `chartVersion` automaticamente [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/atualiza.sh)

***

## 💾 3.3 Backup dos values atuais

```bash
helm get values <release> -n <namespace> > values.yaml
```

👉 Isso garante:

* não perder customizações
* rollback rápido se necessário

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/istio-base.sh)

***

## ⚠️ 3.4 Tratamento especial (CRDs)

### ✅ Apenas quando necessário (ex: Istio)

```bash
kubectl get crds -l app.kubernetes.io/part-of=istio
```

Aplicar labels:

```bash
kubectl label <crd> app.kubernetes.io/managed-by=Helm --overwrite
kubectl annotate <crd> meta.helm.sh/release-name=<release>
```

📌 No teu script Istio isso já está automatizado [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/istio-base.sh)

***

## ⬆️ 3.5 Executar upgrade

```bash
helm upgrade <release> <chart> \
  --version <version> \
  -n <namespace> \
  -f values.yaml
```

👉 Nos scripts:

* usa sempre `values.yaml` exportado
* mantém configuração atual [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/atualiza.sh)

***

# 🔎 4. Validação pós-upgrade

## 📌 Verificar release

```bash
helm list -A | grep <release>
```

***

## 📌 Verificar pods

```bash
kubectl get pods -n <namespace>
```

***

## 📌 Ver logs

```bash
kubectl logs -n <namespace> -l app=<app>
```

***

## 📌 Caso Prometheus

```bash
kubectl get secrets kube-prometheus-stack-grafana -n monitoring-system -o jsonpath="{.data.admin-password}" | base64 -d
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/kube-prometheus-stack.sh)

***

# ⚠️ 5. Pontos de atenção por componente

## 🔵 Istio

* Precisa tratar CRDs antes
* Ordem importante:
  * base → control plane → ingress

***

## 🟠 Prometheus (kube-prometheus-stack)

* Pode impactar observabilidade
* Verificar:
  * alertmanager
  * grafana
  * prometheus targets

***

## 🟢 External DNS / Autoscaler

* Validar integração com AWS
* Ver logs após upgrade

***

## 🟣 CSI / CNI

* Impacto direto em rede/storage
* Atualizar fora de horário crítico

***

# ✅ 6. Checklist padrão

Antes:

* ✅ Backup values.yaml
* ✅ Validar namespace
* ✅ Validar dependências

Durante:

* ✅ Aplicar upgrade
* ✅ Monitorar rollout

Depois:

* ✅ Pods running
* ✅ Logs sem erro
* ✅ Métricas/serviços ativos

***

# 🔥 7. Script genérico padrão (padrão da squad)

Aqui você pode unificar todos:

```bash
#!/bin/bash

RELEASE=$1
NAMESPACE=$2
CHART=$3
REPO=$4
REPO_URL=$5

echo "Atualizando $RELEASE..."

helm repo add $REPO $REPO_URL
helm repo update

VERSION=$(helm search repo $CHART | awk 'NR==2 {print $2}')

echo "Versão detectada: $VERSION"

helm get values $RELEASE -n $NAMESPACE > values.yaml

helm upgrade $RELEASE $CHART \
  --version $VERSION \
  -n $NAMESPACE \
  -f values.yaml

echo "Verificando..."

helm list -A | grep $RELEASE
kubectl get pods -n $NAMESPACE

echo "Concluído ✅"
```

***

# 🚀 Boas práticas

* ✅ Nunca atualizar direto sem backup
* ✅ Sempre validar CRDs (principalmente Istio)
* ✅ Atualizar um componente por vez
* ✅ Monitorar impacto (Prometheus / CNI)
* ✅ Testar primeiro em DEV

