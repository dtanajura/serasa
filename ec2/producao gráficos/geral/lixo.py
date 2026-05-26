import pandas as pd
import psycopg2
from psycopg2 import sql

try:
    # Leia o arquivo Excel
    file_path = 'Pasta1.xlsx'
    df = pd.read_excel(file_path, engine='openpyxl')

    # Renomeie as colunas para corresponder aos nomes esperados no banco de dados
    df.columns = ['instance_type', 'hourly_rate', 'vCPU', 'memory', 'storage', 'network']

    # Dados de conexão com o banco de dados
    conn = psycopg2.connect(
        host='observabilidade-0.cwhrk1jkkma0.sa-east-1.rds.amazonaws.com',
        user='app-user',
        password='123Trocar$',
        dbname='custos_nike'
    )
    cursor = conn.cursor()

    # Crie a tabela no banco de dados
    create_table_query = """
    CREATE TABLE IF NOT EXISTS instances_type_caracteristics (
        instance_type VARCHAR(20),
        hourly_rate FLOAT,
        vCPU INTEGER,
        memory VARCHAR(30),
        storage VARCHAR(30),
        network VARCHAR(30)
    )
    """
    cursor.execute(create_table_query)
    conn.commit()

    # Insira os dados na tabela
    insert_query = """
    INSERT INTO instances_type_caracteristics (instance_type, hourly_rate, vCPU, memory, storage, network)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    for index, row in df.iterrows():
        cursor.execute(insert_query, (
            row['instance_type'],
            row['hourly_rate'],
            row['vCPU'],
            row['memory'],
            row['storage'],
            row['network']
        ))

    conn.commit()
    cursor.close()
    conn.close()

    print("Os dados foram inseridos com sucesso na tabela instances_type_caracteristics.")

except PermissionError as e:
    print(f"Erro de permissão: {e}")
except KeyError as e:
    print(f"Erro de chave: {e}. Verifique se os nomes das colunas no arquivo Excel estão corretos.")
except Exception as e:
    print(f"Ocorreu um erro: {e}")