# Configuração da ROLE BURoleForNegativos para acesso ao Workspace do EMR Studio
$profile_aws="negativodev"
$rolename="BURoleForNegativos"

aws iam get-role --role-name $rolename --profile $profile_aws 

Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\emr studio\Acesso NegativoDEV"
aws iam update-assume-role-policy --role-name $rolename --policy-document file://trust.json --profile $profile_aws

# Criei a politica BUPolicyForEMRServeless via automação

aws iam attach-role-policy `
  --role-name $rolename  `
  --policy-arn "arn:aws:iam::300374333803:policy/BUPolicyForEMRServeless" `
  --profile $profile_aws
