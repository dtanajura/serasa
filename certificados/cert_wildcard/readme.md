Aqui está um `README.md` específico para o seu script `roteiro.sh`, explicando o fluxo completo:

***

# 🔐 Roteiro de Importação de Certificados AWS (ACM)

Este repositório contém um script (`roteiro.sh`) que documenta o passo a passo para:

* Configuração de ambiente no PowerShell
* Autenticação em múltiplas contas AWS via `saml2aws`
* Conexão em instâncias EC2 via Session Manager
* Conversão de certificados `.pfx` para formatos compatíveis
* Importação de certificados no AWS ACM (AWS Certificate Manager)

***

## 🎯 Objetivo

Padronizar e automatizar o processo de:

* Preparação de certificados SSL/TLS
* Conversão entre formatos (`.pfx`, `.pem`, `.crt`)
* Distribuição dos certificados em diferentes contas e ambientes AWS

***

## 📋 Pré-requisitos

Antes de executar os passos, você precisa ter instalado:

* AWS CLI configurado
* `saml2aws`
* OpenSSL
* Acesso às contas AWS necessárias
* Permissão para usar:
  * AWS ACM
  * AWS SSM (Session Manager)

***

## ⚙️ Etapas do Processo

### 1. Configuração do Ambiente (PowerShell)

Definição de variáveis necessárias:

```powershell
$env:AWS_CA_BUNDLE="c:\\tmp\\serasa.pem"
$env:PATH += ";C:\\tmp"
```

Customização opcional do prompt para facilitar navegação.

***

### 2. Navegação para Diretório de Certificados

```powershell
Set-Location "C:\\Users\\<usuario>\\...\\cert_wildcard"
```

***

### 3. Login via SAML

Autenticação em contas AWS:

```bash
saml2aws.exe login -a <account-alias>
```

Exemplo:

* `devexperience-sandbox`
* `devexperience-prod`
* `devexperience-dev`
* `devexperience-uat`
* labs (`lab01` até `lab05`)

***

### 4. Acesso a Instância via SSM

```bash
aws ssm start-session --target <instance-id> --profile <profile>
```

Exemplo:

```bash
aws ssm start-session --target i-08dcdf0f9056eb152 --profile devexperience-sandbox
```

***

### 5. Geração de Chave SSH (opcional)

```bash
ssh-keygen -t rsa -b 2048
```

***

### 6. Conversão de Certificados

Conversão de `.pfx` para `.pem`:

```bash
openssl pkcs12 -in arquivo.pfx -out arquivo.pem
```

Separando certificado e chave privada:

```bash
# Certificado
openssl pkcs12 -in arquivo.pfx -clcerts -nokeys -out arquivo.crt

# Chave privada
openssl pkcs12 -in arquivo.pfx -nocerts -nodes -out arquivo.pem
```

Esse processo é repetido para múltiplos ambientes:

* `prd-devhub`
* `dev-devhub`
* `qa-devhub`
* `lab01` até `lab05`
* `snd-devhub`

***

### 7. Importação no AWS ACM

Importar certificado:

```bash
aws acm import-certificate \
  --certificate fileb://certificado.crt \
  --private-key fileb://chave.pem \
  --profile <profile>
```

Exemplo:

```bash
aws acm import-certificate \
  --certificate fileb://prd-devhub.br.experian.eeca.crt \
  --private-key fileb://prd-devhub.br.experian.eeca.pem \
  --profile devexperience-prod
```

***

### 8. Validação do Certificado

```bash
aws acm describe-certificate \
  --certificate-arn <arn> \
  --profile <profile>
```

***

## 🌍 Ambientes Atendidos

O script cobre múltiplos ambientes:

* 🧪 Sandbox
* 🛠️ Dev
* 🧫 UAT
* 🚀 Prod
* 🧪 Labs (lab01 a lab05)

***

## ⚠️ Observações Importantes

* Os caminhos locais devem ser ajustados conforme o ambiente do usuário
* Os arquivos `.pfx` devem estar disponíveis antes da execução
* As senhas dos certificados serão solicitadas durante o uso do OpenSSL
* Certifique-se de usar o profile correto para cada ambiente
* O script é um roteiro manual — não é totalmente automatizado

***

## 🔧 Possíveis melhorias

* Transformar em script automatizado (bash ou python)
* Validar existência de arquivos antes das operações
* Criar logs de execução
* Parametrizar entradas (nome do certificado, perfil, etc.)
* Integração com pipeline CI/CD

***

## 🧑‍💻 Uso recomendado

Utilize este roteiro como:

* ✅ Guia operacional
* ✅ Checklist para deploy de certificados
* ✅ Base para automação futura

***