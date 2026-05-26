cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\lens"

$profile_aws = "dsstage"
aws iam list-roles --profile $profile_aws --query "Roles[].RoleName" | Select-String -Pattern "BURoleForDatahub"
$role_name = "BURoleForDatahub"


# Criar uma role para as aplicações baseada na BURoleForAssumeRoleEKS
$policy_arn = aws iam create-policy --policy-name BUPolicyForEKSAcess --policy-document file://BUPolicyForEKSAccess.json --profile $profile_aws --query "Policy.Arn" --output text

# Se a policy já existir na conta
aws iam list-policies --scope Local --profile $profile_aws | Select-String -Pattern "BUPolicyForEKSAcess"
$policy_arn = "arn:aws:iam::662860092544:policy/BUPolicyForEKSAcess"

aws iam attach-role-policy  --role-name $role_name  --policy-arn $policy_arn --profile $profile_aws

aws iam get-role-policy  --role-name $role_name --policy-name BUPolicyForEKSAcess --profile $profile_aws

aws iam update-role --role-name $role_name --max-session-duration 36000 --profile $profile_aws

aws iam update-assume-role-policy --role-name $role_name --policy-document file://trust.json --profile $profile_aws

# Verificar Role via CLI
aws iam get-role  --role-name $role_name --profile $profile_aws
aws iam list-attached-role-policies --role-name $role_name --profile $profile_aws

# pegar contexto do cluster (ver se existe mais de um cluster na conta)
aws eks list-clusters  --profile $profile_aws
# Se tiver só um cluster na conta, podemos usar esse comando
$cluster_name=aws eks list-clusters --profile $profile_aws --output text --query "clusters[1]"
# Caso contrário, precisamos setar na mão
$cluster_name="sales-eks-01-uat"
aws eks update-kubeconfig --name $cluster_name  --profile $profile_aws

# # Criar Cluster Role
kubectl delete -f .\ClusterRoleBinding.yaml
kubectl delete -f .\ClusterRole.yaml

# Criar Cluster Role
kubectl create -f .\ClusterRole.yaml
kubectl create -f .\ClusterRoleBinding.yaml

# Publicar a ROLE no IDC
$ProductViewID=aws servicecatalog search-products --profile $profile_aws --query "ProductViewSummaries[].[Id]" --output text --filter "FullTextSearch=CustomADGroup"
$ProvisioningArtifactsID=aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --query "ProvisioningArtifacts[].Id"
$LaunchPathsID=aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --output text --query LaunchPaths[].Id

# Para listar os parâmetros obrigatórios, usei:
aws servicecatalog describe-provisioning-parameters --product-name CustomADGroup --provisioning-artifact-id $ProvisioningArtifactsID --path-id $LaunchPathsID --profile $profile_aws

aws servicecatalog provision-product  --product-name CustomADGroup  --provisioning-artifact-id $ProvisioningArtifactsID --provisioned-product-name CustomADGroup-$profile_aws  --provisioning-parameters file://provision-parameters-CustomADGroup.json  --profile $profile_aws


eksctl create iamidentitymapping --cluster ds-eks-01-prod --arn arn:aws:iam::662860092544:role/BURoleForDatahub --username devsustain --group devsustain --no-duplicate-arns

# Processo alternativo
k edit configmap aws-auth -n kube-system
- groups:
  - devsustain
  rolearn: arn:aws:iam::662860092544:role/BURoleForDatahub
  username: devsustain

k get configmap aws-auth -n kube-system -o yaml

saml2aws.exe login -a eec-aws-br-nike-sales-prod --role=arn:aws:iam::662860092544:role/BURoleForDatahub --force --session-duration=36000


