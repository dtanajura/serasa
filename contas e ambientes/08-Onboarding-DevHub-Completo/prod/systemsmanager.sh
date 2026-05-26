# Criar a função IAM:
aws iam create-role --role-name BURoleForSSM-Instance-Role --assume-role-policy-document file://BURoleforSSM.json --profile devhub-prod --no-verify-ssl
## BURoleforSSM.json
# {
#   "Version": "2012-10-17",
#   "Statement": {
#     "Effect": "Allow",
#     "Principal": {
#       "Service": "ec2.amazonaws.com"
#     },
#     "Action": "sts:AssumeRole"
#   }
# }

# ===> Este comando cria uma função chamada "SSM-Instance-Role" que pode ser assumida por instâncias EC2.

# Anexar a política do Systems Manager à função:
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile devhub-prod --no-verify-ssl
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy  --profile devhub-prod --no-verify-ssl
# ===> Este comando anexa a política do Systems Manager à função para conceder permissões de gerenciamento básicas.

# Criar um perfil IAM para as instâncias EC2:
aws iam create-instance-profile --instance-profile-name SSM-Instance-Profile  --profile devhub-prod --no-verify-ssl

# Adicionar a função à instância do perfil IAM:
aws iam add-role-to-instance-profile --instance-profile-name SSM-Instance-Profile --role-name BURoleForSSM-Instance-Role   --profile devhub-prod --no-verify-ssl

# Criar uma chave
aws ec2 create-key-pair --key-name bastion-devhub-prod --key-type rsa --query "KeyMaterial" --profile devhub-prod --no-verify-ssl --output text > bastion-devhub-prod.pem

# Criar Security Group para o Bastion
aws ec2 create-security-group --group-name SG-Bastion --description "SG para acesso ao bastion" --vpc-id vpc-0b4a9286d9288da07 --region sa-east-1 --profile devhub-prod --no-verify-ssl
# {
#     "GroupId": "sg-0de4fcb2a01197c3f"
# }


aws ec2 authorize-security-group-ingress --group-id sg-0de4fcb2a01197c3f --protocol tcp --port 22 --cidr 10.0.0.0/8 --profile devhub-prod --no-verify-ssl

# Lançar ou atualizar instâncias EC2 associadas ao perfil IAM:
aws ec2 run-instances --image-id ami-0e2c5604ae8bb1c54 --subnet-id subnet-0a43f7aad6d89c36e --key-name bastion-devhub-prod --security-group-ids sg-0de4fcb2a01197c3f --instance-type t3.micro --iam-instance-profile Name=SSM-Instance-Profile --profile devhub-prod --no-verify-ssl
aws ec2 create-tags --resources i-0e0570cede267b07d --tags Key=Name,Value='bastion-devhub-prod' --profile devhub-prod --no-verify-ssl
aws ec2 create-tags --resources i-0e0570cede267b07d --tags Key=CostString,Value='1800.BR.134.607500' Key=Environment,Value='prd' Key=AppID,Value='21231' Key=CentrifyUnixRole,Value='' Key=ResourceName,Value='devhub-bastion' Key=ResourceAppRole,Value='app' Key=ResourceOwner,Value='devhub_team@br.experian.com' Key=adDomain,Value='br.experian.local' Key=adGroup,Value='' --profile devhub-prod --no-verify-ssl

