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

            # Adiciona a tag ResourceName à lista de tags atuais, evitando duplicatas
            existing_keys = {tag['Key'] for tag in current_tags}
            if 'ResourceName' not in existing_keys:
                current_tags.append({'Key': 'ResourceName', 'Value': bucket_name})

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