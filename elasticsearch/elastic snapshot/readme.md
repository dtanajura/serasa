# 📦 Roteiro – Snapshot Elasticsearch / OpenSearch

## 🎯 Objetivo

Gerenciar snapshots de índices Elasticsearch para:

* ✅ Backup de dados
* ✅ Migração entre clusters
* ✅ Disaster Recovery (DR)
* ✅ Auditoria de dados

***

# 🧠 1. Arquitetura do snapshot

Fluxo:

```text
Elasticsearch Cluster (source)
        ↓
Snapshot Repository (S3)
        ↓
Restore em outro cluster (destination)
```

***

## 📌 Componentes

* Cluster origem (ES/OpenSearch)
* Bucket S3 (`es-snapshot-v3`)
* IAM Role de snapshot
* Cluster destino (opcional)

***

# 📂 2. Listar snapshots (S3)

## ▶️ Script: `listsnapshots.py`

### ✅ Função

Lista arquivos no bucket de snapshot

```python
s3_client.list_objects_v2(Bucket=snapshot_bucket)
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/listsnapshots.py)

***

## ▶️ Execução

```bash
python3 listsnapshots.py
```

***

## 📊 Resultado

```text
snapshot-es-index-uat/...
```

***

# 🔍 3. Listar índices do cluster

## ▶️ Script: `createSnapshotES.py`

### ✅ Endpoint usado

```bash
/_cat/indices?format=json
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/createSnapshotES.py)

***

## ▶️ Execução

```bash
python3 createSnapshotES.py
```

***

## 📊 Resultado

```text
Índices encontrados:
- synthetic_consumptions_maintenance
```

***

# 📸 4. Criar snapshot

## ▶️ Endpoint Elasticsearch

```bash
PUT /_snapshot/<repo>/<snapshot_name>
```

***

## 📌 Exemplo do seu script

```python
payload = {
  "indices": ["synthetic_consumptions_maintenance"]
}
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/createSnapshotES.py)

***

## ▶️ Execução

```bash
python3 createSnapshotES.py
```

***

## ✅ Resultado esperado

```text
200 OK
snapshot created
```

***

# 🔐 5. Configurar repositório (S3)

Antes do snapshot/restore é necessário registrar:

```json
{
  "type": "s3",
  "settings": {
    "bucket": "es-snapshot-v3",
    "region": "sa-east-1",
    "role_arn": "arn:aws:iam::<ACCOUNT>:role/BURoleForESSnapshot"
  }
}
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/restoresnapshot.py)

***

## ▶️ Endpoint

```bash
PUT /_snapshot/es-snapshot-v3
```

***

# 🔄 6. Restaurar snapshot

## ▶️ Script: `restoresnapshot.py`

### ✅ Função:

* Registra repositório
* Restaura snapshot

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/restoresnapshot.py)

***

## ▶️ Execução

```bash
python3 restoresnapshot.py
```

***

## 📌 Endpoint

```bash
POST /_snapshot/<repo>/<snapshot_name>/_restore
```

***

## ✅ Resultado esperado

```text
acknowledged: true
```

***

# 🔎 7. Validação pós-restore

## 📌 Listar índices

```bash
GET /_cat/indices?v
```

***

## 📌 Ver status

```bash
GET /_cluster/health
```

***

## 📌 Conferir dados

* contagem de docs
* tamanho índice
* queries de teste

***

# ⚠️ 8. Pontos de atenção

## 🔐 Permissões IAM

Role precisa:

```json
s3:ListBucket
s3:GetObject
s3:PutObject
```

***

## 🪣 Bucket S3

* Deve estar acessível pelo cluster
* Encrypted (recomendado)

***

## 🌐 Network

* VPC endpoints (se privado)
* Security Group liberando acesso

***

## 📛 Nome do snapshot

Evitar sobrescrever:

```text
snapshot-es-YYYY-MM-DD
```

***

# 🚀 9. Boas práticas

* ✅ Snapshot diário automático
* ✅ Nome padrão
* ✅ Separar bucket por ambiente
* ✅ Validar restore periodicamente
* ✅ Usar lifecycle no S3

***

# 🔥 Script completo (resumo)

```bash
# 1. listar índices
GET /_cat/indices

# 2. criar snapshot
PUT /_snapshot/repo/snapshot-name
{
  "indices": "meu-indice"
}

# 3. verificar snapshots
GET /_snapshot/repo/_all

# 4. restore
POST /_snapshot/repo/snapshot-name/_restore
```

***

# ✅ 10. Checklist final

* ✅ Repository configurado
* ✅ Snapshot criado
* ✅ Arquivo no S3
* ✅ Restore testado
* ✅ Índices validados
