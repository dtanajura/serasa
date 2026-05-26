import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

def add_resource_name_tags(profile_name, region='sa-east-1'):
    try:
        # Configura o profile da AWS
        session = boto3.Session(profile_name=profile_name)
        ec2 = session.client('ec2', region_name=region)
        
        # Obtém todas as instâncias EC2
        instances = ec2.describe_instances()
        
        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                resource_id = instance['InstanceId']
                
                # Obtém as tags da instância
                tags = {tag['Key']: tag['Value'] for tag in instance.get('Tags', [])}
                
                # Verifica se a tag 'Name' ou 'name' existe
                name_tag_value = tags.get('Name') or tags.get('name')
                print(f"Tag 'Name' existe na instância {resource_id} com valor '{name_tag_value}'")
                
                if name_tag_value:
                    # Verifica se a tag 'ResourceName' já existe
                    if 'Application' not in tags:
                        # Cria a tag 'ResourceName' com o mesmo valor da tag 'Name' ou 'name'
                        # ec2.create_tags(
                        #     Resources=[resource_id],
                        #     Tags=[
                        #         {
                        #             'Key': 'ResourceName',
                        #             'Value': name_tag_value
                        #         }
                        #     ]
                        # )
                        print(f"Tag 'ResourceName' criada para a instância {resource_id} com valor '{name_tag_value}'")
                    else:
                        resourcename_tag_value = tags.get('Application')
                        print(f"A tag 'ResourceName' já existe para a instância {resource_id} com valor '{resourcename_tag_value}'.")
                else:
                    print(f"A tag 'Name' ou 'name' não foi encontrada para a instância {resource_id}.")
    except (NoCredentialsError, PartialCredentialsError):
        print("Credenciais da AWS não encontradas ou incompletas. Verifique seu profile name e configuração.")

# Exemplo de uso
profile_name = 'dsprod'  # Substitua pelo nome do seu profile
add_resource_name_tags(profile_name)