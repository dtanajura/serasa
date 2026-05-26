# Ambiente MWAA – experian-mwaa-warriors-dev

Este documento descreve as configurações e características do ambiente **Amazon MWAA (Managed Workflows for Apache Airflow)** utilizado no ambiente **DEV**.

As informações aqui documentadas foram obtidas a partir do comando `aws mwaa get-environment` e servem como **referência técnica e operacional**.

---

## Identificação do Ambiente

- **Nome:** experian-mwaa-warriors-dev
- **Status:** AVAILABLE
- **Região:** sa-east-1
- **Airflow Version:** 2.10.1
- **Classe do Ambiente:** mw1.small
- **Criado em:** 29/11/2024 15:55 (GMT-03)

---

## Acesso

- **URL do Webserver:**
  - Ambiente privado (PRIVATE_ONLY)
  - Acesso via VPC Endpoint

- **Modo de acesso:** PRIVATE_ONLY

---

## IAM Roles

- **Execution Role:**
  - BURoleForMWAAmwaa-warriors-dev

- **Service Role:**
  - AWSServiceRoleForAmazonMWAA

Essas roles são responsáveis por permitir que o MWAA acesse recursos como S3, CloudWatch, SQS e outros serviços AWS necessários para a execução dos workflows.

---

## Armazenamento (S3)

- **Bucket de origem:** mwaa-warriors-dev
- **Caminho dos DAGs:** dags/
- **Caminho dos plugins:** plugins/plugins.zip

---

## Configuração de Workers e Webserver

- **Min Workers:** 1
- **Max Workers:** 10
- **Schedulers:** 2
- **Min Webservers:** 2
- **Max Webservers:** 2

---

## Configuração de Rede

- **Subnets:**
  - subnet-0eb6a26da3a880d53
  - subnet-0da0bbd24ff90ab51

- **Security Group:**
  - sg-0dfa37fde6ec6f82a

- **VPC Endpoint Webserver:**
  - com.amazonaws.vpce.sa-east-1.vpce-svc-0997250d16ef97653

- **VPC Endpoint Database:**
  - com.amazonaws.vpce.sa-east-1.vpce-svc-0c265b411b95db05a

---

## Logs (CloudWatch)

- **Dag Processing Logs:**
  - Nível: INFO

- **Scheduler Logs:**
  - Nível: ERROR

- **Webserver Logs:**
  - Nível: ERROR

- **Worker Logs:**
  - Nível: ERROR

- **Task Logs:**
  - Nível: INFO

Todos os logs estão habilitados e direcionados para grupos de logs no Amazon CloudWatch.

---

## Manutenção e Atualizações

- **Janela de manutenção semanal:** MON:04:00

- **Última atualização:**
  - Status: SUCCESS
  - Data: 01/04/2026 10:26 (GMT-03)

---

## Fila do Executor (Celery)

- **SQS Queue:**
  - airflow-celery-c9d5901f-a52f-4548-b990-1a55d9630781

---

## Tags do Ambiente

- Asset_Category: Metadata
- AppID: 19678
- Environment: dev
- CostString: 1800.BR.134.404506
- Data_Category: N/A
- Data_Type: N/A

---

## Comando de Referência

```bash
aws mwaa get-environment   --name experian-mwaa-warriors-dev   --region sa-east-1   --profile nikedataservicedev
```

---

## Observações Finais

Este README serve como **documentação técnica do ambiente DEV do MWAA**, facilitando auditorias, troubleshooting e padronização entre ambientes.

Sempre validar permissões, endpoints e configurações antes de replicar este setup para outros ambientes (UAT / PROD).
