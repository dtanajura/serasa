# Dados do chamado
Conta do MSK - eec-aws-br-ds-dataservices-prod
MSK - msk-dt-passagem-prod
ARN - arn:aws:kafka:sa-east-1:662860092544:cluster/ds-msk-prod/90e49179-2238-4ac2-8de1-29e44d56c731-3

Tópicos:
nike.reports.gold.depara_hash
nike.reports.gold.negativos.acoes.pf
nike.reports.gold.negativos.acoes.pj
nike.reports.gold.negativos.ccf.pf
nike.reports.gold.negativos.ccf.pj
nike.reports.gold.negativos.divida.vencida.pf
nike.reports.gold.negativos.divida.vencida.pj
nike.reports.gold.negativos.facon.pf
nike.reports.gold.negativos.facon.pj
nike.reports.gold.negativos.pefin.pf
nike.reports.gold.negativos.pefin.pj
nike.reports.gold.negativos.pie.pf
nike.reports.gold.negativos.protestos.pf
nike.reports.gold.negativos.protestos.pj
nike.reports.gold.negativos.refin.pf
nike.reports.gold.negativos.refin.pj
nike.reports.gold.negativos.spc.pf
nike.reports.gold.negativos.spc.pj

Role na conta - BURoleForMSKWarriors (criar)

aws iam list-attached-role-policies \
  --role-name BURoleForEmrEc2Nike \
  --profile nikedataserviceprod
arn:aws:iam::662860092544:policy/BUPolicyForEMREC2Nike  
arn:aws:iam::662860092544:policy/eec-aws-baseline-emr-ec2-role-policy   
arn:aws:iam::662860092544:policy/eec-aws-baseline-emr-encryption-policy 
arn:aws:iam::662860092544:policy/eec-aws-baseline-emr-role-policy       
arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy     
arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore    
arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role  
arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM        

# Entender sobre a role que vai assumir
Conta - 225989352496 eec-aws-br-eits-nikedataservice-prod
Role - BURoleForMSKWarriors

# Obter dados da role
aws iam get-role \
  --role-name BURoleForMSKWarriors \
  --profile nikedataserviceprod


aws iam list-roles \
  --profile nikedataserviceprod \
  --query "Roles[?starts_with(RoleName, 'BURoleFor')].RoleName" \
  --output json

# Exemplo de Aloia
Na conta Dataservices-stage tem uma ROLE BURoleforMSKWarriors e uma Policy BUPolicyForMSKWarriors
Que confiam na Role arn:aws:iam::713881783816:role/BURoleForEmrEc2Nike

ver - https://code.experian.local/projects/NIKESRE/repos/iac-eec-aws-br-ds-dataservices-stage/browse/sa-east-1/iam

# assume-role
okta-aws-cli web --profile nikedataserviceuat --aws-region sa-east-1 --aws-session-duration 36000
Web browser will open the following URL to begin Okta device authorization for the AWS CLI

https://experian.okta.com/activate?user_code=JWDRKWFK

  IdP: arn:aws:iam::713881783816:saml-provider/OktaSSO  Role: arn:aws:iam::713881783816:role/BUAdministratorAccessRoleUpdated profile "nikedataserviceuat" in credentials file "/Users/c96531a/.aws/credentials".
c96531a@MACFM7P993G iac-eec-aws-br-eits-datahub-stage % aws iam get-role \                                                      
  --role-name BURoleForEmrEc2Nike \
  --profile nikedataserviceuat

