aws iam list-policies \
  --scope Local \
  --query "Policies[?PolicyName=='BUPolicyForDevSecOpsPiaaS'].Arn" \
  --output text \
  --profile nikedataserviceuat

aws iam list-policy-versions \
  --policy-arn arn:aws:iam::713881783816:policy/BUPolicyForDevSecOpsPiaaS \
  --profile nikedataserviceuat

aws iam delete-policy-version \
  --policy-arn arn:aws:iam::713881783816:policy/BUPolicyForDevSecOpsPiaaS \
  --version-id v3 \
  --profile nikedataserviceuat

aws iam create-policy-version \
  --policy-arn arn:aws:iam::713881783816:policy/BUPolicyForDevSecOpsPiaaS \
  --policy-document file://policy.json \
  --set-as-default \
  --profile nikedataserviceuat