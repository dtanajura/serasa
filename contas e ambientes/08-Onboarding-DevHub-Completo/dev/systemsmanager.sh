# Criar a função IAM:
aws iam create-role --role-name BURoleForSSM-Instance-Role --assume-role-policy-document file://BURoleforSSM.json --profile devhub-dev --no-verify-ssl
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
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile devhub-dev --no-verify-ssl
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy  --profile devhub-dev --no-verify-ssl
# ===> Este comando anexa a política do Systems Manager à função para conceder permissões de gerenciamento básicas.

# Criar um perfil IAM para as instâncias EC2:
aws iam create-instance-profile --instance-profile-name SSM-Instance-Profile  --profile devhub-dev --no-verify-ssl

# Adicionar a função à instância do perfil IAM:
aws iam add-role-to-instance-profile --instance-profile-name SSM-Instance-Profile --role-name BURoleForSSM-Instance-Role   --profile devhub-dev --no-verify-ssl

# Criar uma chave
aws ec2 create-key-pair --key-name bastion-devhub-dev --key-type rsa --query "KeyMaterial" --profile devhub-dev --no-verify-ssl --output text > bastion-devhub-dev.pem

# Criar Security Group para o Bastion
aws ec2 create-security-group --group-name SG-Bastion --description "SG para acesso ao bastion" --vpc-id vpc-00c8ba3ca859c6546 --region sa-east-1 --profile devhub-dev --no-verify-ssl
# {
#     "GroupId": "sg-0aac9150117d27336"
# }


aws ec2 authorize-security-group-ingress --group-id sg-0aac9150117d27336 --protocol tcp --port 22 --cidr 10.0.0.0/8 --profile devhub-dev --no-verify-ssl

# Lançar ou atualizar instâncias EC2 associadas ao perfil IAM:
aws ec2 run-instances --image-id ami-0e2c5604ae8bb1c54 --subnet-id subnet-086adfca9bc8df6aa --key-name bastion-devhub-dev --security-group-ids sg-0aac9150117d27336 --instance-type t3.micro --iam-instance-profile Name=SSM-Instance-Profile --profile devhub-dev --no-verify-ssl
aws ec2 create-tags --resources i-06fe4d5c9e8d8d142 --tags Key=Name,Value='bastion-devhub-dev' --profile devhub-dev --no-verify-ssl
aws ec2 create-tags --resources i-06fe4d5c9e8d8d142 --tags Key=CostString,Value='1800.BR.134.607500' Key=Environment,Value='dev' Key=AppID,Value='21231' Key=CentrifyUnixRole,Value='' Key=ResourceName,Value='devhub-bastion' Key=ResourceAppRole,Value='app' Key=ResourceOwner,Value='devhub_team@br.experian.com' Key=adDomain,Value='br.experian.local' Key=adGroup,Value='' --profile devhub-dev --no-verify-ssl

# Criar o Patch Baseline
aws ssm create-patch-baseline --name "Baseline_AMZLinux2" --operating-system "AMAZON_LINUX_2" --approval-rules "PatchRules=[{PatchFilterGroup={PatchFilters=[{Key=PRODUCT,Values=[AmazonLinux2,AmazonLinux2.0]},{Key=CLASSIFICATION,Values=[Bugfix,Enhancement,Newpackage,Recommended,Security]},{Key=SEVERITY,Values=[Critical,Important,Medium]}]},ApproveAfterDays=7}]" --profile devhub-dev --no-verify-ssl
aws ssm update-patch-baseline --baseline-id pb-0586d3df545388ebd   --approved-patches-enable-non-security --approval-rules "PatchRules=[{PatchFilterGroup={PatchFilters=[{Key=PRODUCT,Values=[AmazonLinux2,AmazonLinux2.0]},{Key=CLASSIFICATION,Values=[Bugfix,Enhancement,Newpackage,Recommended,Security]},{Key=SEVERITY,Values=[Critical,Important,Medium]}]},ApproveAfterDays=7,EnableNonSecurity=true}]" --profile devhub-dev --no-verify-ssl
aws ssm register-default-patch-baseline --baseline-id pb-0586d3df545388ebd  --profile devhub-dev --no-verify-ssl
aws ssm get-default-patch-baseline --operating-system AMAZON_LINUX_2 --profile devhub-dev --no-verify-ssl
# Rodar o quick setup para criar a patch policy
aws ec2 create-tags --resources i-06fe4d5c9e8d8d142 --tags Key=PatchGroup,Value='PatchGroup02' --profile devhub-dev --no-verify-ssl