$profiles = @(
   "corporateprod",
   "arcsandbox",
   "ssrmdev",
   "ssrmsandbox",
   "ssrmprod",
   "corporatedev",
   "sredev",
   "dsstage",
   "dsprod",
   "dsdev",
   "datahubprod",
   "datahubdev",
   "bnsprod",
   "bnsuat",
   "dodev",
   "douat",
   "positivoprod",
   "datainsightprod",
   "nikedatadev",
   "nikedataprod",
   "nikedatauat"
)
foreach ($profile_aws  in $profiles) {
  Write-Host "********************************************"
  $profile_aws
   aws eks list-clusters --profile $profile_aws
}
foreach ($profile_aws  in $profiles) {
  Write-Host "********************************************"
  $profile_aws
  # aws ec2 describe-vpcs --query "Vpcs[].CidrBlockAssociationSet[*].CidrBlock" --profile $profile_aws
#  aws iam list-roles --profile $profile_aws --query "Roles[].RoleName" | Select-String -Pattern "BURoleForDevSustain"
  $clusters=aws eks list-clusters --profile $profile_aws | ConvertFrom-Json
  foreach ($cluster in $clusters.clusters) {
      Write-Host "Cluster: $cluster"
      aws iam list-roles --profile $profile_aws --query "Roles[].RoleName" | Select-String -Pattern "BURoleForDevSustain"
      aws eks update-kubeconfig --name $cluster --profile $profile_aws
      # # Criar Cluster Role
      kubectl delete -f .\ClusterRoleBinding.yaml
      kubectl delete -f .\ClusterRole.yaml

      # Criar Cluster Role
      kubectl create -f .\ClusterRole.yaml
      kubectl create -f .\ClusterRoleBinding.yaml
      k get configmap aws-auth -n kube-system -o yaml | Select-String -Pattern "BURoleForDevSustain" -Context 5,5

  }
}

  $profile_aws = "dsstage"
  # aws ec2 describe-vpcs --query "Vpcs[].CidrBlockAssociationSet[*].CidrBlock" --profile $profile_aws
#  aws iam list-roles --profile $profile_aws --query "Roles[].RoleName" | Select-String -Pattern "BURoleForDevSustain"
  $clusters=aws eks list-clusters --profile $profile_aws | ConvertFrom-Json
  foreach ($cluster in $clusters.clusters) {
      Write-Host "Cluster: $cluster"
      aws iam list-roles --profile $profile_aws --query "Roles[].RoleArn" | Select-String -Pattern "BURoleForDevSustain"
      aws iam get-role --role-name BURoleForDevSustain --profile $profile_aws --query "Role.Arn"
      aws eks update-kubeconfig --name $cluster --profile $profile_aws
      k get configmap aws-auth -n kube-system # -o yaml #| Select-String -Pattern "BURoleForDevSustain"
      k get clusterrole view-restartpod # -o yaml
  }



$profiles = @(
   "dsstage",
   "dsprod",
   "datahubprod",
   "datahubdev",
   "dodev",
   "douat"
)
foreach ($profile_aws  in $profiles) {
  Write-Host "********************************************"
  $profile_aws
  # aws ec2 describe-vpcs --query "Vpcs[].CidrBlockAssociationSet[*].CidrBlock" --profile $profile_aws
#  aws iam list-roles --profile $profile_aws --query "Roles[].RoleName" | Select-String -Pattern "BURoleForDevSustain"
  $clusters=aws eks list-clusters --profile $profile_aws | ConvertFrom-Json
  foreach ($cluster in $clusters.clusters) {
      Write-Host "Cluster: $cluster"
      aws iam list-roles --profile $profile_aws --query "Roles[].RoleName" | Select-String -Pattern "BURoleForDevSustain"
      aws eks update-kubeconfig --name $cluster --profile $profile_aws
      # # Criar Cluster Role
      kubectl delete -f .\ClusterRoleBinding.yaml
      kubectl delete -f .\ClusterRole.yaml

      # Criar Cluster Role
      kubectl create -f .\ClusterRole.yaml
      kubectl create -f .\ClusterRoleBinding.yaml
      k get configmap aws-auth -n kube-system -o yaml | Select-String -Pattern "BURoleForDevSustain" -Context 5,5
  }
}

