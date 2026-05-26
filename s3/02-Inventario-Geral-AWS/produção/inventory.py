import boto3
import argparse
import psycopg2
from datetime import datetime, timedelta

def list_tags(db_config, session, account_id):
    print("**************** List Tags")
    tagging_client = session.client('resourcegroupstaggingapi')
    paginator = tagging_client.get_paginator('get_resources')
    page_iterator = paginator.paginate()
    tag_set = set()
    for page in page_iterator:
        for resource_tag_mapping in page['ResourceTagMappingList']:
            tag_set.update(tag['Value'] for tag in resource_tag_mapping['Tags'] if tag['Key'] == "Name")

    tamanho=len(tag_set)
    # '12qw3esrtrfgb print(f"Unique tags found: {tamanho}")

    ce_client = session.client('ce')

    # Configura datas para cobrir o último ano
    end_date = datetime.now()
    end_date = end_date.replace(hour=0,minute=0,second=0,microsecond=0)
    start_date = end_date.replace(year=end_date.year - 1)
    end_date = end_date.strftime('%Y-%m-%d')
    start_date = start_date.strftime('%Y-%m-%d')
    posicao=0
    for tag_value in tag_set:
        # Verifica se há custos associados à tag no último ano
        print(f"Posição = {posicao} de Total = {tamanho}")
        posicao=posicao+1
        cost_response = ce_client.get_cost_and_usage(
            TimePeriod={'Start': start_date, 'End': end_date},
            Granularity='MONTHLY',
            Metrics=['UnblendedCost'],
            Filter={
                'Tags': {
                    'Key': 'Name',
                    'Values': [tag_value]
                }
            }
        )
        # Se houver custos, chama fetch_and_store_costs
        total_cost = sum(float(result['Total']['UnblendedCost']['Amount']) for result in cost_response['ResultsByTime'] if 'UnblendedCost' in result['Total'])
        if total_cost != 0:
            fetch_and_store_costs(db_config, account_id, tag_value, cost_response)
        else:
            print(f"No costs found for tag '{tag_value}' in the last year, skipping fetch_and_store_costs.")

def fetch_and_store_costs(db_config, account_id, tag_value, cost_response):
    print(f"TAG: {tag_value}")
    try:
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()

        for result in cost_response['ResultsByTime']:
            month_end = datetime.strptime(result['TimePeriod']['End'], '%Y-%m-%d')
            amount = result['Total']['UnblendedCost']['Amount'] if 'UnblendedCost' in result['Total'] else '0'
            service = 'Generic Service'  # Assume generic service if no specific service data
            print(f"Mês: {month_end} Valor {amount}")

            cursor.execute("""
                INSERT INTO tag_cost (account_id, tag_name, unblended_cost, type, service, date_register)
                VALUES (%s, %s, %s, 'Cost Allocation', %s, %s)
                ON CONFLICT (account_id, tag_name, service, date_register) DO UPDATE
                SET unblended_cost = EXCLUDED.unblended_cost;
            """, (account_id, tag_value, amount, service, month_end))
        conn.commit()

    except Exception as e:
        print(f"Erro ao acessar o banco de dados: {e}")

    finally:
        if conn:
            cursor.close()
            conn.close()

def write_eks_version(db_config,session,account_id):
    print("**************** write_eks_version")
    # Cria um cliente para o serviço EKS
    eks_client = session.client('eks')
    
    # Lista todos os clusters EKS
    response = eks_client.list_clusters()
    clusters = response['clusters']
 
    # Para cada cluster, busca a versão do Kubernetes
    for cluster_name in clusters:
        cluster_info = eks_client.describe_cluster(name=cluster_name)
        version = cluster_info['cluster']['version']
        print(f"Account ID: {account_id}, Cluster: {cluster_name}, Kubernetes Version: {version}")

