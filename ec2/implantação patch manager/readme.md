# 🩹 Roteiro – Implantação AWS Patch Manager (SSM)

## 🎯 Objetivo

Configurar o AWS Systems Manager Patch Manager para:

* ✅ Atualizar automaticamente sistemas (EC2)
* ✅ Aplicar patches de segurança
* ✅ Criar baseline de patch
* ✅ Agendar execução (janela)
* ✅ Compliance de patch

***

# 🧠 1. Arquitetura

```text
EC2 Instance
   ↓
SSM Agent
   ↓
SSM Patch Manager
   ↓
Patch Baseline
   ↓
Maintenance Window
   ↓
Automação
```

***

# 📋 2. Pré-requisitos

## ✅ Instância EC2 deve ter:

* SSM Agent instalado
* Role IAM associada

***

## ✅ IAM Role mínima

Exemplo:

```json
AmazonSSMManagedInstanceCore
```

***

## ✅ Verificar SSM Agent

```bash
sudo systemctl status amazon-ssm-agent
```

***

## ✅ Registrar na SSM

```bash
aws ssm describe-instance-information
```

***

# ⚙️ 3. Criar Patch Baseline

## ▶️ Criar baseline

```bash
aws ssm create-patch-baseline \
  --name "baseline-linux" \
  --operating-system AMAZON_LINUX_2 \
  --approval-rules '{
    "PatchRules": [{
      "PatchFilterGroup": {
        "PatchFilters": [{
          "Key": "CLASSIFICATION",
          "Values": ["Security"]
        }]
      },
      "ApproveAfterDays": 0
    }]
  }'
```

***

## 📌 Tipos comuns

* SECURITY ✅
* BUGFIX
* CRITICAL

***

# 🔗 4. Associar baseline aos targets

```bash
aws ssm register-patch-baseline-for-patch-group \
  --baseline-id <BASELINE_ID> \
  --patch-group "datahub"
```

***

## 📌 Tag na EC2

```bash
Key=Patch Group, Value=datahub
```

***

# ⏰ 5. Criar Maintenance Window

```bash
aws ssm create-maintenance-window \
  --name "patch-window-datahub" \
  --schedule "cron(0 3 ? * SUN *)" \
  --duration 2 \
  --cutoff 1 \
  --allow-unassociated-targets
```

***

## 📌 Resultado

* Executa domingo 03:00
* Duração: 2 horas

***

# 🎯 6. Registrar targets

```bash
aws ssm register-target-with-maintenance-window \
  --window-id <WINDOW_ID> \
  --targets Key=tag:PatchGroup,Values=datahub \
  --resource-type INSTANCE
```

***

# 🔧 7. Criar task de patch

```bash
aws ssm register-task-with-maintenance-window \
  --window-id <WINDOW_ID> \
  --targets Key=tag:PatchGroup,Values=datahub \
  --task-arn "AWS-RunPatchBaseline" \
  --service-role-arn "arn:aws:iam::<ACCOUNT>:role/service-role/AmazonSSMMaintenanceWindowRole" \
  --task-type RUN_COMMAND \
  --task-parameters '{
    "Operation": ["Install"]
  }'
```

***

## 📌 Tipos de operação

```text
Scan     → verifica patches
Install  → aplica patches
```

***

# 🚀 8. Executar patch manual (teste)

```bash
aws ssm send-command \
  --document-name "AWS-RunPatchBaseline" \
  --targets Key=tag:PatchGroup,Values=datahub \
  --parameters "Operation=Install"
```

***

# 🔎 9. Monitorar execução

## 📌 Ver comandos

```bash
aws ssm list-command-invocations
```

***

## 📌 Logs

```bash
/var/log/amazon/ssm/
```

***

## 📌 CloudWatch

```bash
/aws/ssm/*
```

***

# ✅ 10. Verificar compliance

```bash
aws ssm describe-instance-patch-states
```

***

## 📊 Resultado

* ✅ Compliant
* ❌ Non-compliant

***

# 📊 11. Dashboard (Console)

Ir em:

```text
Systems Manager → Patch Manager → Compliance
```

***

# ⚠️ 12. Pontos críticos

## 🔐 Segurança

* Sempre testar em DEV primeiro
* Não aplicar em PROD sem validação

***

## 🧪 Aplicações críticas

* RDS / Kafka / apps sensíveis
* Validar restart

***

## 🔁 Reboot

Alguns patches exigem:

```bash
reboot
```

***

# 🚀 13. Boas práticas

* ✅ Separar ambientes:
  * dev / hml / prod
* ✅ Usar tags:

```text
PatchGroup=datahub
```

* ✅ Criar diferentes baselines
* ✅ Monitorar compliance

***

# 🔥 14. Script completo

```bash
#!/bin/bash

echo "Criando baseline..."

aws ssm create-patch-baseline \
  --name "baseline-datahub" \
  --operating-system AMAZON_LINUX_2

echo "Criando maintenance window..."

aws ssm create-maintenance-window \
  --name "patch-window" \
  --schedule "cron(0 3 ? * SUN *)"

echo "Executando patch..."

aws ssm send-command \
  --document-name "AWS-RunPatchBaseline" \
  --parameters "Operation=Install"

echo "Concluído ✅"
```

***

# ✅ 15. Checklist final

* ✅ SSM Agent ativo
* ✅ IAM Role configurada
* ✅ Patch baseline criado
* ✅ Maintenance window criado
* ✅ Targets registrados
* ✅ Task configurada
* ✅ Logs funcionando
* ✅ Compliance OK

***

# 🧠 Próximo nível (posso montar pra você)

* 🔹 Patch Manager multi-account
* 🔹 integração com AWS Organizations
* 🔹 automação via Lambda
* 🔹 dashboards de compliance
* 🔹 patch + Ansible / SSM hybrid

***

✅ Resumo direto:

Você cria um pipeline:

* Tag → Baseline → Window → Task → Compliance

👉 Isso vira um **Patch Management framework corporativo**.

