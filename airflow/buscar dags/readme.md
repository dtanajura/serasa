# 🔍 Roteiro – Busca e Auditoria de DAGs no MWAA (Airflow)

## 🎯 Objetivo

Localizar, analisar e auditar DAGs no ambiente MWAA, incluindo:

* Listagem de DAGs via S3
* Extração de informações (dag\_id, connections)
* Correlação com connections do Airflow
* Identificação de inconsistências (ex: env errado)

***

# ⚙️ 1. Pré-requisitos

* AWS CLI configurado
* Permissão para:
  * `s3:list-objects`
  * `s3:get-object`
  * `mwaa:create-cli-token`
* Python + boto3 instalado

***

# 📦 2. Configurações base

Do teu script:

```python
PROFILE = "datahubprod"
BUCKET = "airflow-mwaa97d2522122f0f00b-prod-415071355886"
PREFIX = "dags/"
MWAA_ENV = "airflow-mwaa-datahub-prod"
```

👉 Isso define:

* Bucket onde estão as DAGs
* Pasta `dags/`
* Ambiente MWAA

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/buscatags.py)

***

# 📂 3. Listar DAGs no S3

## ▶️ Execução lógica

O script percorre o bucket:

```python
paginator = s3.get_paginator("list_objects_v2")
```

E filtra:

```python
if key.endswith(".py")
```

✅ Resultado:

* Lista de arquivos `.py` (DAGs)

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/buscatags.py)

***

## 📊 Output esperado

```
📦 Arquivos DAG encontrados: X
```

***

# 🔎 4. Extrair informações das DAGs

O script usa regex para encontrar:

```python
dag_pattern = r'dag_id\s*=\s*[^"\']+["\']'
conn_pattern = r'emr_conn_id\s*=\s*[^"\']+["\']'
```

👉 Extrai:

* `dag_id`
* `emr_conn_id` (connection)

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/buscatags.py)

***

## 📌 Resultado esperado

Mapeamento:

```text
DAG → Connection → Arquivo
```

***

# 🔐 5. Buscar connections do MWAA

## ▶️ Via CLI interno do Airflow

```python
token = mwaa.create_cli_token(Name=MWAA_ENV)
```

Depois chama:

```bash
connections export
```

✅ Resultado:

* Lista completa de connections

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/buscatags.py)

***

## 📊 Output

```
📡 Connections carregadas: X
```

***

# 🏷️ 6. Analisar tags das connections

Baseado no seu outro script:

```python
if c.conn_type == "emr"
```

e:

```python
if tag.get("Key") == "Environment"
```

Validação:

```python
if env_value != "prd"
```

👉 Identifica:

* connections fora do padrão

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/exportconnections.py)

***

# 📊 7. Cruzar dados

Resultado final:

```text
DAG → Connection → Environment
```

Problemas detectados:

* ❌ DAG usando connection errada
* ❌ Environment incorreto (ex: dev em prod)
* ❌ connection inexistente

***

# ✅ 8. Resultado esperado

Exemplo:

```json
[
  {
    "dag_id": "dag_exemplo",
    "conn_id": "emr-dev",
    "environment": "dev"
  }
]
```

***

# 🧪 9. Execução

```bash
python buscatags.py
```

ou

```bash
python exportconnections.py
```

***

# ⚠️ Pontos de atenção

* DAGs podem:
  * não ter connection
  * usar outros operadores
* Regex pode não pegar todos os casos
* DAGs dinâmicas podem escapar

***

# 🚀 Boas práticas

* ✅ Versionar DAGs no Git
* ✅ Padronizar uso de connections
* ✅ Validar tags obrigatórias
* ✅ Criar auditoria periódica

***

# 🔥 Script simplificado (check rápido)

```bash
echo "Listando DAGs..."

aws s3 ls s3://$BUCKET/dags/ --recursive | grep .py

echo "Total:"
aws s3 ls s3://$BUCKET/dags/ --recursive | grep .py | wc -l
```

***

# 🧠 Próximo nível (recomendado)

Posso evoluir isso para você:

* 🔹 auditoria automática (Lambda diária)
* 🔹 alerta se DAG usar env errado
* 🔹 dashboard de DAGs × connections
* 🔹 validação CI/CD (antes de subir DAG)
* 🔹 correção automática

