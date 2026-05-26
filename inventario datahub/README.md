# inventario datahub

## 📌 Visão Geral

**Scripts Python:** `grava_tags copy.py`, `grava_tags.py`, `invent_excel.py`, `inventario.py`, `inventario2.py`

**Roteiro:** `roteiro.txt`

## 📋 Instruções

1. # https://pages.experian.local/spaces/DDSE/pages/1267765967/DATAHUB+2.1.2.4.2+TAG+AWS
2. Tags relevantes:
3. AppID
4. CostString: 1800.BR.123.456789
5. Environment: prd, hml, uat, stg, sbx, dev
6. Asset_Category:
7. Valores aceitos: Productive data, Development or Staging or Sandbox, Model development, Logs, Embbeded, Metadata, Cache, Backup, N/A (Mandatory for S3 Buckets and Databases)
8. Data_Category:
9. Valores aceitos: Registry, Behavioral, Negative, Positive, Financial, N/A
10. Data_Type:
11. Valores aceitos: PP, LP, PP/LP, N/A
12. adDomain: Mandatory for EC2 - br.experian.local
13. BU
14. CreatedBy
15. Layer: Gold, Silver, Bronze

## 🐍 Scripts Python

### `grava_tags copy.py`

**Função:** Script Python

**Funções principais:**
- **aplicar_tags_excel**: Lê uma planilha Excel e aplica tags nos recursos AWS listados.

**Como usar:**
```bash
python grava_tags copy.py
```

**Bibliotecas:**
- `boto3`
- `pandas`

**Retorna:**
- Resultado impresso no console
- Interação com AWS via Boto3
- Geração de arquivo Excel

### `grava_tags.py`

**Função:** Script Python

**Funções principais:**
- **aplicar_tags_excel**: Lê uma planilha Excel e aplica tags nos recursos AWS listados.
    Todos os valores são tratados com

**Como usar:**
```bash
python grava_tags.py
```

**Bibliotecas:**
- `boto3`
- `pandas`

**Retorna:**
- Resultado impresso no console
- Interação com AWS via Boto3
- Geração de arquivo Excel

### `invent_excel.py`

**Função:** Script Python

**Como usar:**
```bash
python invent_excel.py
```

**Bibliotecas:**
- `pandas`

**Retorna:**
- Resultado impresso no console
- Geração de arquivo Excel

### `inventario.py`

**Função:** Script Python

**Funções principais:**
- **sanitize_filename**: Converte um ARN (que contém caracteres inválidos para nomes de arquivo)
    em um nome de arquivo se
- **get_service_from_arn**: Tenta extrair o nome do serviço (ec2, s3, rds) do ARN.
    Formato do ARN: arn:partition:service:reg
- **scan_and_save_resources**: Busca todos os recursos, imprime na tela e salva
    um JSON individual para cada um na pasta 'resou

**Como usar:**
```bash
python inventario.py
```

**Bibliotecas:**
- `argparse`
- `boto3`
- `botocore`

**Retorna:**
- Resultado impresso no console
- Interação com AWS via Boto3

### `inventario2.py`

**Função:** Script Python

**Funções principais:**
- **get_service_from_arn**: Extrai o nome do serviço do ARN.

**Como usar:**
```bash
python inventario2.py
```

**Bibliotecas:**
- `argparse`
- `boto3`
- `botocore`
- `pandas`

**Retorna:**
- Resultado impresso no console
- Interação com AWS via Boto3
- Geração de arquivo Excel

## 📋 Pré-requisitos

**Python 3.6+** com bibliotecas:
```bash
pip install boto3 pandas openpyxl
```

**AWS:**
- AWS CLI v2
- Credenciais configuradas
- Permissões apropriadas

## 💡 Exemplos

**Usar grava_tags copy.py:**
```bash
python grava_tags copy.py
```

**Usar grava_tags.py:**
```bash
python grava_tags.py
```

**Executar roteiro completo:**
```bash
```

## 🐛 Troubleshooting

| Erro | Solução |
|------|----------|
| Erro de autenticação | `saml2aws login -a <account>` |
| ModuleNotFoundError | `pip install boto3` |
| Acesso negado | Verificar permissões IAM |

## ⚠️ Importante

- ✅ Testar em DEV antes de PROD
- ✅ Revisar scripts antes de executar
- ✅ Fazer backup de dados sensíveis
- ❌ Nunca commitar credenciais AWS

---
*Última atualização: 2026-05-26*
