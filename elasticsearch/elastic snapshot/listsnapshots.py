import boto3

# Configurações
region = 'sa-east-1'
profile = 'dsstage'
snapshot_bucket = 'es-snapshot-v3'

# Inicializa a sessão boto3
session = boto3.Session(profile_name=profile)
s3_client = session.client('s3', region_name=region)

# Função para listar os objetos no bucket
def list_bucket_objects():
    response = s3_client.list_objects_v2(Bucket=snapshot_bucket)
    for obj in response.get('Contents', []):
        print(obj['Key'])

# Executa a função
list_bucket_objects()
