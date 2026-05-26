# import boto3
# import requests
# from requests_aws4auth import AWS4Auth

# # Configuração do host e região
# destination_host = 'https://vpc-credit-services-ext-v3-c5io3d2d3bgnc5k2cwuhveghti.sa-east-1.es.amazonaws.com'
# region = 'sa-east-1'
# service = 'es'

# # Criação da sessão boto3 usando o perfil 'dsstage'
# session = boto3.Session(profile_name='dsstage')
# credentials = session.get_credentials()
# awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

# # Registrar repositório no endpoint de destino
# repository_path = '_snapshot/snapshot-elastic-credit-services-ext-v3'
# repository_url = destination_host + '/' + repository_path

# payload = {
#    "type": "s3",
#    "settings": {
#     "bucket": "es-snapshot-v3",
#     "region": "sa-east-1",
#     "role_arn" : "arn:aws:iam::146737708860:role/BURoleForESSnapshot"
#   }
# }

# headers = {"Content-Type": "application/json"}

# # Fazendo a requisição PUT para registrar o repositório
# r = requests.put(repository_url, auth=awsauth, json=payload, headers=headers)

# print(f"Registrando repositório: {r.status_code} {r.text}")

# # Verificar se o repositório foi registrado com sucesso
# if r.status_code == 200:
#     # Restaurar os índices
#     restore_path = '_snapshot/snapshot-elastic-credit-services-ext-v3/snapshot-es-index-ext/_restore'
#     restore_url = destination_host + '/' + restore_path
#     indices = ['rs_bloqueio_docto', 'rf_pessoa_fisica', 'atividade-economica', 're_recheque', 'fs_tvedcg', 'rf_natureza_jur', 'rs_tvacoes', 'nr_regcons_analit', 'uc_tvbanco', 'bo_obitos', 'uc_codigo_serasa', 'rs_pendencia_ban', 'uc_passagem_spc', 'natureza', 'cargo', 'rs_tvcartor', 'rs_pendencia_fin', 'fs_tvparl', 'fs_totais_filiais', 'uc_cna_convivencia', 'profissao', 'rs_resumo', 'rf_rel_cnae_serasa', 'fs_tvcontpesjur', 'rx_mensagens_docto', 'nr_regcons_sint', 'uc_passagem_log', 'rs_cheque_ccf', 'rf_pessoa_juridica', 'rs_anotacoes_spc', 'rs_protestos', 'uc_localidade', 'fs_tvpf', 'fs_tvdttb', 'rs_tvdistribuidor', 'pre-negativo', 'fs_tvrncg', 'rc_pie', 'bi_pessoas_fisicas', 'fs_tvfrasespesjur', 'fs_tvpm', 'fs_tvcadfrases', 'praca', 'sn_cad_sintegra', 'te_telefones', 'pessoa-fisica-complo', 'bp_bloqueio_dados', 'nr_cliente_sacado', '.kibana_1', 'rc_facon', 'fs_tvcg', 'uc_tabela', 'rs_divida_vencida', 'fs_tvcodserasa']

#     payload = {
#       "indices": ",".join(indices),
#       "include_global_state": True
#     }

#     headers = {"Content-Type": "application/json"}

#     # Fazendo a requisição POST para restaurar os índices
#     r = requests.post(restore_url, auth=awsauth, json=payload, headers=headers)

#     print(f"Restaurando índices: {r.status_code} {r.text}")
# else:
#     print(f"Erro ao registrar repositório: {r.status_code} {r.text}")


import boto3
import requests
from requests_aws4auth import AWS4Auth

# Configuração do host e região
source_host = 'https://vpc-credit-services-uat-v3-h4yauwoh5sl6mixxvpdtmiksom.sa-east-1.es.amazonaws.com'
destination_host = 'https://vpc-credit-services-ext-v3-c5io3d2d3bgnc5k2cwuhveghti.sa-east-1.es.amazonaws.com'
region = 'sa-east-1'
service = 'es'

# Criação da sessão boto3 usando o perfil 'dsstage'
session = boto3.Session(profile_name='dsstage')
credentials = session.get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

# Registrar repositório no endpoint de destino
repository_path = '_snapshot/snapshot-elastic-credit-services-ext-v3'
repository_url = destination_host + '/' + repository_path

payload = {
   "type": "s3",
   "settings": {
    "bucket": "es-snapshot-v3",
    "region": "sa-east-1",
    "role_arn" : "arn:aws:iam::146737708860:role/BURoleForESSnapshot",
    "base_path": "indices"
  }
}

headers = {"Content-Type": "application/json"}

# Fazendo a requisição PUT para registrar o repositório
r = requests.put(repository_url, auth=awsauth, json=payload, headers=headers)

print(f"Registrando repositório: {r.status_code} {r.text}")

# Verificar se o repositório foi registrado com sucesso
if r.status_code == 200:
    # Restaurar os índices
    restore_path = '_snapshot/snapshot-elastic-credit-services-ext-v3/snapshot-es-index-ext/_restore'
    restore_url = destination_host + '/' + restore_path

    indices = ['rs_bloqueio_docto', 'rf_pessoa_fisica', 'atividade-economica', 're_recheque', 'fs_tvedcg', 'rf_natureza_jur', 'rs_tvacoes', 'nr_regcons_analit', 'uc_tvbanco', 'bo_obitos', 'uc_codigo_serasa', 'rs_pendencia_ban', 'uc_passagem_spc', 'natureza', 'cargo', 'rs_tvcartor', 'rs_pendencia_fin', 'fs_tvparl', 'fs_totais_filiais', 'uc_cna_convivencia', 'profissao', 'rs_resumo', 'rf_rel_cnae_serasa', 'fs_tvcontpesjur', 'rx_mensagens_docto', 'nr_regcons_sint', 'uc_passagem_log', 'rs_cheque_ccf', 'rf_pessoa_juridica', 'rs_anotacoes_spc', 'rs_protestos', 'uc_localidade', 'fs_tvpf', 'fs_tvdttb', 'rs_tvdistribuidor', 'pre-negativo', 'fs_tvrncg', 'rc_pie', 'bi_pessoas_fisicas', 'fs_tvfrasespesjur', 'fs_tvpm', 'fs_tvcadfrases', 'praca', 'sn_cad_sintegra', 'te_telefones', 'pessoa-fisica-complo', 'bp_bloqueio_dados', 'nr_cliente_sacado', '.kibana_1', 'rc_facon', 'fs_tvcg', 'uc_tabela', 'rs_divida_vencida', 'fs_tvcodserasa']

    payload = {
      "indices": ",".join(indices),
      "include_global_state": True
    }

    headers = {"Content-Type": "application/json"}

    # Fazendo a requisição POST para restaurar os índices
    r = requests.post(restore_url, auth=awsauth, json=payload, headers=headers)

    print(f"Restaurando índices: {r.status_code} {r.text}")
else:
    print(f"Erro ao registrar repositório: {r.status_code} {r.text}")
