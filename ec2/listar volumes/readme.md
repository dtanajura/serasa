# 📊 Roteiro de Inventário AWS (EBS + Snapshots Multi-Serviço)

Este repositório contém um conjunto de scripts para **coletar inventário de recursos AWS** em múltiplas contas e gerar relatórios em CSV.

***

## 🎯 Objetivo

Centralizar e automatizar a coleta de informações sobre:

* Volumes EBS
* Snapshots (multi-serviço)

Com suporte a:

* Execução em **múltiplos profiles AWS**
* Exportação para **CSV**
* Padronização de dados

***

## 🧱 Estrutura dos Scripts

### 🐍 `list_ebs.py`

Responsável por listar todos os volumes EBS na conta.

Coleta informações como:

* Volume ID
* Estado (`in-use` / `available`)
* Tamanho (GB)
* Tipo (gp2, gp3, etc.)
* Instâncias associadas

✅ Suporta exportação para CSV [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/list_ebs.py)

***

### 🐍 `list_snapshots.py`

Responsável por listar snapshots de múltiplos serviços AWS:

* EC2 / EBS
* RDS (instance e cluster)
* DocumentDB
* Redshift
* ElastiCache
* AWS Backup

Unifica os dados em um único formato:

* `resource_id`, `status`, `engine`
* `size_gb`, `encrypted`
* `kms_key_id`
* `start_time`
* `snapshot_type`

✅ Geração de inventário consolidado multi-serviço [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/list_snapshots.py)

***

### 🐚 `lista.sh`

Script orquestrador responsável por:

* Executar o `list_ebs.py` para múltiplos profiles
* Gerar arquivos CSV por conta
* Organizar saídas em diretório
* Permitir execução sequencial ou paralela

Inclui:

* Lista de diversos profiles AWS
* Retry automático
* Logs de execução

✅ Automação em escala para várias contas [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/lista.sh)

***

# 🚀 Como usar

***

## 📋 Pré-requisitos

* Python 3.x
* AWS CLI configurado
* Acesso aos profiles AWS desejados
* Biblioteca:

```bash
pip install boto3
```

***

## ▶️ Execução individual

### Listar volumes EBS

```bash
python list_ebs.py --profile <profile>
```

Exportar CSV:

```bash
python list_ebs.py --profile <profile> --csv ebs.csv
```

***

### Listar snapshots

```bash
python list_snapshots.py --profile <profile>
```

Exportar CSV:

```bash
python list_snapshots.py --profile <profile> --csv snapshots.csv
```

***

## ⚙️ Execução em massa (multi-conta)

```bash
bash lista.sh
```

***

## 📁 Saída

Os arquivos CSV serão gerados em:

```
./csv/
```

Exemplo:

```
csv/
 ├── datahubdev.csv
 ├── datahubprod.csv
 ├── positivoprod.csv
```

***

# ✅ Fluxo Completo

1. Definir profiles no `lista.sh`
2. Executar script orquestrador
3. Coletar dados de EBS
4. (Opcional) coletar snapshots via script dedicado
5. Consolidar CSVs para análise

***

# ⚠️ Observações

* O script utiliza a região definida no profile
* Alguns serviços podem não existir na região (tratado com warning)
* Execução paralela pode ser ativada via:

```bash
PARALLEL_JOBS > 1
```

***

# 🔐 Permissões necessárias

A role/profile AWS precisa permitir:

* `ec2:DescribeVolumes`
* `ec2:DescribeSnapshots`
* `rds:DescribeDBSnapshots`
* `rds:DescribeDBClusterSnapshots`
* `redshift:DescribeClusterSnapshots`
* `elasticache:DescribeSnapshots`
* `backup:ListRecoveryPoints*`

***

# 📈 Possíveis usos

* 📊 Inventário de infraestrutura
* 💸 Análise de custos
* 🧹 Identificação de recursos não utilizados
* 🔐 Auditoria de criptografia (KMS)
* 📦 Governança de dados

***

# 🔧 Melhorias futuras

* Consolidar todos CSVs em um único arquivo
* Exportar para banco de dados ou Data Lake
* Criar dashboard (QuickSight / Power BI)
* Adicionar filtros por tag ou idade
* Integração com Lambda / agendamento

***

# 🧑‍💻 Uso recomendado

Ideal para:

* ✅ SRE / Cloud Ops
* ✅ FinOps (controle de custos)
* ✅ Auditoria de backups
* ✅ Governança multi-conta

***