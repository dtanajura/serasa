#### AWS Backup
$profile_aws = "corporateprod"
# Create a backup vault by running:
aws backup create-backup-vault --backup-vault-name backup-vault-$profile_aws --profile $profile_aws

# Create a backup plan by running 
# Ajustar arquivo JSON com:
# ===> backup-vault-name = backup-vault-devexperience-prod
aws backup create-backup-plan --cli-input-json file://backup-plan.json --profile $profile_aws

# Create a backup selection by running:
# Ajustar arquivo JSON com:
# ===> BackupPlanId = 7a38f5ec-ea85-4722-b6f2-acfe5280000e
# ===> IamRoleArn = arn:aws:iam::562223391796:role/aws-service-role/backup.amazonaws.com/AWSServiceRoleForBackup
aws iam list-roles --query 'Roles[?RoleName==`AWSServiceRoleForBackup`].Arn' --output text --profile $profile_aws

aws backup create-backup-selection --cli-input-json file://backup-selection.json  --profile $profile_aws

# Crie a role:
aws iam create-role --role-name BURoleForAWSBackup --assume-role-policy-document file://trust-policy.json --profile corporateprod
# Anexe a política inline à role:
aws iam put-role-policy --role-name BURoleForAWSBackup --policy-name InlinePolicy --policy-document file://inline-policy.json --profile corporateprod
# Anexe a política gerenciada à role:
aws iam attach-role-policy --role-name BURoleForAWSBackup --policy-arn arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup --profile corporateprod
# Verifique se as políticas foram anexadas corretamente:
aws iam list-attached-role-policies --role-name BURoleForAWSBackup --profile corporateprod
# Verifique a política inline:
aws iam get-role-policy --role-name BURoleForAWSBackup --policy-name InlinePolicy --profile corporateprod

aws backup list-backup-selections --backup-plan-id 42b69383-b29a-48b1-8092-4d0e4fbfb42b --profile corporateprod
# {
#     "BackupSelectionsList": [
#         {
#             "SelectionId": "7142e7e8-8947-47e4-bea7-5841b2e180a0",
#             "SelectionName": "backup-selection-corporateprod",
#             "BackupPlanId": "42b69383-b29a-48b1-8092-4d0e4fbfb42b",
#             "CreationDate": "2024-12-12T14:43:32.677000-03:00",
#             "IamRoleArn": "arn:aws:iam::564593125549:role/aws-service-role/backup.amazonaws.com/AWSServiceRoleForBackup"
#         }
#     ]
# }

aws backup create-backup-selection --cli-input-json file://backup-selection.json --profile corporateprod
# {
#     "SelectionId": "db52ac28-e384-49ed-9f8c-dfbde92b9344",
#     "BackupPlanId": "42b69383-b29a-48b1-8092-4d0e4fbfb42b",
#     "CreationDate": "2024-12-13T15:49:48.291000-03:00"
# }
