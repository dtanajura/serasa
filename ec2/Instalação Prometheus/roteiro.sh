ssh -i servidores.pem ec2-user@10.99.144.18 
dnf upgrade --releasever=2023.4.20240611 -y
sudo tee /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
EOF


# Criar uma role para as aplicações baseada na BURoleForAssumeRoleEKS
cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\Instalação Prometheus"

$profile_aws="ssrmsandbox"
aws iam create-role --role-name BURoleForObservabilidade --assume-role-policy-document file://trust.json --profile $profile_aws

aws iam attach-role-policy --role-name BURoleForObservabilidade --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForObservabilidade --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForObservabilidade --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess --profile $profile_aws
aws iam attach-role-policy --role-name BURoleForObservabilidade --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess --profile $profile_aws

100 -
(
  avg(node_memory_MemAvailable_bytes{job="observabilidade",  instance="$instance"}) /
  avg(node_memory_MemTotal_bytes{job="observabilidade",  instance="$instance"})
* 100
)

Endereço grafana http://10.99.144.38:8080/
Endereço grafana conta ssrmprod - grafana.nikessrmprod.br.experian.eeca admin password is: K9Cb8KRFV6bdr6B1t

Adicionar s3://experian-ssrm-artifacts-prod/bootstrap/node_exporter.sh no bootstrap do cluster

# Criar uma lista com o Levantamento dos clusters EMR
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
  "datahubdev",
  "datahubdevus",
  "datahubprod",
  "consentdev",
  "consentprod"
)
foreach ($profile_aws in $profiles) {
  Write-Output "$profile_aws"
  aws ec2 describe-vpcs --profile $profile_aws  --query "Vpcs[].CidrBlock" --output text
  aws route53 list-hosted-zones --profile $profile_aws --query "HostedZones[].Name" --output text
}

# Arquivo de saída
$outputFile = "lista_clusters.txt"

# Inicia o arquivo de saída
"" > $outputFile

foreach ($profile_aws in $profiles) {
  $header = "*****************   $profile_aws   ******************"
  Write-Output $header | Out-File -FilePath $outputFile -Append

  # Comando para listar todos os clusters
  $clusters = aws emr list-clusters --profile $profile_aws --query "Clusters[].[Name,Status.State]" --output json

  # Converte o resultado JSON para um objeto PowerShell
  $clusters_obj = $clusters | ConvertFrom-Json

  # Extrai apenas os nomes dos clusters
  $cluster_names = $clusters_obj | ForEach-Object { $_[0] }

  # Remove duplicatas
  $unique_clusters = $cluster_names | Sort-Object -Unique

  # Exibe os nomes dos clusters únicos e escreve no arquivo
  $unique_clusters | ForEach-Object { Write-Output $_ | Out-File -FilePath $outputFile -Append }
}

Write-Host "A lista de clusters foi salva em $outputFile"

# Alterar o Security Group para permitir o tráfego do node exporter
$sg = "sg-035c9264a47919a69"
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 9100 --cidr 10.99.144.0/24 --profile "ssrmprod"


aws ec2 describe-vpcs --profile arcsandbox --query "Vpcs[].CidrBlock"
aws ec2 describe-vpcs --profile ssrmsandbox --query "Vpcs[].CidrBlock"
aws ec2 describe-vpcs --profile ssrmprod --query "Vpcs[].CidrBlock"
aws ec2 describe-vpcs --profile dsprod --query "Vpcs[].CidrBlock"


# Configuração de scrap para ambiente kubernetes
# ver página: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/additional-scrape-config.md
# selecionar pasta
cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\Instalação Prometheus"

# altera o arquivo prometheus-scrap.yaml
  - job_name: "experian-replication-batch"
    ec2_sd_configs:
      - region: sa-east-1
    relabel_configs:
      - source_labels: [__meta_ec2_tag_Name]
        regex: 'experian-replication-batch'
        action: keep
      - source_labels: [__meta_ec2_private_ip]
        target_label: __address__
        replacement: '${1}:9100'

# Pega o nome do cluster e obtem o contexto desse cluster
aws eks list-clusters --profile dsprod
{
    "clusters": [
        "ds-eks-01-prod"
    ]
}

