# check_acm_cert_chain.py

Script em Python para **auditar a cadeia real de certificados TLS (CA raiz / issuer)** utilizados por domínios associados a certificados do **AWS ACM**, cruzando informações de **Route53**, **TLS/OpenSSL** e **ACM**.

O objetivo principal é identificar **qual CA raiz está efetivamente sendo apresentada em produção**, independentemente do que está configurado ou esperado no ACM.

---

## Objetivo

- Auditar certificados TLS ativos em domínios públicos
- Identificar **issuer** e **cadeia de certificação real**
- Validar certificados ACM utilizados em endpoints HTTPS
- Auxiliar migrações de CA, troubleshooting e auditorias de segurança

---

## Funcionamento Geral

O script realiza, de forma resumida:

1. Conexão com a AWS usando profile configurado
2. Identificação de hosted zones no Route53
3. Coleta de hostnames associados aos domínios
4. Conexão TLS real via `openssl s_client`
5. Extração dos certificados apresentados
6. Parsing da cadeia usando `cryptography`
7. Exibição do **Subject** e **Issuer** de cada certificado

Isso permite identificar:
- CA raiz efetiva
- Intermediárias utilizadas
- Diferenças entre configuração lógica (ACM) e prática (TLS)

---

## Pré-requisitos

Antes de executar o script, certifique-se de que possui:

- Python 3.8+
- AWS CLI configurada
- Profile AWS válido
- OpenSSL instalado no sistema
- Bibliotecas Python:
  - `boto3`
  - `cryptography`

Instalação das dependências:
```bash
pip install boto3 cryptography