{
    "Role": {
        "Path": "/",
        "RoleName": "BURoleForEmrEc2Nike",
        "RoleId": "AROA2MNVLRYEKIZCNZAZ5",
        "Arn": "arn:aws:iam::713881783816:role/BURoleForEmrEc2Nike",
        "CreateDate": "2024-11-26T14:18:43+00:00",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": [
                            "elasticmapreduce.amazonaws.com",
                            "ec2.amazonaws.com"
                        ]
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        },
        "Description": "BURoleForEmrEc2Nike role",
        "MaxSessionDuration": 7200,
        "Tags": [
            {
                "Key": "map-migrated",
                "Value": "d-server-02n52mmgua5hr6"
c96531a@MACFM7P993G iac-eec-aws-br-eits-datahub-stage % aws iam list-role-policies \
  --role-name BURoleForEmrEc2Nike \
  --profile nikedataserviceuat --output text
c96531a@MACFM7P993G iac-eec-aws-br-eits-datahub-stage % aws iam list-attached-role-policies \
  --role-name BURoleForEmrEc2Nike \ 
  --profile nikedataserviceuat --output text
ATTACHEDPOLICIES        arn:aws:iam::713881783816:policy/BUPolicyForEMREC2Nike  BUPolicyForEMREC2Nike
ATTACHEDPOLICIES        arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy     CloudWatchAgentServerPolicy
ATTACHEDPOLICIES        arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore    AmazonSSMManagedInstanceCore
ATTACHEDPOLICIES        arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role   AmazonElasticMapReduceforEC2Role
ATTACHEDPOLICIES        arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM        AmazonEC2RoleforSSM
c96531a@MACFM7P993G iac-eec-aws-br-eits-datahub-stage % aws iam get-policy \
  --policy-arn arn:aws:iam::713881783816:policy/BUPolicyForEMREC2Nike \
  --profile nikedataserviceuat
{
    "Policy": {
        "PolicyName": "BUPolicyForEMREC2Nike",
        "PolicyId": "ANPA2MNVLRYEBYB4ZA6FQ",
        "Arn": "arn:aws:iam::713881783816:policy/BUPolicyForEMREC2Nike",
        "Path": "/",
        "DefaultVersionId": "v10",
        "AttachmentCount": 1,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "Description": "BUPolicyForEMREC2Nike Policy",
        "CreateDate": "2024-11-26T14:18:09+00:00",
        "UpdateDate": "2026-01-27T13:54:25+00:00",
        "Tags": [
            {
                "Key": "Asset_Category",
                "Value": "N/A"
            },
            {
                "Key": "map-migrated",
                "Value": "d-server-02n52mmgua5hr6"
            },
            {
                "Key": "AppID",
                "Value": "19678"
            },
            {
                "Key": "Data_Type",
c96531a@MACFM7P993G iac-eec-aws-br-eits-datahub-stage % aws iam get-policy-version \
  --policy-arn arn:aws:iam::713881783816:policy/BUPolicyForEMREC2Nike \
  --version-id v10 \
  --profile nikedataserviceuat \
  --query "PolicyVersion.Document"
{
    "Statement": [
        {
            "Action": [
                "airflow:UpdateEnvironment",
                "secretsmanager:GetSecretValue",
                "cassandra:*",
                "athena:*",
                "glue:DeleteTableVersion",
                "glue:BatchDeleteTableVersion",
                "glue:GetTable",
                "lambda:InvokeFunction",
                "logs:DeleteLogGroup",
                "lambda:DeleteFunction",
                "iam:DetachRolePolicy",
                "elasticmapreduce:DeleteSecurityConfiguration",
                "elasticmapreduce:GetManagedScalingPolicy",
                "elasticmapreduce:PutAutoScalingPolicy",
                "elasticmapreduce:RemoveManagedScalingPolicy",
                "elasticmapreduce:PutManagedScalingPolicy",
                "elasticmapreduce:RemoveAutoScalingPolicy",
                "elasticmapreduce:DescribeCluster",
                "elasticmapreduce:ListInstanceFleets",
                "elasticmapreduce:ListInstanceGroups",
                "elasticmapreduce:ListInstances",
                "elasticmapreduce:ListBootstrapActions",
                "elasticmapreduce:AddTags",
                "elasticmapreduce:RemoveTags",
                "elasticmapreduce:PutAutoTerminationPolicy",
                "elasticmapreduce:GetAutoTerminationPolicy",
                "elasticmapreduce:RemoveAutoTerminationPolicy",
                "elasticmapreduce:TerminateJobFlows",
                "cloudformation:List*",
                "cloudformation:Delete*",
                "emr-serverless:ListApplications",
                "emr-serverless:GetApplication",
                "emr-serverless:StartApplication",
                "emr-serverless:StopApplication",
                "emr-serverless:StartJobRun",
                "emr-serverless:CancelJobRun",
                "emr-serverless:ListJobRuns",
                "emr-serverless:GetJobRun",
                "sts:AssumeRole",
                "kms:GenerateDataKey",
                "kms:GenerateDataKeyWithoutPlaintext",
                "kms:GenerateRandom",
                "kms:Encrypt",
                "kms:ReEncrypt*",
                "kms:Decrypt",
                "kms:Put*",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion",
                "kms:Describe*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Enable*",
                "kms:Delete*",
                "kms:List*",
                "kms:Update*",
                "kms:Create*",
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation",
                "s3:List*",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "cloudwatch:*",
                "dynamodb:*",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CancelSpotInstanceRequests",
                "ec2:CreateNetworkInterface",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteTags",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribePrefixLists",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSpotInstanceRequests",
                "ec2:DescribeSpotPriceHistory",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeVpcEndpointServices",
                "ec2:DescribeVpcs",
                "ec2:DetachNetworkInterface",
                "ec2:ModifyImageAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:RequestSpotInstances",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:DeleteVolume",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:ListInstanceProfiles",
                "iam:ListRolePolicies",
                "iam:PassRole",
                "sdb:BatchPutAttributes",
                "sdb:Select",
                "sqs:CreateQueue",
                "sqs:Delete*",
                "sqs:GetQueue*",
                "sqs:PurgeQueue",
                "sqs:ReceiveMessage",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DeleteAlarms",
                "application-autoscaling:RegisterScalableTarget",
                "application-autoscaling:DeregisterScalableTarget",
                "application-autoscaling:PutScalingPolicy",
                "application-autoscaling:DeleteScalingPolicy",
                "application-autoscaling:Describe*",
                "glue:*",
                "datasync:CreateLocationS3",
                "datasync:CreateTask",
                "datasync:DescribeLocation*",
                "datasync:DescribeTaskExecution",
                "datasync:ListLocations",
                "datasync:ListTaskExecutions",
                "datasync:DescribeTask",
                "datasync:CancelTaskExecution",
                "datasync:ListTasks",
                "datasync:StartTaskExecution",
                "iam:CreateRole",
                "iam:CreatePolicy",
                "iam:AttachRolePolicy",
                "iam:ListRoles",
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets",
                "datasync:DeleteTask",
                "elasticmapreduce:*",
                "kms:*",
                "kafka-cluster:*"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "VisualEditor1"
        },
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Resource": "arn:aws:iam::146737708860:role/BURoleForMSKWarriors",
            "Sid": "AssumeCrossAccountRole"
        }
    ],
    "Version": "2012-10-17"
}

