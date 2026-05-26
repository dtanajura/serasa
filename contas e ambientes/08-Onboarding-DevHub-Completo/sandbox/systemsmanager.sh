# Criar a função IAM:
aws iam create-role --role-name BURoleForSSM-Instance-Role --assume-role-policy-document file://BURoleforSSM.json --profile devhub-sandbox --no-verify-ssl
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
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile devhub-sandbox --no-verify-ssl
aws iam attach-role-policy --role-name BURoleForSSM-Instance-Role --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy  --profile devhub-sandbox --no-verify-ssl
# ===> Este comando anexa a política do Systems Manager à função para conceder permissões de gerenciamento básicas.

# Criar um perfil IAM para as instâncias EC2:
aws iam create-instance-profile --instance-profile-name SSM-Instance-Profile  --profile devhub-sandbox --no-verify-ssl

# Adicionar a função à instância do perfil IAM:
aws iam add-role-to-instance-profile --instance-profile-name SSM-Instance-Profile --role-name BURoleForSSM-Instance-Role   --profile devhub-sandbox --no-verify-ssl

# Criar uma chave
aws ec2 create-key-pair --key-name bastion-devhub-sandbox --key-type rsa --key-format pem --query "KeyMaterial" --profile devhub-sandbox --no-verify-ssl --output text > bastion-devhub-sandbox.pem

# Criar Security Group para o Bastion
aws ec2 create-security-group --group-name SG-Bastion --description "SG para acesso ao bastion" --vpc-id vpc-0f405711cd62b7ac8 --region sa-east-1 --profile devhub-sandbox --no-verify-ssl
# {
#     "GroupId": "sg-03d41ee5166058c43"
# }

aws ec2 authorize-security-group-ingress --group-id sg-03d41ee5166058c43 --protocol tcp --port 22 --cidr 10.0.0.0/8 --profile devhub-sandbox --no-verify-ssl

# Lançar ou atualizar instâncias EC2 associadas ao perfil IAM:
aws ec2 run-instances --image-id ami-0e2c5604ae8bb1c54 --subnet-id subnet-01ae076c3421d58a9 --key-name bastion-devhub-sandbox --security-group-ids sg-03d41ee5166058c43 --instance-type t2.micro --iam-instance-profile Name=SSM-Instance-Profile --profile devhub-sandbox --no-verify-ssl
aws ec2 create-tags --resources i-051013e4899cc9f6a --tags Key=Name,Value='bastion-devhub-sandbox' --profile devhub-sandbox --no-verify-ssl
aws ec2 create-tags --resources i-051013e4899cc9f6a --tags Key=CostString,Value='1800.BR.134.607500' Key=Environment,Value='sbx' Key=AppID,Value='21231' Key=CentrifyUnixRole,Value='' Key=ResourceName,Value='devhub-eks-sandbox-test01' Key=ResourceAppRole,Value='app' Key=ResourceOwner,Value='devhub_team@br.experian.com' Key=adDomain,Value='br.experian.local' Key=adGroup,Value='' --profile devhub-sandbox --no-verify-ssl

# Criar o Patch Baseline
aws ssm create-patch-baseline --name "Baseline_AMZLinux2" --operating-system "AMAZON_LINUX_2" --approval-rules "PatchRules=[{PatchFilterGroup={PatchFilters=[{Key=PRODUCT,Values=[AmazonLinux2,AmazonLinux2.0]},{Key=CLASSIFICATION,Values=[Bugfix,Enhancement,Newpackage,Recommended,Security]},{Key=SEVERITY,Values=[Critical,Important,Medium]}]},ApproveAfterDays=7}]" --profile devhub-sandbox --no-verify-ssl
aws ssm update-patch-baseline --baseline-id pb-00195efae57d317c1   --approved-patches-enable-non-security --approval-rules "PatchRules=[{PatchFilterGroup={PatchFilters=[{Key=PRODUCT,Values=[AmazonLinux2,AmazonLinux2.0]},{Key=CLASSIFICATION,Values=[Bugfix,Enhancement,Newpackage,Recommended,Security]},{Key=SEVERITY,Values=[Critical,Important,Medium]}]},ApproveAfterDays=7,EnableNonSecurity=true}]" --profile devhub-sandbox --no-verify-ssl
aws ssm register-default-patch-baseline --baseline-id pb-00195efae57d317c1 --profile devhub-sandbox --no-verify-ssl
aws ssm get-default-patch-baseline --operating-system AMAZON_LINUX_2 --profile devhub-sandbox --no-verify-ssl
# Rodar o quick setup para criar a patch policy
aws ec2 create-tags --resources i-051013e4899cc9f6a --tags Key=PatchGroup,Value='PatchGroup02' --profile devhub-sandbox --no-verify-ssl