def write_cost_by_services(db_config, session, account_id):
    print("**************** write_cost_by_services")
    ce_client = session.client('ce')

    # Configura datas para cobrir o último ano
    end_date = datetime.now()
    end_date = end_date.replace(hour=0,minute=0,second=0,microsecond=0)
    start_date = end_date.replace(year=end_date.year - 1)
    end_date = end_date.strftime('%Y-%m-%d')
    start_date = start_date.strftime('%Y-%m-%d')

    try:
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()

        cost_response = ce_client.get_cost_and_usage(
            TimePeriod={'Start': start_date, 'End': end_date},
            Granularity='MONTHLY',
            Metrics=["UnblendedCost", "UsageQuantity"],
            GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}]
        )

        # Processar e armazenar dados
        for month_data in cost_response['ResultsByTime']:
            month_start = datetime.strptime(month_data['TimePeriod']['Start'], '%Y-%m-%d')
            month_end = datetime.strptime(month_data['TimePeriod']['End'], '%Y-%m-%d')
            # Verificar se já existem dados para o mês
            cursor.execute("""
                SELECT 1 FROM resource_cost 
                WHERE account_id = %s AND date_register = %s;
            """, (account_id, month_end))
            if cursor.fetchone():
                print(f"Dados já registrados para {month_start.strftime('%Y-%m-%d')} a {month_end.strftime('%Y-%m-%d')}, pulando...")
                continue

            for group in month_data['Groups']:
                service_name = group['Keys'][0]
                unblended_cost_amount = group['Metrics']['UnblendedCost']['Amount']
                usage_quantity_amount = group['Metrics']['UsageQuantity']['Amount']

                cursor.execute("""
                    INSERT INTO resource_cost (date_register, service, account_id, unblended_cost, usage_quantity)
                    VALUES (%s, %s, %s, %s, %s);
                """, (month_end, service_name, account_id, unblended_cost_amount, usage_quantity_amount))
            
            conn.commit()

    except Exception as e:
        print(f"Erro ao acessar o banco de dados: {e}")
    finally:
        if conn:
            cursor.close()
            conn.close()

def write_cost_by_account(db_config, session, account_id):
    print("write_cost_by_account")
    ce_client = session.client('ce')
    now = datetime.now()
    now = now.replace(hour=0,minute=0,second=0,microsecond=0)
    
    # Conectando ao banco de dados
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()

    try:
        # Loop para os últimos 12 meses + mês corrente
        for i in range(13):
            month_start = (now.replace(day=1) - timedelta(days=i*30)).replace(day=1)
            if i == 0:  # Mês corrente
                month_end = now
            else:
                month_end = month_start + timedelta(days=32)
                month_end = month_end.replace(day=1) - timedelta(days=1)
            
            date_register = month_end

            # Verificar se o custo já foi registrado para evitar consultas duplicadas
            cursor.execute("""
                SELECT unblended_cost FROM account_cost
                WHERE account_id = %s AND date_register = %s;
            """, (account_id, date_register))
            result = cursor.fetchone()
            
            if result is None:
                # Consulta ao Cost Explorer
                response = ce_client.get_cost_and_usage(
                    TimePeriod={'Start': month_start.strftime('%Y-%m-%d'), 'End': month_end.strftime('%Y-%m-%d')},
                    Granularity='MONTHLY',
                    Metrics=["UnblendedCost"],
                )
                
                if response['ResultsByTime'][0]['Total']:
                    account_cost = response['ResultsByTime'][0]['Total']['UnblendedCost']['Amount']
                else:
                    account_cost = 0

                print(account_cost)

                # Inserir novo registro
                cursor.execute("""
                    INSERT INTO account_cost (account_id, unblended_cost, date_register)
                    VALUES (%s, %s, %s);
                """, (account_id, account_cost, date_register))
                print(f"Account ID: {account_id} Inserted cost {date_register}: {account_cost}")
            else:
                print(f"Cost for {date_register} already in database: {result[0]}")
        
        conn.commit()

    except (Exception, psycopg2.Error) as error:
        print(f"Erro de banco de dados: {error}")
    finally:
        # Fechando a conexão
        if conn:
            cursor.close()
            conn.close()

def write_cost_by_tag(db_config,account_id,tag_name,type_tag,tag_unblended_cost):
    print("write_cost_by_tag")
    try:
            # Conectando ao banco de dados
            conn = psycopg2.connect(**db_config)
            cursor = conn.cursor()

            # Comando SQL para inserir os valores na tabela account
            # Verificando se o account_id já existe na tabela
            check_query = f"""
                SELECT FROM tag_cost WHERE account_id = '{account_id}' and tag_name = '{tag_name}';
            """
            cursor.execute(check_query)
            result = cursor.fetchone()
            print(f"Custos - {account_id}, {tag_name}, {tag_unblended_cost}, {type_tag}")
            if result == None:
                # O account_id e tag_name não existem, então vamos inserir uma nova linha
                insert_query = f"""
                    INSERT INTO tag_cost (account_id,tag_name,unblended_cost,type)
                    VALUES ({account_id}, '{tag_name}', '{tag_unblended_cost}','{type_tag}');
                """
                cursor.execute(insert_query)
                conn.commit()
            else:
                # account_id e tag_name existem, então vamos atualizar unblended cost
                update_query = f"""
                    UPDATE tag_cost SET unblended_cost = {tag_unblended_cost}
                    WHERE account_id = '{account_id}' AND tag_name = '{tag_name}';
                """
                cursor.execute(update_query)
                conn.commit()

    except (Exception, psycopg2.Error) as error:
        # Fechando a conexão com o banco de dados
        print(f"Erro de banco de dados: {error}")
    finally:
        # Fechando a conexão
        if conn:
            cursor.close()
            conn.close()

