cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\_outras tarefas\demo permissões eks"
saml2aws.exe login -a eec-aws-br-nike-architecture-sandbox
saml2aws.exe console -a eec-aws-br-nike-architecture-sandbox
$profile_aws = "arcsandbox"

aws eks list-clusters --profile $profile_aws
 
aws eks update-kubeconfig --region sa-east-1 --name nike-tech-dev --profile $profile_aws
aws eks describe-cluster --name nike-tech-dev --query "cluster.identity.oidc.issuer" --output text --profile $profile_aws


# Criar uma role para as aplicações baseada na BURoleForAssumeRoleEKS
aws iam create-role --role-name BURoleForAppsEKS-teste --assume-role-policy-document file://trust.json --profile $profile_aws
$policy_arn = aws iam create-policy --policy-name BUPolicyForAppsEks-teste --policy-document file://policy.json --profile $profile_aws --query "Policy.Arn" --output text
aws iam attach-role-policy  --role-name BURoleForAppsEKS-teste  --policy-arn $policy_arn --profile $profile_aws


# comandos kubectl
kubectl create -f .\deploy.yaml
kubectl get pods -n teste
kubectl exec -it nginx-deployment-7c79c4bf97-4j9rg -n teste -- bash

# No Pod
cat /etc/os-release
apt-get update
apt-get upgrade -y
apt-get install awscli -y
aws --version
aws configure set cli_pager ""
aws sts get-caller-identity

# Alterar o ServiceAccount
kubectl get ServiceAccount -n teste

kubectl edit ServiceAccount my-service-account -n teste

metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::187739130313:role/BURoleForAppsEKS-teste

kubectl rollout restart deployment nginx-deployment -n teste

# Removendo elementos do Kubernetes
kubectl delete -f .\deploy.yaml

# Apagando as configurações do IAM
aws iam detach-role-policy --role-name BURoleForAppsEKS-teste --policy-arn $policy_arn --profile $profile_aws
aws iam delete-policy --policy-arn $policy_arn --profile $profile_aws
aws iam delete-role --role-name BURoleForAppsEKS-teste --profile $profile_aws


