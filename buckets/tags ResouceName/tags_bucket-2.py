import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

def tag_buckets(profile_name):
    try:
        # Cria uma sessão usando o perfil especificado
        session = boto3.Session(profile_name=profile_name)

        # Cria um cliente S3
        s3_client = session.client('s3')

        # Lista todos os buckets
        buckets = s3_client.list_buckets()

        # Define as regras de tags para cada grupo de buckets
        tagging_rules = {
            "commons": {
                "buckets": [
                    "athena-log-update",
                    "athenalogprod",
                    "aws-logs-662860092544-sa-east-1",
                    "dataservices-airflow-dags-prod",
                    "experian-datahub-checkpoint-prod",
                    "experian-datahub-config-files-prod",
                    "experian-datahub-landing-zone-prod",
                    "grafana-athena-nike",
                    "replication-lambda-exclude-versions-glue-prod",
                    "replication-lambda-nike-monitoring-checkpoint-prod",
                    "experian-datahub-validation",
                    "experian-replication-lambda-external-notification-prod"
                ],
                "tags": {
                    "BU": "EITS",
                    "Layer": "Commons",
                    "Project": "Nike reports",
                    "Squad": "DcF",
                    "Dataset": "Commons"
                }
            },
            "bronze_negativos": {
                "buckets": [
                    "experian-datahub-bronze-prod",
                    "experian-datahub-kafkalog-prod",
                    "experian-datahub-kafkalog-v2-prod"
                ],
                "tags": {
                    "BU": "EITS",
                    "Layer": "Bronze",
                    "Project": "Nike reports",
                    "Squad": "DcF",
                    "Dataset": "Negativos"
                }
            },
            "silver_negativos": {
                "buckets": [
                    "experian-datahub-silver-prod"
                ],
                "tags": {
                    "BU": "EITS",
                    "Layer": "Silver",
                    "Project": "Nike reports",
                    "Squad": "DcF",
                    "Dataset": "Negativos"
                }
            },
            "gold_negativos": {
                "buckets": [
                    "experian-datahub-gold-reports-prod",
                    "experian-dataservices-reports-artifacts-prod"
                ],
                "tags": {
                    "BU": "EITS",
                    "Layer": "Gold",
                    "Project": "Nike reports",
                    "Squad": "DcF",
                    "Dataset": "Negativos"
                }
            },
            "bronze_passagem": {
                "buckets": [
                    "experian-datahub-passagem-bronze-prod",
                    "experian-datahub-passagem-kafkalog-prod",
                    "experian-replication-kafka-connector-passagem-prod"
                ],
                "tags": {
                    "BU": "EITS",
                    "Layer": "Bronze",
                    "Project": "Nike reports",
                    "Squad": "DcF",
                    "Dataset": "Passagem"
                }
            },
            "silver_passagem": {
                "buckets": [
                    'experian-datahub-passagem-silver-prod'
                ],
                'tags': {
                    'BU': 'EITS',
                    'Layer': 'Silver',
                    'Project': 'Nike reports',
                    'Squad': 'DcF',
                    'Dataset': 'Passagem'
                }
            },
            'silver_cadastrais': {
                'buckets': [
                    'experian-datahub-cadastrais-silver-prod'
                ],
                'tags': {
                    'BU': 'EITS',
                    'Layer': 'Silver',
                    'Project': 'Nike reports',
                    'Squad': 'DcF',
                    'Dataset': 'Cadastrais'
                }
            }
        }

        # Itera sobre cada bucket
        for bucket in buckets['Buckets']:
            bucket_name = bucket['Name']
            
            # Obtém as tags atuais do bucket
            try:
                current_tags = s3_client.get_bucket_tagging(Bucket=bucket_name)['TagSet']
            except ClientError as e:
                if e.response['Error']['Code'] == 'NoSuchTagSet':
                    current_tags = []
                else:
                    raise

            # Adiciona as novas tags conforme a regra, evitando duplicatas
            for rule in tagging_rules.values():
                if bucket_name in rule['buckets']:
                    for key, value in rule['tags'].items():
                        if not any(tag['Key'] == key for tag in current_tags):
                            current_tags.append({'Key': key, 'Value': value})

            # Atualiza as tags do bucket
            s3_client.put_bucket_tagging(
                Bucket=bucket_name,
                Tagging={
                    'TagSet': current_tags
                }
            )

            print(f"Tags foram adicionadas com sucesso ao bucket {bucket_name}.")

    except NoCredentialsError:
        print("Erro: Credenciais não encontradas. Verifique seu arquivo de credenciais AWS.")
    except PartialCredentialsError:
        print("Erro: Credenciais incompletas. Verifique seu arquivo de credenciais AWS.")
    except ClientError as e:
        print(f"Erro ao acessar o cliente S3: {e}")
    except Exception as e:
        print(f"Ocorreu um erro: {e}")

# Chama a função com o perfil especificado
tag_buckets('dsprod')