# Criar a janela de manutenção para instalação dos poatches
aws ssm create-maintenance-window --name "Patches-Terca" --schedule "cron(0 22 ? * TUE *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devhub-dev --no-verify-ssl
aws ssm register-target-with-maintenance-window --window-id "mw-01d17de7f614e0d24" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira " --profile devhub-dev --no-verify-ssl
aws ssm register-task-with-maintenance-window --window-id "mw-01d17de7f614e0d24" --targets "Key=WindowTargetIds,Values=a0331492-3595-4be7-886d-00712e7db13e" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::977554819825:role/service-role/SSMMaintenanceWindowRole" --max-concurrency 5 --max-errors 1 --profile devhub-dev --no-verify-ssl
# Lembrar de colocar o número da conta no ARN, alem do window-id e do windowtargetid
aws ssm create-maintenance-window --name "Patches-Quarta" --schedule "cron(0 22 ? * WED *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devhub-dev --no-verify-ssl
aws ssm register-target-with-maintenance-window --window-id "mw-0c2ff52256773709f" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira " --profile devhub-dev --no-verify-ssl
aws ssm register-task-with-maintenance-window --window-id "mw-0c2ff52256773709f" --targets "Key=WindowTargetIds,Values=b93500dc-c48e-42e6-88db-e08937a75753" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::977554819825:role/service-role/SSMMaintenanceWindowRole" --max-concurrency 5 --max-errors 1 --profile devhub-dev --no-verify-ssl
aws ssm create-maintenance-window --name "Patches-Quinta" --schedule "cron(0 22 ? * THU *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devhub-dev --no-verify-ssl
aws ssm register-target-with-maintenance-window --window-id "mw-0caceea7053eb8e6f" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira " --profile devhub-dev --no-verify-ssl
aws ssm register-task-with-maintenance-window --window-id "mw-0caceea7053eb8e6f" --targets "Key=WindowTargetIds,Values=85dd1376-472f-4b49-a5bb-8fe543ae6a27" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::977554819825:role/service-role/SSMMaintenanceWindowRole" --max-concurrency 5 --max-errors 1 --profile devhub-dev --no-verify-ssl

#### AWS Backup
# Create a backup vault by running:
aws backup create-backup-vault --backup-vault-name backup-vault-devhub-dev --profile devhub-dev --no-verify-ssl

# Create a backup plan by running 
aws backup create-backup-plan --cli-input-json file://backup-plan.json --profile devhub-dev --no-verify-ssl
# {
#     "BackupPlanId": "92c89611-27da-4264-9e73-855c263e77a8",
#     "BackupPlanArn": "arn:aws:backup:sa-east-1:977554819825:backup-plan:92c89611-27da-4264-9e73-855c263e77a8",
#     "CreationDate": "2023-10-26T16:33:55.727000-03:00",
#     "VersionId": "NWMxMWNjMDktYTY1Ny00ZTFjLWIxMDQtNDZjNGYwYzFhYTMw"
# }

# Create a backup selection by running:
aws backup create-backup-selection --cli-input-json file://backup-selection.json  --profile devhub-dev --no-verify-ssl
aws ec2 create-tags --resources i-06fe4d5c9e8d8d142 --tags Key=Backup,Value='True' --profile devhub-dev --no-verify-ssl

# Alterar o backup selection
aws backup list-backup-plans  --profile devhub-dev --no-verify-ssl 
aws backup list-backup-selections --backup-plan-id 92c89611-27da-4264-9e73-855c263e77a8  --profile devhub-dev --no-verify-ssl
aws backup delete-backup-selection --backup-plan-id 92c89611-27da-4264-9e73-855c263e77a8 --selection-id 8c07de00-2980-4c20-b16f-1d65026d1ee6 --profile devhub-dev --no-verify-ssl
aws backup create-backup-selection --cli-input-json file://backup-selection.json  --profile devhub-dev --no-verify-ssl

aws iam create-role --role-name AWSBackupDefaultServiceRole --assume-role-policy-document file://assumerole-backupservice.json  --profile devhub-dev --no-verify-ssl
aws iam attach-role-policy --role-name AWSBackupDefaultServiceRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup  --profile devhub-dev --no-verify-ssl
aws iam attach-role-policy --role-name AWSBackupDefaultServiceRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores  --profile devhub-dev --no-verify-ssl


