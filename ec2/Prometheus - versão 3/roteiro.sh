# Criar instâncias Linux nas constas dsprod 

# Instalação Prometheus
yum update -y

yum install wget tar -y
wget https://github.com/prometheus/prometheus/releases/download/v2.54.1/prometheus-2.54.1.linux-amd64.tar.gz
tar xvfz prometheus-2.54.1.linux-amd64.tar.gz
cp prometheus-2.54.1.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.54.1.linux-amd64/promtool /usr/local/bin/
mkdir /etc/prometheus
cp -r prometheus-2.54.1.linux-amd64/consoles /etc/prometheus
cp -r prometheus-2.54.1.linux-amd64/console_libraries /etc/prometheus
cp prometheus-2.54.1.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml
mkdir /var/lib/prometheus

useradd --no-create-home --shell /bin/false prometheus

chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /var/lib/prometheus
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
chown -R prometheus:prometheus /etc/prometheus
tee /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus
systemctl status prometheus


# Instalar o Grafana
yum update -y
tee /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
EOF

yum install grafana -y
systemctl start grafana-server
systemctl enable grafana-server
systemctl status grafana-server
### Passo 4: Configurar o Firewall
#    - Se você estiver usando um Security Group na AWS, certifique-se de adicionar uma regra para permitir o tráfego na porta 3000.

# encontrar as estações criadas
$profiles = @(
  "corporateprod"
  "dsprod",
  "dsdev"
)
foreach ($profileAws  in $profiles) {
  Write-Output "Perfil: $profileAws"
  aws ec2 describe-instances --filters "Name=tag:Name,Values=Observabilidade" --query "Reservations[].Instances[].[InstanceId,PrivateIpAddress,Tags[?Key=='Name'].Value, State.Name]" --output text --profile $profileAws
  aws ec2 describe-vpcs --profile $profileAws --query "Vpcs[].[CidrBlock]" --output text
}

aws ec2 stop-instances --instance-ids i-062bd2f4604e8cec7 --profile dsprod
aws ec2 stop-instances --instance-ids i-07e7df5acb6903d6a --profile dsdev
aws ec2 start-instances --instance-ids i-07e7df5acb6903d6a --profile dsdev
aws ec2 start-instances --instance-ids i-062bd2f4604e8cec7 --profile dsprod


# Listar os security groups para os nodes do cluster EKS
$ClusterName = aws eks list-clusters --profile dsdev --query "clusters" --output text

# Listar os node groups
$NodeGroups = aws eks list-nodegroups --cluster-name $ClusterName --profile dsdev --query 'nodegroups' --output text

# Iterar sobre cada node group e listar os security groups
$NodeGroupsArray = $NodeGroups.Trim() -split "\s+"
foreach ($NodeGroup in $NodeGroupsArray) {
    Write-Output "Node Group: $NodeGroup"
    $AutoScalingGroupName = aws eks describe-nodegroup --cluster-name $ClusterName --nodegroup-name EKS-ds-eks-01-dev-NG-infra-20240730145310281500000002 --profile dsdev --query 'nodegroup.resources.autoScalingGroups[0].name'--output text
    $AutoScalingGroupInstance = aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $AutoScalingGroupName --profile dsdev --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text
    $SecurityGroups = aws ec2 describe-instances --instance-ids $AutoScalingGroupInstance --profile dsdev --query 'Reservations[*].Instances[*].SecurityGroups[*].GroupId' --output text
    $SecurityGroupsArray = $SecurityGroups.Trim() -split "\s+"
    foreach ($SG in $SecurityGroupsArray) {
        Write-Output "Security Groups Rules for: $SG"
        $Rules = aws ec2 describe-security-groups --group-ids $SG --profile dsdev --query 'SecurityGroups[*].IpPermissions' --output json
        Write-Output $Rules
    }
}

# Adicionar regras de acesso ao prometheus e ao node exporter aos node do EKS
$SecurityGroupId = "sg-0a4941330acb60b7c"

# Adicionar regra para a porta 9090
aws ec2 authorize-security-group-ingress --group-id $SecurityGroupId --protocol tcp --port 9090 --cidr 10.0.0.0/8 --profile dsdev

# Adicionar regra para a porta 9100
aws ec2 authorize-security-group-ingress --group-id $SecurityGroupId --protocol tcp --port 9100 --cidr 10.0.0.0/8 --profile dsdev

aws ec2 describe-security-groups --group-ids $SecurityGroupId --profile dsdev --query 'SecurityGroups[*].IpPermissions' --output json



aws ec2 describe-instances --filters "Name=tag:Name,Values=experian-replication-streaming-producer-s3-as-is"  --profile $profileAws

# --query "Reservations[].Instances[].[InstanceId,PrivateIpAddress,State.Name]" --output text

$SecurityGroupId = "sg-01fba3ff28966db26"

aws ec2 describe-security-groups --group-ids $SecurityGroupId --profile dsdev --query 'SecurityGroups[*].IpPermissions' --output json

$SecurityGroupId = "sg-0d663bd924060b83a"

aws ec2 authorize-security-group-ingress --group-id $SecurityGroupId --protocol tcp --port 9100 --cidr 10.0.0.0/8 --profile dsdev

atlantis apply -d sa-east-1/ec2/observabilidade

usuário: admin / senha: 5f59CC3UHS0u0QyV

aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId,PrivateIpAddress,Tags[?Key=='Name'].Value, State.Name]" --output text --profile dsprod

