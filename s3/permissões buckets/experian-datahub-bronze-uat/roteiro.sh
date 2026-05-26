# Configurar permissões nos buckets na conta de stage (146737708860 - eec-aws-br-ds-dataservices-stage):
# experian-datahub-bronze-uat
# experian-datahub-silver-uat
# experian-datahub-negativos-silver-uat
# experian-datahub-gold-reports-uat
 
# Actions:
# s3:Get
# s3:List
# s3:GetObjectAcl
# s3:GetObject
# s3:ListBucket

# Pegar as policies
aws s3api get-bucket-policy --bucket experian-datahub-bronze-uat --profile dsstage

# Pegar a ARN da Role BURoleForNegativos na conta negativodev
aws iam get-role --role-name BURoleForNegativos --profile negativodev --query Role.Arn
# "arn:aws:iam::300374333803:role/BURoleForNegativos"

# Incluir o statement nas buckets policies:
<#
        {
            "Sid": "Acesso para a conta de Negativos Privados",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::300374333803:role/BURoleForNegativos"
            },
            "Action": [
                "s3:Get",
                "s3:List",
                "s3:GetObjectAcl",
                "s3:GetObject",
                "s3:ListBucket"            
            ],
            "Resource": [
                "arn:aws:s3:::nome-bucket/*",
                "arn:aws:s3:::nome-bucket"
            ]
        }
#>

# Verificar necessidade de criação de policy do KMS
aws s3api get-bucket-encryption --bucket experian-datahub-bronze-uat --profile dsstage
<#
Nesse caso não é necessário pois estamos usando uma SSE-S3 - "SSEAlgorithm": "AES256"
{
    "ServerSideEncryptionConfiguration": {
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                },
                "BucketKeyEnabled": true
            }
        ]
    }
}
#>

aws s3api get-bucket-encryption --bucket experian-datahub-silver-uat --profile dsstage
aws s3api get-bucket-encryption --bucket experian-datahub-negativos-silver-uat --profile dsstage
aws s3api get-bucket-encryption --bucket experian-datahub-gold-reports-uat --profile dsstage


# Agora é alterar a policy no Repositório e aplicar a mudança na esteira do Atlantis para cada bucket

# Checar também o versioning e o payer
aws s3api get-bucket-versioning --bucket experian-datahub-bronze-uat --profile dsstage
aws s3api get-bucket-request-payment --bucket experian-datahub-bronze-uat --profile dsstage

aws s3api get-bucket-versioning --bucket experian-datahub-silver-uat --profile dsstage
aws s3api get-bucket-request-payment --bucket experian-datahub-silver-uat --profile dsstage

aws s3api get-bucket-versioning --bucket experian-datahub-negativos-silver-uat --profile dsstage
aws s3api get-bucket-request-payment --bucket experian-datahub-negativos-silver-uat --profile dsstage

aws s3api get-bucket-versioning --bucket experian-datahub-gold-reports-uat --profile dsstage
aws s3api get-bucket-request-payment --bucket experian-datahub-gold-reports-uat --profile dsstage

# Recuperação do bucket experian-datahub-silver-uat
aws s3api get-bucket-versioning --bucket experian-datahub-silver-uat --profile dsstage
# {
#     "Status": "Suspended"
# }

aws s3api put-bucket-versioning --bucket experian-datahub-silver-uat  --versioning-configuration Status=Enabled --profile dsstage
aws s3api get-bucket-versioning --bucket experian-datahub-silver-uat --profile dsstage
# {
#     "Status": "Enabled"
# }

aws s3api get-bucket-logging --bucket experian-datahub-silver-uat --profile dsstage
aws s3api put-bucket-logging --bucket experian-datahub-silver-uat --bucket-logging-status file://logging.json --profile dsstage
aws s3api get-bucket-logging --bucket experian-datahub-silver-uat --profile dsstage
# {
#     "LoggingEnabled": {
#         "TargetBucket": "aws-logs-146737708860-sa-east-1",
#         "TargetPrefix": "experian-datahub-silver-uat"
#     }
# }

aws s3api get-bucket-encryption --bucket experian-datahub-silver-uat --profile dsstage
# {
#     "ServerSideEncryptionConfiguration": {
#         "Rules": [
#             {
#                 "ApplyServerSideEncryptionByDefault": {
#                     "SSEAlgorithm": "AES256"
#                 },
#                 "BucketKeyEnabled": false
#             }
#         ]
#     }
# }

