# Crie a role:
aws iam create-role --role-name BURoleForMesaOptin --assume-role-policy-document file://trust.json --profile positivoprod
# Anexe a política inline à role:
aws iam put-role-policy --role-name BURoleForMesaOptin --policy-name InlinePolicy --policy-document file://inline_policy.json --profile positivoprod
# Anexe a política gerenciada à role:
aws iam attach-role-policy --role-name BURoleForAWSBackup --policy-arn arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup --profile corporateprod
# Verifique se as políticas foram anexadas corretamente:
aws iam list-attached-role-policies --role-name BURoleForAWSBackup --profile corporateprod
# Verifique a política inline:
aws iam get-role-policy --role-name BURoleForAWSBackup --policy-name InlinePolicy --profile corporateprod
aws iam create-open-id-connect-provider --url https://oidc.eks.sa-east-1.amazonaws.com/id/B9414B05E6ACE60A23B746C0BFAFC46F --client-id-list sts.amazonaws.com --thumbprint-list 06b25927c42a721631c1efd9431e648fa62e1e39 --profile positivoprod


aws iam update-assume-role-policy --role-name BURoleForMesaOptin --policy-document file://trust2.json --profile positivoprod

aws eks describe-cluster --name ds-eks-01-prod --query "cluster.identity.oidc.issuer" --output text --profile positivoprod

# atualizar trust da role
aws iam update-assume-role-policy --role-name BURoleForMesaOptin --policy-document file://trust2.json --profile positivoprod --no-verify-ssl