def list_emr_clusters_by_tag(session,account_id):
    print("list_emr_clusters_by_tag")
    clusters_emr = []
    # Cria um cliente para o serviço EMR
    emr_client = session.client('emr')

    # Cria um cliente para o serviço Resource Groups Tagging API
    tagging_client = session.client('resourcegroupstaggingapi')

    # Lista os clusters EMR
    response = emr_client.list_clusters(ClusterStates=['STARTING', 'BOOTSTRAPPING', 'RUNNING', 'WAITING', 'TERMINATING'])
        
    # Para cada cluster, obter as tags e imprimir a tag "Name"
    for cluster in response['Clusters']:
        cluster_id = cluster['Id']
        tags_response = tagging_client.get_resources(
#            ResourceTypeFilters=['elasticmapreduce:cluster'],
            ResourceARNList=[
                f'arn:aws:elasticmapreduce:{session.region_name}:{account_id}:cluster/{cluster_id}'
            ]
        )
        
        if tags_response['ResourceTagMappingList']:
            tags = tags_response['ResourceTagMappingList'][0]['Tags']
            name_tag = next((tag for tag in tags if tag['Key'] == 'Name'), None)
            if name_tag:
                clusters_emr.append(name_tag['Value'])

                
    return clusters_emr

def write_inventory_items(session,db_config,region,resource_types):
    print("write_inventory_items")
    config_client = session.client('config', region_name=region)
    paginator = config_client.get_paginator('list_discovered_resources')

    try:
    # Conectando ao banco de dados
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()

        for full_resource_type in resource_types:
            iterator = paginator.paginate(resourceType=full_resource_type)
            for page in iterator:
                if page['resourceIdentifiers'] != "": 
                    for resource in page['resourceIdentifiers']:
                        parts = full_resource_type.split("::")
                        service = parts[1]
                        resource_type = parts[2]
                        print(f"Service = {service}   Resource Type = {resource_type}   Resource ID = {resource['resourceId']}")
                        insert_query = f"""
                            INSERT INTO resources (account_id, region, resource_service, resource_type, resource_id)
                            VALUES ('{account_id}', '{region}', '{service}', '{resource_type}', '{resource['resourceId']}')
                            ON CONFLICT (account_id, region, resource_service, resource_type, resource_id) DO NOTHING;
                        """
                        # Executando o comando
                        cursor.execute(insert_query)
            conn.commit()
    
    except (Exception, psycopg2.Error) as error:
        # Fechando a conexão com o banco de dados
        print(f"Erro de banco de dados: {error}")
    finally:
        # Fechando a conexão
        if conn:
            cursor.close()
            conn.close()

def get_resource_types(db_config):
    print("get_resource_types")
    resource_types = []
    try:
        # Conectando ao banco de dados
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()

       # Consulta para obter os tipos de recursos da tabela "resources_type"
        query = "SELECT types FROM resources_type"
        cursor.execute(query)
        resource_types = [row[0] for row in cursor.fetchall()]

    #     # Lê os tipos de recursos do arquivo especificado
    #     with open(args.resource_file, 'r') as file:
    #         resource_types = [line.strip() for line in file if line.strip()]

    except (Exception, psycopg2.Error) as error:
        print(f"Erro de banco de dados: {error}")

    finally:
        # Fechando a conexão
        if conn:
            cursor.close()
            conn.close()
    return resource_types