aws eks update-kubeconfig --name ds-eks-01-prod --profile dsprod
Updated context arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod in C:\Users\c96531a\.kube\config

# Cria uma secret a partir dessa configuração
kubectl create secret generic additional-scrape-configs -n monitoring-system --from-file=prometheus-scrap.yaml --dry-run=client -o yaml > additional-scrape-configs.yaml
kubectl apply -f additional-scrape-configs.yaml -n monitoring-system

# Finalmente adiciona essa configuração ao Prometheus.yaml
kubectl get Prometheus -n monitoring-system
NAME                               VERSION   DESIRED   READY   RECONCILED   AVAILABLE   AGE
kube-prometheus-stack-prometheus   v2.53.0   1         1       True         True        34d

kubectl edit Prometheus -n monitoring-system kube-prometheus-stack-prometheus

# apiVersion: monitoring.coreos.com/v1
# kind: Prometheus
# metadata:
#   name: prometheus
#   labels:
#     prometheus: prometheus
# spec:
#   replicas: 2
#   serviceAccountName: prometheus
#   serviceMonitorSelector:
#     matchLabels:
#       team: frontend
  additionalScrapeConfigs:
    name: additional-scrape-configs
    key: prometheus-scrap.yaml

# Verificar no prometheus:
https://prometheus.prod-ds.br.experian.eeca

# Informações das instâncias:
aws ec2 describe-instances --profile dsdev --query "Reservations[].Instances[].[Tags[?Key=='Name'].Value]" --output text

# Informações dos clusters EMRs
aws emr list-clusters --profile dsdev --query "Clusters[].Name" --active

# Para autorizar o acesso do Prometheus aos nodes do EMR com o node-exporter
$sgs = @(
  "sg-01fba3ff28966db26",
  "sg-0d663bd924060b83a",
  "sg-060fda749c16e864f"
)
foreach ($sg in $sgs) {
  aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 9100 --cidr 100.64.0.0/16 --profile "dsdev"
}

# Para autorizar o acesso do Prometheus aos nodes do EMR com o node-exporter
$sgs = @(
  "sg-05db813996c73c790",
  "sg-0e90e633758a1d4d7",
  "sg-0e5cab222d109dcdd"
)
foreach ($sg in $sgs) {
  aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 9100 --cidr 100.64.0.0/16 --profile "dsprod"
}


# Configurar o prometheus federado
# Checar comunicação:
# ambiente Prometheus de origem:
aws eks list-clusters --profile corporateprod
{
    "clusters": [
        "eks-nike-tech-01-prod"
    ]
}
aws eks update-kubeconfig --name eks-nike-tech-01-prod --profile corporateprod
k get pods -n monitoring-system

# ambientes Prometheius de destino:
aws eks list-clusters --profile dsprod
{
    "clusters": [
        "ds-eks-01-prod"
    ]
}

aws eks list-clusters --profile dsdev
{
    "clusters": [
        "ds-eks-01-dev"
    ]
}
aws eks update-kubeconfig --name ds-eks-01-prod --profile dsprod
k get vs -n monitoring-system
prometheus-virtual-service   ["prometheus-gateway"]   ["prometheus.prod-ds.br.experian.eeca"]   527d

aws eks update-kubeconfig --name ds-eks-01-dev --profile dsdev
k get vs -n monitoring-system
prometheus-virtual-service   ["prometheus-gateway"]   ["prometheus.dev-ds.br.experian.eeca"]   6d14h

# Fiz um teste na conta de origem e não consegui chegar no destino
aws eks update-kubeconfig --name eks-nike-tech-01-prod --profile corporateprod
k exec -n monitoring-system -it nginx -- bash
  apt-get install telnet
  telnet 10.99.8.33 9090
  curl -I http://10.99.8.33:9090
# ambos comandos falharam

# Vou verificar se o SG do Prometheus no destino permite o tráfego da porta 9090
# mudando de contextos:
k config get-contexts
k config use-context arn:aws:eks:sa-east-1:530914589075:cluster/ds-eks-01-dev
k config use-context arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod
k get pods -n monitoring-system -o wide
k get pod prometheus-kube-prometheus-stack-prometheus-0 -n monitoring-system -o jsonpath='{.spec.nodeName}'
ip-10-99-8-71.sa-east-1.compute.internal