foreach ($profile_aws  in $profiles) {
  Write-Host "********************************************"
  $profile_aws
  $policies = aws iam list-policies --scope Local --query "Policies[?PolicyName=='BUPolicyForEKSAcess'].Arn" --profile $profile_aws
  $ok = ($policies | ConvertFrom-Json)[0]  
  $policy_arn = $ok
  if ($ok) {
    Write-Host "tem policy $ok"
    } 
  else {
    Write-Host "não tem policy"
    }
  
  $ok = aws iam list-roles --profile $profile_aws --query "Roles[].RoleName" | Select-String -Pattern "BURoleForDevSustain"
  if ($ok) {
    Write-Host "tem role $ok"
    aws iam get-role  --role-name BURoleForDevSustain --profile $profile_aws
    # aws iam attach-role-policy  --role-name BURoleForDevSustain  --policy-arn $policy_arn --profile $profile_aws
    aws iam list-attached-role-policies --role-name BURoleForDevSustain --profile $profile_aws
    # Publicar a ROLE no IDC
    $ProductViewID=aws servicecatalog search-products --profile $profile_aws --query "ProductViewSummaries[].[Id]" --output text --filter "FullTextSearch=CustomADGroup"
    $ProvisioningArtifactsID=aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --query "ProvisioningArtifacts[].Id"
    $LaunchPathsID=aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --output text --query LaunchPaths[].Id

    # Para listar os parâmetros obrigatórios, usei:
    aws servicecatalog describe-provisioning-parameters --product-name CustomADGroup --provisioning-artifact-id $ProvisioningArtifactsID --path-id $LaunchPathsID --profile $profile_aws

    aws servicecatalog provision-product  --product-name CustomADGroup  --provisioning-artifact-id $ProvisioningArtifactsID --provisioned-product-name CustomADGroup-$profile_aws  --provisioning-parameters file://provision-parameters-CustomADGroup.json  --profile $profile_aws

    } 
  else {
    Write-Host "Não tem role"
  }
}



foreach ($profile_aws  in $profiles) {
  Write-Host "********************************************"
  $profile_aws
  $policies = aws iam list-policies --scope Local --query "Policies[?PolicyName=='BUPolicyForEKSAcess'].Arn" --profile $profile_aws
  $ok = ($policies | ConvertFrom-Json)[0]
  if ($ok) {
    Write-Host "tem policy $ok"
    $policy_arn = $ok
    } 
  else {
    Write-Host "não tem policy"
    $policy_arn = aws iam create-policy --policy-name BUPolicyForEKSAcess --policy-document file://BUPolicyForEKSAccess.json --profile $profile_aws --query "Policy.Arn" --output text
    }
  
  $ok = aws iam list-roles --profile $profile_aws --query "Roles[].RoleName" | Select-String -Pattern "BURoleForDevSustain"
  if ($ok) {
    Write-Host "tem role"
    } 
  else {
    Write-Host "Criando função para o perfil $profile"
    # Obter o número da conta AWS
    $accountId = (aws sts get-caller-identity --profile $profile_aws --query "Account" --output text)

    # Ler o conteúdo do arquivo trust.json como texto
    $trustJsonContent = Get-Content -Path "./trust.json" -Raw

    # Substituir o ID da conta existente (877001948254) pelo novo ID
    $updatedTrustJsonContent = $trustJsonContent -replace '877001948254', $accountId

    # Salvar o conteúdo atualizado em um novo arquivo updated_trust.json
    $tempFilePath = "./updated_trust.json"
    $updatedTrustJsonContent | Out-File -FilePath $tempFilePath -Encoding ascii

    # Exibir o conteúdo atualizado para verificação
    Write-Output "Conteúdo do JSON atualizado:"
    Get-Content -Path $tempFilePath

    # Criar a role usando o arquivo JSON atualizado
    aws iam create-role --role-name BURoleForDevSustain --assume-role-policy-document file://updated_trust.json --profile $profile_aws

    # Remover o arquivo temporário
    Remove-Item -Path $tempFilePath
    aws iam attach-role-policy  --role-name BURoleForDevSustain  --policy-arn $policy_arn --profile $profile
  }
}



# Criar Cluster Role
kubectl create -f .\clusterroledevs-2.yaml
kubectl create -f .\ClusterRoleBindingDeveloper.yaml