# Criar o Patch Baseline
aws ssm create-patch-baseline --name "Baseline_AMZLinux2" --operating-system "AMAZON_LINUX_2" --approval-rules "PatchRules=[{PatchFilterGroup={PatchFilters=[{Key=PRODUCT,Values=[AmazonLinux2,AmazonLinux2.0]},{Key=CLASSIFICATION,Values=[Bugfix,Enhancement,Newpackage,Recommended,Security]},{Key=SEVERITY,Values=[Critical,Important,Medium]}]},ApproveAfterDays=7}]" --profile devhub-prod --no-verify-ssl
aws ssm update-patch-baseline --baseline-id pb-0290e706eee5049ce   --approved-patches-enable-non-security --approval-rules "PatchRules=[{PatchFilterGroup={PatchFilters=[{Key=PRODUCT,Values=[AmazonLinux2,AmazonLinux2.0]},{Key=CLASSIFICATION,Values=[Bugfix,Enhancement,Newpackage,Recommended,Security]},{Key=SEVERITY,Values=[Critical,Important,Medium]}]},ApproveAfterDays=7,EnableNonSecurity=true}]" --profile devhub-prod --no-verify-ssl
aws ssm register-default-patch-baseline --baseline-id pb-0290e706eee5049ce  --profile devhub-prod --no-verify-ssl
aws ssm get-default-patch-baseline --operating-system AMAZON_LINUX_2 --profile devhub-prod --no-verify-ssl
# Rodar o quick setup para criar a patch policy
aws ec2 create-tags --resources i-0e0570cede267b07d --tags Key=PatchGroup,Value='PatchGroup01' --profile devhub-prod --no-verify-ssl

# Criar a janela de manutenção para instalação dos poatches
aws ssm create-maintenance-window --name "Patches-Terca" --schedule "cron(0 22 ? * TUE *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devhub-prod --no-verify-ssl
aws ssm register-target-with-maintenance-window --window-id "mw-0b31e4bee4769a6c0" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira " --profile devhub-prod --no-verify-ssl
aws ssm register-task-with-maintenance-window --window-id "mw-0b31e4bee4769a6c0" --targets "Key=WindowTargetIds,Values=841c5d7d-f185-4315-b957-c69cdc65c468" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::306298826605:role/service-role/SSMMaintenanceWindowRole" --max-concurrency 5 --max-errors 1 --profile devhub-prod --no-verify-ssl
# Lembrar de colocar o número da conta no ARN, alem do window-id e do windowtargetid
aws ssm create-maintenance-window --name "Patches-Quarta" --schedule "cron(0 22 ? * WED *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devhub-prod --no-verify-ssl
aws ssm register-target-with-maintenance-window --window-id "mw-03644349f2d2eb401" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira " --profile devhub-prod --no-verify-ssl
aws ssm register-task-with-maintenance-window --window-id "mw-03644349f2d2eb401" --targets "Key=WindowTargetIds,Values=7c41f8b1-cc03-4eaa-a6a9-d5d5f221b1c0" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::306298826605:role/service-role/SSMMaintenanceWindowRole" --max-concurrency 5 --max-errors 1 --profile devhub-prod --no-verify-ssl
aws ssm create-maintenance-window --name "Patches-Quinta" --schedule "cron(0 22 ? * THU *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devhub-prod --no-verify-ssl
aws ssm register-target-with-maintenance-window --window-id "mw-0cbb2d54b365482ee" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira " --profile devhub-prod --no-verify-ssl
aws ssm register-task-with-maintenance-window --window-id "mw-0cbb2d54b365482ee" --targets "Key=WindowTargetIds,Values=15bd9204-a8b5-4721-8654-04922a3e7161" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::306298826605:role/service-role/SSMMaintenanceWindowRole" --max-concurrency 5 --max-errors 1 --profile devhub-prod --no-verify-ssl

#### AWS Backup
# Create a backup vault by running:
aws backup create-backup-vault --backup-vault-name backup-vault-devhub-prod --profile devhub-prod --no-verify-ssl

# Create a backup plan by running 
aws backup create-backup-plan --cli-input-json file://backup-plan.json --profile devhub-prod --no-verify-ssl
# {
#     "BackupPlanId": "2fea05c4-d951-4afc-8ab8-ee5f4f7bb6c7",
#     "BackupPlanArn": "arn:aws:backup:sa-east-1:306298826605:backup-plan:2fea05c4-d951-4afc-8ab8-ee5f4f7bb6c7",
#     "CreationDate": "2023-10-27T15:41:54.093000-03:00",
#     "VersionId": "NjdiNmY0NmQtZmY2OC00OWEyLTk2NGItZGRiMDk0ODJlZjYy"
# }


