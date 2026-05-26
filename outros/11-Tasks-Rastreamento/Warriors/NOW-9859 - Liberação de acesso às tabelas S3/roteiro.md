Solicito a liberação de acesso às tabelas armazenadas no S3 (policy de acesso) para utilização nas contas de desenvolvimento do time de dados, conforme detalhes abaixo.

# Tabelas a serem liberadas
s3://experian-datahub-passagem-gold-reports-uat/warehouse/reports/passagem_resumo_pf
s3://experian-datahub-passagem-gold-reports-uat/warehouse/reports/passagem_resumo_pj
s3://experian-datahub-passagem-gold-reports-uat/warehouse/reports/passagem_detalhe_pj
s3://experian-datahub-passagem-gold-reports-uat/warehouse/reports/passagem_detalhe_pf
s3://experian-datahub-cadastrais-bronze-uat/warehouse/replicacao/rx_mensagens_doctoconta

# Role na conta consumidora
BURoleForEmrEc2Nike

# Contas
# Conta de DEV do time Warriors (consumidora):
eec-aws-br-eits-nikedataservice-dev (050752636274)
# Conta de AUT/Dados com Farinha (fornecedora):
eec-aws-br-ds-dataservices-stage (146737708860)

# Levantamento da Role
aws iam get-role \
  --role-name BURoleForEmrEc2Nike \
  --profile nikedataservicedev

# Obter policies
echo "Attached policies:" && \
aws iam list-attached-role-policies \
  --role-name BURoleForEmrEc2Nike \
  --profile nikedataservicedev

echo "Inline policies:" && \
aws iam list-role-policies \
  --role-name BURoleForEmrEc2Nike \
  --profile nikedataservicedev

# O Json da policy arn:aws:iam::050752636274:policy/BUPolicyForEMREC2Nike
# qual a versão corrente
aws iam get-policy \
  --policy-arn arn:aws:iam::050752636274:policy/BUPolicyForEMREC2Nike \
  --profile nikedataservicedev

# permissões da policy
aws iam get-policy-version \
  --policy-arn arn:aws:iam::050752636274:policy/BUPolicyForEMREC2Nike \
  --version-id v4 \
  --profile nikedataservicedev \
  --query "PolicyVersion.Document"  

# Buckets
# Obter as policies
aws s3api get-bucket-policy \
  --bucket experian-datahub-passagem-gold-reports-uat \
  --profile dataservicesstage

aws s3api get-bucket-policy \
  --bucket experian-datahub-cadastrais-bronze-uat \
  --profile dataservicesstage

# aplicar as policies
aws s3api put-bucket-policy \
  --bucket experian-datahub-passagem-gold-reports-uat \
  --policy file://experian-datahub-passagem-gold-reports-uat-v2.json \
  --profile dataservicesstage