Aqui está um único `README.md` consolidando os dois scripts (`roteiro 1.sh` e `roteiro 2.sh`), tratando-os como **um mesmo processo de migração DMS**, aplicado em momentos diferentes ou contas distintas:

***

# 🔄 Roteiro de Migração de Banco via AWS DMS (DB-PEP)

Este repositório contém dois roteiros que fazem parte do **mesmo processo de migração de banco de dados utilizando AWS DMS**, aplicados a ambientes distintos, mas com a mesma lógica.

***

## 🎯 Objetivo

Realizar a migração completa do banco **`db_pep`** entre contas AWS, garantindo:

* Criação da infraestrutura de replicação (DMS)
* Execução da carga inicial (full-load)
* Reprocessamento do banco (drop + reload)
* Ajustes estruturais pós-migração
* Validação e tuning do ambiente

***

## 🧱 Visão Geral do Processo

O fluxo está dividido em duas grandes fases:

### 🅰️ Fase 1 — Setup da Migração (roteiro 1)

Responsável por:

* Criar infraestrutura DMS
* Configurar endpoints (source/target)
* Criar task de replicação
* Executar a migração inicial

***

### 🅱️ Fase 2 — Reprocessamento / Reload (roteiro 2)

Responsável por:

* Resetar banco de destino
* Reexecutar carga DMS
* Ajustar parâmetros do RDS
* Validar e corrigir estrutura

***

# ⚙️ Fase 1 — Setup da Migração (DMS)

## 🔧 1. Criar infraestrutura de rede

* Criar Security Group para replicação
* Liberar porta 3306 (MySQL)

***

## 🔐 2. Criar roles necessárias

* `dms-vpc-role`
* `dms-cloudwatch-logs-role`

Com policies:

* `AmazonDMSVPCManagementRole`
* `AmazonDMSCloudWatchLogsRole`

***

## 🌐 3. Criar Replication Subnet Group

* Utiliza subnets da VPC
* Necessário para DMS funcionar

***

## 🚀 4. Criar Replication Instance

Exemplo:

```bash
dms.c6i.large
```

***

## 🔗 5. Criar endpoints

### Source (origem)

* Banco da conta **dsprod**

### Target (destino)

* Banco Aurora na conta **datahubprod**

***

## 🧪 6. Testar conexão

```bash
aws dms test-connection ...
```

***

## 🔄 7. Criar Replication Task

* Tipo: `full-load`
* Utiliza:
  * `table-mappings.json`
  * `task-settings.json`

***

## 📦 8. Criar bucket S3 para logs/assessment

```bash
aws s3 mb s3://dms-migration-db-pep
```

***

## ▶️ 9. Executar migração

```bash
aws dms start-replication-task
```

***

## ⚙️ 10. Ajustes no RDS antes/depois

### Antes da migração:

* Ajustar timeouts
* Habilitar `local_infile`

### Depois:

* Restaurar parâmetros padrão
* Reboot das instâncias

***

## 🧩 11. Ajustes pós-migração

* Recriar constraints (foreign keys)
* Ajustar auto increment
* Criar triggers e índices

***

# ⚙️ Fase 2 — Reload / Reprocessamento

## ⚠️ Quando usar essa fase

* Dados inconsistentes
* Falha na carga inicial
* Necessidade de recriar o banco

***

## 🔧 1. Resetar parâmetros do RDS

Remover:

```bash
innodb_autoinc_lock_mode
```

Reboot necessário.

***

## 🗑️ 2. Dropar e recriar banco

Via acesso Kubernetes + MySQL:

```sql
DROP DATABASE db_pep;
CREATE DATABASE db_pep;
```

***

## 📸 3. Criar snapshot antes da operação

```bash
aws rds create-db-cluster-snapshot
```

***

## 🔄 4. Executar reload no DMS

```bash
aws dms start-replication-task \
  --start-replication-task-type reload-target
```

***

## 🔧 5. Restaurar parâmetros do banco

```bash
innodb_autoinc_lock_mode = 1
```

Reboot das instâncias novamente.

***

## 🧩 6. Reaplicar estrutura

* Auto increment
* Foreign keys
* Índices

***

## 📸 7. Snapshot pós-migração

Para validação e rollback futuro.

***

## 📈 8. Ajuste de performance (caso necessário)

Exemplo:

```bash
db.r6g.2xlarge
```

***

# ✅ Fluxo Completo (Resumo)

1. Criar infraestrutura DMS
2. Configurar endpoints (source/target)
3. Criar task de migração
4. Executar carga inicial
5. Validar dados
6. (Opcional) Dropar e recriar banco
7. Executar reload
8. Ajustar estrutura (FKs, índices)
9. Realizar snapshots
10. Ajustar performance

***

# ⚠️ Pontos de Atenção

* ⚠️ Senhas sensíveis aparecem no script → mover para Secrets Manager
* ⚠️ Necessário acesso correto entre VPCs
* ⚠️ Constraints não são totalmente suportadas no full-load → recriar manualmente
* ⚠️ Parâmetros do RDS impactam a migração
* ⚠️ Tamanho da instância pode afetar performance

***

# 🔐 Boas práticas

* Usar Secrets Manager para credenciais
* Sempre criar snapshot antes de mudanças críticas
* Validar dados após migração
* Monitorar CloudWatch durante execução
* Documentar mappings e settings do DMS

***

# 📈 Melhorias futuras

* Automatizar fluxo via Terraform
* Criar pipeline (CI/CD) para migração
* Criar rollback automatizado
* Monitoramento estruturado
* Scripts de validação de dados

***

# 🧑‍💻 Uso recomendado

Ideal para:

* ✅ Migração de bancos entre contas AWS
* ✅ Consolidação de data platforms
* ✅ Reprocessamento de cargas via DMS
* ✅ Times de Data Engineering / SRE

***