def update_account_name(db_config, account_id, account_name):
    print("update_account_name")
    try:
        # Conectando ao banco de dados
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()

        # Verifica se o account_id existe e se o account_name é diferente do novo valor
        cursor.execute("""
            SELECT account_name FROM accounts WHERE account_id = %s;
        """, (account_id,))
        result = cursor.fetchone()

        if result is None:
            # O account_id não existe, então vamos inserir uma nova linha
            cursor.execute("""
                INSERT INTO accounts (account_id, account_name) VALUES (%s, %s);
            """, (account_id, account_name))
            conn.commit()
            print(f"Nova linha inserida com sucesso: account_id: {account_id}, account_name: {account_name}")
        elif result[0] != account_name:
            # O account_name é diferente, precisa atualizar
            cursor.execute("""
                UPDATE accounts SET account_name = %s WHERE account_id = %s;
            """, (account_name, account_id))
            conn.commit()
            print(f"account_id {account_id} atualizado para novo account_name: {account_name}")
        else:
            # O account_name é o mesmo, não faz nada
            print(f"Nenhuma atualização necessária para account_id {account_id}.")

    except (Exception, psycopg2.Error) as error:
        print(f"Erro de banco de dados: {error}")

    finally:
        # Fechando a conexão
        if conn:
            cursor.close()
            conn.close()

def clean_table_records(db_config,account_id):
    print("clean_table_records")
    try:
            # Conectando ao banco de dados
            conn = psycopg2.connect(**db_config)
            cursor = conn.cursor()

            # Comando SQL para excluir registros com o account_id específico
            delete_query = f"""
                DELETE FROM resources
                WHERE account_id = '{account_id}';
            """
            # delete_query = f"""
            #     DELETE FROM resourcescost
            #     WHERE account_id = '{account_id}';
            # """

            # Executando o comando
            cursor.execute(delete_query)
            conn.commit()
            print(f"Registros com account_id {account_id} excluídos com sucesso!")

    except (Exception, psycopg2.Error) as error:
        print(f"Erro de banco de dados: {error}")

    finally:
        # Fechando a conexão
        if conn:
            cursor.close()
            conn.close()

def write_date_register(db_config):
    print("write_date_register")
    try:
            # Conectando ao banco de dados
            conn = psycopg2.connect(**db_config)
            cursor = conn.cursor()
            now = datetime.now()
            now = now.replace(hour=0,minute=0,second=0,microsecond=0)


            # Comando SQL para excluir registros com o account_id específico
            update_query = f"""
                UPDATE registro
                SET date_register = '{now}';
            """
            # Executando o comando
            cursor.execute(update_query)
            conn.commit()

    except (Exception, psycopg2.Error) as error:
        print(f"Erro de banco de dados: {error}")

    finally:
        # Fechando a conexão
        if conn:
            cursor.close()
            conn.close()

if __name__ == '__main__':
    inicio=datetime.now()
    parser = argparse.ArgumentParser(description='List discovered resources in specified AWS regions for a specific AWS CLI profile.')
    parser.add_argument('profile', help='The name of the AWS CLI profile to use')

    args = parser.parse_args()
    account = args.profile      # nome conhecido da conta pelo time Nike

    # Obtém o número da conta da AWS
    session = boto3.Session(profile_name=account)
    sts_client = session.client('sts')
    account_id = sts_client.get_caller_identity()['Account']
    # account_name = '{{account_name}}'  # nome de registro da conta na AWS ex.: eec-aws-br-ds-dataservices-dev

    # Define as regiões permitidas
    permitted_regions = ['us-east-1','sa-east-1' ]
    for permitted_region in permitted_regions:
        ec2 = session.client("ec2",region_name=permitted_region)
        response = ec2.describe_vpcs(Filters=[{'Name':'isDefault','Values': ['false']}])
        if response['Vpcs']:
            region=permitted_region
    

    db_config = {
        'host': 'dev-hub-portal-qa.cbjrpisgumc2.sa-east-1.rds.amazonaws.com',
        'user': 'app-user',
        'password': '123Trocar$',
        'dbname': 'inventario'
    }

    # Configurar data e hora da última coleta
    write_date_register(db_config)

    # Atualizando o account name na tabela accounts
    update_account_name(db_config,account_id,account)

    # Consulta para obter os tipos de recursos da tabela "resources_type"
    resource_types = get_resource_types(db_config)
    
    # Escreve os itens de inventário 
    write_inventory_items(session,db_config,region,resource_types)

    # Obetem custo total da conta da AWS
    write_cost_by_account(db_config,session,account_id)

    # Obtem custo dos servicos
    write_cost_by_services(db_config,session,account_id)

    # Obtem o custo por Tags Name
    list_tags(db_config, session, account_id)

    fim=datetime.now()
    print(f"************************************************\n Tempo de execução da conta {account} é de {fim - inicio}")