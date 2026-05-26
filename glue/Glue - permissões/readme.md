# 🧬 Roteiro – Permissões AWS Glue (Data Catalog + S3)

## 🎯 Objetivo

Configurar permissões completas para uso do Glue em cenário Data Lake:

* ✅ Acesso ao Data Catalog (Glue)
* ✅ Acesso aos dados no S3
* ✅ Compartilhamento cross-account
* ✅ Integração com EMR / Athena / Databricks

***

# 🧠 1. Arquitetura de permissões

```text
Usuário / Role (EMR / ECS / Glue / Databricks)
          ↓
Glue Data Catalog (metadata)
          ↓
S3 Bucket (dados físicos)
```

👉 IMPORTANTE:

✅ Permissão Glue ≠ acesso S3  
✅ Você SEMPRE precisa dos dois

***

# 🔐 2. Permissões Glue (Data Catalog)

## 📄 `glue_resource_policy.json`

### ✅ Permissões principais

```json
"Action": [
  "glue:GetDatabases",
  "glue:GetDatabase",
  "glue:GetTables",
  "glue:GetTable",
  "glue:GetPartitions"
]
```

👉 Permite leitura de metadata no Glue    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/glue_resource_policy.json)

***

## 🏢 Cross-account access

Você liberou:

```json
"Principal": {
  "AWS": [
    "arn:aws:iam::331365656181:root",
    "arn:aws:iam::730335661246:root",
    "arn:aws:iam::713881783816:root"
  ]
}
```

👉 Permite acesso a múltiplas contas    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/glue_resource_policy.json)

***

## 📊 Escopo de recursos

```json
"Resource": [
  "arn:aws:glue:sa-east-1:146737708860:catalog",
  "arn:aws:glue:...:database/reports",
  "arn:aws:glue:...:table/reports/*"
]
```

👉 Controle por:

* catalog
* database
* tabela    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/glue_resource_policy.json)

***

## 🔥 Exemplo real (do seu caso)

* DB: `reports`
* DB: `replicacao`
* tabelas específicas liberadas

***

# 🪣 3. Permissões S3 (dados)

## 📄 `bucket_policy.json`

### ✅ Permissões básicas

```json
"Action": [
  "s3:GetObject",
  "s3:GetObjectAcl"
]
```

👉 Leitura de dados    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/bucket_policy.json)

***

## ✅ List bucket

```json
"Action": "s3:ListBucket"
```

👉 Necessário para Athena/Glue listar diretórios [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/bucket_policy.json)

***

## ✅ Acesso por prefixo

```json
"Resource": [
  "arn:aws:s3:::experian-datahub-gold-reports-uat/warehouse/reports/*"
]
```

👉 Controle granular por pasta    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/bucket_policy.json)

***

## ✅ Escrita (quando necessário)

```json
"s3:PutObject",
"s3:DeleteObject"
```

👉 Ex: ECS / Databricks escrevendo dados    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/bucket_policy.json)

***

# 🔗 4. Integração Glue + S3

## ✅ Para funcionar corretamente, precisa:

| Componente   | Permissão                     |
| ------------ | ----------------------------- |
| Glue Catalog | `glue:Get*`                   |
| S3 Bucket    | `s3:GetObject` + `ListBucket` |

***

⚠️ Sem S3:
👉 consulta falha

⚠️ Sem Glue:
👉 tabela não é encontrada

***

# 🏗️ 5. Aplicar Glue Resource Policy

```bash
aws glue put-resource-policy \
  --policy-in-json file://glue_resource_policy.json \
  --region sa-east-1
```

***

# 🪣 6. Aplicar Bucket Policy

```bash
aws s3api put-bucket-policy \
  --bucket experian-datahub-gold-reports-uat \
  --policy file://bucket_policy.json
```

***

# 🔎 7. Validação

## ✅ Testar Glue

```bash
aws glue get-tables \
  --database-name reports
```

***

## ✅ Testar S3

```bash
aws s3 ls s3://experian-datahub-gold-reports-uat/
```

***

## ✅ Testar Athena

```sql
SELECT * FROM reports.depara_hash LIMIT 10;
```

***

# ⚠️ 8. Pontos críticos

## 🔐 Segurança

* Evitar:

```json
"Resource": "*"
```

***

## 🧱 Cross-account

* Sempre validar:
  * Account ID
  * Role/Principal correto

***

## 🧬 Glue ≠ Lake Formation

* Se usar Lake Formation:
  * regras mudam completamente

***

## 🔥 Ordem de troubleshooting

Se der erro:

1. Glue ok?
2. S3 ok?
3. IAM Role ok?
4. Glue Resource Policy ok?

***

# 🚀 9. Boas práticas

* ✅ Permissões mínimas (least privilege)
* ✅ Separar por:
  * database
  * tabela
* ✅ Evitar liberar bucket inteiro
* ✅ Versionar policies

***

# 🔥 10. Template reutilizável

## Glue

```json
{
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::<ACCOUNT>:role/<ROLE>"
  },
  "Action": [
    "glue:GetDatabase",
    "glue:GetTables"
  ],
  "Resource": [
    "arn:aws:glue:<region>:<account>:database/<db>",
    "arn:aws:glue:<region>:<account>:table/<db>/*"
  ]
}
```

***

## S3

```json
{
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::<ACCOUNT>:role/<ROLE>"
  },
  "Action": [
    "s3:GetObject",
    "s3:ListBucket"
  ],
  "Resource": [
    "arn:aws:s3:::bucket",
    "arn:aws:s3:::bucket/path/*"
  ]
}
```

✅ Resumo direto:

Seu cenário está correto e enterprise:

* Glue policy → controla metadata
* S3 policy → controla dados
* Cross-account → liberado por role

👉 Isso já é padrão **Data Lake corporativo (DataHub)**

