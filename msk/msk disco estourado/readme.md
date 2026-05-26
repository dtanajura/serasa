# 📡 Acesso e Preparação de Ambiente AWS MSK (Kafka)

Este roteiro documenta a criação de infraestrutura e configuração de acesso a clusters **AWS MSK (Kafka)** na conta `dsstage`, incluindo:

- Listagem de clusters Kafka
- Obtenção de bootstrap brokers
- Criação de instância EC2 (bastion)
- Configuração de roles IAM
- Associação de permissões para acesso ao MSK

---

## 📌 Visão Geral

O objetivo deste roteiro é preparar um ambiente (bastion host) com permissões adequadas para interagir com clusters MSK.

---

## 🔍 1. Listar clusters MSK

```bash
aws kafka list-clusters   --profile dsstage   --region sa-east-1   --no-verify-ssl   --query "ClusterInfoList[].ClusterName"
```

### 🔎 O que faz

- Lista os clusters MSK disponíveis na conta
- `--query`: filtra apenas os nomes dos clusters
- `--no-verify-ssl`: ignora validação de certificado (não recomendado em produção)

---

## 🔗 2. Obter bootstrap brokers

```bash
aws kafka get-bootstrap-brokers   --cluster-arn <CLUSTER_ARN>   --profile dsstage   --region sa-east-1   --no-verify-ssl
```

### 🔎 O que faz

- Retorna os endpoints para conexão com o Kafka
- Necessário para producers/consumers

---

## 🖥️ 3. Criar instância EC2 (Bastion)

```bash
aws ec2 run-instances   --image-id ami-0130f936a23ed9bd0   --count 1   --instance-type t3.medium   --iam-instance-profile Name=BURoleForSREAutomation   --security-group-ids sg-05d93c159076a5ee2   --subnet-id subnet-08e6a67b3b6d4aa4c   --profile dsstage   --region sa-east-1   --no-verify-ssl
```

---

## 🔑 4. Criar chave SSH

```bash
aws ec2 create-key-pair   --key-name bastion-sre-temp   --query 'KeyMaterial'   --output text > bastion-sre-temp.pem   --profile dsstage   --region sa-east-1
```

---

## 🔐 5. Criar e configurar roles IAM

### Criar role

```bash
aws iam create-role   --role-name BURoleForBastionSRE   --assume-role-policy-document file://trust.json   --profile dsstage   --region sa-east-1
```

### Anexar políticas

```bash
aws iam attach-role-policy   --role-name BURoleForBastionSRE   --policy-arn arn:aws:iam::aws:policy/AmazonMSKReadOnlyAccess

aws iam attach-role-policy   --role-name BURoleForBastionSRE   --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
```

### Criar instance profile

```bash
aws iam create-instance-profile   --instance-profile-name BURoleForBastionSRE
```

### Associar role ao profile

```bash
aws iam add-role-to-instance-profile   --instance-profile-name BURoleForBastionSRE   --role-name BURoleForBastionSRE
```

---

## 🔗 6. Associar role à instância EC2

```bash
aws ec2 associate-iam-instance-profile   --instance-id <INSTANCE_ID>   --iam-instance-profile Name=BURoleForBastionSRE
```

### Validar associação

```bash
aws ec2 describe-iam-instance-profile-associations   --filters Name=instance-id,Values=<INSTANCE_ID>
```

### Remover associação (se necessário)

```bash
aws ec2 disassociate-iam-instance-profile   --association-id <ASSOCIATION_ID>
```

---

## 🧪 Requisitos da Instância

Recomendado:

- 8 vCPU
- 32 GB RAM
- Disco: 250 GB (throughput otimizado)
- Swap habilitado (Linux)
- Acesso à internet
- Instância sempre ativa

Exemplo ideal:

- Tipo: `c8g.8xlarge`
- AMI: `ami-0476785cbf79d83a3`
- Conta destino: `eec-aws-br-eits-datahub-dev (730335661246)`

---

## ⚠️ Observações

- Evitar uso de `--no-verify-ssl` em ambientes produtivos
- Garantir políticas corretas no IAM
- Utilizar SSM Session Manager em vez de SSH quando possível

---

## ✅ Resultado Esperado

- Instância pronta para acesso ao cluster MSK
- Permissões configuradas corretamente
- Capacidade de listar tópicos e consumir/produzir mensagens

