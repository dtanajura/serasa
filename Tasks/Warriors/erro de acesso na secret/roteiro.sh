# Durante a integração do Spark com o cluster MSK usando autenticação SASL/SCRAM, o processo de leitura das credenciais armazenadas no AWS Secrets Manager falhava com o erro:
# AccessDeniedException: Access to KMS is not allowed
# Após investigação, identifiquei que:
# O Secret utilizado para autenticação no MSK
# arn:aws:secretsmanager:sa-east-1:146737708860:secret:AmazonMSK_user-ds-msk-uat-WGpctQ
# é criptografado pela KMS Key
# arn:aws:kms:sa-east-1:146737708860:key/db2ce4ff-275d-46c4-bd13-4af654a6dd51.

# A role utilizada pelo job Spark
# arn:aws:iam::146737708860:role/BURoleForMSKWarriors
# possuía permissão no Secrets Manager, mas não estava autorizada na policy da KMS Key, impossibilitando a descriptografia do secret — requisito obrigatório do serviço.

aws secretsmanager describe-secret \
#   --secret-id arn:aws:secretsmanager:sa-east-1:146737708860:secret:AmazonMSK_user-ds-msk-uat-WGpctQ \
#   --region sa-east-1 \
#   --query KmsKeyId \
#   --output text --profile dataservicesstage
# arn:aws:kms:sa-east-1:146737708860:key/db2ce4ff-275d-46c4-bd13-4af654a6dd51

aws kms get-key-policy \
  --key-id arn:aws:kms:sa-east-1:146737708860:key/db2ce4ff-275d-46c4-bd13-4af654a6dd51 \
  --policy-name default \
  --region sa-east-1 \
  --output json \
  --profile dataservicesstage

# {
#     "Policy": "{\n  \"Version\" : \"2012-10-17\",\n  \"Id\" : \"key-consolepolicy-3\",\n  \"Statement\" : [ {\n    \"Sid\" : \"Enable IAM User Permissions\",\n    \"Effect\" : \"Allow\",\n    \"Principal\" : {\n      \"AWS\" : \"arn:aws:iam::146737708860:root\"\n    },\n    \"Action\" : \"kms:*\",\n    \"Resource\" : \"*\"\n  } ]\n}",
#     "PolicyName": "default"
# }

aws kms put-key-policy \
  --key-id arn:aws:kms:sa-east-1:146737708860:key/db2ce4ff-275d-46c4-bd13-4af654a6dd51 \
  --policy-name default \
  --policy file://policy.json \
  --region sa-east-1 \
  --profile dataservicesstage