# Criar a janela de manutenção para instalação dos poatches
aws ssm create-maintenance-window --name "Patches-Terca" --schedule "cron(0 22 ? * TUE *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devhub-sandbox --no-verify-ssl
aws ssm register-target-with-maintenance-window --window-id "mw-0e74ac55c4a060562" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira " --profile devhub-sandbox --no-verify-ssl
aws ssm register-task-with-maintenance-window --window-id "mw-0e74ac55c4a060562" --targets "Key=WindowTargetIds,Values=3aa3fb8a-d400-4002-b657-4908d349004b" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::071087690196:role/service-role/SSMMaintenanceWindowRole" --max-concurrency 5 --max-errors 1 --profile devhub-sandbox --no-verify-ssl
# Lembrar de colocar o número da conta no ARN, alem do window-id e do windowtargetid
aws ssm create-maintenance-window --name "Patches-Quarta" --schedule "cron(0 22 ? * WED *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devhub-sandbox --no-verify-ssl
aws ssm register-target-with-maintenance-window --window-id "mw-010548f70e88d0513" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira " --profile devhub-sandbox --no-verify-ssl
aws ssm register-task-with-maintenance-window --window-id "mw-0e74ac55c4a060562" --targets "Key=WindowTargetIds,Values=3aa3fb8a-d400-4002-b657-4908d349004b" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::071087690196:role/service-role/SSMMaintenanceWindowRole" --max-concurrency 5 --max-errors 1 --profile devhub-sandbox --no-verify-ssl
aws ssm create-maintenance-window --name "Patches-Quinta" --schedule "cron(0 22 ? * THU *)" --duration 3 --cutoff 1 --no-allow-unassociated-targets --profile devhub-sandbox --no-verify-ssl
aws ssm register-target-with-maintenance-window --window-id "mw-0ca0c6dc8c43d2798" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira " --profile devhub-sandbox --no-verify-ssl
aws ssm register-task-with-maintenance-window --window-id "mw-0e74ac55c4a060562" --targets "Key=WindowTargetIds,Values=ee9e1b1f-d2e9-462b-ac20-1e60288fafd7" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::071087690196:role/service-role/SSMMaintenanceWindowRole" --max-concurrency 5 --max-errors 1 --profile devhub-sandbox --no-verify-ssl

#### AWS Backup
# Create a backup vault by running:
aws backup create-backup-vault --backup-vault-name backup-vault-devhub-sandbox --profile devhub-sandbox --no-verify-ssl

# Create a backup plan by running 
aws backup create-backup-plan --cli-input-json file://backup-plan.json --profile devhub-sandbox --no-verify-ssl
# {
#     "BackupPlanId": "3d736f9a-fa3f-45ec-ab30-1b4e465ac52d",
#     "BackupPlanArn": "arn:aws:backup:sa-east-1:071087690196:backup-plan:3d736f9a-fa3f-45ec-ab30-1b4e465ac52d",
#     "CreationDate": "2023-10-26T16:33:55.727000-03:00",
#     "VersionId": "NWMxMWNjMDktYTY1Ny00ZTFjLWIxMDQtNDZjNGYwYzFhYTMw"
# }

