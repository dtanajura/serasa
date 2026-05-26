####################################
### Logar na conta
.\saml2aws.exe login -a eec-aws-br-eits-devhub-sandbox

####################################
### Listar todos os recursos
aws resourcegroupstaggingapi get-resources --region sa-east-1 --profile devhub-sandbox --no-verify-ssl --query "ResourceTagMappingList[].ResourceARN" --output table > devhub-sandbox-resources.txt


####################################
### Limpar Buckets
aws s3 ls --profile devhub-prod --no-verify-ssl
# Linux
aws s3 ls | cut -d" " -f 3 | xargs -I{} aws s3 rb s3://{} --force
# Powershell
aws s3 ls --profile devhub-sandbox --no-verify-ssl | ForEach-Object { ([string]$_).Split(" ")[2] } | ForEach-Object {aws s3 rb s3://$_ --force --profile devhub-sandbox --no-verify-ssl}

## Caso o bucket esteja versionado - ver a seguinte expressão
aws s3api delete-objects --bucket ${bucket_name} \
  --delete "$(aws s3api list-object-versions \
  --bucket "${bucket_name}" \
  --output=json \
  --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

####################################
### Cluster EKS

aws eks list-clusters  --profile devhub-sandbox --no-verify-ssl --query="clusters[]" --output text
aws eks list-nodegroups --cluster-name "$(aws eks list-clusters  --profile devhub-sandbox --no-verify-ssl --query="clusters[]" --output text)" --profile devhub-sandbox --no-verify-ssl
aws eks delete-nodegroup --nodegroup-name my-nodegroup --cluster-name my-cluster 
