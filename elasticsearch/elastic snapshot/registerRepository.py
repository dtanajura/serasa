# import boto3
# import requests
# from requests_aws4auth import AWS4Auth

# #host = 'https://vpc-elastic-ssbl-prd-num37u3eskfqyzstedw7456vma.sa-east-1.es.amazonaws.com/'
# #host = 'https://vpc-elastic-ssbl-prod-e3liing5nm5ghrahh2wpa3fdgu.sa-east-1.es.amazonaws.com/'
# host = 'https://vpc-credit-services-uat-v3-h4yauwoh5sl6mixxvpdtmiksom.sa-east-1.es.amazonaws.com'
# #host = 'https://vpc-elastic-ssbl-uat-prkbcc6wibfdcq3467goahy7h4.sa-east-1.es.amazonaws.com/'
# #host = 'vpc-elastic-ssbl-qa-65heb5vt2bl6enexgdllrkghn4.sa-east-1.es.amazonaws.com'
# #host = 'vpc-elastic-ssbl-dev-ufxo6firerm27ykdtyyedopk24.sa-east-1.es.amazonaws.com'
# region = 'sa-east-1'
# service = 'es'
# credentials = boto3.Session().get_credentials()
# awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

# # Register repository

# path = '_snapshot/snapshot-elastic-credit-services-uat-v3' # the OpenSearch API endpoint
# url = host + path

# payload = {
#    "type": "s3",
#    "settings": {
#     "bucket": "es-snapshot-v3",
#     "region": "sa-east-1",
#     "role_arn" : "arn:aws:iam::146737708860:role/BURoleForESSnapshot"
#   }
# }

# headers = {"Content-Type": "application/json"}

# r = requests.put(url, auth=awsauth, json=payload, headers=headers)

# print(r.status_code)
# print(r.text)

import boto3
import requests
from requests_aws4auth import AWS4Auth

# Configuração do host e região
host = 'https://vpc-credit-services-uat-v3-h4yauwoh5sl6mixxvpdtmiksom.sa-east-1.es.amazonaws.com'
region = 'sa-east-1'
service = 'es'

# Criação da sessão boto3 usando o perfil 'dsstage'
session = boto3.Session(profile_name='dsstage')
credentials = session.get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

# Registro do repositório
path = '_snapshot/snapshot-elastic-credit-services-uat-v3'
url = host + '/' + path

payload = {
   "type": "s3",
   "settings": {
    "bucket": "es-snapshot-v3",
    "region": "sa-east-1",
    "role_arn" : "arn:aws:iam::146737708860:role/BURoleForESSnapshot"
  }
}

headers = {"Content-Type": "application/json"}

# Fazendo a requisição PUT
r = requests.put(url, auth=awsauth, json=payload, headers=headers)

print(r.status_code)
print(r.text)