# Create a backup selection by running:
aws backup create-backup-selection --cli-input-json file://backup-selection.json  --profile devhub-prod --no-verify-ssl
aws ec2 create-tags --resources i-0e0570cede267b07d --tags Key=Backup,Value='True' --profile devhub-prod --no-verify-ssl

# Alterar o backup selection
aws backup list-backup-plans  --profile devhub-prod --no-verify-ssl 
aws backup list-backup-selections --backup-plan-id 2fea05c4-d951-4afc-8ab8-ee5f4f7bb6c7  --profile devhub-prod --no-verify-ssl
aws backup delete-backup-selection --backup-plan-id 2fea05c4-d951-4afc-8ab8-ee5f4f7bb6c7 --selection-id 17ee8759-2857-4375-9265-c5dd799ba5ff --profile devhub-prod --no-verify-ssl
aws backup create-backup-selection --cli-input-json file://backup-selection.json  --profile devhub-prod --no-verify-ssl

aws iam create-role --role-name AWSBackupDefaultServiceRole --assume-role-policy-document file://assumerole-backupservice.json  --profile devhub-prod --no-verify-ssl
aws iam attach-role-policy --role-name AWSBackupDefaultServiceRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup  --profile devhub-prod --no-verify-ssl
aws iam attach-role-policy --role-name AWSBackupDefaultServiceRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores  --profile devhub-prod --no-verify-ssl

aws iam create-role --role-name BURoleForDevHubSSMMaintenanceWindow --assume-role-policy-document file://assumerole_BURoleForDevHubSSMMaintenanceWindow.json  --profile devhub-prod --no-verify-ssl
aws iam create-policy --policy-name BUPolicyForDevHubSSMMaintenanceWindow --policy-document file://BUPolicyForDevHubSSMMaintenanceWindow.json  --profile devhub-prod --no-verify-ssl
aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::306298826605:policy/BUPolicyForDevHubSSMMaintenanceWindow  --profile devhub-prod --no-verify-ssl

### Refazendo configuração das Janelas de aplicação de patches
## listar janelas
aws ssm describe-maintenance-windows --profile devhub-prod --no-verify-ssl --query "WindowIdentities[].[WindowId,Name]" --output text
mw-0b31e4bee4769a6c0    Patches-Terca
mw-03644349f2d2eb401    Patches-Quarta
mw-0cbb2d54b365482ee    Patches-Quinta

##########################
#### Terça
##########################
aws ssm describe-maintenance-window-tasks --window-id mw-0b31e4bee4769a6c0 --profile devhub-prod --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
478f24e4-b563-4ff8-9d43-e82b55ba5aa7

aws ssm describe-maintenance-window-targets --window-id mw-0b31e4bee4769a6c0 --profile devhub-prod --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
841c5d7d-f185-4315-b957-c69cdc65c468

aws ssm deregister-target-from-maintenance-window --window-id mw-0b31e4bee4769a6c0 --window-target-id 841c5d7d-f185-4315-b957-c69cdc65c468 --profile devhub-prod --no-verify-ssl

aws ssm deregister-task-from-maintenance-window --window-id mw-0b31e4bee4769a6c0 --window-task-id 478f24e4-b563-4ff8-9d43-e82b55ba5aa7 --profile devhub-prod --no-verify-ssl

aws ssm register-target-with-maintenance-window --window-id "mw-0b31e4bee4769a6c0" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira" --profile devhub-prod --no-verify-ssl
42e54f7f-306e-4683-878b-f9dd2c91657d

