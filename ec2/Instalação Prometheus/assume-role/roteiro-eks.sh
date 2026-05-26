# Conta origem (conta que tem o serviço do Prometheus)
# Autenticação na conta:
saml2aws.exe login -a eec-aws-br-nike-corporate-prod
$profile_origem = "corporateprod"

# Listar cluster EKS
aws eks list-clusters --profile $profile_origem
$cluster_name = "eks-nike-tech-01-prod"
aws eks describe-cluster --name $cluster_name --profile $profile_origem --query "cluster.roleArn"
# "arn:aws:iam::564593125549:role/BURoleForEksCeks-nike-tech-01-prod-20221014204028885500000004"

# Criar policy para a ROLE na conta de origem
$policy_arn = aws iam create-policy --policy-name BUPolicyForObservabilidade --policy-document file://policy-conta-origem.json --profile $profile_origem --query "Policy.Arn" --output text

# Atachar a policy na role do EKS
aws iam attach-role-policy  --role-name BURoleForEksCeks-nike-tech-01-prod-20221014204028885500000004  --policy-arn $policy_arn --profile $profile_origem

# Verificar policies atachadas
aws iam list-attached-role-policies --role-name BURoleForEksCeks-nike-tech-01-prod-20221014204028885500000004 --profile $profile_origem


# Contas de destino
$profiles = @(
    "arcsandbox",
    "ssrmprod",
    "dsstage",
    "dsprod",
    "dsdev",
    "datahubprod"
)
# Exclusão das roles existentes
$roleName="BURoleForObservabilidadeDestino"
foreach ($profileAws in $profiles) {
    Write-Host "Excluindo Role: $roleName"
    Write-Host "************************"
    Write-Host "aws iam list-attached-role-policies --role-name $roleName --profile $profileAws"
    $policies = aws iam list-attached-role-policies --role-name $roleName --profile $profileAws | ConvertFrom-Json
    foreach ($policy in $policies.AttachedPolicies) {
        Write-Host "Desassociando política $($policy.PolicyArn)"
        Write-Host "aws iam detach-role-policy --role-name $roleName --policy-arn $($policy.PolicyArn) --profile $profileAws"
        aws iam detach-role-policy --role-name $roleName --policy-arn $($policy.PolicyArn) --profile $profileAws
        Write-Host "aws iam delete-policy --policy-arn $($policy.PolicyArn) --profile $profileAws"
        aws iam delete-policy --policy-arn $($policy.PolicyArn) --profile $profileAws
        }
    Write-Host "aws iam list-role-policies --role-name $roleName --profile $profileaws --query \"PolicyNames\" --output text"
    $inlinePolicy= aws iam list-role-policies --role-name $roleName --profile $profileaws --query "PolicyNames" --output text
    Write-Host "aws iam delete-role-policy --role-name $roleName --policy-name $inlinePolicy --profile $profileAws"
    aws iam delete-role-policy --role-name $roleName --policy-name $inlinePolicy --profile $profileAws

    # Excluir a IAM Role
    Write-Host "aws iam delete-role --role-name $roleName --profile $profileAws"
    aws iam delete-role --role-name $roleName --profile $profileAws
}

        # "AWS": "arn:aws:iam::564593125549:role/BURoleForEksCeks-nike-tech-01-prod-20221014204028885500000004",

# Criar novas policies
foreach ($profile_destino in $profiles) {

# Crie a role na conta de destino com essa política de trust.
aws iam create-role --role-name BURoleForObservabilidadeDestino --assume-role-policy-document file://trust-conta-destino.json --profile $profile_destino

# Criar policy para a ROLE na conta de destino
$policy_arn = aws iam create-policy --policy-name BUPolicyForObservabilidade --policy-document file://policy-conta-destino.json --profile $profile_destino --query "Policy.Arn" --output text
$policy_arn = aws iam list-policies --query "Policies[?PolicyName=='BUPolicyForObservabilidade'].Arn" --profile $profile_destino --output text
# Atachar a policy na role do EKS
aws iam attach-role-policy  --role-name BURoleForObservabilidadeDestino  --policy-arn $policy_arn --profile $profile_destino

# Verificar policies atachadas
aws iam list-attached-role-policies --role-name BURoleForObservabilidadeDestino  --profile $profile_destino

}