# Create a backup selection by running:
aws backup create-backup-selection --cli-input-json file://backup-selection.json  --profile devhub-sandbox --no-verify-ssl
aws ec2 create-tags --resources i-051013e4899cc9f6a --tags Key=Backup,Value='True' --profile devhub-sandbox --no-verify-ssl

# Alterar o backup selection
aws backup list-backup-plans  --profile devhub-sandbox --no-verify-ssl 
aws backup list-backup-selections --backup-plan-id 3d736f9a-fa3f-45ec-ab30-1b4e465ac52d  --profile devhub-sandbox --no-verify-ssl
aws backup delete-backup-selection --backup-plan-id 3d736f9a-fa3f-45ec-ab30-1b4e465ac52d --selection-id 2e1a2ab6-30cd-46e2-875c-e2b74eb0c27a --profile devhub-sandbox --no-verify-ssl
aws backup create-backup-selection --cli-input-json file://backup-selection.json  --profile devhub-sandbox --no-verify-ssl

aws iam create-role --role-name BURoleForDevHubSSMMaintenanceWindow --assume-role-policy-document file://assumerole_BURoleForDevHubSSMMaintenanceWindow.json  --profile devhub-sandbox --no-verify-ssl
aws iam create-policy --policy-name BUPolicyForDevHubSSMMaintenanceWindow --policy-document file://BUPolicyForDevHubSSMMaintenanceWindow.json  --profile devhub-sandbox --no-verify-ssl
aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::071087690196:policy/BUPolicyForDevHubSSMMaintenanceWindow  --profile devhub-sandbox --no-verify-ssl

### Refazendo configuração das Janelas de aplicação de patches
## listar janelas
aws ssm describe-maintenance-windows --profile devhub-sandbox --no-verify-ssl --query "WindowIdentities[].[WindowId,Name]" --output text
mw-010548f70e88d0513    Patches-Quarta
mw-0ca0c6dc8c43d2798    Patches-Quinta
mw-0e74ac55c4a060562    Patches-Terca

##########################
#### Terça
##########################
aws ssm describe-maintenance-window-tasks --window-id mw-0e74ac55c4a060562 --profile devhub-sandbox --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
ae3bf011-5929-42c3-b51d-406fc6a765c2
c197b13f-9a5b-477a-8524-be613e06efe1
fdc0451b-0718-4c0e-a709-645aafcf0c14


aws ssm describe-maintenance-window-targets --window-id mw-0e74ac55c4a060562 --profile devhub-sandbox --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
6c654f23-6ff5-4b57-ac86-c049a508d42e

aws ssm deregister-target-from-maintenance-window --window-id mw-0e74ac55c4a060562 --window-target-id 6c654f23-6ff5-4b57-ac86-c049a508d42e --profile devhub-sandbox --no-verify-ssl

aws ssm deregister-task-from-maintenance-window --window-id mw-0e74ac55c4a060562 --window-task-id ae3bf011-5929-42c3-b51d-406fc6a765c2 --profile devhub-sandbox --no-verify-ssl
aws ssm deregister-task-from-maintenance-window --window-id mw-0e74ac55c4a060562 --window-task-id c197b13f-9a5b-477a-8524-be613e06efe1 --profile devhub-sandbox --no-verify-ssl
aws ssm deregister-task-from-maintenance-window --window-id mw-0e74ac55c4a060562 --window-task-id fdc0451b-0718-4c0e-a709-645aafcf0c14 --profile devhub-sandbox --no-verify-ssl

aws ssm register-target-with-maintenance-window --window-id "mw-0e74ac55c4a060562" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira " --profile devhub-sandbox --no-verify-ssl
565f1f53-fbd0-4746-9126-1bba2adb29f3

aws ssm register-task-with-maintenance-window --window-id "mw-0e74ac55c4a060562" --targets "Key=WindowTargetIds,Values=565f1f53-fbd0-4746-9126-1bba2adb29f3" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::071087690196:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devhub-sandbox --no-verify-ssl
"WindowTaskId": "26996501-5136-4013-b50c-ec78782628fb"

