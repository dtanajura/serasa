# 🧪 Roteiro – Criação de Ambiente LAB (AWS Sandbox / DevHub)

## 🎯 Objetivo

Provisionar um ambiente de laboratório isolado para desenvolvedores, com:

* VPC segregada por ambiente
* Acesso controlado via DevHub Portal
* Automação de lifecycle (Lambda)
* Integração com rede corporativa (Transit Gateway)
* Segurança e governança padrão

***

# 🏗️ 1. Fluxo de Provisionamento

## 📌 Processo geral

1. Desenvolvedor solicita ambiente via DevHub
2. Aprovação do pedido
3. Definição de:
   * Instâncias
   * Serviços liberados
   * Região
4. Criação de Role com acesso aos recursos
5. Provisionamento na conta Sandbox

📊 Representado no diagrama:

* DevHub → Aprovação → Role → Conta Sandbox → VPCs isoladas

***

# 🌐 2. Arquitetura de Rede

## 🧩 Componentes

* Múltiplas VPCs (isolamento por lab)
* Subnets privadas
* Transit Gateway (comunicação interna)
* NAT Gateway (saída controlada)
* Internet Gateway (somente quando necessário)

***

## 🔀 Conectividade

* VPCs conectadas via **Transit Gateway**
* Rotas propagadas automaticamente entre VPCs
* Saída internet via NAT

📌 Exemplo de rotas:

| Destino    | Target             |
| ---------- | ------------------ |
| CIDR VPC A | local              |
| 0.0.0.0/0  | transit-gateway-id |

***

# 🔐 3. Restrições de Rede (OBRIGATÓRIO)

* ❌ Sem exposição direta para internet
* ✅ Permitir tráfego interno (rede 10.x.x.x)
* ❌ Bloquear saída direta para rede interna (sem NAT)
* ✅ Usar NAT Gateway quando necessário
* ✅ Comunicação entre VPCs isolada e controlada

👉 Isso garante que um lab não impacte outro

***

# ⚙️ 4. Pré-requisitos de Infra

## 📦 AWS CLI + Auth

* Instalar AWS CLI
* Configurar via OKTA (SSO) [\[Roteiro \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7B54CF1862-97C7-400E-AED6-BAF14784AD6B%7D&file=Roteiro.docx&action=default&mobileredirect=true)

***

## 🌐 Validar VPC e CIDR

```bash
aws ec2 describe-vpcs \
  --profile lab01 \
  --query "Vpcs[].CidrBlockAssociationSet[*]"
```

***

## 🔎 Validar Subnets

```bash
aws ec2 describe-subnets \
  --profile lab01 \
  --query "Subnets[].[
    SubnetId,
    CidrBlock,
    Tags[?Key=='Network'].Value[]
  ]"
```

👉 Esperado:

* Private subnets
* Pod CIDR (ex: 100.64.0.0/16) [\[Roteiro \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7B54CF1862-97C7-400E-AED6-BAF14784AD6B%7D&file=Roteiro.docx&action=default&mobileredirect=true)

***

# 🔥 5. Firewall e Egress

## 📌 Regra obrigatória

Permitir saída para repositório Nexus:

| Origem   | Destino  | Porta |
| -------- | -------- | ----- |
| VPC CIDR | 10.x.x.x | 443   |

📌 Tráfego deve passar por **CSS Egress** [\[Roteiro \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7B54CF1862-97C7-400E-AED6-BAF14784AD6B%7D&file=Roteiro.docx&action=default&mobileredirect=true)

***

# 🔗 6. VPC Endpoints (CRÍTICO)

Criar endpoints para evitar internet pública:

* ECR API
* ECR DKR
* EC2
* CloudWatch Logs

 [\[Roteiro \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7B54CF1862-97C7-400E-AED6-BAF14784AD6B%7D&file=Roteiro.docx&action=default&mobileredirect=true)

***

## 🛠️ Exemplo

```bash
aws ec2 create-vpc-endpoint \
  --vpc-id <VPC_ID> \
  --service-name com.amazonaws.sa-east-1.ecr.api \
  --vpc-endpoint-type Interface \
  --subnet-ids <SUBNETS> \
  --security-group-ids <SG>
```

***

## 🔐 Security Group

Permitir:

```bash
10.0.0.0/8  → TCP 443  
100.64.0.0/16 → TCP 443
```

***

# 🔑 7. IAM e Onboarding

## 📌 Criar policy base

```bash
aws iam create-policy \
  --policy-name BUPolicyForDevSecOpsPiaaS \
  --policy-document file://policy.json
```

 [\[Roteiro \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7B54CF1862-97C7-400E-AED6-BAF14784AD6B%7D&file=Roteiro.docx&action=default&mobileredirect=true)

***

## 📦 Criar bucket de estado

```bash
aws s3api create-bucket \
  --bucket tfstate-devhub-sandbox \
  --region sa-east-1
```

***

## 🔐 Criar KMS

```bash
aws kms create-key \
  --description "Chave para onboarding"
```

***

# 🌎 8. DNS e Certificados

## 📌 Criar domínio interno

Formato:

```
<env>-<bu>.br.experian.eeca
```

Exemplo:

```
sandbox-lab.br.experian.eeca
```

 [\[Roteiro \| Word\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/_layouts/15/Doc.aspx?sourcedoc=%7B54CF1862-97C7-400E-AED6-BAF14784AD6B%7D&file=Roteiro.docx&action=default&mobileredirect=true)

***

## 🔐 Gerar CSR

```bash
openssl req -newkey rsa:2048 \
  -nodes \
  -keyout sandbox-lab.key \
  -out sandbox-lab.csr
```

***

## 📥 Importar no ACM

* Receber certificado do time middleware
* Importar via ACM

***

# 🤖 9. Automação do Ambiente (Lambda)

## 📌 Rotinas padrão

### ✅ Instance Scheduler

* Liga/desliga ambiente automaticamente

### ✅ Environment Sweeper

* Limpeza semanal (domingo 23:59)

👉 Evita custos desnecessários

***

# 🧪 10. Provisionamento de Labs

## 📌 Estrutura final

Cada LAB contém:

* 1 VPC isolada
* Subnets privadas
* Acesso via role
* Recursos definidos (EC2, EKS, etc)
* Integração com TGW

***

# ✅ 11. Validação Final

Checklist:

* ✅ VPC criada
* ✅ Subnets corretas
* ✅ Endpoints ativos
* ✅ SG liberado
* ✅ IAM aplicado
* ✅ DNS configurado
* ✅ Certificado importado
* ✅ Lambda de limpeza ativo

***

# 🚀 Boas práticas

* ✅ Isolar cada lab em uma VPC
* ✅ Automatizar cleanup
* ✅ Nunca expor serviços diretamente
* ✅ Versionar infra (Terraform se possível)
* ✅ Monitorar via CloudWatch
