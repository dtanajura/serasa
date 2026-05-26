# Configurar acesso ao Grafana, com autenticação no OKTA
# id da conta: 225989352496
# eec-aws-br-eits-nikedata-prod
# login: admin
# Senha: Serasa@2023
# Home - Dashboards - Grafana - https://observability.nikedataprod.br.experian.eeca/?orgId=1&from=now-6h&to=now&timezone=browser
# i-0629d7002f2d1b3be
# 10.121.33.93
# Procedimento do Veloso
# https://pages.experian.local/pages/viewpage.action?pageId=1109204265
# Zero to hero
# https://pages.experian.local/spaces/EDPB/pages/1055727537/Zero+To+Hero
# Procedimento da Raissa
# https://pages.experian.local/pages/viewpage.action?pageId=1658349252


aws ec2 describe-instances `
  --profile nikedataprod `
  --query "Reservations[*].Instances[*].[Tags[?Key=='Name']|[0].Value, InstanceId, PrivateIpAddress]" `
  --output text 


# 1- Precisamos garantir que o ambiente com o servidor AD LDAP (10.96.215.13) nas portas 389 e 636
## Dar acesso ao session manager na role BURoleForSREAutomation 
aws iam attach-role-policy  --role-name BURoleForSREAutomation --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore  --profile nikedataprod --region sa-east-1
aws iam attach-role-policy  --role-name BURoleForSREAutomation --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy  --profile nikedataprod --region sa-east-1
aws iam attach-role-policy  --role-name BURoleForSREAutomation --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile nikedataprod --region sa-east-1

aws ec2 describe-instances --instance-ids i-0629d7002f2d1b3be --query "Reservations[*].Instances[*].IamInstanceProfile.Arn"  --profile nikedataprod --region sa-east-1
aws ec2 describe-vpc-endpoints --filters Name=vpc-id,Values=vpc-072dd384007fdb169 --profile nikedataprod --region sa-east-1

## Testar comunicação do servidor:
telnet 10.96.215.13:389
telnet 10.96.215.13:636

# 2- Solicitações:
## Criação dos grupos. REQ de EX: RITM2851317
# Exemplo de nome de grupo: APP-GRAFANA-XXX-ADMIN e APP-GRAFANA-XXX-READONLY
# Link: https://experian.service-now.com/com.glideapp.servicecatalog_cat_item_view.do?v=1&sysparm_id=6e0a0926db0c2700af053b2ffe9619b7&sysparm_link_parent=3e0454dd1b03119066604372b24bcb3c&sysparm_catalog=e0d08b13c3330100c8b837659bba8fb4&sysparm_catalog_view=catalog_default&sysparm_view=text_search
# ======> APP-OBSERVABILIDADE-NIKEDATAPROD-USERS e APP-OBSERVABILIDADE-NIKEDATAPROD-ADMINS

## Criação de usuário sistêmico. Faça isso depois que os grupos forem criados
# https://experian.service-now.com/now/nav/ui/classic/params/target/catalog_find.do%3Fsysparm_parent%3D%26sysparm_catalog%3De0d08b13c3330100c8b837659bba8fb4%26sysparm_catalog_view%3Dcatalog_default%26sysparm_processing_hint%3D%26sysparm_tsgroups%3D%26sysparm_view%3Dtext_search%26sysparm_parent_sys_id%3D%26sysparm_parent_table%3D%26sysparm_view%3Dcatalog_default%26sysparm_collection%3D%26sysparm_collectionID%3D%26sysparm_collection_key%3D%26sysparm_search%3DAdd%252C%2BChange%252C%2BDelete%2BService%2BAccount
# Inclua o nome dos grupos na solicitação para ter certeza que o usuário faça parte dos grupos criados
# ======>  usr-nikedata-observ 

## Abrir um chamado para configuração da senha do usuário
# https://experian.service-now.com/now/nav/ui/classic/params/target/sc_req_item.do%3Fsys_id%3Dddad3e279314f250081d71ffebba1088%26sysparm_stack%3D%26sysparm_view%3D

aws secretsmanager create-secret --name user-grafana-okta --secret-string file://secret.json --profile nikedataprod

aws secretsmanager put-secret-value --secret-id user-grafana-okta --secret-string file://secret.json --profile nikedataprod

# 3- Configuração do Grafana
## Grafana.ini
## ldap.toml



INSERT INTO user (login, email, name, password, is_admin, is_disabled, version) VALUES ('novo_admin', 'novo@admin.com', 'Novo Admin',
'$2b$12$u5YeHX17B1jgZO5P6ub0FerBiht2iet.T3NMKjBAh2Wrfc5U99ejC', 1, 0, 1);


ldapsearch -x -H ldap://10.96.215.13:389 \
  -D "CN=usr-nikedata-observ,OU=Service Accounts,OU=Accounts,DC=br,DC=experian,DC=local" \
  -w "GhS#Y8U#hgTY" \
  -b "DC=br,DC=experian,DC=local" \
  "(uid=c96531a)"

  br.experian.local/Accounts/Service Accounts/usr-nikedata-observ