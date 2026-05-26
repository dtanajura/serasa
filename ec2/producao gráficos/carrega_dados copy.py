import re
import boto3
import argparse
import psycopg2
from datetime import datetime, timedelta

def write_cost_by_tags_details(db_config, session, account_id):
    print("\n**************** write_cost_by_tags_details")
    ce_client = session.client('ce')

    # Configura datas para cobrir o último ano
    end_date = datetime.now()
    end_date = end_date.replace(hour=0,minute=0,second=0,microsecond=0)
    start_date = end_date.replace(year=end_date.year - 1)
    end_date = end_date.strftime('%Y-%m-%d')
    start_date = start_date.strftime('%Y-%m-%d')

    fim_mes = datetime.now().replace(hour=0,minute=0,second=0,microsecond=0)
    fim_mes = fim_mes.replace(day=1,month=fim_mes.month+1) - timedelta(days=1)

    try:
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()

        cost_response = ce_client.get_cost_and_usage(
            TimePeriod={'Start': start_date, 'End': end_date},
            Granularity='MONTHLY',
            Metrics=['UnblendedCost'],
            GroupBy=[{'Type': 'TAG', 'Key': 'Name'}, {'Type': 'DIMENSION', 'Key': 'SERVICE'}]
        )
        # Processar e armazenar dados
        for month_data in cost_response['ResultsByTime']:
            month_start = datetime.strptime(month_data['TimePeriod']['Start'], '%Y-%m-%d')
            # month_end = datetime.strptime(month_data['TimePeriod']['End'], '%Y-%m-%d')
            month_end = month_start + timedelta(days=32)
            month_end = month_end.replace(day=1) - timedelta(days=1)

            # Verificar se já existem dados para o mês
            cursor.execute("""
                SELECT 1 FROM tag_details_costs 
                WHERE account_id = %s AND date_register = %s;
            """, (account_id, month_end))
            if cursor.fetchone() and month_end != fim_mes:
                print(f"Dados já registrados para {month_start.strftime('%Y-%m-%d')} a {month_end.strftime('%Y-%m-%d')}, pulando...")
                continue
            else:
                print(f"\nRegistrando Tags e Serviços do período {month_start.strftime('%Y-%m-%d')} a {month_end.strftime('%Y-%m-%d')}")

            for group in month_data['Groups']:
                tag_name = group['Keys'][0]
                service_name = group['Keys'][1]
                tag_name = tag_name.replace("Name$", "")
                if tag_name == "": tag_name = "vazio"
                unblended_cost_amount = float(group['Metrics']['UnblendedCost']['Amount'])

                cursor.execute(f"""
                    INSERT INTO tag_details_costs (date_register, tag_name, service, account_id, unblended_cost)
                    VALUES ('{month_end}', '{tag_name}', '{service_name}', '{account_id}', '{unblended_cost_amount}')
                    ON CONFLICT (account_id, tag_name, service, date_register)
                    DO UPDATE SET unblended_cost = '{unblended_cost_amount}';
                """)
                print(f"Tag: {tag_name}, Service: {service_name} - Inserted cost {month_end}: {unblended_cost_amount}")
            conn.commit()

    except Exception as e:
        print(f"Erro ao acessar o banco de dados: {e}")
    finally:
        if conn:
            cursor.close()
            conn.close()

