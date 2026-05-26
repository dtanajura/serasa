# AWS Backup – Backup Plan e Backup Selection

Este repositório contém os arquivos necessários para **criação e configuração de backups utilizando o AWS Backup**, incluindo **backup vault**, **backup plan** e **backup selection**.

O conteúdo é voltado para **uso operacional**, servindo como referência e checklist para configuração inicial ou recriação de políticas de backup em ambientes AWS.

---

## Objetivo

- Criar um **Backup Vault** no AWS Backup
- Definir um **Backup Plan** com regras de agendamento e retenção
- Associar recursos AWS a um plano através de **Backup Selection**
- Documentar o procedimento completo via AWS CLI

---

## Arquivos do Repositório

### `backup-plan.json`

Define o **plano de backup**, contendo:
- Nome do plano
- Regras de execução
- Backup Vault de destino
- Agendamento (cron)
- Janela de início e conclusão
- Política de retenção

Este arquivo é utilizado diretamente no comando `aws backup create-backup-plan`.

---

### `backup-selection.json`

Define a **seleção de recursos** que farão parte do backup, incluindo:
- Backup Plan ID
- IAM Role utilizada pelo AWS Backup
- Recursos AWS (EC2, RDS, etc.)

Este arquivo é utilizado no comando `aws backup create-backup-selection`.

---

### `roteiro.sh`

Roteiro operacional com os **comandos AWS CLI necessários para executar todo o processo**, desde a criação do vault até a validação final da seleção de backup.

O arquivo deve ser utilizado como **guia step-by-step**, executando os comandos manualmente após os devidos ajustes.

---

## Procedimento (Roteiro Operacional)

### 1. Definir o profile AWS

```bash
profile_aws="corporateprod"
```

---

### 2. Criar o Backup Vault

```bash
aws backup create-backup-vault   --backup-vault-name backup-vault-$profile_aws   --profile $profile_aws
```

---

### 3. Criar o Backup Plan

Antes de executar:
- Ajustar no `backup-plan.json` o nome do **TargetBackupVaultName**

```bash
aws backup create-backup-plan   --cli-input-json file://backup-plan.json   --profile $profile_aws
```

Guarde o **BackupPlanId** retornado, pois ele será usado no próximo passo.

---

### 4. Criar e configurar a IAM Role

Criar a role:

```bash
aws iam create-role   --role-name BURoleForAWSBackup   --assume-role-policy-document file://trust-policy.json   --profile corporateprod
```

Anexar política inline:

```bash
aws iam put-role-policy   --role-name BURoleForAWSBackup   --policy-name InlinePolicy   --policy-document file://inline-policy.json   --profile corporateprod
```

Anexar política gerenciada:

```bash
aws iam attach-role-policy   --role-name BURoleForAWSBackup   --policy-arn arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup   --profile corporateprod
```

Validar as políticas:

```bash
aws iam list-attached-role-policies   --role-name BURoleForAWSBackup   --profile corporateprod
```

---

### 5. Criar o Backup Selection

Antes de executar, ajustar no `backup-selection.json`:
- `BackupPlanId`
- `IamRoleArn`

```bash
aws backup create-backup-selection   --cli-input-json file://backup-selection.json   --profile corporateprod
```

---

### 6. Validar Backup Selections

```bash
aws backup list-backup-selections   --backup-plan-id <BACKUP_PLAN_ID>   --profile corporateprod
```

---

## Boas Práticas

- Sempre versionar os arquivos JSON utilizados
- Validar cron e retenção antes de produção
- Garantir que a IAM Role tenha apenas permissões necessárias
- Testar restore após criação do backup

---

## Avisos Importantes

⚠️ Backups impactam custo de armazenamento  
⚠️ Alterações devem seguir políticas internas de retenção  
⚠️ Nunca alterar planos de produção sem validação prévia

---

## Público-alvo

- SRE
- DevOps
- Cloud / Platform Engineers
- Times responsáveis por governança e backup

---

## Observação Final

Este repositório serve como **documentação operacional e referência prática** para configuração de AWS Backup via CLI.

Sempre revise IDs, ARNs e region antes da execução.