Resource assignment name
Backup-Geral
IAM role
arn:aws:iam::328257591560:role/service-role/AWSBackupDefaultServiceRole
Assign by ARN prefix
arn:aws:ec2:*:*:instance/*
Tags - equal
aws:ResourceTag/Backup - True

aws iam create-role --role-name BURoleForDevHubSSMMaintenanceWindow --assume-role-policy-document file://assumerole_BURoleForDevHubSSMMaintenanceWindow.json  --profile devhub-dev --no-verify-ssl
aws iam create-policy --policy-name BUPolicyForDevHubSSMMaintenanceWindow --policy-document file://BUPolicyForDevHubSSMMaintenanceWindow.json  --profile devhub-dev --no-verify-ssl
aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::977554819825:policy/BUPolicyForDevHubSSMMaintenanceWindow  --profile devhub-dev --no-verify-ssl

### Refazendo configuração das Janelas de aplicação de patches
## listar janelas
aws ssm describe-maintenance-windows --profile devhub-dev --no-verify-ssl --query "WindowIdentities[].[WindowId,Name]" --output text
mw-01d17de7f614e0d24    Patches-Terca
mw-0c2ff52256773709f    Patches-Quarta
mw-0caceea7053eb8e6f    Patches-Quinta

##########################
#### Terça
##########################
aws ssm describe-maintenance-window-tasks --window-id mw-01d17de7f614e0d24 --profile devhub-dev --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
02ebd479-4d0d-4605-a027-383a8e132eb7

aws ssm describe-maintenance-window-targets --window-id mw-01d17de7f614e0d24 --profile devhub-dev --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
a0331492-3595-4be7-886d-00712e7db13e

aws ssm deregister-target-from-maintenance-window --window-id mw-01d17de7f614e0d24 --window-target-id a0331492-3595-4be7-886d-00712e7db13e --profile devhub-dev --no-verify-ssl

aws ssm deregister-task-from-maintenance-window --window-id mw-01d17de7f614e0d24 --window-task-id 02ebd479-4d0d-4605-a027-383a8e132eb7 --profile devhub-dev --no-verify-ssl

aws ssm register-target-with-maintenance-window --window-id "mw-01d17de7f614e0d24" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira" --profile devhub-dev --no-verify-ssl
3fbd06e8-ed3c-461f-92e5-6372241466aa

aws ssm register-task-with-maintenance-window --window-id "mw-01d17de7f614e0d24" --targets "Key=WindowTargetIds,Values=3fbd06e8-ed3c-461f-92e5-6372241466aa" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::977554819825:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devhub-dev --no-verify-ssl
"WindowTaskId": "edbf0a2b-599d-4af6-bb25-81ec42d0e26e"

##########################
#### Quarta
##########################
aws ssm describe-maintenance-window-tasks --window-id mw-0c2ff52256773709f --profile devhub-dev --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
39e19cb4-2750-4dba-aa79-a91a9af5ac18

aws ssm describe-maintenance-window-targets --window-id mw-0c2ff52256773709f --profile devhub-dev --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
b93500dc-c48e-42e6-88db-e08937a75753

aws ssm deregister-target-from-maintenance-window --window-id mw-0c2ff52256773709f --window-target-id b93500dc-c48e-42e6-88db-e08937a75753 --profile devhub-dev --no-verify-ssl

aws ssm deregister-task-from-maintenance-window --window-id mw-0c2ff52256773709f  --window-task-id 39e19cb4-2750-4dba-aa79-a91a9af5ac18 --profile devhub-dev --no-verify-ssl

aws ssm register-target-with-maintenance-window --window-id "mw-0c2ff52256773709f" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira" --profile devhub-dev --no-verify-ssl
924cc8a8-5267-4f9d-a686-63dff1d09f9c

aws ssm register-task-with-maintenance-window --window-id "mw-0c2ff52256773709f" --targets "Key=WindowTargetIds,Values=924cc8a8-5267-4f9d-a686-63dff1d09f9c" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::977554819825:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devhub-dev --no-verify-ssl
"WindowTaskId": "8be66b48-6e64-443c-8eab-f37d485b2d04"

##########################
#### Quinta
##########################
aws ssm describe-maintenance-window-tasks --window-id mw-0caceea7053eb8e6f --profile devhub-dev --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
4721ff29-8036-43a5-9f3b-db3f7f1cba9d

aws ssm describe-maintenance-window-targets --window-id mw-0caceea7053eb8e6f --profile devhub-dev --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
85dd1376-472f-4b49-a5bb-8fe543ae6a27

aws ssm deregister-target-from-maintenance-window --window-id mw-0caceea7053eb8e6f --window-target-id 85dd1376-472f-4b49-a5bb-8fe543ae6a27 --profile devhub-dev --no-verify-ssl

aws ssm deregister-task-from-maintenance-window --window-id mw-0caceea7053eb8e6f --window-task-id 4721ff29-8036-43a5-9f3b-db3f7f1cba9d --profile devhub-dev --no-verify-ssl

aws ssm register-target-with-maintenance-window --window-id "mw-0caceea7053eb8e6f" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira" --profile devhub-dev --no-verify-ssl
f1ced5f7-ac2e-4805-937a-13ad9138bcbf

aws ssm register-task-with-maintenance-window --window-id "mw-0caceea7053eb8e6f" --targets "Key=WindowTargetIds,Values=f1ced5f7-ac2e-4805-937a-13ad9138bcbf" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::977554819825:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devhub-dev --no-verify-ssl
"WindowTaskId": "5c9dbf23-57aa-4029-986e-183324a8fa54"

aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile devhub-dev --no-verify-ssl

### Ajuste das tasks
# Ajutar policy da Role para execução das tasks
aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile devhub-dev --no-verify-ssl

# Listar Maintenance Windows
aws ssm describe-maintenance-windows --profile devhub-dev --no-verify-ssl --query "WindowIdentities[].[WindowId,Name]" --output text
mw-01d17de7f614e0d24    Patches-Terca
mw-0c2ff52256773709f    Patches-Quarta
mw-0caceea7053eb8e6f    Patches-Quinta

# Excluir target
# Terça
aws ssm describe-maintenance-window-targets --window-id mw-01d17de7f614e0d24 --profile devhub-dev --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
3fbd06e8-ed3c-461f-92e5-6372241466aa
aws ssm deregister-target-from-maintenance-window --window-id mw-01d17de7f614e0d24 --window-target-id 3fbd06e8-ed3c-461f-92e5-6372241466aa --profile devhub-dev --no-verify-ssl
# Quarta
aws ssm describe-maintenance-window-targets --window-id mw-0c2ff52256773709f --profile devhub-dev --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
924cc8a8-5267-4f9d-a686-63dff1d09f9c
aws ssm deregister-target-from-maintenance-window --window-id mw-0c2ff52256773709f --window-target-id 924cc8a8-5267-4f9d-a686-63dff1d09f9c --profile devhub-dev --no-verify-ssl
# Quinta
aws ssm describe-maintenance-window-targets --window-id mw-0caceea7053eb8e6f --profile devhub-dev --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
f1ced5f7-ac2e-4805-937a-13ad9138bcbf
aws ssm deregister-target-from-maintenance-window --window-id mw-0caceea7053eb8e6f  --window-target-id f1ced5f7-ac2e-4805-937a-13ad9138bcbf --profile devhub-dev --no-verify-ssl

# Excluir task atual
# Terça
aws ssm describe-maintenance-window-tasks --window-id mw-01d17de7f614e0d24 --profile devhub-dev --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
edbf0a2b-599d-4af6-bb25-81ec42d0e26e

aws ssm deregister-task-from-maintenance-window --window-id mw-01d17de7f614e0d24 --window-task-id "edbf0a2b-599d-4af6-bb25-81ec42d0e26e" --profile devhub-dev --no-verify-ssl 
# Quarta
aws ssm describe-maintenance-window-tasks --window-id mw-0c2ff52256773709f --profile devhub-dev --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
8be66b48-6e64-443c-8eab-f37d485b2d04

aws ssm deregister-task-from-maintenance-window --window-id mw-0c2ff52256773709f --window-task-id "8be66b48-6e64-443c-8eab-f37d485b2d04" --profile devhub-dev --no-verify-ssl 
# Quinta
aws ssm describe-maintenance-window-tasks --window-id mw-0caceea7053eb8e6f --profile devhub-dev --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
5c9dbf23-57aa-4029-986e-183324a8fa54

aws ssm deregister-task-from-maintenance-window --window-id mw-0caceea7053eb8e6f --window-task-id "5c9dbf23-57aa-4029-986e-183324a8fa54" --profile devhub-dev --no-verify-ssl 
# Criar uma nova target
# Terça
aws ssm register-target-with-maintenance-window --window-id mw-01d17de7f614e0d24 --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira " --profile devhub-dev --no-verify-ssl
5d27a79f-40fe-46b8-a023-fc4819d6ca82

aws ssm register-task-with-maintenance-window --window-id mw-01d17de7f614e0d24  --targets "Key=WindowTargetIds,Values=5d27a79f-40fe-46b8-a023-fc4819d6ca82" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::977554819825:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devhub-dev --no-verify-ssl
# Quarta
aws ssm register-target-with-maintenance-window --window-id mw-0c2ff52256773709f --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira " --profile devhub-dev --no-verify-ssl
26387b73-ee54-43c7-8733-b313a2f437f7

aws ssm register-task-with-maintenance-window --window-id mw-0c2ff52256773709f  --targets "Key=WindowTargetIds,Values=26387b73-ee54-43c7-8733-b313a2f437f7" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::977554819825:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devhub-dev --no-verify-ssl
# Quinta
aws ssm register-target-with-maintenance-window --window-id mw-0caceea7053eb8e6f --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira " --profile devhub-dev --no-verify-ssl
8129fc94-79b0-4550-b24b-10312ab40ae5

aws ssm register-task-with-maintenance-window --window-id mw-0caceea7053eb8e6f  --targets "Key=WindowTargetIds,Values=8129fc94-79b0-4550-b24b-10312ab40ae5" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::977554819825:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devhub-dev --no-verify-ssl
