saml2aws.exe login -a eec-aws-br-nike-ss-sandbox
saml2aws.exe console -a eec-aws-br-nike-ss-sandbox

$profile_aws = "ssrmsandbox"

# Verificar cluster EMR
aws emr list-clusters --profile $profile_aws --active --query "Clusters[].Name"

# Verificar cluster EKS
$eks_cluster_name=aws eks list-clusters --profile $profile_aws --output text --query "clusters"

# Pegar o contexto do cluster
aws eks update-kubeconfig --region sa-east-1 --name $eks_cluster_name --profile $profile_aws

# verificar se tem o PROMETHEUS e GRAFANA
k get pods -n monitoring-system

# verificar o endereço do GRAFANA da conta
aws route53 list-hosted-zones --profile $profile_aws
$hosted_zone_id=aws route53 list-hosted-zones --profile $profile_aws --query "HostedZones[].Id" --output text
aws route53 list-resource-record-sets --hosted-zone-id $hosted_zone_id --profile $profile_aws --query  "ResourceRecordSets[].Name" | Select-String -Pattern "grafana"
# http://grafana.nikessrmsandbox.br.experian.eeca

# pegar a senha do admin do grafana
# ver qual o pod do Grafana
k get pods -n monitoring-system
# descobrir o nome da secret que tem o usuário e senha do Grafana
k get pods kube-prometheus-stack-grafana-6b7c9bf4b7-xv5x6 -n monitoring-system -o yaml
# ver valor da secret
k get secrets kube-prometheus-stack-grafana -n monitoring-system -o yaml
# usar um decodificador base 64 para obter os valores do usuario e senha
# https://www.base64encode.org/
# no meu caso usuário admin e senha KOBm8KDU6bdr6B1t

# Verificar arquivo de configuração do prometheus