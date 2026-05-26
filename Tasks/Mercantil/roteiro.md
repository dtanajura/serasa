# Conta:
# APP-eec-aws#146737708860#BURoleForMercantil
Account: eec-aws-br-ds-dataservices-stage (146737708860)
# APP-eec-aws#530914589075#BURoleForMercantil
Account: eec-aws-br-ds-dataservices-dev (530914589075)
# APP-eec-aws#662860092544#BURoleForMercantil
Account: eec-aws-br-ds-dataservices-prod (662860092544)
# Role 
aws iam get-role \
  --role-name BURoleForMercantil \
  --profile dataservicesprod
# Obter policies
echo "Attached policies:" && \
aws iam list-attached-role-policies \
  --role-name BURoleForMercantil \
  --profile dataservicesprod

echo "Inline policies:" && \
aws iam list-role-policies \
  --role-name BURoleForMercantil \
  --profile dataservicesprod
# O Json da policy arn:aws:iam::662860092544:policy/BUPolicyforMercantil
# qual a versão corrente
aws iam get-policy \
  --policy-arn arn:aws:iam::662860092544:policy/BUPolicyforMercantil \
  --profile dataservicesprod

# permissões da policy
aws iam get-policy-version \
  --policy-arn arn:aws:iam::662860092544:policy/BUPolicyforMercantil \
  --version-id v1 \
  --profile dataservicesprod \
  --query "PolicyVersion.Document"  

  