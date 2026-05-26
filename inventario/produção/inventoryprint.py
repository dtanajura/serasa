
import boto3
import argparse
import psycopg2

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

    # Consulta para obter os tipos de recursos da tabela "resources_type"
#    query = "SELECT * FROM resources"
    query = "SELECT COUNT(*) FROM resources"
    cursor.execute(query)

    # Recupere o resultado da consulta
    resultado = cursor.fetchall()

    # Exiba o resultado
    print(f"Total de registros na tabela 'resources': {resultado[0][0]}")
    # Iterando sobre os resultados e exibindo cada linha
    # for row in cursor.fetchall():
    #     account_id, region, service, resource_type, resource_id = row
    #     print(f"Account ID: {account_id}, Region: {region}, Service: {service}, Resource Type: {resource_type}, Resource ID: {resource_id}")

# Fechando a conexão com o banco de dados
except (Exception, psycopg2.Error) as error:
    print(f"Erro de banco de dados: {error}")

finally:
    # Fechando a conexão
    if conn:
        cursor.close()
        conn.close()

