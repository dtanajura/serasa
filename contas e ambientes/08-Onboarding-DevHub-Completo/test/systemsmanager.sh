# Criar a função IAM:
aws iam create-role --role-name BURoleForSSM-Instance-Role --assume-role-policy-document file://BURoleforSSM.json --profile devhub-test --no-verify-ssl
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
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile devhub-test --no-verify-ssl
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy  --profile devhub-test --no-verify-ssl
# ===> Este comando anexa a política do Systems Manager à função para conceder permissões de gerenciamento básicas.

# Criar um perfil IAM para as instâncias EC2:
aws iam create-instance-profile --instance-profile-name SSM-Instance-Profile  --profile devhub-test --no-verify-ssl

# Adicionar a função à instância do perfil IAM:
aws iam add-role-to-instance-profile --instance-profile-name SSM-Instance-Profile --role-name BURoleForSSM-Instance-Role   --profile devhub-test --no-verify-ssl

# Criar uma chave
aws ec2 create-key-pair --key-name bastion-devhub-test --key-type rsa --query "KeyMaterial" --profile devhub-test --no-verify-ssl --output text > bastion-devhub-test.pem

# Criar Security Group para o Bastion
aws ec2 create-security-group --group-name SG-Bastion --description "SG para acesso ao bastion" --vpc-id vpc-0caa86767b44fe141 --region sa-east-1 --profile devhub-test --no-verify-ssl
# {
#     "GroupId": "sg-056ff36e3a521f143"
# }


aws ec2 authorize-security-group-ingress --group-id sg-056ff36e3a521f143 --protocol tcp --port 22 --cidr 10.0.0.0/8 --profile devhub-test --no-verify-ssl

# Lançar ou atualizar instâncias EC2 associadas ao perfil IAM:
aws ec2 run-instances --image-id ami-0e2c5604ae8bb1c54 --subnet-id subnet-0167345181547d50c --key-name bastion-devhub-test --security-group-ids sg-056ff36e3a521f143 --instance-type t3.micro --iam-instance-profile Name=SSM-Instance-Profile --profile devhub-test --no-verify-ssl
aws ec2 create-tags --resources i-01498b537887e5910 --tags Key=Name,Value='bastion-devhub-test' --profile devhub-test --no-verify-ssl
aws ec2 create-tags --resources i-01498b537887e5910 --tags Key=CostString,Value='1800.BR.134.607500' Key=Environment,Value='uat' Key=AppID,Value='21231' Key=CentrifyUnixRole,Value='' Key=ResourceName,Value='devhub-bastion' Key=ResourceAppRole,Value='app' Key=ResourceOwner,Value='devhub_team@br.experian.com' Key=adDomain,Value='br.experian.local' Key=adGroup,Value='' --profile devhub-test --no-verify-ssl

# Criar o Patch Baseline
aws ssm create-patch-baseline --name "Baseline_AMZLinux2" --operating-system "AMAZON_LINUX_2" --approval-rules "PatchRules=[{PatchFilterGroup={PatchFilters=[{Key=PRODUCT,Values=[AmazonLinux2,AmazonLinux2.0]},{Key=CLASSIFICATION,Values=[Bugfix,Enhancement,Newpackage,Recommended,Security]},{Key=SEVERITY,Values=[Critical,Important,Medium]}]},ApproveAfterDays=7}]" --profile devhub-test --no-verify-ssl
aws ssm update-patch-baseline --baseline-id pb-05653c54577372060   --approved-patches-enable-non-security --approval-rules "PatchRules=[{PatchFilterGroup={PatchFilters=[{Key=PRODUCT,Values=[AmazonLinux2,AmazonLinux2.0]},{Key=CLASSIFICATION,Values=[Bugfix,Enhancement,Newpackage,Recommended,Security]},{Key=SEVERITY,Values=[Critical,Important,Medium]}]},ApproveAfterDays=7,EnableNonSecurity=true}]" --profile devhub-test --no-verify-ssl
aws ssm register-default-patch-baseline --baseline-id pb-05653c54577372060  --profile devhub-test --no-verify-ssl
aws ssm get-default-patch-baseline --operating-system AMAZON_LINUX_2 --profile devhub-test --no-verify-ssl
# Rodar o quick setup para criar a patch policy
aws ec2 create-tags --resources i-01498b537887e5910 --tags Key=PatchGroup,Value='PatchGroup01' --profile devhub-test --no-verify-ssl

