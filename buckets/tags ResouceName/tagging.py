import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

try:
    # Cria uma sessão usando o perfil especificado
    session = boto3.Session(profile_name='ssrmsandbox')

    # Cria um cliente S3
    s3_client = session.client('s3')

    # Lista todos os buckets
    buckets = s3_client.list_buckets()

    # Novas tags a serem adicionadas
    new_tags = [
        {'Key': 'Asset_Category', 'Value': 'Sandbox'},
        {'Key': 'Data_Category', 'Value': 'N/A'},
        {'Key': 'Data_Type', 'Value': 'N/A'},
        {'Key': 'Project', 'Value': 'nike'}
    ]

    # Nome do bucket a ser excluído
    excluded_bucket = "087086536124-ssbl-tfstates"

    # Itera sobre cada bucket
    for bucket in buckets['Buckets']:
        bucket_name = bucket['Name']
        
        # Pula o bucket excluído
        if bucket_name == excluded_bucket:
            continue
        
        # Obtém as tags atuais do bucket
        try:
            current_tags = s3_client.get_bucket_tagging(Bucket=bucket_name)['TagSet']
        except s3_client.exceptions.NoSuchTagSet:
            current_tags = []

        # Adiciona as novas tags à lista de tags atuais, evitando duplicatas
        existing_keys = {tag['Key'] for tag in current_tags}
        for tag in new_tags:
            if tag['Key'] not in existing_keys:
                current_tags.append(tag)

        # Lê a tag ResourceName e adiciona a tag Name com o mesmo valor
        resource_name_tag = next((tag for tag in current_tags if tag['Key'] == 'ResourceName'), None)
        if resource_name_tag:
            current_tags.append({'Key': 'Name', 'Value': resource_name_tag['Value']})

        # Atualiza as tags do bucket
        s3_client.put_bucket_tagging(
            Bucket=bucket_name,
            Tagging={
                'TagSet': current_tags
            }
        )

        print(f"Tags foram adicionadas com sucesso ao bucket {bucket} .")

except NoCredentialsError:
    print("Erro: Credenciais não encontradas. Verifique seu arquivo de credenciais AWS.")
except PartialCredentialsError:
    print("Erro: Credenciais incompletas. Verifique seu arquivo de credenciais AWS.")
except ClientError as e:
    print(f"Erro ao acessar o cliente S3: {e}")
except Exception as e:
    print(f"Ocorreu um erro: {e}")