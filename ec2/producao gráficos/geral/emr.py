import boto3
from datetime import datetime, timedelta
import psycopg2
import traceback
import time
import botocore.exceptions

def obter_detalhes_cluster_emr(dia_anterior, emr):
    # Obter clusters criados no dia anterior
    print("Lendo dados dos clusters...")
    response = emr.list_clusters(
        ClusterStates=['STARTING', 'BOOTSTRAPPING', 'RUNNING', 'WAITING', 'TERMINATING', 'TERMINATED'],
        CreatedAfter=dia_anterior.replace(hour=0, minute=0, second=0),
        CreatedBefore=dia_anterior.replace(hour=23, minute=59, second=59)
    )

    detalhes_clusters = []

    for cluster in response['Clusters']:
        cluster_id = cluster['Id']
        cluster_nome = cluster['Name']
        cluster_criacao = cluster['Status']['Timeline']['CreationDateTime']
        cluster_termino = cluster['Status']['Timeline'].get('EndDateTime')

        instancias = []

        # Obter IDs e tipos das instâncias com retry e backoff exponencial
        max_retries = 4
        retry_count = 0
        while retry_count < max_retries:
            try:
                instances_response = emr.list_instances(ClusterId=cluster_id)
                for instance in instances_response['Instances']:
                    instance_id = instance['Ec2InstanceId']
                    instance_type = instance['InstanceType']
                    instancias.append({
                        'id_instancia': instance_id,
                        'tipo_instancia': instance_type
                    })
                break  # Sair do loop se a chamada for bem-sucedida
            except botocore.exceptions.ClientError as error:
                if error.response['Error']['Code'] == 'ThrottlingException':
                    retry_count += 1
                    wait_time = 2 ** retry_count  # Exponential backoff
                    time.sleep(wait_time)
                else:
                    raise error

        detalhes_clusters.append({
            'id_cluster': cluster_id,
            'nome_cluster': cluster_nome,
            'criacao_cluster': cluster_criacao,
            'termino_cluster': cluster_termino,
            'instancias': instancias
        })

    return detalhes_clusters

def salvar_detalhes_no_banco(detalhes, cursor, data_coleta, account_id):
    # Excluir todos os dados coletados para essa account_id e data_coleta na tabela emr_instancias
    cursor.execute("""
        DELETE FROM emr_instancias
        WHERE cluster_id IN (
            SELECT cluster_id
            FROM emr
            WHERE account_id = %s AND date_register = %s
        )
    """, (account_id, data_coleta.date()))

    # Excluir todos os dados coletados para essa account_id e data_coleta na tabela emr
    cursor.execute("""
        DELETE FROM emr
        WHERE account_id = %s AND date_register = %s
    """, (account_id, data_coleta.date()))

    conn.commit()  # Commit para garantir que as exclusões sejam aplicadas

    # Inserir os novos dados
    for cluster in detalhes:
        cursor.execute("""
            INSERT INTO emr (cluster_id, cluster_name, cluster_start, cluster_end, date_register, account_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (cluster['id_cluster'], cluster['nome_cluster'], cluster['criacao_cluster'], cluster['termino_cluster'], data_coleta.date(), account_id))

        print(f"Insert EMR Cluster ID: {cluster['id_cluster']} Cluster Name {cluster['nome_cluster']}")

        for instancia in cluster['instancias']:
            cursor.execute("""
                INSERT INTO emr_instancias (instance_id, cluster_id, instance_type)
                VALUES (%s, %s, %s)
                ON CONFLICT (instance_id) DO NOTHING
            """, (instancia['id_instancia'], cluster['id_cluster'], instancia['tipo_instancia']))

            print(f"Insert EMR Instances Cluster ID: {cluster['id_cluster']} Instance ID: {instancia['id_instancia']} e Instance type: {instancia['tipo_instancia']}")


if __name__ == '__main__':
    dia_anterior = datetime.now() - timedelta(days=12)
    # dia_anterior = datetime.now()
    try:
        conn = psycopg2.connect(
            host='observabilidade-0.cwhrk1jkkma0.sa-east-1.rds.amazonaws.com',
            user='app-user',
            password='123Trocar$',
            dbname='custos_nike'
        )
        cursor = conn.cursor()
        print("Conexão bem-sucedida!")

    # try:
    #     conn = psycopg2.connect(
    #         host='{{pgs_host}}',
    #         user='{{pgs_login}}',
    #         password='{{pgs_pw}}',
    #         dbname='custos_nike'
    #     )
    #     print("Conexão bem-sucedida!")


    except Exception as e:
        print(f"Erro ao conectar ao banco de dados: {str(e)}")
        traceback.print_exc()  

    account = "dsstage"
    session = boto3.Session(profile_name=account)
    account_id = session.client('sts').get_caller_identity().get('Account')

    emr = session.client('emr')
    cloudwatch_logs = session.client('logs')
    pricing = session.client('pricing', region_name='us-east-1')

    detalhes = obter_detalhes_cluster_emr(dia_anterior, emr)
    # print(f"detalhes: {detalhes}")

    salvar_detalhes_no_banco(detalhes, cursor, dia_anterior, account_id)
    

    conn.commit()
    cursor.close()
    conn.close()
