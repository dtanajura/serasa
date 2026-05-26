import boto3
import json
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

def list_buckets_and_tags(profile_name):
    try:
        # Cria uma sessão usando o perfil especificado
        session = boto3.Session(profile_name=profile_name)

        # Cria um cliente S3
        s3_client = session.client('s3')

        # Lista todos os buckets
        buckets = s3_client.list_buckets()

        # Dicionário para armazenar as tags dos buckets
        buckets_tags = {}

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

            # Armazena as tags no dicionário
            buckets_tags[bucket_name] = current_tags
            print(bucket_name)

        # Salva as tags dos buckets em um arquivo JSON
        with open('buckets_tags.json', 'w') as json_file:
            json.dump(buckets_tags, json_file, indent=4)

        print("As tags dos buckets foram salvas com sucesso no arquivo 'buckets_tags.json'.")

    except NoCredentialsError:
        print("Erro: Credenciais não encontradas. Verifique seu arquivo de credenciais AWS.")
    except PartialCredentialsError:
        print("Erro: Credenciais incompletas. Verifique seu arquivo de credenciais AWS.")
    except ClientError as e:
        print(f"Erro ao acessar o cliente S3: {e}")
    except Exception as e:
        print(f"Ocorreu um erro: {e}")

# Chama a função com o perfil especificado
list_buckets_and_tags('dsprod')