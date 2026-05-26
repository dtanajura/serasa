
# 🧾 Roteiro – CMS (Cloud Maturity Score) / Compliance AWS

## 🎯 Objetivo

Executar ações de compliance e governança em contas AWS, cobrindo:

* ✅ Tagging obrigatório (Data Governance / EEC)
* ✅ FinOps (otimização de custo)
* ✅ Certificados (EEC Certificate)
* ✅ Padrões corporativos (AD Domain, tagging AWS)
* ✅ Correções manuais via CLI

***

# 🏗️ 1. Escopo das contas

O CMS foi aplicado nas seguintes contas:

* devhub-sandbox
* devhub-dev
* devhub-prod
* devhub-test
* architecture-sandbox
* lab01 / lab02 / lab03 / lab04
* nike-architecture-sandbox

 [\[CMS \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7BA9912307-940E-44FD-95C2-84A48E8CA38D%7D&file=CMS.docx&action=default&mobileredirect=true)

***

# 🏷️ 2. Data Governance – Tags obrigatórias

## 📌 Ação principal: S3 Tagging

```bash
aws s3api put-bucket-tagging \
  --bucket <BUCKET_NAME> \
  --tagging file://tagging.json \
  --profile <PROFILE>
```

👉 Usado em múltiplos buckets (Sagemaker, EKS logs, tfstate, etc.) [\[CMS \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7BA9912307-940E-44FD-95C2-84A48E8CA38D%7D&file=CMS.docx&action=default&mobileredirect=true)

***

## 📌 Validar buckets

```bash
aws s3api list-buckets \
  --profile <PROFILE> \
  --query "Buckets[].Name"
```

***

## 📊 Resultado

✅ Buckets ajustados para compliance    [\[CMS \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7BA9912307-940E-44FD-95C2-84A48E8CA38D%7D&file=CMS.docx&action=default&mobileredirect=true)

***

# 💰 3. FinOps (Otimização de custos)

## 🟠 RDS → Migrar para Graviton

```bash
aws rds modify-db-instance \
  --db-instance-identifier <DB_NAME> \
  --db-instance-class db.m6g.large \
  --apply-immediately
```

👉 Redução de custo com ARM (Graviton) [\[CMS \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7BA9912307-940E-44FD-95C2-84A48E8CA38D%7D&file=CMS.docx&action=default&mobileredirect=true)

***

## 🔴 EC2 subutilizadas

```bash
aws ec2 stop-instances \
  --instance-ids <INSTANCE_ID>
```

📌 Ação recomendada:

* Validar com time antes
* Criar política de desligamento

***

## 🟡 RDS subutilizado

* Avaliar se:
  * ainda é necessário
  * pode reduzir tamanho
  * pode ser desligado

***

# 🔐 4. EEC Certificate (Compliance)

## 📌 Status

* Não executado (sem visibilidade de pendência no portal)

👉 Isso aparece em várias contas [\[CMS \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7BA9912307-940E-44FD-95C2-84A48E8CA38D%7D&file=CMS.docx&action=default&mobileredirect=true)

***

## ✅ Ação recomendada

* Validar no portal CMS/EEC:
  * certificados expirando
  * falta de TLS enforcement
* Integrar com:
  * ACM
  * certificados internos

***

# 🧠 5. AD Domain tagging

## 📌 Aplicar em EC2

```bash
aws ec2 create-tags \
  --resources <INSTANCE_IDS> \
  --tags Key=adDomain,Value='br.experian.local' Key=adGroup,Value=''
```

👉 Usado em múltiplos ambientes [\[CMS \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7BA9912307-940E-44FD-95C2-84A48E8CA38D%7D&file=CMS.docx&action=default&mobileredirect=true)

***

# 🧪 6. LAB accounts – Ajustes

## 📌 Tagging obrigatório

```bash
aws s3api put-bucket-tagging \
  --bucket tfstate-lab01 \
  --tagging file://tagging.json \
  --profile lab01
```

***

## 📌 Observações

* Alguns recursos não foram alterados por serem parte do LAB
* Uso planejado → não otimizado

 [\[CMS \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7BA9912307-940E-44FD-95C2-84A48E8CA38D%7D&file=CMS.docx&action=default&mobileredirect=true)

***

# 🏗️ 7. Architecture / Sandbox – Tagging massivo

## 📌 Execução em larga escala

Você aplicou tagging em dezenas de buckets:

* observability
* eks logs
* terraform states
* cloudtrail
* kafka / airflow / devhub

👉 Tudo via:

```bash
aws s3api put-bucket-tagging \
  --tagging file://tagging.json \
  --profile devhub-legada-sandbox \
  --bucket <BUCKET>
```

 [\[CMS \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7BA9912307-940E-44FD-95C2-84A48E8CA38D%7D&file=CMS.docx&action=default&mobileredirect=true)

***

# ✅ 8. Resultado geral

* ✅ Data governance aplicada
* ✅ Buckets padronizados
* ✅ FinOps parcialmente ajustado
* ✅ Tags obrigatórias aplicadas
* ⚠️ Certificados pendentes (não visíveis)

***

# ⚠️ 9. Pontos de atenção

* Certificados:
  * não monitorados
  * risco de expiração
* EC2 subutilizado:
  * precisa política automática
* RDS:
  * nem todos avaliados

***

# 🚀 10. Boas práticas recomendadas

## ✅ Governança

* Padronizar `tagging.json`
* Validar automaticamente

***

## ✅ FinOps

* Usar:
  * Instance Scheduler
  * Savings Plans / RI

***

## ✅ Certificados

* Centralizar:
  * ACM
  * Wildcard por ambiente

***

## ✅ Automação

* Lambda:
  * auditoria de tags
  * desligamento EC2
* Script centralizado CMS

***

# 🔥 Script padrão CMS (base)

```bash
#!/bin/bash

PROFILE=$1

echo "=== CMS CHECK $PROFILE ==="

echo "Listando buckets..."
aws s3api list-buckets --profile $PROFILE

echo "Aplicando tags padrão..."
for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text --profile $PROFILE); do
  aws s3api put-bucket-tagging \
    --bucket $bucket \
    --tagging file://tagging.json \
    --profile $PROFILE
done

echo "Verificando instâncias ativas..."
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].InstanceId' \
  --profile $PROFILE

echo "Concluído ✅"
```

***

# 🧠 Evolução (recomendado)

Posso te levar isso para outro nível:

* 🔹 CMS automático multi-account
* 🔹 auditoria contínua (Lambda + EventBridge)
* 🔹 dashboard (compliance score)
* 🔹 integração com Control Tower
* 🔹 auto-remediation (corrige sozinho)