# Criar a janela de manutenção para instalação dos poatches
aws ssm create-maintenance-window --name "Patches-Terca" --schedule "cron(0 22 ? * TUE *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devhub-test --no-verify-ssl
aws ssm register-target-with-maintenance-window --window-id "mw-0476d3e5612fe58fe" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira " --profile devhub-test --no-verify-ssl
aws ssm register-task-with-maintenance-window --window-id "mw-0476d3e5612fe58fe" --targets "Key=WindowTargetIds,Values=5e8f4a11-0086-43ac-a784-ad3c713e5e22" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::838498078144:role/service-role/SSMMaintenanceWindowRole" --max-concurrency 5 --max-errors 1 --profile devhub-test --no-verify-ssl
# Lembrar de colocar o número da conta no ARN, alem do window-id e do windowtargetid
aws ssm create-maintenance-window --name "Patches-Quarta" --schedule "cron(0 22 ? * WED *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devhub-test --no-verify-ssl
aws ssm register-target-with-maintenance-window --window-id "mw-0aecd8a4ba7d1a533" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira " --profile devhub-test --no-verify-ssl
aws ssm register-task-with-maintenance-window --window-id "mw-0aecd8a4ba7d1a533" --targets "Key=WindowTargetIds,Values=05eab071-e050-4257-ae15-fbd3a79a9a76" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::838498078144:role/service-role/SSMMaintenanceWindowRole" --max-concurrency 5 --max-errors 1 --profile devhub-test --no-verify-ssl
aws ssm create-maintenance-window --name "Patches-Quinta" --schedule "cron(0 22 ? * THU *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devhub-test --no-verify-ssl
aws ssm register-target-with-maintenance-window --window-id "mw-0053158620501cfaa" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira " --profile devhub-test --no-verify-ssl
aws ssm register-task-with-maintenance-window --window-id "mw-0053158620501cfaa" --targets "Key=WindowTargetIds,Values=fd87726e-4f6d-402f-9fd3-38ae21da96a9" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::838498078144:role/service-role/SSMMaintenanceWindowRole" --max-concurrency 5 --max-errors 1 --profile devhub-test --no-verify-ssl

#### AWS Backup
# Create a backup vault by running:
aws backup create-backup-vault --backup-vault-name backup-vault-devhub-test --profile devhub-test --no-verify-ssl

# Create a backup plan by running 
aws backup create-backup-plan --cli-input-json file://backup-plan.json --profile devhub-test --no-verify-ssl
# {
#     "BackupPlanId": "5f10cfc6-d0e9-48c1-aaf4-9b8374b1fa58",
#     "BackupPlanArn": "arn:aws:backup:sa-east-1:838498078144:backup-plan:5f10cfc6-d0e9-48c1-aaf4-9b8374b1fa58",
#     "CreationDate": "2023-10-27T15:41:54.093000-03:00",
#     "VersionId": "NjdiNmY0NmQtZmY2OC00OWEyLTk2NGItZGRiMDk0ODJlZjYy"
# }


# Create a backup selection by running:
aws backup create-backup-selection --cli-input-json file://backup-selection.json  --profile devhub-test --no-verify-ssl
aws ec2 create-tags --resources i-01498b537887e5910 --tags Key=Backup,Value='True' --profile devhub-test --no-verify-ssl

# Alterar o backup selection
aws backup list-backup-plans  --profile devhub-test --no-verify-ssl 
aws backup list-backup-selections --backup-plan-id 5f10cfc6-d0e9-48c1-aaf4-9b8374b1fa58  --profile devhub-test --no-verify-ssl
aws backup delete-backup-selection --backup-plan-id 5f10cfc6-d0e9-48c1-aaf4-9b8374b1fa58 --selection-id dfd38ef9-70d8-4700-ac25-f9cf6564a647 --profile devhub-test --no-verify-ssl
aws backup create-backup-selection --cli-input-json file://backup-selection.json  --profile devhub-test --no-verify-ssl


aws iam create-role --role-name AWSBackupDefaultServiceRole --assume-role-policy-document file://assumerole-backupservice.json  --profile devhub-test --no-verify-ssl
aws iam attach-role-policy --role-name AWSBackupDefaultServiceRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup  --profile devhub-test --no-verify-ssl
aws iam attach-role-policy --role-name AWSBackupDefaultServiceRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores  --profile devhub-test --no-verify-ssl

aws iam create-role --role-name BURoleForDevHubSSMMaintenanceWindow --assume-role-policy-document file://assumerole_BURoleForDevHubSSMMaintenanceWindow.json  --profile devhub-test --no-verify-ssl
aws iam create-policy --policy-name BUPolicyForDevHubSSMMaintenanceWindow --policy-document file://BUPolicyForDevHubSSMMaintenanceWindow.json  --profile devhub-test --no-verify-ssl
aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::838498078144:policy/BUPolicyForDevHubSSMMaintenanceWindow  --profile devhub-test --no-verify-ssl

