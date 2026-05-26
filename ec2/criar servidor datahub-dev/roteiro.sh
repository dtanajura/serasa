# Instancia Linux com interface gráfica (se não tiver linux pode ser windows)
# Jonathan vai informar qual conta vou subir a Instancia
# Acesso Internet
# se for linux ter o swap habilitado
# 8 vcpu e 32 gb de ram (foco em memoria)
# Ligada full time
# c8g.8xlarge
# disco 250 GB - throughput otimizado
# eec-aws-br-eits-datahub-dev (730335661246)
# Imagem da instância
# eec_aws_arm64_amzn_lnx_2023_1756494381_1.276.141.4021
# ami-0d35406cc614df7fe
# Hardened Amazon Linux 2023 AMI ARM64 for Experian AWS Cloud
# OwnerAlias: –
# Platform: –
# Architecture: arm64
# Owner: 363353661606
# Publish date: 2025-08-29
# Root device type: ebs
# Virtualization: hvm
# ENA enabled: Yes
# Boot mode: uefi

aws ec2 create-key-pair `
    --key-name bastion-rulextract-ai `
    --query 'KeyMaterial' `
    --output text > bastion-rulextract-ai.pem `
    --profile datahubdev `
    --region sa-east-1 `
    --no-verify-ssl

aws iam create-role  --role-name BURoleForBastionRuleXtract  --assume-role-policy-document file://trust.json   --profile datahubdev --region sa-east-1  --no-verify-ssl

$policy_arn = aws iam create-policy --policy-name BUPolicyForBastionRuleXtract --policy-document file://policy.json --profile datahubdev --region sa-east-1  --no-verify-ssl --query "Policy.Arn" --output text

aws iam attach-role-policy  --role-name BURoleForBastionRuleXtract  --policy-arn $policy_arn --profile datahubdev --region sa-east-1  --no-verify-ssl 
aws iam attach-role-policy  --role-name BURoleForBastionRuleXtract --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore    --profile datahubdev --region sa-east-1  --no-verify-ssl

aws iam create-instance-profile  --instance-profile-name BURoleForBastionRuleXtract  --profile datahubdev  --region sa-east-1 --no-verify-ssl

aws iam add-role-to-instance-profile --instance-profile-name BURoleForBastionRuleXtract  --role-name BURoleForBastionRuleXtract --profile datahubdev --region sa-east-1  --no-verify-ssl

aws ec2 run-instances `
    --image-id ami-0d35406cc614df7fe `
    --count 1 `
    --instance-type c8g.8xlarge `
    --iam-instance-profile Name="BURoleForBastionRuleXtract" `
    --security-group-ids sg-0081b7edb68f16fe5 `
    --subnet-id subnet-09457eb844099e03a `
    --profile datahubdev `
    --region sa-east-1 `
    --no-verify-ssl `
    --block-device-mappings file://block_device_mappings.json `
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bastion-rulextract-ai},{Key=CostString,Value=1800.BR.134.607500},{Key=AppID,Value=20274},{Key=Environment,Value=dev},{Key=CentrifyUnixRole,Value=0},{Key=ResourceName,Value=bastion-rulextract-ai},{Key=ResourceAppRole,Value=app},{Key=adDomain,Value=br.experian.local},{Key=adGroup,Value=0}]'

aws iam create-policy-version `
    --policy-arn $policy_arn `
    --policy-document file://policy.json `
    --set-as-default `
    --profile datahubdev `
    --region sa-east-1 `
    --no-verify-ssl

aws route53 list-hosted-zones --profile lab01 --region sa-east-1
# {
#     "HostedZones": [
#         {
#             "Id": "/hostedzone/Z01370942U58PE9MASBN9",
#             "Name": "sandbox-lab.br.experian.eeca.",
#             "CallerReference": "980294b0-1d96-4b1c-b72a-3eb519da5bbe-2023-09-28 14:46:38.442",
#             "Config": {
#                 "PrivateZone": true
#             },
#             "ResourceRecordSetCount": 22
#         }
#     ]
# }


aws ec2 describe-vpcs --query "Vpcs[*].VpcId" --output text --profile datahubdev --region sa-east-1
# vpc-0e87239604bd7ce1d

    # Conta DONA do DNS:
aws route53 create-vpc-association-authorization --hosted-zone-id HOSTEDZONEID_DO_ROUTE53 --vpc VPCRegion=sa-east-1,VPCId=VPCID_DA_CONTA_QUE_PRECISA_RESOLVER

aws route53 create-vpc-association-authorization `
  --hosted-zone-id Z01370942U58PE9MASBN9 `
  --vpc VPCRegion=sa-east-1,VPCId=vpc-0e87239604bd7ce1d `
  --profile lab01 `
  --region sa-east-1

# {
#     "HostedZoneId": "Z01370942U58PE9MASBN9",
#     "VPC": {
#         "VPCRegion": "sa-east-1",
#         "VPCId": "vpc-0e87239604bd7ce1d"
#     }
# }


# Conta que precisa RESOLVER o DNS:
aws route53 associate-vpc-with-hosted-zone --hosted-zone-id HOSTEDZONEID_DO_ROUTE53 --vpc VPCRegion=sa-east-1,VPCId=VPCID_DA_CONTA_QUE_PRECISA_RESOLVER

aws route53 associate-vpc-with-hosted-zone `
  --hosted-zone-id Z01370942U58PE9MASBN9 `
  --vpc VPCRegion=sa-east-1,VPCId=vpc-0e87239604bd7ce1d `
  --profile datahubdev `
  --region sa-east-1

# {
#     "ChangeInfo": {
#         "Id": "/change/C00005331BNHK0Y88ZAN",
#         "Status": "PENDING",
#         "SubmittedAt": "2025-09-23T20:34:37.962000+00:00",
#         "Comment": ""
#     }
# }

aws s3 mb rulextract-ai   --profile datahubdev --region sa-east-1
aws ec2 terminate-instances --instance-ids i-0ce029034bba88e1d --profile datahubdev --region sa-east-1