# Lista todos os nodes do cluster
aws ec2 describe-instances --filters "Name=tag:eks:cluster-name,Values=ds-eks-01-dev" --profile dsdev --query "Reservations[*].Instances[*].[InstanceId,SecurityGroups[*].GroupId]"

# Automação para os SGs (obter o contexto do kubernetes antes de executar):
$profileAws = "dsprod"
$nodeName = k get pod prometheus-kube-prometheus-stack-prometheus-0 -n monitoring-system -o jsonpath='{.spec.nodeName}'

# Lista informações apenas do node que está o Prometheus
$instanceId = aws ec2 describe-instances --filters "Name=private-dns-name,Values=$nodeName" --query "Reservations[*].Instances[*].InstanceId" --output text --profile $profileAws

$instanceDetails = aws ec2 describe-instances --instance-ids $instanceId --profile $profileAws | ConvertFrom-Json


foreach ($sg in $instanceDetails.Reservations.Instances.SecurityGroups.GroupId) {
  Write-Output "SG ID = $sg"
  $sgRules = aws ec2 describe-security-groups --group-ids $sgID --query "SecurityGroups[*].IpPermissions[*].[IpProtocol,FromPort,ToPort,IpRanges[*].CidrIp]" --profile $profileAws --output text
  Add-Content -Path output.txt -Value $sgRules
}

aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 9090 --cidr 10.99.151.0/24 --profile $profileAws


kubectl create secret generic okta-secret --namespace monitoring-system --from-literal=client_id=0oa165k6lkzHrHxDP0x8 --from-literal=client_secret=B4KFBhO4BrDgv0cyxS-LAnpWxqZkiYBndOn-X5BtL0fT96HJGl-7cLXxQgL45Gqo














#### Roteiro criação de scrap config no ambiente EKS

### Procedimentos iniciais: 
# logar na conta
saml2aws.exe login -a eec-aws-br-ds-dataservices-dev
# mudar pasta
cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\Instalação Prometheus"
$profileAws = "ssrmprod"
# ver nome do cluster
$clusterName = aws eks list-clusters --profile $profileAws --query "clusters[0]"
# obter contexto do cluster kubernetes
# se for primeira vez:
aws eks update-kubeconfig --name $clusterName --profile $profileAws

# Verificar se a ROLE de Observabilidade tem na conta
aws iam list-roles --profile $profileAws --query "Roles[].RoleName" | Select-String -Pattern "BURoleForObservabilidade"
# O resultado é "BURoleForObservabilidadeDestino",

# Verificar qual o security group dos clusters EMRs

# listar informações das regras no SG
$sgID = "sg-0a58059b31e6a3a23"
aws ec2 describe-security-groups --group-ids $sgID --query "SecurityGroups[*].IpPermissions[*].[IpProtocol,FromPort,ToPort,IpRanges[*].CidrIp]" --profile $profileAws --output text
# tem que ter essa resposta: tcp     9100    9100 - 10.99.151.0/24

# Ver https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/additional-scrape-config.md
# Criar arquivo de scrap com clusters do ambiente
Ver C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\Instalação Prometheus\scrap-config-ssrmprod.yaml

# Criar uma secret a partir desse arquivo de scrap
kubectl create secret generic additional-scrape-configs -n monitoring-system --from-file=scrap-config-ssrmprod.yaml --dry-run=client -o yaml > additional-scrape-configs.yaml

kubectl apply -f additional-scrape-configs.yaml -n monitoring-system

# Editar o objeto Prometheus
# no EKS os objetos foram deployados com Helm, então precisam ser atualizados por lá
# Primeiro, obter o values.yaml do pacote do Prometheus
helm get values kube-prometheus-stack -n monitoring-system -o yaml > kube-prometheus-stack-values-ssrmprod.yaml

# Edite esse arquivo de values adicionando na seção Prometheus as seguintes informações:
prometheus:
  prometheusSpec:
    additionalScrapeConfigs:
      name: additional-scrape-configs
      key: prometheus-scrap-corp-prod.yaml