k edit configmap aws-auth -n kube-system
    - rolearn: arn:aws:iam::146737708860:role/BURoleForNike
      username: developer
      groups:
      - developer

k get configmap aws-auth -n kube-system -o yaml

$profile_aws = "dsprod"
aws iam create-role --role-name BURoleForAccessAppWatchlist --assume-role-policy-document file://trust.json --profile $profile_aws

aws iam update-assume-role-policy --role-name BURoleForAccessAppWatchlist --policy-document file://trust.json --profile $profile_aws

$policy_arn = aws iam create-policy --policy-name BUPolicyForEKSAcess --policy-document file://BUPolicyForEKSAccess.json --profile $profile_aws --query "Policy.Arn" --output text
aws iam list-policies --scope Local --profile $profile_aws | Select-String -Pattern "BUPolicyForEKSAcess"
            # "PolicyName": "BUPolicyForEKSAcess",
            # "Arn": "arn:aws:iam::662860092544:policy/BUPolicyForEKSAcess",
$policy_arn = "arn:aws:iam::662860092544:policy/BUPolicyForEKSAcess"
$role_name = "BURoleForAccessAppWatchlist"

aws iam attach-role-policy  --role-name $role_name  --policy-arn $policy_arn --profile $profile_aws

### Essa ROLE vai ter que ser registrada no IDC para solicitação de acesso
# Primeiro vamos obter o PRODUCT-ID da automação
$productID = aws servicecatalog search-products --profile $profile_aws --query "ProductViewSummaries[].[Id]" --output text --filter "FullTextSearch=CustomADGroup"

# Vamos agora obter o ProvisioningArtifacts Id
$provisioningArtifactsId = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --query "ProvisioningArtifacts[].Id"

# Por último, vamos obter o Path ID
$pathID = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --output text --query LaunchPaths[].Id

# Para listar os parâmetros obrigatórios, usei:
# aws servicecatalog describe-provisioning-parameters --product-name CustomADGroup --provisioning-artifact-id $provisioningArtifactsId --path-id $pathID --profile $profile

# Por fim, executar o produto CustomADGroup
aws servicecatalog provision-product  --product-name CustomADGroup  --provisioning-artifact-id $provisioningArtifactsId --provisioned-product-name CustomADGroup-$profile_aws  --provisioning-parameters file://provision-parameters-CustomADGroup.json  --profile $profile_aws



aws iam list-attached-role-policies --role-name BURoleForAccessAppWatchlist --profile $profile_aws
aws iam detach-role-policy --role-name BURoleForAccessAppWatchlist --policy-arn arn:aws:iam::662860092544:policy/BUPolicyForEKSAcess --profile $profile_aws
aws iam delete-role --role-name BURoleForAccessAppWatchlist --profile $profile_aws

arn:aws:iam::662860092544:role/BURoleForAccessAppWatchlist

kubectl create -f .\ClusterRole-listns.yaml
kubectl create -f .\ClusterRoleBinding-listns.yaml

##############################################################
# Ambiente DEV
$profile_aws = "dsdev"
### Essa ROLE vai ter que ser registrada no IDC para solicitação de acesso
# Primeiro vamos obter o PRODUCT-ID da automação
$productID = aws servicecatalog search-products --profile $profile_aws --query "ProductViewSummaries[].[Id]" --output text --filter "FullTextSearch=CustomADGroup"

# Vamos agora obter o ProvisioningArtifacts Id
$provisioningArtifactsId = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --query "ProvisioningArtifacts[].Id"

# Por último, vamos obter o Path ID
$pathID = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --output text --query LaunchPaths[].Id

# Para listar os parâmetros obrigatórios, usei:
# aws servicecatalog describe-provisioning-parameters --product-name CustomADGroup --provisioning-artifact-id $provisioningArtifactsId --path-id $pathID --profile $profile

# Por fim, executar o produto CustomADGroup
aws servicecatalog provision-product  --product-name CustomADGroup  --provisioning-artifact-id $provisioningArtifactsId --provisioned-product-name CustomADGroup-$profile_aws  --provisioning-parameters file://provision-parameters-CustomADGroup.json  --profile $profile_aws