aws ssm register-task-with-maintenance-window --window-id "mw-0b31e4bee4769a6c0" --targets "Key=WindowTargetIds,Values=42e54f7f-306e-4683-878b-f9dd2c91657d" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::306298826605:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devhub-prod --no-verify-ssl
"WindowTaskId": "756dc346-00f3-4b53-a3b9-9a9a147b53f8"

##########################
#### Quarta
##########################
aws ssm describe-maintenance-window-tasks --window-id mw-03644349f2d2eb401 --profile devhub-prod --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
# 86a13981-322e-488f-b20e-dedabd2987c5

aws ssm describe-maintenance-window-targets --window-id mw-03644349f2d2eb401 --profile devhub-prod --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
# 7c41f8b1-cc03-4eaa-a6a9-d5d5f221b1c0

aws ssm deregister-target-from-maintenance-window --window-id mw-03644349f2d2eb401 --window-target-id 7c41f8b1-cc03-4eaa-a6a9-d5d5f221b1c0 --profile devhub-prod --no-verify-ssl

aws ssm deregister-task-from-maintenance-window --window-id mw-03644349f2d2eb401  --window-task-id 86a13981-322e-488f-b20e-dedabd2987c5 --profile devhub-prod --no-verify-ssl

aws ssm register-target-with-maintenance-window --window-id "mw-03644349f2d2eb401" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira" --profile devhub-prod --no-verify-ssl
543b22df-7349-4e68-b91a-cdf002f54e8b

aws ssm register-task-with-maintenance-window --window-id "mw-03644349f2d2eb401" --targets "Key=WindowTargetIds,Values=543b22df-7349-4e68-b91a-cdf002f54e8b" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::306298826605:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devhub-prod --no-verify-ssl
"WindowTaskId": "62f0f4c3-7724-465d-bac1-17797d734026"

##########################
#### Quinta
##########################
aws ssm describe-maintenance-window-tasks --window-id mw-0cbb2d54b365482ee --profile devhub-prod --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
8f941347-ec71-4baf-9ce8-04008601661a

aws ssm describe-maintenance-window-targets --window-id mw-0cbb2d54b365482ee --profile devhub-prod --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
15bd9204-a8b5-4721-8654-04922a3e7161

aws ssm deregister-target-from-maintenance-window --window-id mw-0cbb2d54b365482ee --window-target-id 15bd9204-a8b5-4721-8654-04922a3e7161 --profile devhub-prod --no-verify-ssl

aws ssm deregister-task-from-maintenance-window --window-id mw-0cbb2d54b365482ee --window-task-id 8f941347-ec71-4baf-9ce8-04008601661a --profile devhub-prod --no-verify-ssl

aws ssm register-target-with-maintenance-window --window-id "mw-0cbb2d54b365482ee" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira" --profile devhub-prod --no-verify-ssl
a19558f8-1041-4f1d-bd4b-0994da6be74e

aws ssm register-task-with-maintenance-window --window-id "mw-0cbb2d54b365482ee" --targets "Key=WindowTargetIds,Values=a19558f8-1041-4f1d-bd4b-0994da6be74e" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::306298826605:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devhub-prod --no-verify-ssl
"WindowTaskId": "508ab604-b537-467f-946a-8e2a1bf14dfd"

aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile devhub-prod --no-verify-ssl

### Ajuste das tasks
# Ajutar policy da Role para execução das tasks
aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile devhub-prod --no-verify-ssl

# Listar Maintenance Windows
aws ssm describe-maintenance-windows --profile devhub-prod --no-verify-ssl --query "WindowIdentities[].[WindowId,Name]" --output text
mw-0b31e4bee4769a6c0    Patches-Terca
mw-03644349f2d2eb401    Patches-Quarta
mw-0cbb2d54b365482ee    Patches-Quinta

