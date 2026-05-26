# Configurar role para acesso ao bucket S3 onde estão os parquets.

# Nome da Conta: eec-aws-br-eits-datahub-dev
# Nome do Serviço: S3
# Nome do Recurso: eec-aws-br-do-positivo-table-dev-bucket
# Ambiente executado a atividade: (DEV, QA, UAT, PROD): DEV
# Fora do escopo: n/a
# Tecnologias Envolvidas: aws-s3
# Problema Encontrado: Conceder permissão de leitura no path (/hive/reloads/positivo.reload_ds_optinout) para a role, arn:aws:iam::415071355886:role/BURoleForPositivoMercantil

aws iam get-role --role-name BURoleForPositivoMercantil --profile datahubdev

Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\_outras tarefas\configuração permissão buckets"
# configurar policy
aws s3 ls --profile dodev | Select-String -Pattern "eec-aws-br-do-positivo-table-dev-bucket" 

aws s3api get-bucket-policy --bucket eec-aws-br-do-positivo-table-dev-bucket --profile dodev


aws s3api put-bucket-policy --bucket eec-aws-br-do-positivo-table-dev-bucket --policy file://policy_bucket.json --profile dodev

# Configurar policy do kms
# Primeiro - buscar ARN da chave KMS do bucket
aws s3api get-bucket-encryption --bucket eec-aws-br-do-positivo-table-dev-bucket --profile dodev
<#
{
    "ServerSideEncryptionConfiguration": {
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "aws:kms",
                    "KMSMasterKeyID": "arn:aws:kms:sa-east-1:916546429908:key/cde4fd62-16ef-4fa5-952b-cc91193bfe62"
                },
                "BucketKeyEnabled": true
            }
        ]
    }
}
#>
# Segundo - Listar a policy existente na chave KMS
aws kms get-key-policy --key-id "arn:aws:kms:sa-east-1:916546429908:key/cde4fd62-16ef-4fa5-952b-cc91193bfe62" --profile dodev --policy-name default
<#
{
    "Policy": "{\n  \"Version\" : \"2012-10-17\",\n  \"Id\" : \"key-consolepolicy-3\",\n  \"Statement\" : [ {\n    \"Sid\" : \"Enable IAM User Permissions\",\n    \"Effect\" : \"Allow\",\n    \"Principal\" : {\n      \"AWS\" : \"arn:aws:iam::916546429908:root\"\n    },\n    \"Action\" : \"kms:*\",\n    \"Resource\" : \"*\"\n  }, {\n    \"Sid\" : \"Allow access for Key Administrators\",\n    \"Effect\" : \"Allow\",\n    \"Principal\" : {\n      \"AWS\" : \"arn:aws:iam::916546429908:user/BUUserForPositivoDev\"\n    },\n    \"Action\" : [ \"kms:Create*\", \"kms:Describe*\", \"kms:Enable*\", \"kms:List*\", \"kms:Put*\", \"kms:Update*\", \"kms:Revoke*\", \"kms:Disable*\", \"kms:Get*\", \"kms:Delete*\", \"kms:TagResource\", \"kms:UntagResource\", \"kms:ScheduleKeyDeletion\", \"kms:CancelKeyDeletion\" ],\n    \"Resource\" : \"*\"\n  }, {\n    \"Sid\" : \"Allow use of the key\",\n    \"Effect\" : \"Allow\",\n    \"Principal\" : {\n      \"AWS\" : [ \"arn:aws:iam::530914589075:role/BURoleForOdinAccess\", \"arn:aws:iam::822130695371:role/BURoleForEMREC2DefaultRole\", \"arn:aws:iam::530914589075:role/BURoleForListasRestritivas\", \"arn:aws:iam::530914589075:role/BURoleForLambda\", \"arn:aws:iam::822130695371:root\", \"arn:aws:iam::916546429908:user/BUUserForPositivoDev\", \"arn:aws:iam::730335661246:role/BURoleForListasRestritivas\", \"arn:aws:iam::730335661246:role/BURoleForContatos\" ]\n    },\n    \"Action\" : [ \"kms:Encrypt\", \"kms:Decrypt\", \"kms:ReEncrypt*\", \"kms:GenerateDataKey*\", \"kms:DescribeKey\" ],\n    \"Resource\" : \"*\"\n  }, {\n    \"Sid\" : \"Allow attachment of persistent resources\",\n    \"Effect\" : \"Allow\",\n    \"Principal\" : {\n      \"AWS\" : [ \"arn:aws:iam::822130695371:root\", \"arn:aws:iam::916546429908:user/BUUserForPositivoDev\" ]\n    },\n    \"Action\" : [ \"kms:CreateGrant\", \"kms:ListGrants\", \"kms:RevokeGrant\" ],\n    \"Resource\" : \"*\",\n    \"Condition\" : {\n      \"Bool\" : {\n        \"kms:GrantIsForAWSResource\" : \"true\"\n      }\n    }\n  } ]\n}"
}
#>

# Terceiro - Alterar a policy para permitir o acesso a role na conta de origem a chave na conta de destino
# Criei o arquivo kms_policy.json

# Finalmente ajustar a policy na chave
aws kms put-key-policy --key-id "arn:aws:kms:sa-east-1:916546429908:key/cde4fd62-16ef-4fa5-952b-cc91193bfe62" --policy-name default --policy file://kms_policy.json --profile dodev