# No Kubernetes
# Pegar contexto do cluster
aws eks update-kubeconfig --name $cluster_name  --profile $profile_origem

# Listar o pod do PROMETHEUS
k get pods -n monitoring-system

# Acessar o shell do pod do PROMETHEUS
k exec -n monitoring-system -it prometheus-kube-prometheus-stack-prometheus-0 -- sh

# Listar as roles nas contas de destino
$profiles = @(
    "arcsandbox",
    "ssrmprod",
    "dsstage",
    "dsprod",
    "dsdev",
    "datahubprod"
)
$roleName="BURoleForObservabilidadeDestino"
foreach ($profileAws in $profiles) {
    Write-Host $profileAws
    aws iam get-role --role-name $roleName --profile $profileAws --query "Role.Arn"
}

arcsandbox
"arn:aws:iam::187739130313:role/BURoleForObservabilidadeDestino"

ssrmprod
"arn:aws:iam::877001948254:role/BURoleForObservabilidadeDestino"

dsstage
"arn:aws:iam::146737708860:role/BURoleForObservabilidadeDestino"

dsprod
"arn:aws:iam::662860092544:role/BURoleForObservabilidadeDestino"

dsdev
"arn:aws:iam::530914589075:role/BURoleForObservabilidadeDestino"

datahubprod
"arn:aws:iam::415071355886:role/BURoleForObservabilidadeDestino"


aws iam list-roles --query 'Roles[?RoleName==`AWSServiceRoleForBackup`].Arn' --output text --profile devexperience-uat  --no-verify-ssl


#############################
# Novo roteiro
#############################
# Origem
aws eks list-clusters --profile $profile_origem
$cluster_name = "eks-nike-tech-01-prod"
aws eks update-kubeconfig --name $cluster_name --profile $profile_origem

aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text --profile $profile_origem
# Atualizar o oidc issuer com "oidc.eks.sa-east-1.amazonaws.com/id/AF67F2E13B5143963F12C5C2F09F0C1F", namespace e nome do serviceaccount
# Para atualizar a Trust policy de uma role
aws iam update-assume-role-policy --role-name BURoleForObservabilidadeOrigem --policy-document file://trust-conta-origem.json  --profile $profile_origem
# Para buscar o conteudo de uma role com o nome
$role_arn = aws iam list-roles --query "Roles[?RoleName=='BURoleForObservabilidadeOrigem'].Arn" --profile corporateprod --output text

# Destino
# Atualizar o arquivo do trust-conta-destino com a ARN da role de Observabilidade da Origem
$profiles = @(
    "arcsandbox",
    "ssrmprod",
    "dsstage",
    "dsprod",
    "dsdev",
    "datahubprod"
)
# Exclusão das roles existentes
$roleName="BURoleForObservabilidadeDestino"
foreach ($profileAws in $profiles) {
    Write-Host $profileAws
#    aws iam update-assume-role-policy --profile $profileAws --role-name $roleName --policy-document file://trust-conta-destino.json
    aws iam list-roles --query "Roles[?RoleName==$roleName].AssumeRolePolicyDocument" --profile $profileAws
}

# Vou criar um container para testar as permissões de assume role
k run -n monitoring-system teste --image=nginx

# Editar o Service Account para incluir a Role
k edit ServiceAccount kube-prometheus-stack-grafana -n monitoring-system

Incluir nos Annotations:
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::564593125549:role/BURoleForObservabilidadeOrigem

k exec -it -n monitoring-system teste -- bash
 apt-get update
 apt-get install awscli
 aws configure set cli_pager ""
 aws sts get-caller-identity


###################################
# Precisei criar o OIDC Provider

aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text --profile $profile_origem
    https://oidc.eks.sa-east-1.amazonaws.com/id/AF67F2E13B5143963F12C5C2F09F0C1F

