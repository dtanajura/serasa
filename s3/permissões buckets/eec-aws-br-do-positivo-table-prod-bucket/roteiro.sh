# Nome da Conta: eec-aws-br-ds-dataoffice-prod (822130695371)
# Nome do Serviço: S3
# Nome do Recurso: eec-aws-br-do-positivo-table-prod-bucket
# Ambiente executado a atividade: (DEV, QA, UAT, PROD): PROD
# Fora do escopo: n/a
# Tecnologias Envolvidas: aws-s3
# Problema Encontrado: Conceder permissão de leitura no path (/hive/reloads/positivo.reload_ds_optinout) para a role, arn:aws:iam::415071355886:role/BURoleForPositivoMercantil

aws iam get-role --role-name BURoleForPositivoMercantil --profile datahubprod


aws s3api get-bucket-policy --bucket eec-aws-br-do-positivo-table-prod-bucket --profile doprod

# Incluir o statement nas buckets policies:
<#
        {
            "Sid": "Acesso para a conta de Mercantil",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::415071355886:role/BURoleForPositivoMercantil"
            },
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::eec-aws-br-do-positivo-table-prod-bucket",
                "arn:aws:s3:::eec-aws-br-do-positivo-table-prod-bucket//hive/reloads/positivo.reload_ds_optinout/*"
            ]
        }
#>

# Verificar necessidade de criação de policy do KMS
aws s3api get-bucket-encryption --bucket eec-aws-br-do-positivo-table-prod-bucket --profile doprod