##########################
#### Quarta
##########################
aws ssm describe-maintenance-window-tasks --window-id mw-010548f70e88d0513 --profile devhub-sandbox --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
Nenhum

aws ssm describe-maintenance-window-targets --window-id mw-010548f70e88d0513 --profile devhub-sandbox --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
3aa3fb8a-d400-4002-b657-4908d349004b

aws ssm deregister-target-from-maintenance-window --window-id mw-010548f70e88d0513 --window-target-id 3aa3fb8a-d400-4002-b657-4908d349004b --profile devhub-sandbox --no-verify-ssl

aws ssm register-target-with-maintenance-window --window-id "mw-010548f70e88d0513" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira " --profile devhub-sandbox --no-verify-ssl
866dc792-1c89-4d5b-9fa5-bc370a59a604

aws ssm register-task-with-maintenance-window --window-id "mw-010548f70e88d0513" --targets "Key=WindowTargetIds,Values=866dc792-1c89-4d5b-9fa5-bc370a59a604" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::071087690196:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devhub-sandbox --no-verify-ssl
"WindowTaskId": "e5ca3086-8f13-44a8-a09b-807cbe7e4ab9"

##########################
#### Quinta
##########################
aws ssm describe-maintenance-window-tasks --window-id mw-0ca0c6dc8c43d2798 --profile devhub-sandbox --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
Nenhum

aws ssm describe-maintenance-window-targets --window-id mw-0ca0c6dc8c43d2798 --profile devhub-sandbox --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
ee9e1b1f-d2e9-462b-ac20-1e60288fafd7

aws ssm deregister-target-from-maintenance-window --window-id mw-0ca0c6dc8c43d2798 --window-target-id ee9e1b1f-d2e9-462b-ac20-1e60288fafd7 --profile devhub-sandbox --no-verify-ssl

aws ssm register-target-with-maintenance-window --window-id "mw-0ca0c6dc8c43d2798" --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira " --profile devhub-sandbox --no-verify-ssl
13969ca1-ab08-4b04-bbe6-06877ca1e1b6

aws ssm register-task-with-maintenance-window --window-id "mw-0ca0c6dc8c43d2798" --targets "Key=WindowTargetIds,Values=13969ca1-ab08-4b04-bbe6-06877ca1e1b6" --task-type "RUN_COMMAND" --task-arn "AWS-ApplyPatchBaseline" --service-role-arn "arn:aws:iam::071087690196:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 1 --profile devhub-sandbox --no-verify-ssl
"WindowTaskId": "75db29e3-2f03-4f8b-9f6e-9e8a90e0b047"

### Ajuste das tasks
# Ajutar policy da Role para execução das tasks
aws iam attach-role-policy --role-name BURoleForDevHubSSMMaintenanceWindow --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile devhub-sandbox --no-verify-ssl

# Listar Maintenance Windows
aws ssm describe-maintenance-windows --profile devhub-sandbox --no-verify-ssl --query "WindowIdentities[].[WindowId,Name]" --output text
mw-010548f70e88d0513    Patches-Quarta
mw-0ca0c6dc8c43d2798    Patches-Quinta
mw-0e74ac55c4a060562    Patches-Terca

# Excluir target
# Terça
aws ssm describe-maintenance-window-targets --window-id mw-0e74ac55c4a060562 --profile devhub-sandbox --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
565f1f53-fbd0-4746-9126-1bba2adb29f3
aws ssm deregister-target-from-maintenance-window --window-id mw-0e74ac55c4a060562 --window-target-id 565f1f53-fbd0-4746-9126-1bba2adb29f3 --profile devhub-sandbox --no-verify-ssl
# Quarta
aws ssm describe-maintenance-window-targets --window-id mw-010548f70e88d0513 --profile devhub-sandbox --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
866dc792-1c89-4d5b-9fa5-bc370a59a604
aws ssm deregister-target-from-maintenance-window --window-id mw-010548f70e88d0513 --window-target-id 866dc792-1c89-4d5b-9fa5-bc370a59a604 --profile devhub-sandbox --no-verify-ssl
# Quinta
aws ssm describe-maintenance-window-targets --window-id mw-0ca0c6dc8c43d2798 --profile devhub-sandbox --no-verify-ssl --query "Targets[].[WindowTargetId]" --output text
13969ca1-ab08-4b04-bbe6-06877ca1e1b6
aws ssm deregister-target-from-maintenance-window --window-id mw-0ca0c6dc8c43d2798  --window-target-id 13969ca1-ab08-4b04-bbe6-06877ca1e1b6 --profile devhub-sandbox --no-verify-ssl

