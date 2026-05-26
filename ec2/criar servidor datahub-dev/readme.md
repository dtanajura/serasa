Aqui está um `README.md` completo para esse roteiro, organizado e clarificando o fluxo (criação de bastion + IAM + DNS + S3):

***

# 🚀 Roteiro de Provisionamento de Bastion + IAM + DNS (Route53) + S3

Este repositório contém um roteiro para provisionamento completo de infraestrutura na AWS, incluindo:

* Criação de instância EC2 (bastion)
* Configuração de IAM Role e policies
* Associação de VPC com Hosted Zone (Route53)
* Criação de bucket S3
* Operações auxiliares de rede e DNS

***

## 🎯 Objetivo

Provisionar uma instância bastion robusta e preparada para:

* Execução de workloads com alto consumo de memória
* Integração com serviços AWS (via IAM Role)
* Resolução de DNS privada via Route53
* Acesso a dados em S3

***

## 📋 Especificações da Infraestrutura

### 🖥️ Instância EC2

* **Tipo**: `c8g.8xlarge`
* **CPU**: 8 vCPUs (ARM64)
* **Memória**: 32 GB
* **Disco**: 250 GB (EBS com throughput otimizado)
* **Sistema Operacional**:
  * Amazon Linux 2023 (Hardened)
  * Arquitetura ARM64
* **AMI**:
  ```
  ami-0d35406cc614df7fe
  ```

### ⚙️ Requisitos

* Instância deve:
  * Ter acesso à internet
  * Estar sempre ligada (full time)
  * Ter swap habilitado (caso Linux)

***

# ⚙️ Etapas do Processo

***

## 1. Criar chave SSH

```bash
aws ec2 create-key-pair \
  --key-name bastion-rulextract-ai \
  --query 'KeyMaterial' \
  --output text > bastion-rulextract-ai.pem \
  --profile datahubdev \
  --region sa-east-1
```

***

## 2. Criar IAM Role

### Criar role

```bash
aws iam create-role \
  --role-name BURoleForBastionRuleXtract \
  --assume-role-policy-document file://trust.json
```

***

### Criar policy customizada

```bash
aws iam create-policy \
  --policy-name BUPolicyForBastionRuleXtract \
  --policy-document file://policy.json
```

***

### Anexar policies à role

```bash
aws iam attach-role-policy \
  --role-name BURoleForBastionRuleXtract \
  --policy-arn <POLICY_ARN>
```

Adicionar também:

```bash
arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
```

✅ Permite acesso via Session Manager

***

## 3. Criar Instance Profile

```bash
aws iam create-instance-profile \
  --instance-profile-name BURoleForBastionRuleXtract
```

Associar a role:

```bash
aws iam add-role-to-instance-profile \
  --instance-profile-name BURoleForBastionRuleXtract \
  --role-name BURoleForBastionRuleXtract
```

***

## 4. Subir instância EC2

```bash
aws ec2 run-instances \
  --image-id ami-0d35406cc614df7fe \
  --instance-type c8g.8xlarge \
  --iam-instance-profile Name="BURoleForBastionRuleXtract" \
  --security-group-ids <SG_ID> \
  --subnet-id <SUBNET_ID> \
  --block-device-mappings file://block_device_mappings.json \
  --tag-specifications 'ResourceType=instance,Tags=[...]'
```

***

## 🔐 5. Atualizar policy (caso necessário)

```bash
aws iam create-policy-version \
  --policy-arn <POLICY_ARN> \
  --policy-document file://policy.json \
  --set-as-default
```

***

# 🌐 6. Configuração de DNS (Route53)

## Listar hosted zones

```bash
aws route53 list-hosted-zones --profile lab01
```

***

## Identificar VPC

```bash
aws ec2 describe-vpcs --profile datahubdev
```

***

## Autorizar associação de VPC (conta de origem)

```bash
aws route53 create-vpc-association-authorization \
  --hosted-zone-id <HOSTED_ZONE_ID> \
  --vpc VPCRegion=sa-east-1,VPCId=<VPC_ID>
```

***

## Associar VPC à hosted zone (conta destino)

```bash
aws route53 associate-vpc-with-hosted-zone \
  --hosted-zone-id <HOSTED_ZONE_ID> \
  --vpc VPCRegion=sa-east-1,VPCId=<VPC_ID>
```

✅ Permite resolução de DNS privado entre contas

***

# 🪣 7. Criar bucket S3

```bash
aws s3 mb s3://rulextract-ai \
  --profile datahubdev \
  --region sa-east-1
```

***

# 🧹 8. Remoção de recursos (cleanup)

Para encerrar a instância:

```bash
aws ec2 terminate-instances \
  --instance-ids <INSTANCE_ID>
```

***

# ✅ Fluxo Completo (Resumo)

1. Criar key pair
2. Criar IAM Role + policy
3. Criar instance profile
4. Subir instância EC2
5. Configurar DNS entre contas (Route53)
6. Criar bucket S3
7. Validar acesso e funcionamento

***

# ⚠️ Atenção

* ⚠️ AMI é ARM64 → somente compatível com instâncias ARM
* ⚠️ Ajustar Security Group e Subnet corretamente
* ⚠️ Garantir permissões IAM antes da execução
* ⚠️ `--no-verify-ssl` deve ser evitado em produção

***

# 🔧 Boas práticas

* Usar tags claras nos recursos
* Versionar `policy.json` e `trust.json`
* Não expor `.pem` em repositórios
* Automatizar via Terraform ou CloudFormation futuramente
* Monitorar uso da instância (alto custo)

***

# 📈 Melhorias futuras

* Script automatizado end-to-end
* Criação via Terraform
* Setup automático de swap
* Hardening adicional da instância
* Configuração de CloudWatch/logs

***

## 🧑‍💻 Uso recomendado

Esse roteiro é ideal para:

* ✅ Bastion avançado para workloads de dados/AI
* ✅ Integração entre contas AWS
* ✅ Resolução de DNS privado cross-account
* ✅ Operações de plataforma / SRE

***
