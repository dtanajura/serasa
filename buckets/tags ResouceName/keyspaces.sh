# Defina o perfil, região e keyspace
$profile = "dsprod"
$region = "sa-east-1"
$accountId = "662860092544"
$keyspace = "reports"

# Lista de tabelas
$tables = @(
    "bi_pessoas_fisicas",
    "business_participations",
    "dados_cadastrais_cnae_pj",
    "dados_cadastrais_emails_pf",
    "dados_cadastrais_emails_pj",
    "dados_cadastrais_enderecos_pf",
    "dados_cadastrais_enderecos_pj",
    "dados_cadastrais_pf",
    "dados_cadastrais_pf_v2",
    "dados_cadastrais_pf_v3",
    "dados_cadastrais_pj",
    "dados_cadastrais_pj_v2",
    "dados_cadastrais_reorganizacao_societaria_pj",
    "dados_cadastrais_telefones_pf",
    "dados_cadastrais_telefones_pj",
    "depara_hash",
    "negativos_acoes_pf",
    "negativos_acoes_pj",
    "negativos_ccf_pf",
    "negativos_ccf_pj",
    "negativos_consolidados_pf",
    "negativos_consolidados_pj",
    "negativos_divida_vencida_pf",
    "negativos_divida_vencida_pj",
    "negativos_facon_pj",
    "negativos_pefin_pf",
    "negativos_pefin_pj",
    "negativos_pie_pf",
    "negativos_protestos_pf",
    "negativos_protestos_pj",
    "negativos_refin_pf",
    "negativos_refin_pj",
    "negativos_spc_pf",
    "negativos_spc_pj",
    "passagem_analitica_pf",
    "passagem_analitica_pj",
    "passagem_detalhe_pf",
    "passagem_detalhe_pj",
    "passagem_detalhe_segmento_atuacao_pj",
    "passagem_grupo_segmento_pj",
    "passagem_resumo_pf",
    "passagem_resumo_pj",
    "passagem_segmento_atuacao_pj",
    "person_participations",
    "person_participations_v3",
    "qsa_administrator",
    "qsa_company",
    "qsa_partner",
    "rs_tvnatureza",
    "rs_tvpartconvem",
    "uc_localidade",
    "uc_tvbanco"
)