aws iam list-open-id-connect-providers --profile $profile_origem
    {
        "OpenIDConnectProviderList": [
            {
                "Arn": "arn:aws:iam::564593125549:oidc-provider/rh-oidc.s3.us-east-1.amazonaws.com/22ejnvnnturfmt6km08idd0nt4hekbn7"
            }
        ]
    }


# Criar o OIDC Provider
eksctl utils associate-iam-oidc-provider --region=sa-east-1 --cluster=$cluster_name --approve --profile $profile_origem
PS â€¦\Instalação Prometheus\assume-role> aws iam list-open-id-connect-providers --profile $profile_origem
{
    "OpenIDConnectProviderList": [
        {
            "Arn": "arn:aws:iam::564593125549:oidc-provider/oidc.eks.sa-east-1.amazonaws.com/id/AF67F2E13B5143963F12C5C2F09F0C1F"
        },
        {
            "Arn": "arn:aws:iam::564593125549:oidc-provider/rh-oidc.s3.us-east-1.amazonaws.com/22ejnvnnturfmt6km08idd0nt4hekbn7"
        }
    ]
}

aww iam update-policy --policy-arn arn:aws:iam::564593125549:policy/BUPolicyForObservabilidade --policy-document file://policy-conta-origem.json --profile $profile_origem 
aws iam detach-role-policy --role-name BURoleForObservabilidadeOrigem --policy-arn arn:aws:iam::564593125549:policy/BUPolicyForObservabilidadeOrigem --profile $profile_origem
aws iam delete-policy --policy-arn arn:aws:iam::564593125549:policy/BUPolicyForObservabilidadeOrigem --profile $profile_origem
aws iam delete-policy --policy-arn arn:aws:iam::564593125549:policy/BUPolicyForObservabilidade --profile $profile_origem
aws iam list-entities-for-policy --policy-arn arn:aws:iam::564593125549:policy/BUPolicyForObservabilidade --profile $profile_origem
aws iam detach-role-policy --role-name BURoleForEksCeks-nike-tech-01-prod-20221014204028885500000004 --policy-arn arn:aws:iam::564593125549:policy/BUPolicyForObservabilidade --profile $profile_origem
aws iam delete-policy --policy-arn arn:aws:iam::564593125549:policy/BUPolicyForObservabilidade --profile $profile_origem
$policy_arn = aws iam create-policy --policy-name BUPolicyForObservabilidadeOrigem --policy-document file://policy-conta-origem.json --profile $profile_origem --query "Policy.Arn" --output text
aws iam attach-role-policy --role-name BURoleForObservabilidadeOrigem --policy-arn $policy_arn --profile $profile_origem
aws iam delete-role --role-name BURoleForObservabilidadeOrigem --profile $profile_origem
aws iam create-role --role-name BURoleForObservabilidadeOrigem --assume-role-policy-document file://trust-conta-origem.json --profile $profile_origem
aws iam attach-role-policy --role-name BURoleForObservabilidadeOrigem --policy-arn $policy_arn --profile $profile_origem


$profiles = @(
    "arcsandbox",
    "ssrmprod",
    "dsstage",
    "dsprod",
    "dsdev",
    "datahubprod"
)
$roleName="BURoleForObservabilidadeDestino"
foreach ($profileAws in $profiles) {
    Write-Host $profileAws
    aws iam update-assume-role-policy --role-name BURoleForObservabilidadeDestino --policy-document file://trust-conta-destino.json  --profile $profileAws
}

aws sts assume-role --role-arn arn:aws:iam::530914589075:role/BURoleForObservabilidadeDestino --role-session-name dsdev

aws iam detach-role-policy --role-name BURoleForObservabilidadeOrigem --policy-arn arn:aws:iam::564593125549:policy/BUPolicyForObservabilidadeOrigem --profile $profile_origem
aws iam delete-policy --policy-arn arn:aws:iam::564593125549:policy/BUPolicyForObservabilidadeOrigem --profile $profile_origem
$policy_arn = aws iam create-policy --policy-name BUPolicyForObservabilidadeOrigem --policy-document file://policy-conta-origem.json --profile $profile_origem --query "Policy.Arn" --output text
aws iam attach-role-policy --role-name BURoleForObservabilidadeOrigem --policy-arn $policy_arn --profile $profile_origem