def write_cost_by_tags(db_config, session, account_id):
    print("\n**************** write_cost_by_tags")
    ce_client = session.client('ce')

    # Configura datas para cobrir o último ano
    end_date = datetime.now()
    end_date = end_date.replace(hour=0,minute=0,second=0,microsecond=0)
    start_date = end_date.replace(year=end_date.year - 1)
    end_date = end_date.strftime('%Y-%m-%d')
    start_date = start_date.strftime('%Y-%m-%d')


    fim_mes = datetime.now().replace(hour=0,minute=0,second=0,microsecond=0)
    fim_mes = fim_mes.replace(day=1,month=fim_mes.month+1) - timedelta(days=1)

    try:
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()

        cost_response = ce_client.get_cost_and_usage(
            TimePeriod={'Start': start_date, 'End': end_date},
            Granularity='MONTHLY',
            Metrics=['UnblendedCost'],
            GroupBy=[{'Type': 'TAG','Key': 'Name'}]
        )
        # Processar e armazenar dados
        for month_data in cost_response['ResultsByTime']:
            month_start = datetime.strptime(month_data['TimePeriod']['Start'], '%Y-%m-%d')
            # month_end = datetime.strptime(month_data['TimePeriod']['End'], '%Y-%m-%d')
            month_end = month_start + timedelta(days=32)
            month_end = month_end.replace(day=1) - timedelta(days=1)

            # Verificar se já existem dados para o mês
            cursor.execute("""
                SELECT 1 FROM tag_costs 
                WHERE account_id = %s AND date_register = %s;
            """, (account_id, month_end))
            if cursor.fetchone() and month_end != fim_mes:
                print(f"Dados já registrados para {month_start.strftime('%Y-%m-%d')} a {month_end.strftime('%Y-%m-%d')}, pulando...")
                continue
            else:
                print(f"\nRegistrando Tags do período {month_start.strftime('%Y-%m-%d')} a {month_end.strftime('%Y-%m-%d')}")


            for group in month_data['Groups']:
                tag_name = group['Keys'][0]
                tag_name = tag_name.replace("Name$","")
                if tag_name == "": tag_name="vazio"
                unblended_cost_amount = group['Metrics']['UnblendedCost']['Amount']

                cursor.execute(f"""
                    INSERT INTO tag_costs (date_register, tag_name, account_id, unblended_cost)
                    VALUES ('{month_end}', '{tag_name}', '{account_id}', '{unblended_cost_amount}')
                    ON CONFLICT (account_id, tag_name, date_register)
                    DO UPDATE SET unblended_cost = '{unblended_cost_amount}';
                """)
                print(f"Tag: {tag_name} Inserted cost {month_end}: {unblended_cost_amount}")
            conn.commit()

    except Exception as e:
        print(f"Erro ao acessar o banco de dados: {e}")
    finally:
        if conn:
            cursor.close()
            conn.close()

def write_cost_by_services(db_config, session, account_id):
    print("**************** write_cost_by_services")
    ce_client = session.client('ce')

    # Configura datas para cobrir o último ano
    end_date = datetime.now()
    end_date = end_date.replace(hour=0,minute=0,second=0,microsecond=0)
    start_date = end_date.replace(year=end_date.year - 1)
    end_date = end_date.strftime('%Y-%m-%d')
    start_date = start_date.strftime('%Y-%m-%d')


    fim_mes = datetime.now().replace(hour=0,minute=0,second=0,microsecond=0)
    fim_mes = fim_mes.replace(day=1,month=fim_mes.month+1) - timedelta(days=1)

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
            # month_end = datetime.strptime(month_data['TimePeriod']['End'], '%Y-%m-%d')
            month_end = month_start + timedelta(days=32)
            month_end = month_end.replace(day=1) - timedelta(days=1)


            # Verificar se já existem dados para o mês
            cursor.execute("""
                SELECT 1 FROM resource_costs 
                WHERE account_id = %s AND date_register = %s;
            """, (account_id, month_end))
            if cursor.fetchone() and month_end != fim_mes:
                print(f"Dados já registrados para {month_start.strftime('%Y-%m-%d')} a {month_end.strftime('%Y-%m-%d')}, pulando...")
                continue
            else:
                print(f"\nRegistrando Serviços do período {month_start.strftime('%Y-%m-%d')} a {month_end.strftime('%Y-%m-%d')}")


            for group in month_data['Groups']:
                service_name = group['Keys'][0]
                unblended_cost_amount = group['Metrics']['UnblendedCost']['Amount']

                cursor.execute(f"""
                    INSERT INTO resource_costs (date_register, service, account_id, unblended_cost)
                    VALUES ('{month_end}', '{service_name}', '{account_id}', '{unblended_cost_amount}')
                    ON CONFLICT (account_id, service, date_register)
                    DO UPDATE SET unblended_cost = '{unblended_cost_amount}';
                    """)
                print(f"Serviço: {service_name} Inserted cost {month_end}: {unblended_cost_amount}")
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
    now = now.replace(hour=0, minute=0, second=0, microsecond=0)

    # Conectando ao banco de dados
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()

    try:
        # Loop para os últimos 12 meses + mês corrente
        for i in range(13):
            month_start = (now.replace(day=1) - timedelta(days=i*30)).replace(day=1)
            month_end = now
            # print(f"inicio: {month_start}")
            month_end = month_start + timedelta(days=32)
            month_end = month_end.replace(day=1) - timedelta(days=1)
            # print(f"fim:    {month_end}")

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

            cursor.execute("""
                SELECT unblended_cost FROM account_costs
                WHERE account_id = %s AND date_register = %s;
            """, (account_id, month_end))
            result = cursor.fetchone()

            if result is None:
                # Inserir novo registro
                cursor.execute("""
                    INSERT INTO account_costs (account_id, unblended_cost, date_register)
                    VALUES (%s, %s, %s);
                    """, (account_id, account_cost, month_end))
                print(f"Account ID: {account_id} Inserted cost {month_end}: {account_cost}")
            else:
                if i == 0:
                    cursor.execute(f"""
                        INSERT INTO account_costs (account_id, unblended_cost, date_register)
                        VALUES ('{account_id}', '{account_cost}', '{month_end}') 
                        ON CONFLICT (account_id, date_register)
                        DO UPDATE SET unblended_cost = '{account_cost}';
                        """)                   
                print(f"Cost for {month_end} already in database: {result[0]}")
        
        conn.commit()

    except (Exception, psycopg2.Error) as error:
        print(f"Erro de banco de dados: {error}")
    finally:
        # Fechando a conexão
        if conn:
            cursor.close()
            conn.close()