# Excluir task atual
# Terça
aws ssm describe-maintenance-window-tasks --window-id mw-0e74ac55c4a060562 --profile devhub-sandbox --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
26996501-5136-4013-b50c-ec78782628fb

aws ssm deregister-task-from-maintenance-window --window-id mw-0e74ac55c4a060562 --window-task-id "26996501-5136-4013-b50c-ec78782628fb" --profile devhub-sandbox --no-verify-ssl 
# Quarta
aws ssm describe-maintenance-window-tasks --window-id mw-010548f70e88d0513 --profile devhub-sandbox --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
e5ca3086-8f13-44a8-a09b-807cbe7e4ab9

aws ssm deregister-task-from-maintenance-window --window-id mw-010548f70e88d0513 --window-task-id "e5ca3086-8f13-44a8-a09b-807cbe7e4ab9" --profile devhub-sandbox --no-verify-ssl 
# Quinta
aws ssm describe-maintenance-window-tasks --window-id mw-0ca0c6dc8c43d2798 --profile devhub-sandbox --no-verify-ssl  --query "Tasks[].[WindowTaskId]" --output text
75db29e3-2f03-4f8b-9f6e-9e8a90e0b047

aws ssm deregister-task-from-maintenance-window --window-id mw-0ca0c6dc8c43d2798 --window-task-id "75db29e3-2f03-4f8b-9f6e-9e8a90e0b047" --profile devhub-sandbox --no-verify-ssl 
# Criar uma nova target
# Terça
aws ssm register-target-with-maintenance-window --window-id mw-0e74ac55c4a060562 --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup01" --owner-information "Rotina de Patches da Terca-feira " --profile devhub-sandbox --no-verify-ssl
1300296e-fb3a-44d2-b05b-83493e8eb8c8

aws ssm register-task-with-maintenance-window --window-id mw-0e74ac55c4a060562  --targets "Key=WindowTargetIds,Values=1300296e-fb3a-44d2-b05b-83493e8eb8c8" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::071087690196:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devhub-sandbox --no-verify-ssl
# Quarta
aws ssm register-target-with-maintenance-window --window-id mw-010548f70e88d0513 --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup02" --owner-information "Rotina de Patches da Quarta-feira " --profile devhub-sandbox --no-verify-ssl
0837a337-ea96-40e0-9e63-182fad3bd557

aws ssm register-task-with-maintenance-window --window-id mw-010548f70e88d0513  --targets "Key=WindowTargetIds,Values=0837a337-ea96-40e0-9e63-182fad3bd557" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::071087690196:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devhub-sandbox --no-verify-ssl
# Quinta
aws ssm register-target-with-maintenance-window --window-id mw-0ca0c6dc8c43d2798 --resource-type "INSTANCE" --targets "Key=tag:PatchGroup,Values=PatchGroup03" --owner-information "Rotina de Patches da Quinta-feira " --profile devhub-sandbox --no-verify-ssl
f3cd72c0-d4c4-402b-900b-48e97378eb59

aws ssm register-task-with-maintenance-window --window-id mw-0ca0c6dc8c43d2798  --targets "Key=WindowTargetIds,Values=f3cd72c0-d4c4-402b-900b-48e97378eb59" --task-type "RUN_COMMAND" --task-arn "AWS-RunPatchBaseline" --service-role-arn "arn:aws:iam::071087690196:role/BURoleForDevHubSSMMaintenanceWindow" --max-concurrency 5 --max-errors 5 --profile devhub-sandbox --no-verify-ssl