aws s3api put-bucket-encryption --bucket experian-datahub-silver-uat --server-side-encryption-configuration file://encryption.json --profile dsstage
aws s3api get-bucket-encryption --bucket experian-datahub-silver-uat --profile dsstage
# {
#     "ServerSideEncryptionConfiguration": {
#         "Rules": [
#             {
#                 "ApplyServerSideEncryptionByDefault": {
#                     "SSEAlgorithm": "AES256"
#                 },
#                 "BucketKeyEnabled": true
#             }
#         ]
#     }
# }

aws s3api get-bucket-request-payment --bucket experian-datahub-silver-uat --profile dsstage
# {
#     "Payer": "BucketOwner"
# }

aws s3api get-public-access-block --bucket experian-datahub-silver-uat --profile dsstage
# An error occurred (NoSuchPublicAccessBlockConfiguration) when calling the GetPublicAccessBlock operation: The public access block configuration was not found

# Verifiquei a configuração no bucket experian-datahub-bronze-uat 
aws s3api get-public-access-block --bucket experian-datahub-bronze-uat --profile dsstage
# {
#     "PublicAccessBlockConfiguration": {
#         "BlockPublicAcls": true,
#         "IgnorePublicAcls": true,
#         "BlockPublicPolicy": true,
#         "RestrictPublicBuckets": true
#     }
# }

aws s3api put-public-access-block --bucket experian-datahub-silver-uat --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true --profile dsstage

aws s3api get-public-access-block --bucket experian-datahub-silver-uat --profile dsstage
# {
#     "PublicAccessBlockConfiguration": {
#         "BlockPublicAcls": true,
#         "IgnorePublicAcls": true,
#         "BlockPublicPolicy": true,
#         "RestrictPublicBuckets": true
#     }
# }

aws s3api put-bucket-policy --bucket experian-datahub-silver-uat --policy file://experian-datahub-silver-uat.json --profile dsstage

aws s3api get-bucket-ownership-controls --bucket experian-datahub-silver-uat --profile dsstage
aws s3api put-bucket-ownership-controls --bucket experian-datahub-silver-uat --ownership-controls file://ownership.json --profile dsstage
aws s3api get-bucket-ownership-controls --bucket experian-datahub-bronze-uat --profile dsstage
# {
#     "OwnershipControls": {
#         "Rules": [
#             {
#                 "ObjectOwnership": "BucketOwnerEnforced"
#             }
#         ]
#     }
# }

### Acho que o ACL está igual - não vou mexer!!
aws s3api get-bucket-acl --bucket experian-datahub-silver-uat --profile dsstage
# {
#     "Owner": {
#         "ID": "aa42fc45501a8720e7adf0c2548a0114e6abd7d51e4a41d0461195d01298a259"
#     },
#     "Grants": [
#         {
#             "Grantee": {
#                 "ID": "aa42fc45501a8720e7adf0c2548a0114e6abd7d51e4a41d0461195d01298a259",
#                 "Type": "CanonicalUser"
#             },
#             "Permission": "FULL_CONTROL"
#         }
#     ]
# }

aws s3api get-bucket-acl --bucket experian-datahub-bronze-uat --profile dsstage
# {
#     "Owner": {
#         "DisplayName": "eec-aws-br-ds-dataservices-stage-G6UI87h9nj",
#         "ID": "aa42fc45501a8720e7adf0c2548a0114e6abd7d51e4a41d0461195d01298a259"
#     },
#     "Grants": [
#         {
#             "Grantee": {
#                 "DisplayName": "eec-aws-br-ds-dataservices-stage-G6UI87h9nj",
#                 "ID": "aa42fc45501a8720e7adf0c2548a0114e6abd7d51e4a41d0461195d01298a259",
#                 "Type": "CanonicalUser"
#             },
#             "Permission": "FULL_CONTROL"
#         }
#     ]
# }


aws s3api list-bucket-inventory-configurations --bucket experian-datahub-silver-uat --profile dsstage

aws s3api list-bucket-inventory-configurations --bucket experian-datahub-bronze-uat --profile dsstage
