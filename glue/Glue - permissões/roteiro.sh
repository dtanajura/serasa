# Atribuir permissão na conta Dataservice stage
okta-aws-cli web --profile dsstage --aws-region sa-east-1 --aws-session-duration 36000

# para as roles "arn:aws:iam::278332118946:role/BURoleFor-unity-catalog-dev"
# nas tabelas: rs_bloqjudicial e rs_bloqueio_docto

Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\Glue - permissões"
# obter o arquivo da policy atual no glue
aws glue get-resource-policies --region sa-east-1 --output json --profile dsstage > policy.json

# Editar a policy
<#
{
    "Sid" : "ECSAccess",
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : [ "arn:aws:iam::278332118946:role/BURoleFor-unity-catalog-dev", "arn:aws:iam::093785888205:role/dataops-databricks-default-role-dev" ]
    },
    "Action" : [ "glue:GetDatabase", "glue:GetTables", "glue:GetDatabases", "glue:GetTable", "glue:GetPartitions" ],
    "Resource" : [ "arn:aws:glue:sa-east-1:146737708860:database/replicacao", "arn:aws:glue:sa-east-1:146737708860:database/reports", "arn:aws:glue:sa-east-1:146737708860:catalog", "arn:aws:glue:sa-east-1:146737708860:database/default", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/bt_emails_pf", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/uc_tabela", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/bt_cadastrais_pf", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/bt_enderecos_pf", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/bt_telefones_pf", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/rs_tvpartconvem", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/rs_tvremessa", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/rs_email", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/rs_msg_digital", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/in_capa_comunica", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/in_comun_tribureau", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/rs_h_msg_digital", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/rs_convemparticip", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/rs_h_email", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/bt_cadastrais_pj", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/rs_tvnatureza", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/uc_localidade", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/uc_tvbanco", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/rs_tvpartconvem", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/bt_cadastrais_pj", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/bt_cadastrais_cnae_pj", "arn:aws:glue:sa-east-1:146737708860:table/reports/depara_hash", "arn:aws:glue:sa-east-1:146737708860:table/replicacao/bt_qsa" ]
  }, 
#>

# Obter a ARN das tabelas:
aws glue get-table `
    --database-name replicacao `
    --name rs_bloqjudicial `
    --region sa-east-1 `
    --profile dsstage

# Atualizando a policy
aws glue put-resource-policy --policy-in-json file://glue_resource_policy.json --region sa-east-1 --profile dsstage --policy-exists-condition MUST_EXIST


# Obter a policy do bucket
aws s3api get-bucket-policy --bucket experian-datahub-gold-reports-uat --profile dsstage 

# ajustar a policy

aws s3api put-bucket-policy --bucket experian-datahub-gold-reports-uat --policy file://bucket_policy.json --profile dsstage
