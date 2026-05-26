# Configurar permissão no bucket: eec-aws-br-do-positivo-silver-dev-bucket
# Conta de Origem:  eec-aws-br-eits-datahub-dev (730335661246)
# Role de origem: arn:aws:iam::730335661246:role/BURoleForPositivoMercantil
# Conta de destino: eec-aws-br-ds-dataoffice-dev (916546429908)
# recursive a permissao de read, por favor: /ifs/Cadastral/processados/* 

# Actions:
# s3:Get*
# s3:List*

# Pegar as policies
aws s3api get-bucket-policy --bucket eec-aws-br-do-positivo-silver-dev-bucket --profile dodev
# {
#     "Policy": "{\"Version\":\"2012-10-17\",\"Id\":\"ProductionPermission\",\"Statement\":[{\"Sid\":\"ProductionPermission\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::822130695371:role/BURoleForEMREC2DefaultRole\"},\"Action\":\"s3:*\",\"Resource\":[\"arn:aws:s3:::eec-aws-br-do-positivo-silver-dev-bucket\",\"arn:aws:s3:::eec-aws-br-do-positivo-silver-dev-bucket/*\"]},{\"Sid\":\"Datamasque bucket policy\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::484240119361:role/BuRoleForDatamasqueUAT\"},\"Action\":[\"s3:ListBucket*\",\"s3:GetBucketAcl\",\"s3:GetBucketPolicyStatus\",\"s3:GetBucketAcl\",\"s3:GetBucketPublicAccessBlock\",\"s3:GetBucketObjectLockConfiguration\",\"s3:PutObject\",\"s3:GetObject\",\"s3:GetEncryptionConfiguration\",\"s3:DeleteObject\"],\"Resource\":[\"arn:aws:s3:::eec-aws-br-do-positivo-silver-dev-bucket\",\"arn:aws:s3:::eec-aws-br-do-positivo-silver-dev-bucket/*\"]},{\"Sid\":\"AllowSSLRequestsOnly\",\"Effect\":\"Deny\",\"Principal\":\"*\",\"Action\":\"s3:*\",\"Resource\":[\"arn:aws:s3:::eec-aws-br-do-positivo-silver-dev-bucket\",\"arn:aws:s3:::eec-aws-br-do-positivo-silver-dev-bucket/*\"],\"Condition\":{\"Bool\":{\"aws:SecureTransport\":\"false\"}}}]}"
# }

# Pegar a ARN da Role BURoleForPositivoMercantil na conta datahub-dev
aws iam get-role --role-name BURoleForPositivoMercantil --profile datahubdev --query Role.Arn
# "arn:aws:iam::730335661246:role/BURoleForPositivoMercantil"

# Incluir o statement nas buckets policies:
<#
        {
            "Sid": "Acesso para a conta de Mercantil",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::730335661246:role/BURoleForPositivoMercantil"
            },
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::eec-aws-br-do-positivo-silver-dev-bucket",
                "arn:aws:s3:::eec-aws-br-do-positivo-silver-dev-bucket/ifs/Cadastral/processados/*"
            ]
        }
#>

# Verificar necessidade de criação de policy do KMS
aws s3api get-bucket-encryption --bucket eec-aws-br-do-positivo-silver-dev-bucket --profile dodev
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

************* Nesse caso é necessário configurar a policy de KMS para essa chave
#>

# Obter a policy da chave KMS existente
aws kms get-key-policy `
    --key-id arn:aws:kms:sa-east-1:916546429908:key/cde4fd62-16ef-4fa5-952b-cc91193bfe62 `
    --policy-name default `
    --profile dodev

# Ao abrir a policy da chave veifiquei que a Role já tinha acesso de leitura da chave, então não foi necessária nenhuma configuração

# Checar também o versioning e o payer
aws s3api get-bucket-versioning --bucket eec-aws-br-do-positivo-silver-dev-bucket --profile dodev
aws s3api get-bucket-request-payment --bucket eec-aws-br-do-positivo-silver-dev-bucket --profile dodev
# BucketOwner

# Agora é alterar a policy no Repositório e aplicar a mudança na esteira do Atlantis para cada bucket
aws s3api put-bucket-policy  --bucket eec-aws-br-do-positivo-silver-dev-bucket --profile dodev --policy file://eec-aws-br-do-positivo-silver-dev-bucket.json
