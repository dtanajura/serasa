# Fazer logon na conta
saml2aws.exe login -a eec-aws-br-nike-sales-prod

$profile_aws = "ssrmprod"
aws eks list-clusters --profile $profile_aws

$cluster_name = "sales-eks-01-uat"

aws eks update-kubeconfig --region sa-east-1 --name $cluster_name --profile $profile_aws

# Abrir o Lens
# Abrir o cluster sales-eks-01-uat
# Em configurations - Secrets
# Selecionar o namespace ssbl-uat
# abrir o arquivo de secrets - ebisys-billing-authorization-orchestrator
# Ajustar valores:
Chave	Valor (já em Base64)
# COMMERCIAL_DIVISION_EXCEPTION: RElTVFJJQlVJRE9SO1NFTSBDQU5BTA==
COMMERCIAL_DIVISION_EXCEPTION	U0VNIENBTkFMO07DTyBJREVOVElGSUNBRE8=
# MAINFRAME_FEATURES_EXCEPTION: ezI2OiB7J1MnfSwgMjg6IHsnUyd9fQ==
MAINFRAME_FEATURES_EXCEPTION	ezI4OiB7J1MnfX0=
DISTRIBUTOR_GENERAL_SWITCH	ZmFsc2U=
DISTRIBUTOR_WHITELIST	 
DISTRIBUTOR_COMMERCIAL_DIVISION	 