# Criar a policy e atachar na role criada
$policy_arn = aws iam create-policy --policy-name BUPolicyForEKSAcess --policy-document file://BUPolicyForEKSAccess.json --profile $profile_aws --query "Policy.Arn" --output text

# ou caso a policy exista
aws iam list-policies --scope Local --profile $profile_aws | Select-String -Pattern "BUPolicyForEKSAcess"
$policy_arn = "arn:aws:iam::530914589075:policy/BUPolicyForEKSAcess"

$role_name = "BURoleForAccessAppWatchlist"
aws iam attach-role-policy  --role-name $role_name  --policy-arn $policy_arn --profile $profile_aws

# Por fim criar a role e rolebinding
aws eks list-clusters --profile dsdev
# {
#     "clusters": [
#         "ds-eks-01-dev"
#     ]
# }

aws eks update-kubeconfig --name ds-eks-01-dev --profile dsdev
# Updated context arn:aws:eks:sa-east-1:530914589075:cluster/ds-eks-01-dev in C:\Users\c96531a\.kube\config

kubectl create -f .\eits-datastrategy-datahub-prod\clusterrole.yaml
kubectl create -f .\eits-datastrategy-datahub-prod\rolebinding.yaml

kubectl edit configmap -n kube-system aws-auth
    - rolearn: arn:aws:iam::662860092544:role/BURoleForAccessAppWatchlist
      username: dev-viewer
      groups:
      - dev-viewer-group

##############################################################
# Ambiente UAT
$profile_aws = "dsstage"
### Essa ROLE vai ter que ser registrada no IDC para solicitação de acesso
# Primeiro vamos obter o PRODUCT-ID da automação
$productID = aws servicecatalog search-products --profile $profile_aws --query "ProductViewSummaries[].[Id]" --output text --filter "FullTextSearch=CustomADGroup"

# Vamos agora obter o ProvisioningArtifacts Id
$provisioningArtifactsId = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --query "ProvisioningArtifacts[].Id"

# Por último, vamos obter o Path ID
$pathID = aws servicecatalog describe-product --name CustomADGroup --output text --profile $profile_aws --output text --query LaunchPaths[].Id

# Para listar os parâmetros obrigatórios, usei:
# aws servicecatalog describe-provisioning-parameters --product-name CustomADGroup --provisioning-artifact-id $provisioningArtifactsId --path-id $pathID --profile $profile

# Por fim, executar o produto CustomADGroup
aws servicecatalog provision-product  --product-name CustomADGroup  --provisioning-artifact-id $provisioningArtifactsId --provisioned-product-name CustomADGroup-$profile_aws-2  --provisioning-parameters file://provision-parameters-CustomADGroup.json  --profile $profile_aws

# Criar a policy e atachar na role criada
$policy_arn = aws iam create-policy --policy-name BUPolicyForEKSAcess --policy-document file://BUPolicyForEKSAccess.json --profile $profile_aws --query "Policy.Arn" --output text

# ou caso a policy exista
aws iam list-policies --scope Local --profile $profile_aws | Select-String -Pattern "BUPolicyForEKSAcess"
$policy_arn =  "arn:aws:iam::146737708860:policy/BUPolicyForEKSAcess"

$role_name = "BURoleForAccessAppWatchlist"
aws iam attach-role-policy  --role-name $role_name  --policy-arn $policy_arn --profile $profile_aws

# Por fim criar a role e rolebinding
aws eks list-clusters --profile dsstage
# {
#     "clusters": [
#         "ds-eks-01-uat"
#     ]
# }

aws eks update-kubeconfig --name ds-eks-01-uat --profile dsstage
# Updated context arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat in C:\Users\c96531a\.kube\config

kubectl create -f .\eits-datastrategy-datahub-prod\clusterrole.yaml
kubectl create -f .\eits-datastrategy-datahub-prod\rolebinding.yaml

kubectl edit configmap -n kube-system aws-auth
    - rolearn: arn:aws:iam::662860092544:role/BURoleForAccessAppWatchlist
      username: dev-viewer
      groups:
      - dev-viewer-group

            