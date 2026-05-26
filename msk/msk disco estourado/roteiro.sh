aws kafka list-clusters --profile dsstage --region sa-east-1 --no-verify-ssl --query "ClusterInfoList[].ClusterName"
urllib3\connectionpool.py:1061: InsecureRequestWarning: Unverified HTTPS request is being made to host 'kafka.sa-east-1.amazonaws.com'. Adding certificate verification is strongly advised. See: https://urllib3.readthedocs.io/en/1.26.x/advanced-usage.html#ssl-warnings
# [
#     "ds-msk-uat",
#     "msk-negativos-passagem"
# ]

aws kafka get-bootstrap-brokers `
  --cluster-arn arn:aws:kafka:sa-east-1:146737708860:cluster/ds-msk-uat/124ca450-80c1-439e-894c-1dc869bc57db-4 `
  --profile dsstage --region sa-east-1 --no-verify-ssl

aws ec2 run-instances `
    --image-id ami-0130f936a23ed9bd0 `
    --count 1 `
    --instance-type t3.medium `
    --iam-instance-profile Name=BURoleForSREAutomation `
    --security-group-ids sg-05d93c159076a5ee2 `
    --subnet-id subnet-08e6a67b3b6d4aa4c `
    --profile dsstage `
    --region sa-east-1 `
    --no-verify-ssl `
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bastion-sre-temp},{Key=CostString,Value=1800.BR.134.607500},{Key=AppID,Value=20274},{Key=Environment,Value=dev},{Key=CentrifyUnixRole,Value=0},{Key=ResourceName,Value=bastion-sre-temp},{Key=ResourceAppRole,Value=app},{Key=adDomain,Value=br.experian.local},{Key=adGroup,Value=0}]' 

aws ec2 create-key-pair `
    --key-name bastion-sre-temp `
    --query 'KeyMaterial' `
    --output text > bastion-sre-temp.pem `
    --profile dsstage `
    --region sa-east-1 `
    --no-verify-ssl

aws ec2 run-instances `
    --image-id ami-0130f936a23ed9bd0 `
    --count 1 `
    --instance-type t3.medium `
    --key-name bastion-sre-temp `
    --iam-instance-profile Name=BURoleForSREAutomation `
    --security-group-ids sg-05d93c159076a5ee2 `
    --subnet-id subnet-08e6a67b3b6d4aa4c `
    --profile dsstage `
    --region sa-east-1 `
    --no-verify-ssl `
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bastion-sre-temp},{Key=CostString,Value=1800.BR.134.607500},{Key=AppID,Value=20274},{Key=Environment,Value=dev},{Key=CentrifyUnixRole,Value=0},{Key=ResourceName,Value=bastion-sre-temp},{Key=ResourceAppRole,Value=app},{Key=adDomain,Value=br.experian.local},{Key=adGroup,Value=0}]'

aws iam put-role-policy  --role-name BURoleForSREAutomation --policy-name KafkaListDescribePolicy  --policy-document file://policy.json  --profile dsstage --region sa-east-1  --no-verify-ssl

aws iam update-assume-role-policy  --role-name BURoleForSREAutomation --policy-document file://trust.json   --profile dsstage --region sa-east-1  --no-verify-ssl

aws iam create-role  --role-name BURoleForBastionSRE  --assume-role-policy-document file://trust.json   --profile dsstage --region sa-east-1  --no-verify-ssl

aws iam attach-role-policy  --role-name BURoleForBastionSRE --policy-arn arn:aws:iam::aws:policy/AmazonMSKReadOnlyAccess    --profile dsstage --region sa-east-1  --no-verify-ssl
aws iam attach-role-policy  --role-name BURoleForBastionSRE --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore    --profile dsstage --region sa-east-1  --no-verify-ssl

aws iam create-instance-profile  --instance-profile-name BURoleForBastionSRE  --profile dsstage  --region sa-east-1 --no-verify-ssl

aws iam add-role-to-instance-profile --instance-profile-name BURoleForBastionSRE  --role-name BURoleForBastionSRE --profile dsstage --region sa-east-1  --no-verify-ssl

aws ec2 associate-iam-instance-profile --instance-id i-0c4955f5ed2144a1a --iam-instance-profile Name=BURoleForBastionSRE --profile dsstage  --region sa-east-1  --no-verify-ssl

aws ec2 describe-iam-instance-profile-associations --filters Name=instance-id,Values=i-0c4955f5ed2144a1a  --region sa-east-1 --profile dsstage

aws ec2 disassociate-iam-instance-profile --association-id iip-assoc-0a9c4dfd44ae2fca1 --region sa-east-1 --profile dsstage  --no-verify-ssl

# Instancia Linux com interface gráfica (se não tiver linux pode ser windows)
# Jonathan vai informar qual conta vou subir a Instancia
# Acesso Internet
# se for linux ter o swap habilitado
# 8 vcpu e 32 gb de ram (foco em memoria)
# Ligada full time
# c8g.8xlarge
# disco 250 GB - throughput otimizado
# eec-aws-br-eits-datahub-dev (730335661246)
# ami-0476785cbf79d83a3