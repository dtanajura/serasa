# import boto3
# import requests
# from requests_aws4auth import AWS4Auth

# host = 'https://vpc-credit-services-uat-v3-h4yauwoh5sl6mixxvpdtmiksom.sa-east-1.es.amazonaws.com/'
# region = 'sa-east-1'
# service = 'es'
# credentials = boto3.Session().get_credentials()
# awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

# # Create Snapshot

# path = '_snapshot/snapshot-elastic-credit-services-uat-v3/snapshot-es-index-uat'
# url = host + path

# payload = {
#   "indices": ["synthetic_consumptions_maintenance"]
# }

# headers = {"Content-Type": "application/json"}

# r = requests.put(url, auth=awsauth, json=payload, headers=headers)

# print(r.status_code)
# print(r.text)

import boto3
import requests
from requests_aws4auth import AWS4Auth

# Configuração do host e região
host = 'https://vpc-credit-services-uat-v3-h4yauwoh5sl6mixxvpdtmiksom.sa-east-1.es.amazonaws.com/'
region = 'sa-east-1'
service = 'es'

# Criação da sessão boto3 usando o perfil 'dsstage'
session = boto3.Session(profile_name='dsstage')
credentials = session.get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

# Listar todos os índices
indices_url = host + '_cat/indices?format=json'
response = requests.get(indices_url, auth=awsauth)

if response.status_code == 200:
    indices = [index['index'] for index in response.json()]
    print(f"Índices encontrados: {indices}")

    # Criação do Snapshot
    path = '_snapshot/snapshot-elastic-credit-services-uat-v3/snapshot-es-index-uat'
    url = host + path

    payload = {
      "indices": indices
    }

    headers = {"Content-Type": "application/json"}

    # Fazendo a requisição PUT para criar o snapshot
    r = requests.put(url, auth=awsauth, json=payload, headers=headers)

    print(r.status_code)
    print(r.text)
else:
    print(f"Erro ao listar índices: {response.status_code} {response.text}")
