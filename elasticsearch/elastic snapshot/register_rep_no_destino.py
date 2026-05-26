import boto3
import requests
from requests_aws4auth import AWS4Auth

# Configuração do host e região
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