# Atualizar o pacote Prometheus com o Helm
helm upgrade --namespace monitoring-system kube-prometheus-stack prometheus-community/kube-prometheus-stack -f kube-prometheus-stack-values-ssrmprod.yaml

k get Prometheus -n monitoring-system
NAME                               VERSION   DESIRED   READY   RECONCILED   AVAILABLE   AGE
kube-prometheus-stack-prometheus   v2.54.0   1         1       True         True        42d

k edit Prometheus -n monitoring-system kube-prometheus-stack-prometheus

### Configuração da Federação
# Ver https://prometheus.io/docs/prometheus/latest/federation/

https://grafana.prod-devsecopspaas.br.experian.eeca
admin
5f59CC3UHS0u0QyV

experian-replication-integration_silver_streaming (33/33 up)


# Vou precisar criar uma máquina na conta corporate prod para testar o acesso ao prometheus na conta remota
# primeiro a chave
aws ec2 create-key-pair --key-name chave-teste-eec --query 'KeyMaterial' --output text --profile corporateprod > chave-teste-eec.pem

# segundo listar as imagens
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --profile corporateprod
ami-0f59136b75bca26be

aws ec2 run-instances --image-id ami-0f59136b75bca26be --count 1 --instance-type t2.micro --key-name chave-teste-eec --security-group-ids sg-002b4ae89eac00a86  sg-0df6e6ecda3f32c5c --subnet-id subnet-06588e5b9be554263 --profile corporateprod



# das demais vezes
k config get-contexts
CURRENT   NAME                                                               CLUSTER                                                            AUTHINFO                                                           NAMESPACE
          arn:aws:eks:sa-east-1:087086536124:cluster/ssrm-eks-01-sandbox     arn:aws:eks:sa-east-1:087086536124:cluster/ssrm-eks-01-sandbox     arn:aws:eks:sa-east-1:087086536124:cluster/ssrm-eks-01-sandbox
          arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat           arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat           arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat
          arn:aws:eks:sa-east-1:187739130313:cluster/nike-tech-dev           arn:aws:eks:sa-east-1:187739130313:cluster/nike-tech-dev           arn:aws:eks:sa-east-1:187739130313:cluster/nike-tech-dev
          arn:aws:eks:sa-east-1:258050508433:cluster/lab05-sandbox           arn:aws:eks:sa-east-1:258050508433:cluster/lab05-sandbox           arn:aws:eks:sa-east-1:258050508433:cluster/lab05-sandbox
          arn:aws:eks:sa-east-1:530914589075:cluster/ds-eks-01-dev           arn:aws:eks:sa-east-1:530914589075:cluster/ds-eks-01-dev           arn:aws:eks:sa-east-1:530914589075:cluster/ds-eks-01-dev
*         arn:aws:eks:sa-east-1:564593125549:cluster/eks-nike-tech-01-prod   arn:aws:eks:sa-east-1:564593125549:cluster/eks-nike-tech-01-prod   arn:aws:eks:sa-east-1:564593125549:cluster/eks-nike-tech-01-prod
          arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod          arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod          arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod
          arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-prod       arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-prod       arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-prod
          arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-uat        arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-uat        arn:aws:eks:sa-east-1:877001948254:cluster/sales-eks-01-uat
          arn:aws:eks:us-east-1:975050357449:cluster/consentiment-prod       arn:aws:eks:us-east-1:975050357449:cluster/consentiment-prod       arn:aws:eks:us-east-1:975050357449:cluster/consentiment-prod
          arn:aws:eks:us-east-1:992382670558:cluster/consentimento-dev       arn:aws:eks:us-east-1:992382670558:cluster/consentimento-dev       arn:aws:eks:us-east-1:992382670558:cluster/consentimento-dev

k config use-context arn:aws:eks:sa-east-1:530914589075:cluster/ds-eks-01-dev
k config use-context arn:aws:eks:sa-east-1:662860092544:cluster/ds-eks-01-prod
k config use-context arn:aws:eks:sa-east-1:564593125549:cluster/eks-nike-tech-01-prod
