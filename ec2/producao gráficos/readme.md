# 📊 Roteiro – Produção de Gráficos (Dashboard Custos)

## 🎯 Objetivo

Gerar visualização de custos AWS em produção com:

* ✅ Coleta automática (AWS Cost Explorer)
* ✅ Armazenamento em banco (PostgreSQL)
* ✅ Visualização (Streamlit)
* ✅ Filtros por conta / serviço
* ✅ Atualização contínua

***

# 🧠 1. Arquitetura completa

```text
AWS Cost Explorer
     ↓
Script Python (carrega_dados.py)
     ↓
PostgreSQL (RDS)
     ↓
Dashboard (Streamlit)
     ↓
Usuário (browser)
```

***

# ⚙️ 2. Pipeline de dados (ETL)

## 📄 Script: `carrega_dados.py`

### ✅ O que ele faz:

1. Coleta custos AWS:

```python
ce_client.get_cost_and_usage()
```

👉 Usa:

* `UnblendedCost`
* Aggregation por:
  * conta
  * serviço
  * tags [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/carrega_dados.py)

***

2. Processa dados:

* Agrupa por mês
* Calcula custos
* Formata datas

***

3. Salva no banco:

```sql
INSERT INTO account_costs
INSERT INTO resource_costs
INSERT INTO tag_details_costs
```

👉 Usa UPSERT (`ON CONFLICT`)    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/carrega_dados.py)

***

## 🚀 Execução

```bash
python carrega_dados.py datahubdev
```

***

# 🗄️ 3. Banco de dados

## 📌 Estrutura usada

* `accounts`
* `account_costs`
* `resource_costs`
* `tag_costs`
* `tag_details_costs`

***

## 💡 Banco

```text
RDS PostgreSQL
```

***

# 📊 4. Dashboard (Streamlit)

## 📄 Script: `dashboard.py`

### ✅ Carregamento de dados

```python
pd.read_sql(query, conn)
```

👉 Query dinâmica baseada no gráfico [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/dashboard.py)

***

## ✅ Tipos de gráficos

```python
graph_types = [
  "Custo Mensal das Contas",
  "Custos Mensais Top Serviços",
  "Outro Gráfico"
]
```

***

# 📈 5. Gráficos implementados

## 🔵 1. Linha – custo por conta

```python
st.line_chart()
```

* eixo X: data
* eixo Y: custo
* séries: contas

👉 visão macro    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/dashboard.py)

***

## 🟠 2. Barra – Top serviços

```python
st.bar_chart()
```

### Lógica:

* Top 5 serviços
* Outros → agrupados

👉 ótima prática de visualização    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/dashboard.py)

***

# 🎛️ 6. Filtros

## ✅ Multi-account

```python
multiselect()
```

## ✅ Single account

```python
selectbox()
```

👉 melhora análise    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/dashboard.py)

***

# 🚀 7. Subir em produção

## ▶️ Rodar Streamlit

```bash
streamlit run dashboard.py
```

***

## 🌐 Expor

Opções:

* Nginx reverse proxy
* ALB AWS
* ECS / EKS
* EC2 direto

***

# 🔐 8. Segurança (IMPORTANTE)

⚠️ PROBLEMA no teu código:

```python
'password': '123Trocar$'
```

👉 Nunca deixar senha hardcoded

✅ Corrigir:

* AWS Secrets Manager
* Env vars:

```bash
export DB_PASSWORD=xxx
```

***

# 🧪 9. Atualização automática

## ✅ Rodar ETL periodicamente

Opções:

```bash
crontab -e
```

```text
0 3 * * * python carrega_dados.py datahubdev
```

***

Ou:

* Lambda ✅
* ECS schedule ✅
* Airflow ✅

***

# 🔎 10. Validação

## ✅ Dados no DB

```sql
SELECT * FROM account_costs;
```

***

## ✅ Dashboard

* gráfico aparece
* filtros funcionam

***

## ✅ Logs

```bash
streamlit logs
```

***

# ⚠️ 11. Problemas comuns

## ❌ Dados vazios

* CE sem permissão
* tabela vazia

***

## ❌ Gráfico quebrado

* pivot errado
* data inválida

***

## ❌ Lentidão

* query pesada
* falta index

***

# 🚀 12. Boas práticas

## ✅ Performance

* index em:

```sql
(account_id, date_register)
```

***

## ✅ Visualização

* limitar top serviços
* padronizar cores
* agrupar "outros"

***

## ✅ Governança

* usar tags nos custos
* manter histórico

***

# 🔥 13. Melhorias que você já pode fazer

## 🧠 Backend

* cache com Redis
* materialized views

***

## 📊 Dashboard

* adicionar:
  * drill-down
  * filtros por região
  * gráficos de tendência

***

## ☁️ AWS

* integrar com:
  * Athena
  * QuickSight

***

# 📦 14. Script padrão produção (pipeline)

```bash
#!/bin/bash

echo "Atualizando dados..."

python carrega_dados.py datahubdev

echo "Subindo dashboard..."

streamlit run dashboard.py
```

***

# ✅ 15. Checklist final

* ✅ ETL funcionando
* ✅ dados no banco
* ✅ dashboard acessível
* ✅ filtros funcionando
* ✅ segurança aplicada

