# 🛡️ Roteiro – Criação do Bastion `datahub-stage`

## 🎯 Objetivo

Provisionar uma instância EC2 como **bastion host** para acesso seguro ao ambiente DataHub Stage:

* Acesso via Session Manager (sem SSH público)
* Instância privada (sem IP público)
* Controlada via IAM + Security Group
* Integrada à VPC do DataHub

***

# 📋 1. Parâmetros base (referência do ambiente)

Baseado na sua instância atual:

* Tipo: **t3.small**
* AMI: `ami-03f025ac89b9251f3`
* VPC: `vpc-0e87239604bd7ce1d`
* Subnet: `subnet-09457eb844099e03a`
* SG: `sg-0081b7edb68f16fe5`
* Role: `BURoleForEC2`

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/inst_tunel_datahubdev.json)

***

# 🏗️ 2. Criação da instância (AWS CLI)

```bash
aws ec2 run-instances \
  --image-id ami-03f025ac89b9251f3 \
  --instance-type t3.small \
  --subnet-id subnet-09457eb844099e03a \
  --security-group-ids sg-0081b7edb68f16fe5 \
  --iam-instance-profile Name=BURoleForEC2 \
  --tag-specifications 'ResourceType=instance,Tags=[
    {Key=Name,Value=bastion-datahub-stage},
    {Key=Environment,Value=stage},
    {Key=Project,Value=datahub},
    {Key=Squad,Value=datahub},
    {Key=BU,Value=EITS}
  ]' \
  --profile datahub-stage \
  --region sa-east-1
```

***

# 🔐 3. Regras de segurança (Security Group)

## ✅ Entrada (Inbound)

* ✅ Permitir somente:
  * SSM (não precisa abrir porta)
  * Opcional: VPN corporativa

❌ Não permitir:

* SSH público (`0.0.0.0/0`)

***

## ✅ Saída (Outbound)

* ✅ Liberar:
  * VPC interna (10.x.x.x)
  * Endpoint SSM
  * Serviços necessários (DB, Kafka, etc)

***

# 🌐 4. Requisitos de conectividade

## ✅ VPC deve possuir:

* VPC Endpoints:
  * `ssm`
  * `ssmmessages`
  * `ec2messages`

***

## ✅ Subnet privada

* Sem IP público
* Rota via NAT Gateway ou endpoints

***

# 🔑 5. Acesso ao bastion

## ✅ Via Session Manager

```bash
aws ssm start-session \
  --target <INSTANCE_ID> \
  --profile datahub-stage
```

***

## ✅ Tunnel (uso típico DataHub)

```bash
aws ssm start-session \
  --target <INSTANCE_ID> \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["5432"],"localPortNumber":["5432"]}'
```

👉 Exemplo:

* acessar RDS
* acessar serviços internos

***

# ⚙️ 6. Configurações adicionais

## ✅ Desabilitar IP público

Já ocorre automaticamente em subnet privada

***

## ✅ Metadata (segurança)

```text
HttpTokens = required
```

✅ Já está aplicado no teu exemplo [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/inst_tunel_datahubdev.json)

***

# 🏷️ 7. Tags obrigatórias (padrão)

```text
BU              = EITS
Project         = datahub
Environment     = stage
Squad           = datahub
Name            = bastion-datahub-stage
Asset_Category  = Development
```

📌 Baseado no padrão já aplicado na instância existente [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/inst_tunel_datahubdev.json)

***

# 🤖 8. Automação (recomendado)

## ✅ Instance Scheduler

```text
Instance-Scheduler = br-saopaulo-office-hours
```

👉 Liga/desliga automaticamente    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/inst_tunel_datahubdev.json)

***

# ✅ 9. Validações pós-criação

## 📌 Status

```bash
aws ec2 describe-instances \
  --instance-ids <INSTANCE_ID>
```

***

## 📌 Teste SSM

```bash
aws ssm start-session --target <INSTANCE_ID>
```

***

## 📌 Conectividade interna

* Testar acesso:
  * RDS
  * Kafka
  * APIs internas

***

# ⚠️ Pontos de atenção

* Bastion NÃO deve:
  * Ter IP público
  * Expor portas externas
* Sempre usar:
  * SSM
* Validar Security Group

***

# 🚀 Boas práticas

* ✅ Bastion por ambiente (dev / stage / prod)
* ✅ Usar SSM ao invés de SSH
* ✅ Automatizar start/stop
* ✅ Monitorar logs (CloudWatch)
* ✅ Limitar acesso via IAM

***

# 🔥 Script final (completo)

```bash
#!/bin/bash

echo "Criando bastion datahub-stage..."

aws ec2 run-instances \
  --image-id ami-03f025ac89b9251f3 \
  --instance-type t3.small \
  --subnet-id subnet-09457eb844099e03a \
  --security-group-ids sg-0081b7edb68f16fe5 \
  --iam-instance-profile Name=BURoleForEC2 \
  --tag-specifications 'ResourceType=instance,Tags=[
    {Key=Name,Value=bastion-datahub-stage},
    {Key=Environment,Value=stage},
    {Key=Project,Value=datahub},
    {Key=Squad,Value=datahub},
    {Key=BU,Value=EITS}
  ]'

echo "Aguardando instância subir..."

sleep 10

echo "Validando..."

aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=bastion-datahub-stage"

echo "Concluído ✅"
```
