import boto3
import json
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

def list_keyspaces_and_tags(profile_name):
    try:
        # Cria uma sessão usando o perfil especificado
        session = boto3.Session(profile_name=profile_name)

        # Cria um cliente Keyspaces
        keyspaces_client = session.client('keyspaces')

        # Lista todos os keyspaces
        response = keyspaces_client.list_keyspaces()

        # Verifica se a chave 'keyspaces' está na resposta
        if 'keyspaces' not in response:
            print("Erro: A resposta da API não contém a chave 'keyspaces'.")
            return

        keyspaces = response['keyspaces']

        # Dicionário para armazenar as tags dos keyspaces
        keyspaces_tags = {}

        # Itera sobre cada keyspace
        for keyspace in keyspaces:
            keyspace_name = keyspace['keyspaceName']
            
            # Obtém as tags atuais do keyspace
            try:
                tags_response = keyspaces_client.list_tags_for_resource(
                    resourceArn=keyspace['resourceArn']
                )
                # Verifica se a chave 'Tags' está na resposta
                if 'tags' in tags_response:
                    current_tags = tags_response['tags']
                else:
                    current_tags = []
            except keyspaces_client.exceptions.ResourceNotFoundException:
                current_tags = []

            # Armazena as tags no dicionário
            keyspaces_tags[keyspace_name] = current_tags
            print(keyspace_name)
        
        # Salva as tags dos keyspaces em um arquivo JSON
        with open('keyspaces_tags.json', 'w') as json_file:
            json.dump(keyspaces_tags, json_file, indent=4)

        print("As tags dos keyspaces foram salvas com sucesso no arquivo 'keyspaces_tags.json'.")

    except NoCredentialsError:
        print("Erro: Credenciais não encontradas. Verifique seu arquivo de credenciais AWS.")
    except PartialCredentialsError:
        print("Erro: Credenciais incompletas. Verifique seu arquivo de credenciais AWS.")
    except ClientError as e:
        print(f"Erro ao acessar o cliente Keyspaces: {e}")
    except Exception as e:
        print(f"Ocorreu um erro: {e}")

# Chama a função com o perfil especificado
list_keyspaces_and_tags('dsprod')