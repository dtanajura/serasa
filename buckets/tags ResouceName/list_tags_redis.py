import boto3
import json
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

try:
    # Cria uma sessão usando o perfil especificado
    session = boto3.Session(profile_name='dsprod')

    # Cria um cliente ElastiCache
    elasticache_client = session.client('elasticache')

    # Lista todas as instâncias Redis
    clusters = elasticache_client.describe_cache_clusters()

    # Dicionário para armazenar as tags dos clusters Redis
    clusters_tags = {}

    # Itera sobre cada cluster Redis
    for cluster in clusters['CacheClusters']:
        cluster_id = cluster['CacheClusterId']
        
        # Obtém as tags atuais do cluster
        try:
            current_tags = elasticache_client.list_tags_for_resource(
                ResourceName=f'arn:aws:elasticache:{session.region_name}:{session.client("sts").get_caller_identity()["Account"]}:cluster:{cluster_id}'
            )['TagList']
        except elasticache_client.exceptions.CacheClusterNotFoundFault:
            current_tags = []

        # Armazena as tags no dicionário
        clusters_tags[cluster_id] = current_tags

        print(f"Cluster Redis {cluster_id}")

    # Salva as tags dos clusters Redis em um arquivo JSON
    with open('redis_tags.json', 'w') as json_file:
        json.dump(clusters_tags, json_file, indent=4)

    print("As tags dos clusters Redis foram salvas com sucesso no arquivo 'redis_tags.json'.")

except NoCredentialsError:
    print("Erro: Credenciais não encontradas. Verifique seu arquivo de credenciais AWS.")
except PartialCredentialsError:
    print("Erro: Credenciais incompletas. Verifique seu arquivo de credenciais AWS.")
except ClientError as e:
    print(f"Erro ao acessar o cliente ElastiCache: {e}")
except Exception as e:
    print(f"Ocorreu um erro: {e}")