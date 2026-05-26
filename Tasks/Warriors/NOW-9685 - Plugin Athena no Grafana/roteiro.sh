# https://observability.nikedataprod.br.experian.eeca
# Ao usar o plugin do Athena no Grafana o usuário recebe o erro:
# Error: operation error Athena: ListWorkGroups, get identity: get credentials: failed to refresh cached credentials, operation error STS: AssumeRole, get identity: get credentials: failed to refresh cached credentials, failed to get BURoleForSREAutomation EC2 IMDS role credentials, api error AssumeRoleUnauthorizedAccess: EC2 cannot assume the role BURoleForSREAutomation.
# Please see documentation at https://docs.aws.amazon.com/IAM/latest/UserGuide/troubleshoot_iam-ec2.html#troubleshoot_iam-ec2_errors-info-doc.

# Confirmar que a conta é essa mesmo
aws route53 list-hosted-zones --profile nikedataserviceprod
{
    "HostedZones": [
        {
            "Id": "/hostedzone/Z05245831LIWM9RWKNGY",
            "Name": "nikedataprod.br.experian.eeca.",
            "CallerReference": "d06de5b0-0b0c-4f02-8404-b5f85f115328-2024-10-04 19:08:01.076",
            "Config": {
                "PrivateZone": true
            },
            "ResourceRecordSetCount": 3
        }
    ]
}

# Verificar se a role existe na conta
aws iam list-roles \
  --query "Roles[?contains(RoleName, 'BURoleForSREAutomation')].RoleName" \
  --output table \
  --profile nikedataserviceprod
----------------------------
|         ListRoles        |
+--------------------------+
|  BURoleForSREAutomation  |
+--------------------------+

# Obter as informações da role
aws iam get-role \
  --role-name BURoleForSREAutomation \
  --profile nikedataserviceprod
``
{
    "Role": {
        "Path": "/",
        "RoleName": "BURoleForSREAutomation",
        "RoleId": "AROATJHQD3QYBOHBG6743",
        "Arn": "arn:aws:iam::225989352496:role/BURoleForSREAutomation",
        "CreateDate": "2024-10-03T12:38:04+00:00",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "ecs-tasks.amazonaws.com",
                        "AWS": [
                            "arn:aws:iam::564593125549:role/BURoleForSREAutomation",
                            "arn:aws:iam::504195663072:user/BUUserForSREAutomation"
                        ]
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        },
        "Description": "Role for Nike Sre Automation",
        "MaxSessionDuration": 3600,
        "RoleLastUsed": {
            "LastUsedDate": "2026-02-09T13:03:25+00:00",
            "Region": "sa-east-1"
        }
    }
}

# verificar o instance profile
aws ec2 describe-instances \
  --instance-ids i-0629d7002f2d1b3be \
  --profile nikedataserviceprod \
  --query "Reservations[].Instances[].IamInstanceProfile"
[
    {
        "Arn": "arn:aws:iam::225989352496:instance-profile/BURoleForSREAutomation",
        "Id": "AIPATJHQD3QYFDEY5OO2R"
    }
]

# já criei a trust aqui na pasta. na hora da change CHG2814098 é só palicar o comando:
aws iam update-assume-role-policy \
  --role-name BURoleForSREAutomation \
  --policy-document file://trust.json \
  --profile nikedataserviceprod


# 1. Obter o nome da role dentro do instance profile
aws iam get-instance-profile \
  --instance-profile-name BURoleForSREAutomation \
  --profile nikedataserviceprod \
  --query "InstanceProfile.Roles[].RoleName"

echo "Attached policies:" && \
aws iam list-attached-role-policies \
  --role-name BURoleForSREAutomation \
  --profile nikedataserviceprod --output table

echo "Inline policies:" && \
aws iam list-role-policies \
  --role-name BURoleForSREAutomation \
  --profile nikedataserviceprod --output table

Attached policies:
---------------------------------------------------------------------------------------------
|                                 ListAttachedRolePolicies                                  |
+-------------------------------------------------------------------------------------------+
||                                    AttachedPolicies                                     ||
|+------------------------------------------------------------+----------------------------+|
||                          PolicyArn                         |        PolicyName          ||
|+------------------------------------------------------------+----------------------------+|
||  arn:aws:iam::225989352496:policy/BUPolicyForSREAutomation |  BUPolicyForSREAutomation  ||
|+------------------------------------------------------------+----------------------------+|

aws iam get-policy \
  --policy-arn arn:aws:iam::225989352496:policy/BUPolicyForSREAutomation \
  --profile nikedataserviceprod
{
    "Policy": {
        "PolicyName": "BUPolicyForSREAutomation",
        "PolicyId": "ANPATJHQD3QYF5BMWUKPD",
        "Arn": "arn:aws:iam::225989352496:policy/BUPolicyForSREAutomation",
        "Path": "/",
        "DefaultVersionId": "v5",
        "AttachmentCount": 1,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2024-10-03T12:38:05+00:00",
        "UpdateDate": "2025-10-22T18:16:37+00:00",
        "Tags": []
    }
}
aws iam get-policy-version \
  --policy-arn arn:aws:iam::225989352496:policy/BUPolicyForSREAutomation \
  --version-id v6 \          
  --profile nikedataserviceprod \
  --query "PolicyVersion.Document"

# Na Change CHG2815403 executar 
# Apagar versões anteriores na policy
aws iam delete-policy-version \
--policy-arn arn:aws:iam::225989352496:policy/BUPolicyForSREAutomation \
--version-id v2 \
--profile nikedataserviceprod

# mudar a policy
cd "/Users/c96531a/Library/CloudStorage/OneDrive-EXPERIANSERVICESCORP/serasa/Tasks/Warriors/NOW-9685 - Plugin Athena no Grafana"

aws iam create-policy-version \
--policy-arn arn:aws:iam::225989352496:policy/BUPolicyForSREAutomation \
--policy-document file://policy.json \
--set-as-default \
--profile nikedataserviceprod