# Adicionar tag ResourceName para cada tabela
foreach ($table in $tables) {
    $arn = "arn:aws:cassandra:${region}:${accountId}:/keyspace/${keyspace}/table/${table}"
    aws keyspaces tag-resource --profile $profile --resource-arn $arn --tags key=ResourceName,value=$table
    Write-Host "Tabela $table"

# Adicionar tag ResourceName para o keyspace
$arnKeyspace = "arn:aws:cassandra:${region}:${accountId}:/keyspace/${keyspace}"
aws keyspaces tag-resource --profile $profile --resource-arn $arnKeyspace --tags key=ResourceName,value=$keyspace

# Defina o perfil, região e keyspace
$profile = "dsprod"
$region = "sa-east-1"
$accountId = "662860092544"
$keyspace = "ext"

# Lista de tabelas
$tables = @(
    "depara_hash",
    "negativos_consolidados_pf",
    "negativos_consolidados_pj"
)

# Adicionar tag ResourceName para cada tabela
foreach ($table in $tables) {
    $arn = "arn:aws:cassandra:${region}:${accountId}:/keyspace/${keyspace}/table/${table}"
    aws keyspaces tag-resource --profile $profile --resource-arn $arn --tags key=ResourceName,value=$table
    Write-Host "Tabela $table"
}
$arnKeyspace = "arn:aws:cassandra:sa-east-1:662860092544:/keyspace/ext/"
aws keyspaces tag-resource --profile $profile --resource-arn $arnKeyspace --tags key=ResourceName,value=$keyspace



####################################
# Outras tags

Tabelas:
reports.depara_hash
TAGs:
BU -> EITS
Layer -> Gold
Project -> Nike reports
Squad -> DcF 
Dataset -> Commons 

aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/depara_hash --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Commons

aws keyspaces list-tags-for-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/depara_hash

# QSA
####################QSA############################################
Tabelas:
reports.qsa_partner
reports.qsa_company
reports.qsa_administrator
reports.person_participations_v3
reports.person_participations
reports.business_participations
TAGs:
BU -> EITS
Layer -> Gold
Project -> Nike reports
Squad -> DcF 
Dataset -> QSA 

aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/qsa_partner --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=QSA
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/qsa_company --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=QSA
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/qsa_administrator --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=QSA
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/person_participations_v3 --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=QSA
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/person_participations --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=QSA
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/business_participations --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=QSA


#################Passagem#########################################
Tabelas:
reports.passagem_segmento_atuacao_pj
reports.passagem_resumo_pj
reports.passagem_resumo_pf
reports.passagem_grupo_segmento_pj
reports.passagem_detalhe_segmento_atuacao_pj
reports.passagem_detalhe_pj
reports.passagem_detalhe_pf
reports.passagem_analitica_pj
reports.passagem_analitica_pf
TAGs
TAGs:
BU -> EITS
Layer -> Gold
Project -> Nike reports
Squad -> DcF 
Dataset -> Passagem 

# Passagem
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/passagem_segmento_atuacao_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Passagem
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/passagem_resumo_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Passagem
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/passagem_resumo_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Passagem
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/passagem_grupo_segmento_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Passagem
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/passagem_detalhe_segmento_atuacao_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Passagem
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/passagem_detalhe_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Passagem
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/passagem_detalhe_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Passagem
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/passagem_analitica_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Passagem
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/passagem_analitica_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Passagem


################Negativos########################################
Tabelas:
reports.negativos_spc_pj
reports.negativos_spc_pf
reports.negativos_refin_pj
reports.negativos_refin_pf
reports.negativos_protestos_pj
reports.negativos_protestos_pf
reports.negativos_pie_pf
reports.negativos_pefin_pj
reports.negativos_pefin_pf
reports.negativos_facon_pj
reports.negativos_divida_vencida_pj
reports.negativos_divida_vencida_pf
reports.negativos_consolidados_pj
reports.negativos_consolidados_pf
reports.negativos_ccf_pj
reports.negativos_ccf_pf
reports.negativos_acoes_pj
reports.negativos_acoes_pf
reports.uc_tvbanco
reports.uc_localidade
reports.rs_tvpartconvem
reports.rs_tvnatureza
TAGs:
BU -> EITS
Layer -> Gold
Project -> Nike reports
Squad -> DcF 
Dataset -> Negativos 

# Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_spc_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_spc_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_refin_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_refin_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_protestos_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_protestos_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_pie_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_pefin_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_pefin_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_facon_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_divida_vencida_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_divida_vencida_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_consolidados_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_consolidados_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_ccf_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_ccf_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_acoes_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/negativos_acoes_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/uc_tvbanco --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/uc_localidade --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/rs_tvpartconvem --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/rs_tvnatureza --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Negativos

###################Cadastrais####################################
Tabelas:
reports.dados_cadastrais_telefones_pj
reports.dados_cadastrais_telefones_pf
reports.dados_cadastrais_reorganizacao_societaria_pj
reports.dados_cadastrais_pj_v2
reports.dados_cadastrais_pj
reports.dados_cadastrais_pf_v2
reports.dados_cadastrais_pf_v3
reports.dados_cadastrais_pf
reports.dados_cadastrais_enderecos_pj
reports.dados_cadastrais_enderecos_pf
reports.dados_cadastrais_emails_pj
reports.dados_cadastrais_emails_pf
reports.dados_cadastrais_cnae_pj
reports.bi_pessoas_fisicas
TAGs:
BU -> EITS
Layer -> Gold
Project -> Nike reports
Squad -> DcF 
Dataset -> Cadastrais 

# Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_telefones_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_telefones_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_reorganizacao_societaria_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_pj_v2 --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_pf_v2 --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_pf_v3 --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_enderecos_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_enderecos_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_emails_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_emails_pf --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/dados_cadastrais_cnae_pj --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais
aws keyspaces tag-resource --profile dsprod --resource-arn arn:aws:cassandra:sa-east-1:662860092544:/keyspace/reports/table/bi_pessoas_fisicas --tags key=BU,value=EITS key=Layer,value=Gold key=Project,value="Nike reports" key=Squad,value=DcF key=Dataset,value=Cadastrais