# listar instancias conta datahub-dev
aws ec2 describe-instances \
  --profile datahubdev \
  --region sa-east-1 \
  --query "Reservations[].Instances[].{InstanceId:InstanceId,Name:Tags[?Key=='Name']|[0].Value,State:State.Name}" \
  --output table

# Extrair as informaçoes da instância tunel-datahubdev
aws ec2 describe-instances \
  --profile datahubdev \
  --region sa-east-1 \
  --instance-id i-0ac719ef3306c1cab \
  --output json > inst_tunel_datahubdev.json

# Criar uma nova key para a conta dtahubstage
aws ec2 create-key-pair \
  --profile datahubstage \
  --region sa-east-1 \
  --key-name sre-support \
  --query "KeyMaterial" \
  --output text > sre-support.pem

chmod 400 sre-support.pem

# verificar se a AMI existe nessa conta
aws ec2 describe-images \
  --profile datahubstage \
  --region sa-east-1 \
  --image-ids ami-03f025ac89b9251f3 \
  --query "Images[].{ImageId:ImageId,Name:Name,OwnerId:OwnerId,State:State,Visibility:Public,CreationDate:CreationDate}" \
  --output table

# listar os sgs na conta
aws ec2 describe-security-groups \
  --profile datahubstage \
  --region sa-east-1 \
  --query "SecurityGroups[].{GroupId:GroupId,GroupName:GroupName,VpcId:VpcId,Description:Description}" \
  --output table

# Descobrir a VPC
aws ec2 describe-vpcs \
  --profile datahubstage \
  --region sa-east-1 \
  --query "Vpcs[].{VpcId:VpcId,Cidr:CidrBlock,IsDefault:IsDefault,Name:Tags[?Key=='Name']|[0].Value}" \
  --output table



aws ec2 create-security-group \
  --profile datahubstage \
  --region sa-east-1 \
  --group-name "bastion-datahubsatge" \
  --description "SG for Bastion" \
  --vpc-id vpc-04770b76aa555258b \
  --tag-specifications 'ResourceType=security-group,Tags=[
    {Key=AppID,Value=23008},
    {Key=Squad,Value=datahub},
    {Key=CostString,Value=1800.BR.134.602018},
    {Key=Asset_Category,Value=N/A},
    {Key=BU,Value=EITS},
    {Key=Project,Value=datahub},
    {Key=Environment,Value=stg},
    {Key=Data_Category,Value=N/A},
    {Key=Data_Type,Value=N/A},
    {Key=Name,Value=tunel-datahubdev},
    {Key=BusinessServices,Value=datahub}
  ]' \
  --query 'GroupId' \
  --output text

echo "Created SG: $SG_ID"
