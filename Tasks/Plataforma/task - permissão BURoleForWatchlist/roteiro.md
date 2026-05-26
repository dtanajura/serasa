# Conta eec-aws-br-eits-datahub-dev (730335661246)
# Role 
aws iam get-role \
  --role-name BURoleForWatchlist \
  --profile datahubdev

# Obter policies
echo "Attached policies:" && \
aws iam list-attached-role-policies \
  --role-name BURoleForWatchlist \
  --profile datahubdev

echo "Inline policies:" && \
aws iam list-role-policies \
  --role-name BURoleForWatchlist \
  --profile datahubdev

# O Json da policy arn:aws:iam::730335661246:policy/BUPolicyForWatchlist
# qual a versão corrente
aws iam get-policy \
  --policy-arn arn:aws:iam::730335661246:policy/BUPolicyForWatchlist \
  --profile datahubdev

# permissões da policy
aws iam get-policy-version \
  --policy-arn arn:aws:iam::730335661246:policy/BUPolicyForWatchlist \
  --version-id v1 \
  --profile datahubdev \
  --query "PolicyVersion.Document"  