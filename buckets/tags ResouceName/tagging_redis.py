import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

def list_clusters_and_tags(profile_name):
    try:
        # Cria uma sessão usando o perfil especificado
        session = boto3.Session(profile_name=profile_name)

        # Cria um cliente ElastiCache
        elasticache_client = session.client('elasticache')

        # Lista todas as instâncias Redis
        clusters = elasticache_client.describe_cache_clusters(ShowCacheNodeInfo=False)

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

            # Print the tags of the cluster
            print(f"Cluster ID: {cluster_id}")
            for tag in current_tags:
                print(f"  {tag['Key']}: {tag['Value']}")
            print()

    except NoCredentialsError:
        print("Erro: Credenciais não encontradas. Verifique seu arquivo de credenciais AWS.")
    except PartialCredentialsError:
        print("Erro: Credenciais incompletas. Verifique seu arquivo de credenciais AWS.")
    except ClientError as e:
        print(f"Erro ao acessar o cliente ElastiCache: {e}")
    except Exception as e:
        print(f"Ocorreu um erro: {e}")

# Chama a função com o perfil especificado
list_clusters_and_tags('ssrmprod')