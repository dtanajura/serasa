# import boto3
# import requests
# from requests_aws4auth import AWS4Auth


# host = 'https://vpc-elastic-ssbl-prd-num37u3eskfqyzstedw7456vma.sa-east-1.es.amazonaws.com/'
# #host = 'https://vpc-elastic-ssbl-prod-e3liing5nm5ghrahh2wpa3fdgu.sa-east-1.es.amazonaws.com/'
# #host = 'https://vpc-elastic-ssbl-uat-prkbcc6wibfdcq3467goahy7h4.sa-east-1.es.amazonaws.com/'
# #host = 'vpc-elastic-ssbl-qa-65heb5vt2bl6enexgdllrkghn4.sa-east-1.es.amazonaws.com'
# #host = 'vpc-elastic-ssbl-dev-ufxo6firerm27ykdtyyedopk24.sa-east-1.es.amazonaws.com'
# region = 'sa-east-1'
# service = 'es'
# credentials = boto3.Session().get_credentials()
# awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

# # # Restore snapshot (all indices except Dashboards and fine-grained access control)

# path = '_snapshot/snapshot-es-prod-20220204/manual_snapshot_by_oncall_engineer/_restore'
# url = host + path

# payload = {
#    "indices": [ "synthetic_consumptions", "analytic_consumptions", "synthetic_consumptions_maintenance" ],
#    "include_global_state": True
# }

# headers = {"Content-Type": "application/json"}

# r = requests.post(url, auth=awsauth, json=payload, headers=headers)

# print(r.text)

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

# Listar todos os índices no endpoint de origem
indices_url = source_host + '/_cat/indices?format=json'
response = requests.get(indices_url, auth=awsauth)

if response.status_code == 200:
    indices = [index['index'] for index in response.json()]
    print(f"Índices encontrados: {indices}")

    # Restaurar os índices no endpoint de destino
    restore_path = '_snapshot/snapshot-elastic-credit-services-uat-v3/snapshot-es-index-uat/_restore'
    restore_url = destination_host + '/' + restore_path

    payload = {
      "indices": ",".join(indices),
      "include_global_state": True
    }

    headers = {"Content-Type": "application/json"}

    # Fazendo a requisição POST para restaurar os índices
    r = requests.post(restore_url, auth=awsauth, json=payload, headers=headers)

    print(f"Restaurando índices: {r.status_code} {r.text}")
else:
    print(f"Erro ao listar índices: {response.status_code} {response.text}")