# Excluir target
# Terça
aws ssm describe-maintenance-window-targets --window-id mw-0b31e4bee4769a6c0 --profile devhub-prod --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
42e54f7f-306e-4683-878b-f9dd2c91657d
aws ssm deregister-target-from-maintenance-window --window-id mw-0b31e4bee4769a6c0 --window-target-id 42e54f7f-306e-4683-878b-f9dd2c91657d --profile devhub-prod --no-verify-ssl
# Quarta
aws ssm describe-maintenance-window-targets --window-id mw-03644349f2d2eb401 --profile devhub-prod --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
543b22df-7349-4e68-b91a-cdf002f54e8b
aws ssm deregister-target-from-maintenance-window --window-id mw-03644349f2d2eb401 --window-target-id 543b22df-7349-4e68-b91a-cdf002f54e8b --profile devhub-prod --no-verify-ssl
# Quinta
aws ssm describe-maintenance-window-targets --window-id mw-0cbb2d54b365482ee --profile devhub-prod --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
a19558f8-1041-4f1d-bd4b-0994da6be74e
aws ssm deregister-target-from-maintenance-window --window-id mw-0cbb2d54b365482ee  --window-target-id a19558f8-1041-4f1d-bd4b-0994da6be74e --profile devhub-prod --no-verify-ssl

# Excluir task atual
# Terça
aws ssm describe-maintenance-window-tasks --window-id mw-0b31e4bee4769a6c0 --profile devhub-prod --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
fa0c4bc7-b066-4b85-bccd-afdc503e395d

aws ssm deregister-task-from-maintenance-window --window-id mw-0b31e4bee4769a6c0 --window-task-id "fa0c4bc7-b066-4b85-bccd-afdc503e395d" --profile devhub-prod --no-verify-ssl 
# Quarta
aws ssm describe-maintenance-window-tasks --window-id mw-03644349f2d2eb401 --profile devhub-prod --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
62f0f4c3-7724-465d-bac1-17797d734026

aws ssm deregister-task-from-maintenance-window --window-id mw-03644349f2d2eb401 --window-task-id "62f0f4c3-7724-465d-bac1-17797d734026" --profile devhub-prod --no-verify-ssl 
# Quinta
aws ssm describe-maintenance-window-tasks --window-id mw-0cbb2d54b365482ee --profile devhub-prod --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
508ab604-b537-467f-946a-8e2a1bf14dfd

aws ssm deregister-task-from-maintenance-window --window-id mw-0cbb2d54b365482ee --window-task-id "508ab604-b537-467f-946a-8e2a1bf14dfd" --profile devhub-prod --no-verify-ssl 
# Criar uma nova target
# Terça
aws ssm register-target-with-maintenance-window --window-id mw-0b31e4bee4769a6c0 --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira " --profile devhub-prod --no-verify-ssl
d9f41d31-50be-40ed-bc3f-445b3c3fb927

aws ssm register-task-with-maintenance-window --window-id mw-0b31e4bee4769a6c0  --targets "Key=WindowTargetIds,Values=d9f41d31-50be-40ed-bc3f-445b3c3fb927" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::306298826605:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devhub-prod --no-verify-ssl
# Quarta
aws ssm register-target-with-maintenance-window --window-id mw-03644349f2d2eb401 --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira " --profile devhub-prod --no-verify-ssl
563077ee-734b-428d-b871-d1d189dc259a

aws ssm register-task-with-maintenance-window --window-id mw-03644349f2d2eb401  --targets "Key=WindowTargetIds,Values=563077ee-734b-428d-b871-d1d189dc259a" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::306298826605:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devhub-prod --no-verify-ssl
# Quinta
aws ssm register-target-with-maintenance-window --window-id mw-0cbb2d54b365482ee --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira " --profile devhub-prod --no-verify-ssl
51ad7b6c-0184-4e2c-afbe-2ee434fb5dd1

aws ssm register-task-with-maintenance-window --window-id mw-0cbb2d54b365482ee  --targets "Key=WindowTargetIds,Values=51ad7b6c-0184-4e2c-afbe-2ee434fb5dd1" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::306298826605:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devhub-prod --no-verify-ssl
