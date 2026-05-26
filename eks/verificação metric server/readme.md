# 📊 Roteiro – Verificação do Metrics Server (Kubernetes)

## 🎯 Objetivo

Validar se o **Metrics Server** está funcionando corretamente no cluster Kubernetes, garantindo:

* Coleta de métricas de CPU/Memória
* Integração com `kubectl top`
* Suporte para HPA (Horizontal Pod Autoscaler)

***

## 📋 Pré-requisitos

* `kubectl` configurado
* Acesso ao cluster
* Permissão para listar recursos (`pods`, `apiservices`, etc.)

***

## 🔍 1. Verificar se o Metrics Server está instalado

```bash
kubectl get deployment metrics-server -n kube-system
```

✅ Esperado:

```
READY   UP-TO-DATE   AVAILABLE
1/1     1            1
```

***

## 📦 2. Verificar pods do Metrics Server

```bash
kubectl get pods -n kube-system | grep metrics-server
```

✅ Esperado:

```
metrics-server-xxxxx   Running
```

***

## 📉 3. Verificar logs (em caso de problema)

```bash
kubectl logs -n kube-system deploy/metrics-server
```

🔎 Erros comuns:

* TLS handshake error
* x509 certificate error
* connection refused

***

## 🔗 4. Validar APIService

```bash
kubectl get apiservices | grep metrics
```

✅ Esperado:

```
v1beta1.metrics.k8s.io   True
```

❌ Se aparecer:

```
False
```

→ problema no metrics-server

***

## ⚙️ 5. Testar coleta de métricas (kubectl top)

### Nodes

```bash
kubectl top nodes
```

### Pods

```bash
kubectl top pods -A
```

✅ Se funcionar:

* Metrics Server operacional ✅

❌ Se erro:

```
metrics API not available
```

***

## 🔐 6. Verificar permissões (RBAC)

```bash
kubectl get clusterrole | grep metrics-server
```

```bash
kubectl get clusterrolebinding | grep metrics-server
```

***

## 🌐 7. Teste direto na API

```bash
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq
```

✅ Retorno esperado:

* JSON com métricas

***

## ⚠️ Problemas comuns e soluções

### ❌ x509 / TLS error

👉 Corrigir adicionando flag:

```yaml
--kubelet-insecure-tls
```

***

### ❌ Metrics API not available

👉 Verificar:

* APIService
* Pod status
* RBAC

***

### ❌ Timeout ao coletar métricas

👉 Possível problema:

* Comunicação com kubelet
* Security Group / NetworkPolicy

***

## 🔄 8. Reiniciar Metrics Server

```bash
kubectl rollout restart deployment metrics-server -n kube-system
```

***

## ✅ 9. Validar após restart

```bash
kubectl top nodes
```

***

## 🚀 Script automatizado (check rápido)

```bash
#!/bin/bash

echo "Verificando Metrics Server..."

kubectl get deployment metrics-server -n kube-system

echo "Pods:"
kubectl get pods -n kube-system | grep metrics-server

echo "APIService:"
kubectl get apiservices | grep metrics

echo "Teste kubectl top:"
kubectl top nodes 2>/dev/null || echo "Erro ao coletar métricas"

echo "Logs recentes:"
kubectl logs -n kube-system deploy/metrics-server --tail=20

echo "Check concluído ✅"
```

***

## 🧠 Boas práticas

* ✅ Monitorar disponibilidade do metrics-server
* ✅ Evitar usar `--kubelet-insecure-tls` em produção (se possível)
* ✅ Garantir comunicação com kubelet (porta 10250)
* ✅ Integrar com HPA (horizontal autoscaling)