def update_account(db_config,account_id,account):
    end_date = datetime.now()
    end_date = end_date.replace(hour=0,minute=0,second=0,microsecond=0)
    account_name = get_account_name(account_id)

    permitted_regions = ['us-east-1','sa-east-1' ]
    for permitted_region in permitted_regions:
        ec2 = session.client("ec2",region_name=permitted_region)
        response = ec2.describe_vpcs(Filters=[{'Name':'isDefault','Values': ['false']}])
        if response['Vpcs']:
            region=permitted_region
    try:
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()
        insert_query = f"""
            INSERT INTO accounts (account_id, account_profile, account_region, account_name, date_register)
            VALUES ('{account_id}', '{account}', '{region}', '{account_name}', '{end_date}')
            ON CONFLICT (account_id, account_profile, account_region) DO UPDATE SET date_register = '{end_date}';
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

def get_last_update(db_config,account_id):
    resultado=""
    try:
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()
        query = f"""
            SELECT date_register FROM accounts WHERE account_id='{account_id}';
        """
        # Executando o comando
        cursor.execute(query)
        # conn.commit()
        resultado=cursor.fetchone()
    except (Exception, psycopg2.Error) as error:
        # Fechando a conexão com o banco de dados
        print(f"Erro de banco de dados: {error}")
    finally:
        # Fechando a conexão
        if conn:
            cursor.close()
            conn.close()

        if resultado == "":
            return datetime.strptime("01/01/01")
        else:
            return resultado
        

def get_account_name(account_id):
    file_path = "C:/Users/c96531a/.saml2aws"
    pattern = r"Account: ([\w-]+) \((\d+)\)"  # Define o padrão para capturar o nome e número da conta
    try:
        with open(file_path, 'r') as file:
            for line in file:
                match = re.search(pattern, line)
                if match:
                    account_name = match.group(1)
                    account_number = match.group(2)
                    if (account_number == account_id): return account_name
    except FileNotFoundError:
        print("Arquivo não encontrado!")
    except Exception as e:
        print(f"Error reading the file: {e}")
        return None
    return None


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='List discovered resources in specified AWS regions for a specific AWS CLI profile.')
    parser.add_argument('profile', help='The name of the AWS CLI profile to use')
    args = parser.parse_args()
    account = args.profile      # nome do profile da conta

    # Obtém o número da conta da AWS
    session = boto3.Session(profile_name=account)

    sts_client = session.client('sts')
    account_id = sts_client.get_caller_identity()['Account']

    db_config = {
        'host': 'dev-hub-portal-qa.cbjrpisgumc2.sa-east-1.rds.amazonaws.com',
        'user': 'app-user',
        'password': '123Trocar$',
        'dbname': 'custos_nike'
    }
    # Atualizando os dados da conta na tabela accounts
    update_account(db_config,account_id,account)

    # Obtando data da última carga
    last_update = get_last_update(db_config,account_id,account)

    # Atualizando custos mensais da conta
    write_cost_by_account(db_config,session,account_id)

    # Atualizando custos mensais dos serviços na conta
    write_cost_by_services(db_config,session,account_id)

    # Atualizando custos mensais das tags names na conta
    write_cost_by_tags(db_config, session, account_id)

    # Atualizando custos mensais das tags names na conta
    write_cost_by_tags_details(db_config, session, account_id)


# adsnc9ymobl6oa