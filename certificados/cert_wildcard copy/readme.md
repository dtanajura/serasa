# 🔐 Roteiro – Criação de Certificado Wildcard (AWS ACM + CSR)

## 🎯 Objetivo

Gerar, solicitar e configurar um **certificado wildcard interno** para uso em serviços AWS:

* Domínio privado (Route53)
* Certificado wildcard (`*.domínio`)
* Integração com AWS ACM
* Uso em ALB / NLB / Ingress / MWAA / EKS

***

# 📋 1. Pré-requisitos

* Domínio privado configurado (Route53)
* Acesso ao ServiceNow / Middleware (se aplicável)
* OpenSSL instalado
* Conta AWS com permissões:
  * `acm:ImportCertificate`
  * `route53:*`

***

# 🌐 2. Definir padrão de domínio

## 📌 Formato padrão

```text
<env>-<bu>.br.experian.eeca
```

## 📌 Exemplo

```text
datahub-stage.br.experian.eeca
```

***

## 🔁 Wildcard gerado

```text
*.datahub-stage.br.experian.eeca
```

***

# 🌍 3. Criar Hosted Zone (Route53)

## ✅ Solicitação interna (padrão corp)

* Abrir request para o time Cloud:
  * criação de Private Hosted Zone

***

## ✅ Via CLI (se permitido)

```bash
aws route53 create-hosted-zone \
  --name datahub-stage.br.experian.eeca \
  --vpc VPCRegion=sa-east-1,VPCId=<VPC_ID> \
  --hosted-zone-config Comment="Private Zone DataHub Stage",PrivateZone=true
```

***

# 🔑 4. Gerar chave e CSR (OpenSSL)

## ▶️ Comando

```bash
openssl req -newkey rsa:2048 \
  -nodes \
  -keyout datahub-stage.key \
  -out datahub-stage.csr
```

***

## 📌 Preenchimento

```text
Country Name: BR
State: Sao Paulo
City: Sao Paulo
Organization: Serasa Experian
Organizational Unit: DevHub
Common Name: *.datahub-stage.br.experian.eeca
Email: seu-email@empresa.com
```

***

## 📦 Resultado

Arquivos gerados:

* `datahub-stage.key` ✅ (chave privada)
* `datahub-stage.csr` ✅ (requisição de certificado)

***

# 📤 5. Solicitar certificado

## 📌 Enviar para Middleware / Segurança

Informar:

```text
Domínio: datahub-stage.br.experian.eeca
Wildcard: *.datahub-stage.br.experian.eeca
```

Upload do:

* `.csr`

***

## 📥 Retorno esperado

Você recebe:

* Certificado (CRT)
* Cadeia (chain certificate)

***

# 📦 6. Importar no AWS ACM

## ▶️ Comando

```bash
aws acm import-certificate \
  --certificate fileb://certificate.crt \
  --private-key fileb://datahub-stage.key \
  --certificate-chain fileb://chain.crt \
  --region sa-east-1
```

***

## ✅ Resultado

* ARN do certificado

```text
arn:aws:acm:sa-east-1:ACCOUNT:certificate/xxxxxxxx
```

***

# 🔗 7. Usar certificado

## 🌐 Em ALB / NLB

```bash
aws elbv2 modify-listener \
  --listener-arn <LISTENER_ARN> \
  --certificates CertificateArn=<CERT_ARN>
```

***

## ☸️ Em Kubernetes (Ingress)

```yaml
annotations:
  alb.ingress.kubernetes.io/certificate-arn: <CERT_ARN>
```

***

## 🌪️ Em Istio (Gateway)

```yaml
tls:
  credentialName: wildcard-cert
```

***

# 🔎 8. Validação

## ✅ Verificar ACM

```bash
aws acm list-certificates
```

***

## ✅ Teste DNS

```bash
nslookup app.datahub-stage.br.experian.eeca
```

***

## ✅ Teste HTTPS

```bash
curl -v https://app.datahub-stage.br.experian.eeca
```

***

# ⚠️ Pontos de atenção

* Certificado é regional (ACM)
* Renovação NÃO é automática (importado manualmente)
* Guardar a `private key`
* Wildcard cobre apenas:

```text
*.dominio → não cobre sub.sub.dominio
```

***

# 🔁 9. Renovação

## Passos:

1. Gerar novo CSR
2. Solicitar novo certificado
3. Reimportar no ACM
4. Atualizar serviços

***

# 🤖 10. Automação (recomendado)

## ✅ Checklist automatizável

* Expiração (CloudWatch / script)
* Alertas 30 dias antes
* Pipeline de renovação

***

# ✅ Checklist final

* ✅ Hosted zone criada
* ✅ CSR gerado
* ✅ Certificado solicitado
* ✅ Importado no ACM
* ✅ Aplicado nos serviços
* ✅ Validado HTTPS

***

# 🚀 Boas práticas

* ✅ Usar wildcard por ambiente
* ✅ Nome padrão por BU
* ✅ Centralizar certificados
* ✅ Versionar CSR
* ✅ Monitorar validade

***

# 🔥 Script rápido (execução básica)

```bash
#!/bin/bash

DOMAIN="datahub-stage.br.experian.eeca"

echo "Gerando CSR..."

openssl req -newkey rsa:2048 \
  -nodes \
  -keyout ${DOMAIN}.key \
  -out ${DOMAIN}.csr

echo "Arquivos gerados:"
ls -lh ${DOMAIN}.*
```
