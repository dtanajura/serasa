## Account: eec-aws-br-nike-ss-sandbox (087086536124)
cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\permissões para deployments"
saml2aws.exe login -a eec-aws-br-nike-ss-sandbox
$profile_aws = "nike-ss-sandbox"

# Listar os clusters EKS
$cluster_name=aws eks list-clusters --profile $profile_aws --output text --query "clusters"
# CLUSTERS        ssrm-eks-01-sandbox


aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text --profile $profile_aws 

# Criar uma role para as aplicações baseada na BURoleForAssumeRoleEKS
aws iam create-role --role-name BURoleForAppsEKS --assume-role-policy-document file://trust.json --profile $profile_aws

aws iam attach-role-policy --role-name BURoleForAppsEKS --policy-arn arn:aws:iam::087086536124:policy/BUPolicyForAppsNike --profile $profile_aws

# pegar o contexto do Cluster para o Kubectl
aws eks update-kubeconfig --region sa-east-1 --name $cluster_name --profile $profile_aws

# Criar os Service Accounts
kubectl create -f service-account-chronos-dev.yaml
kubectl create -f service-account-ssbl-dev.yaml
kubectl create -f service-account-ssbl-qa.yaml

kubectl get deploy -n chronos-dev

kubectl delete -f service-account-chronos-dev.yaml
kubectl delete -f service-account-ssbl-dev.yaml
kubectl delete -f service-account-ssbl-qa.yaml
