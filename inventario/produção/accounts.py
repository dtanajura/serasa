
import boto3
import argparse
import psycopg2

def list_discovered_resources(config_client, resource_type):
    """
    Lista os recursos descobertos de um tipo específico, usando um cliente de serviço Config fornecido.
    
    :param config_client: Cliente do serviço AWS Config.
    :param resource_type: Tipo de recurso para listar (ex: 'AWS::S3::Bucket', 'AWS::EC2::Instance').
    :return: Lista de IDs de recursos descobertos.
    """
    # Lista para armazenar os recursos descobertos
    discovered = []

    # Chame o método list_discovered_resources do cliente Config
    paginator = config_client.get_paginator('list_discovered_resources')
    for page in paginator.paginate(resourceType=resource_type):
        for resource in page['resourceIdentifiers']:
            discovered.append(resource['resourceId'])

    return discovered

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='List discovered resources in specified AWS regions for a specific AWS CLI profile.')
    parser.add_argument('profile', help='The name of the AWS CLI profile to use')

    args = parser.parse_args()

    # Obtém o número da conta da AWS
    session = boto3.Session(profile_name=args.profile)
    sts_client = session.client('sts')
    account_id = sts_client.get_caller_identity()['Account']

    # Configurações do banco de dados
    db_config = {
        'host': 'dev-hub-portal-qa.cbjrpisgumc2.sa-east-1.rds.amazonaws.com',
        'user': 'app-user',
        'password': '123Trocar$',
        'dbname': 'inventario'
    }

    try:
        # Conectando ao banco de dados
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()

        # # Comando SQL para inserir os valores
        # insert_query = f"""
        #     INSERT INTO accounts (account_id, account_name)
        #     VALUES ('{account_id}', '{args.profile}');
        # """
        # # Executando o comando
        # cursor.execute(insert_query)
        # conn.commit()
        # print("Valores inseridos com sucesso:")
        # print(f"{account_id},{args.profile}")

        # Verificando se o account_id já existe na tabela
        check_query = f"""
            SELECT COUNT(*) FROM accounts WHERE account_id = '{account_id}';
        """

        cursor.execute(check_query)
        result = cursor.fetchone()

        if result[0] == 0:
            # O account_id não existe, então vamos inserir uma nova linha
            insert_query = f"""
                INSERT INTO accounts (account_id, account_name)
                VALUES ({account_id}, '{args.profile}');
            """
            cursor.execute(insert_query)
            conn.commit()
            print("Nova linha inserida com sucesso:")
            print(f"account_id: {account_id}, account_name: {args.profile}")
        else:
            print(f"O account_id {account_id} já existe na tabela.")


    # Fechando a conexão com o banco de dados
    except (Exception, psycopg2.Error) as error:
        print(f"Erro de banco de dados: {error}")

    finally:
        # Fechando a conexão
        if conn:
            cursor.close()
            conn.close()

