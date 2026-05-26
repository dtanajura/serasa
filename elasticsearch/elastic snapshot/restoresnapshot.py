import boto3
import requests
import json
from requests_aws4auth import AWS4Auth

# Configurações
region = 'sa-east-1'
service = 'es'
profile = 'dsstage'
destination_host = 'https://vpc-credit-services-ext-v3-c5io3d2d3bgnc5k2cwuhveghti.sa-east-1.es.amazonaws.com'
source_host = 'https://vpc-credit-services-uat-v3-h4yauwoh5sl6mixxvpdtmiksom.sa-east-1.es.amazonaws.com'
snapshot_bucket = 'es-snapshot-v3'
snapshot_name = 'snapshot-es-index-uat'  # Nome do snapshot identificado

# Inicializa a sessão boto3
session = boto3.Session(profile_name=profile)
credentials = session.get_credentials()
aws_access_key = credentials.access_key
aws_secret_key = credentials.secret_key
aws_session_token = credentials.token

# Configura a autenticação AWS4Auth
awsauth = AWS4Auth(aws_access_key, aws_secret_key, region, service, session_token=aws_session_token)

# Função para restaurar o snapshot
def restore_snapshot():
    # Registra o repositório de snapshot no destino
    repository_payload = {
        "type": "s3",
        "settings": {
            "bucket": snapshot_bucket,
            "region": region,
            "role_arn": "arn:aws:iam::146737708860:role/BURoleForESSnapshot"  # Substitua pelo ARN do seu role
        }
    }
    response = requests.put(
        f"{destination_host}/_snapshot/es-snapshot-v3",
        data=json.dumps(repository_payload),
        headers={"Content-Type": "application/json"},
        auth=awsauth
    )
    print(response.json())

    # Restaura o snapshot com renomeação
    restore_payload = {
        "indices": "*",  # Substitua pelos índices que você deseja restaurar
        "ignore_unavailable": True,
        "include_global_state": True,
        "rename_pattern": "(.+)",
        "rename_replacement": "restored_$1"
    }
    response = requests.post(
        f"{destination_host}/_snapshot/es-snapshot-v3/{snapshot_name}/_restore",
        data=json.dumps(restore_payload),
        headers={"Content-Type": "application/json"},
        auth=awsauth
    )
    print(response.json())

# Função para listar os índices no source
def list_indices():
    response = requests.get(
        f"{source_host}/_cat/indices?v",
        headers={"Content-Type": "application/json"},
        auth=awsauth
    )
    print(response.text)

# Executa as funções
list_indices()
restore_snapshot()