experian-replication-consumer-streaming-bronze-passagem
experian-replication-integration_silver_streaming
experian-replication-maintenance-negativos-gold
experian-replication-negativos-orquestrator
experian-replication-producer_silver_streaming_passagem
experian-replication-streaming-producer
experian-replication-streaming-producer-passagem
experian-replication-streaming-producer-s3-as-is
experian-replication-streaming-producer-s3-as-is-passagem
experian-reports-streaming-ingestion-pf
experian-reports-streaming-ingestion-pj


# Criar o ALB para acesso do Grafana no CORPORATE PROD
$profileAws = "corporateprod"

aws ec2 describe-subnets  --profile $profileAws --output text --query "Subnets[].[SubnetId,Tags[?Key=='Name']]" --filters "Name=tag:Name,Values=aws*"
subnet-0b502f71eace9c5b5
Name    aws-landing-zone-PrivateSubnet2A
subnet-0d9b9426ecb1299ee
Name    aws-landing-zone-PrivateSubnet3A
subnet-06588e5b9be554263
Name    aws-landing-zone-PrivateSubnet1A

aws ec2 describe-security-groups --query "SecurityGroups[*].[GroupId,GroupName]"  --profile=$profileAws --output text | Select-String -Pattern "observabilidade"
sg-0b3e76685de6d1ec6    secg-SG-Observabilidade

aws ec2 describe-security-group-rules --filters Name=group-id,Values=sg-0b3e76685de6d1ec6 --profile $profileAws

aws ec2 authorize-security-group-ingress --group-id sg-0b3e76685de6d1ec6 --protocol tcp --port 443 --cidr 10.0.0.0/8 --profile $profileAws

# Criar o Load Balancer (ALB)
aws elbv2 create-load-balancer --name alb-observabilidade --subnets subnet-0b502f71eace9c5b5 subnet-0d9b9426ecb1299ee subnet-06588e5b9be554263 --security-groups sg-0b3e76685de6d1ec6 --scheme internal --type application --ip-address-type ipv4 --profile $profileAws

aws elbv2 describe-load-balancers --profile $profileAws --query "LoadBalancers[].[LoadBalancerName,LoadBalancerArn,DNSName]" --output text | Select-String -Pattern "observabilidade"

alb-observabilidade     arn:aws:elasticloadbalancing:sa-east-1:564593125549:loadbalancer/app/alb-observabilidade/f0c38ca51dcd07f1
internal-alb-observabilidade-1671560840.sa-east-1.elb.amazonaws.com

# Criar o Target Group
aws elbv2 create-target-group --name tg-observabilidade --protocol HTTP --port 8080 --vpc-id vpc-0a9d3b72fba388442 --health-check-protocol HTTP  --health-check-path /health --profile $profileAws

aws elbv2 register-targets --target-group-arn arn:aws:elasticloadbalancing:sa-east-1:564593125549:targetgroup/tg-observabilidade/4aca4283fc1c87e9 --targets Id=i-09d72d2f1b3e62466 --profile $profileAws

aws elbv2 describe-target-groups --profile $profileAws --query "TargetGroups[].[TargetGroupName,TargetGroupArn,LoadBalancerArns[*]]" --output text | Select-String -Pattern "observabilidade"

tg-observabilidade      arn:aws:elasticloadbalancing:sa-east-1:564593125549:targetgroup/tg-observabilidade/4aca4283fc1c87e9
arn:aws:elasticloadbalancing:sa-east-1:564593125549:loadbalancer/app/alb-observabilidade/f0c38ca51dcd07f1

# Criar Listener para HTTPS (porta 443)
aws acm list-certificates --profile $profileAws

aws elbv2 create-listener --load-balancer-arn arn:aws:elasticloadbalancing:sa-east-1:564593125549:loadbalancer/app/alb-observabilidade/f0c38ca51dcd07f1 --protocol HTTPS --port 443 --certificates CertificateArn=arn:aws:acm:sa-east-1:564593125549:certificate/02a9afc6-2b18-44d3-96d4-df88159f8971 --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:sa-east-1:564593125549:targetgroup/tg-observabilidade/4aca4283fc1c87e9 --profile $profileAws

aws elbv2 create-listener --load-balancer-arn arn:aws:elasticloadbalancing:sa-east-1:564593125549:loadbalancer/app/alb-observabilidade/f0c38ca51dcd07f1 --protocol HTTP --port 80 --default-actions file://default-actions.json --profile $profileAws


# Para excluir
 aws elbv2 delete-listener --listener-arn arn:aws:elasticloadbalancing:sa-east-1:564593125549:listener/app/alb-observabilidade/f0c38ca51dcd07f1/be7932e5b0c42261 --profile $profileAws
aws elbv2 delete-listener --listener-arn arn:aws:elasticloadbalancing:sa-east-1:564593125549:listener/app/alb-observabilidade/f0c38ca51dcd07f1/a3a16fc7f70b354f --profile $profileAws
aws elbv2 delete-target-group --target-group-arn  arn:aws:elasticloadbalancing:sa-east-1:564593125549:targetgroup/tg-observabilidade/4aca4283fc1c87e9 --profile $profileAws
aws elbv2 delete-load-balancer --load-balancer-arn arn:aws:elasticloadbalancing:sa-east-1:564593125549:loadbalancer/app/alb-observabilidade/f0c38ca51dcd07f1   --profile $profileAws


# No grafana alterar o uid do datasource
          "datasource": {
            "type": "grafana-postgresql-datasource",
            "uid": "bdx3zd9s0jbb4d"
          },

# Prometheus - dsprod
          "datasource": {
            "type": "prometheus",
            "uid": "adx3ygcmddbeoe"
          },

# Prometheus - dsprod
      "datasource": {
        "name": "prometheus-dsdev",
        "type": "prometheus",
        "uid": "edx3yqi86clxce"
      },
