# inventario datahub copy

## 📌 Descrição

Pasta: `inventario datahub copy`

**Scripts Python encontrados:**
- `grava_tags copy.py`
- `grava_tags.py`
- `inventario.py`
- `inventario2.py`
- `invent_excel.py`

**Roteiro de execução disponível**

## 📋 Roteiro de Execução

Passos a serem executados:

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
16. map-migrated
17. Project
18. Name
19. Squad
20. Account: eec-aws-br-eits-datahub-dev (730335661246)

... (total de 116 passos)

## 🐍 Scripts Python

### grava_tags copy.py

**Descrição:** Lê uma planilha Excel e aplica tags nos recursos AWS listados.

**Bibliotecas usadas:** `boto3`, `pandas`, `sys`

**Entrada esperada:** Parâmetros não especificados

**Como usar:**
```bash
python grava_tags copy.py [argumentos]
```

### grava_tags.py

**Descrição:** Lê uma planilha Excel e aplica tags nos recursos AWS listados.
    Todos os valores são tratados como texto, preservando zeros à esquerda e removendo decimais desnecessários.

**Bibliotecas usadas:** `boto3`, `pandas`, `sys`

**Entrada esperada:** Parâmetros não especificados

**Como usar:**
```bash
python grava_tags.py [argumentos]
```

### inventario.py

**Descrição:** Converte um ARN (que contém caracteres inválidos para nomes de arquivo)
    em um nome de arquivo seguro.
    Substitui ':' por '_' e '/' por '-'.

**Bibliotecas usadas:** `boto3`, `botocore`, `sys`, `argparse`, `os`, `json`

**Entrada esperada:** Parâmetros não especificados

**Como usar:**
```bash
python inventario.py [argumentos]
```

### inventario2.py

**Descrição:** Extrai o nome do serviço do ARN.

**Bibliotecas usadas:** `boto3`, `pandas`, `argparse`, `sys`, `botocore`

**Entrada esperada:** Parâmetros não especificados

**Como usar:**
```bash
python inventario2.py [argumentos]
```

### invent_excel.py

**Descrição:** Script Python

**Bibliotecas usadas:** `os`, `json`, `pandas`

**Entrada esperada:** Parâmetros não especificados

**Como usar:**
```bash
python invent_excel.py [argumentos]
```


## ⚙️ Arquivos de Configuração

**JSON:**
- `merged_tags.json`
- `tags-buckets.json`
- `tags.json`

**Planilhas Excel:**
- `bnsuat.xlsx`
- `datahubdev.xlsx`
- `datahubprod.xlsx`
- `datahubstage.xlsx`
- `eec-aws-br-eits-datahub-dev_non_compliant_resources.xlsx`
- `eec-aws-br-eits-datahub-prod_non_compliant_resources.xlsx`
- `eec-aws-br-eits-datahub-stage_non_compliant_resources.xlsx`
- `recursos_aws.xlsx`
- `recursos_aws_datahubdev.xlsx`
- `recursos_aws_nikedataserviceprod.xlsx`
- `recursos_aws_nikedataserviceuat.xlsx`
- `recursos_aws_tags - datahubdev - 24.11.25.xlsx`
- `recursos_aws_tags - datahubdev - 26.11.25.xlsx`
- `recursos_aws_tags - datahubdev - 27.11.25.xlsx`
- `recursos_aws_tags - datahubprod - 24.11.25.xlsx`
- `recursos_aws_tags - datahubprod - 26.11.25.xlsx`
- `recursos_aws_tags - datahubprod - 27.11.25.xlsx`

## 📋 Pré-requisitos

- Python 3.6+
- Bibliotecas necessárias:
  - `argparse`
  - `boto3`
  - `botocore`
  - `pandas`

**Instalar dependências:**
```bash
pip install -r requirements.txt
```

- AWS CLI configurada
- Credenciais AWS com permissões apropriadas

## ⚠️ Observações Importantes

- Sempre testar em ambiente DEV antes de executar em PROD
- Revisar o roteiro antes de executar automaticamente
- Fazer backup dos dados antes de operações destrutivas
- Verificar credenciais e permissões necessárias

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique o arquivo `roteiro.sh` ou `roteiro.txt`
2. Consulte os comentários nos scripts Python
3. Revise os arquivos de configuração

---

*Documentação gerada automaticamente - Última atualização: 2026-05-26*