### Refazendo configuração das Janelas de aplicação de patches
## listar janelas
aws ssm describe-maintenance-windows --profile devhub-test --no-verify-ssl --query "WindowIdentities[].[WindowId,Name]" --output text
mw-0476d3e5612fe58fe    Patches-Terca
mw-0aecd8a4ba7d1a533    Patches-Quarta
mw-0053158620501cfaa    Patches-Quinta

##########################
#### Terça
##########################
aws ssm describe-maintenance-window-tasks --window-id mw-0476d3e5612fe58fe --profile devhub-test --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
44cd53f3-1eb8-4762-b053-2e4658470641

aws ssm describe-maintenance-window-targets --window-id mw-0476d3e5612fe58fe --profile devhub-test --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
5e8f4a11-0086-43ac-a784-ad3c713e5e22

aws ssm deregister-target-from-maintenance-window --window-id mw-0476d3e5612fe58fe --window-target-id 5e8f4a11-0086-43ac-a784-ad3c713e5e22 --profile devhub-test --no-verify-ssl

aws ssm deregister-task-from-maintenance-window --window-id mw-0476d3e5612fe58fe --window-task-id 44cd53f3-1eb8-4762-b053-2e4658470641 --profile devhub-test --no-verify-ssl

aws ssm register-target-with-maintenance-window --window-id "mw-0476d3e5612fe58fe" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira" --profile devhub-test --no-verify-ssl
85eb6799-cf2b-4e5c-a405-f8048d263545

aws ssm register-task-with-maintenance-window --window-id "mw-0476d3e5612fe58fe" --targets "Key=WindowTargetIds,Values=85eb6799-cf2b-4e5c-a405-f8048d263545" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::838498078144:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devhub-test --no-verify-ssl
"WindowTaskId": "756dc346-00f3-4b53-a3b9-9a9a147b53f8"

##########################
#### Quarta
##########################
aws ssm describe-maintenance-window-tasks --window-id mw-0aecd8a4ba7d1a533 --profile devhub-test --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
# c4cf4eb3-60c5-43ca-9579-23b31aa97250

aws ssm describe-maintenance-window-targets --window-id mw-0aecd8a4ba7d1a533 --profile devhub-test --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
# 05eab071-e050-4257-ae15-fbd3a79a9a76

aws ssm deregister-target-from-maintenance-window --window-id mw-0aecd8a4ba7d1a533 --window-target-id 05eab071-e050-4257-ae15-fbd3a79a9a76 --profile devhub-test --no-verify-ssl

aws ssm deregister-task-from-maintenance-window --window-id mw-0aecd8a4ba7d1a533  --window-task-id c4cf4eb3-60c5-43ca-9579-23b31aa97250 --profile devhub-test --no-verify-ssl

aws ssm register-target-with-maintenance-window --window-id "mw-0aecd8a4ba7d1a533" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira" --profile devhub-test --no-verify-ssl
6a1ccdfe-2c75-446c-9dfc-9bb5e5fd02f3

aws ssm register-task-with-maintenance-window --window-id "mw-0aecd8a4ba7d1a533" --targets "Key=WindowTargetIds,Values=6a1ccdfe-2c75-446c-9dfc-9bb5e5fd02f3" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::838498078144:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devhub-test --no-verify-ssl
"WindowTaskId": "8be66b48-6e64-443c-8eab-f37d485b2d04"

##########################
#### Quinta
##########################
aws ssm describe-maintenance-window-tasks --window-id mw-0053158620501cfaa --profile devhub-test --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
44c87a61-7849-4978-87aa-9ff033ed87b7

aws ssm describe-maintenance-window-targets --window-id mw-0053158620501cfaa --profile devhub-test --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
fd87726e-4f6d-402f-9fd3-38ae21da96a9

aws ssm deregister-target-from-maintenance-window --window-id mw-0053158620501cfaa --window-target-id fd87726e-4f6d-402f-9fd3-38ae21da96a9 --profile devhub-test --no-verify-ssl

aws ssm deregister-task-from-maintenance-window --window-id mw-0053158620501cfaa --window-task-id 44c87a61-7849-4978-87aa-9ff033ed87b7 --profile devhub-test --no-verify-ssl

aws ssm register-target-with-maintenance-window --window-id "mw-0053158620501cfaa" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira" --profile devhub-test --no-verify-ssl
a10ff18c-613d-48e6-9b4f-b909a6741daa

aws ssm register-task-with-maintenance-window --window-id "mw-0053158620501cfaa" --targets "Key=WindowTargetIds,Values=a10ff18c-613d-48e6-9b4f-b909a6741daa" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::838498078144:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devhub-test --no-verify-ssl
"WindowTaskId": "5c9dbf23-57aa-4029-986e-183324a8fa54"

aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile devhub-test --no-verify-ssl

### Ajuste das tasks
# Ajutar policy da Role para execução das tasks
aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile devhub-test --no-verify-ssl

# Listar Maintenance Windows
aws ssm describe-maintenance-windows --profile devhub-test --no-verify-ssl --query "WindowIdentities[].[WindowId,Name]" --output text
mw-0476d3e5612fe58fe    Patches-Terca
mw-0aecd8a4ba7d1a533    Patches-Quarta
mw-0053158620501cfaa    Patches-Quinta

# Excluir target
# Terça
aws ssm describe-maintenance-window-targets --window-id mw-0476d3e5612fe58fe --profile devhub-test --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
85eb6799-cf2b-4e5c-a405-f8048d263545
aws ssm deregister-target-from-maintenance-window --window-id mw-0476d3e5612fe58fe --window-target-id 85eb6799-cf2b-4e5c-a405-f8048d263545 --profile devhub-test --no-verify-ssl
# Quarta
aws ssm describe-maintenance-window-targets --window-id mw-0aecd8a4ba7d1a533 --profile devhub-test --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
6a1ccdfe-2c75-446c-9dfc-9bb5e5fd02f3
aws ssm deregister-target-from-maintenance-window --window-id mw-0aecd8a4ba7d1a533 --window-target-id 6a1ccdfe-2c75-446c-9dfc-9bb5e5fd02f3 --profile devhub-test --no-verify-ssl
# Quinta
aws ssm describe-maintenance-window-targets --window-id mw-0053158620501cfaa --profile devhub-test --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
a10ff18c-613d-48e6-9b4f-b909a6741daa
aws ssm deregister-target-from-maintenance-window --window-id mw-0053158620501cfaa  --window-target-id a10ff18c-613d-48e6-9b4f-b909a6741daa --profile devhub-test --no-verify-ssl

# Excluir task atual
# Terça
aws ssm describe-maintenance-window-tasks --window-id mw-0476d3e5612fe58fe --profile devhub-test --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
edbf0a2b-599d-4af6-bb25-81ec42d0e26e

aws ssm deregister-task-from-maintenance-window --window-id mw-0476d3e5612fe58fe --window-task-id "edbf0a2b-599d-4af6-bb25-81ec42d0e26e" --profile devhub-test --no-verify-ssl 
# Quarta
aws ssm describe-maintenance-window-tasks --window-id mw-0aecd8a4ba7d1a533 --profile devhub-test --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
8be66b48-6e64-443c-8eab-f37d485b2d04

aws ssm deregister-task-from-maintenance-window --window-id mw-0aecd8a4ba7d1a533 --window-task-id "8be66b48-6e64-443c-8eab-f37d485b2d04" --profile devhub-test --no-verify-ssl 
# Quinta
aws ssm describe-maintenance-window-tasks --window-id mw-0053158620501cfaa --profile devhub-test --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
5c9dbf23-57aa-4029-986e-183324a8fa54

aws ssm deregister-task-from-maintenance-window --window-id mw-0053158620501cfaa --window-task-id "5c9dbf23-57aa-4029-986e-183324a8fa54" --profile devhub-test --no-verify-ssl 
# Criar uma nova target
# Terça
aws ssm register-target-with-maintenance-window --window-id mw-0476d3e5612fe58fe --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira " --profile devhub-test --no-verify-ssl
bc55de4f-ee33-4e08-86da-d0d194e5cd8e

aws ssm register-task-with-maintenance-window --window-id mw-0476d3e5612fe58fe  --targets "Key=WindowTargetIds,Values=bc55de4f-ee33-4e08-86da-d0d194e5cd8e" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::838498078144:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devhub-test --no-verify-ssl
# Quarta
aws ssm register-target-with-maintenance-window --window-id mw-0aecd8a4ba7d1a533 --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira " --profile devhub-test --no-verify-ssl
defcddb9-4132-4009-9f01-609c6771b170

aws ssm register-task-with-maintenance-window --window-id mw-0aecd8a4ba7d1a533  --targets "Key=WindowTargetIds,Values=defcddb9-4132-4009-9f01-609c6771b170" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::838498078144:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devhub-test --no-verify-ssl
# Quinta
aws ssm register-target-with-maintenance-window --window-id mw-0053158620501cfaa --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira " --profile devhub-test --no-verify-ssl
6997395b-1707-45dc-8988-6a8059e9419a

aws ssm register-task-with-maintenance-window --window-id mw-0053158620501cfaa  --targets "Key=WindowTargetIds,Values=6997395b-1707-45dc-8988-6a8059e9419a" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::838498078144:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devhub-test --no-verify-ssl
