import boto3
import psycopg2
import os
import time
from datetime import datetime

def main():
    # Definir variáveis de ambiente diretamente na função
    os.environ['DB_HOST'] = 'observabilidade-0.cwhrk1jkkma0.sa-east-1.rds.amazonaws.com'
    os.environ['DB_USER'] = 'app-user'
    os.environ['DB_PASSWORD'] = '123Trocar$'
    os.environ['DB_NAME'] = 'custos_nike'

    # Criação da sessão com boto3 utilizando o profile 'dsstage'
    session = boto3.Session(profile_name='dsstage')
    ec2_client = session.client('ec2', region_name='sa-east-1')
    ssm_client = session.client('ssm', region_name='sa-east-1')
    sts_client = session.client('sts')

    # Obter o número da conta
    account_id = sts_client.get_caller_identity()['Account']
    print(f"account_id: {account_id}")

import boto3
import psycopg2
import os
import time
from datetime import datetime

def main():
    # Definir variáveis de ambiente diretamente na função
    os.environ['DB_HOST'] = 'observabilidade-0.cwhrk1jkkma0.sa-east-1.rds.amazonaws.com'
    os.environ['DB_USER'] = 'app-user'
    os.environ['DB_PASSWORD'] = '123Trocar$'
    os.environ['DB_NAME'] = 'custos_nike'

    # Criação da sessão com boto3 utilizando o profile 'dsstage'
    session = boto3.Session(profile_name='dsstage')
    ec2_client = session.client('ec2', region_name='sa-east-1')
    ssm_client = session.client('ssm', region_name='sa-east-1')
    sts_client = session.client('sts')

    # Obter o número da conta
    account_id = sts_client.get_caller_identity()['Account']
    print(f"account_id: {account_id}")

    # Listar instâncias ativas
    response = ec2_client.describe_instances(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
    )
    
    instance_ids = [instance['InstanceId'] for reservation in response['Reservations'] for instance in reservation['Instances']]
    
    for instance_id in instance_ids:
        response = ssm_client.send_command(
            DocumentName='ColetarMetricas',
            Targets=[{'Key': 'instanceIds', 'Values': [instance_id]}],
            TimeoutSeconds=600,
            MaxConcurrency='50',
            MaxErrors='0'
        )
        command_id = response['Command']['CommandId']

        # Aguarde a conclusão do comando com configurações ajustadas
        waiter = ssm_client.get_waiter('command_executed')
        waiter.wait(
            CommandId=command_id,
            InstanceId=instance_id,
            WaiterConfig={
                'Delay': 10,  # Intervalo de 10 segundos entre as tentativas
                'MaxAttempts': 20  # Máximo de 20 tentativas
            }
        )        
        # waiter.wait(
        #     CommandId=command_id,
        #     InstanceId=instance_id,
        #     WaiterConfig={
        #         'Delay': 30,  # Intervalo de 30 segundos entre as tentativas
        #         'MaxAttempts': 40  # Máximo de 40 tentativas
        #     }
        # )

        # Obtenha os resultados
        response = ssm_client.list_command_invocations(
            CommandId=command_id,
            InstanceId=instance_id,
            Details=True
        )
        output = response['CommandInvocations'][0]['CommandPlugins'][0]['Output']
        linhas = output.split('\n')

        # Verifique se a lista 'linhas' tem os índices esperados
        if len(linhas) > 3:
            cpu_usage = linhas[1]
            mem_usage = linhas[3].split('Uso de Disco:')[0].strip()
            disk_usage = linhas[3].split('Uso de Disco:')[1].strip()
            print(f"InstanceId: {instance_id}, disk_usage: {disk_usage}")
            # disk_usage = float(disk_usage.replace('%', '')) / 100
            
        #     if not cpu_usage:
        #         cpu_usage = '0.0'
        #     if not mem_usage:
        #         mem_usage = '0.0'
        #     if not disk_usage:
        #         disk_usage = '0.0'
        # else:
        #     print(f"Erro ao processar a saída para a instância {instance_id}: {linhas}")
        #     continue

        # # Obter o horário da coleta
        # coleta_horario = datetime.now().isoformat()
        # print(f"coleta_horario: {coleta_horario}")

        # # Imprimir os resultados para cada instância
        # print(f"instance_id: {instance_id}, cpu_usage: {cpu_usage}, mem_usage: {mem_usage}, disk_usage: {disk_usage}, account_id: {account_id}, coleta_horario: {coleta_horario}")

        # # Armazene os resultados no banco de dados PostgreSQL
        # connection = psycopg2.connect(
        #     host=os.environ['DB_HOST'],
        #     user=os.environ['DB_USER'],
        #     password=os.environ['DB_PASSWORD'],
        #     dbname=os.environ['DB_NAME']
        # )
        # cursor = connection.cursor()
        # sql = """
        # INSERT INTO metricas (instance_id, cpu_usage, mem_usage, disk_usage, account_id, coleta_horario)
        # VALUES (%s, %s, %s, %s, %s, %s)
        # """
        # print(f"SQL: {sql}")
        # print(f"Values: {instance_id}, {cpu_usage}, {mem_usage}, {disk_usage}, {account_id}, {coleta_horario}")
        # cursor.execute(sql, (instance_id, cpu_usage, mem_usage, disk_usage, account_id, coleta_horario))
        # connection.commit()
        # cursor.close()
        # connection.close()

if __name__ == "__main__":
    # Medir o tempo de execução
    start_time = time.time()
    main()
    # Calcular o tempo total de execução
    end_time = time.time()
    total_time = end_time - start_time
    print(f'Tempo total de execução: {total_time:.2f} segundos')
    print('Métricas coletadas e armazenadas com sucesso!')


if __name__ == "__main__":
    # Medir o tempo de execução
    start_time = time.time()
    main()
    # Calcular o tempo total de execução
    end_time = time.time()
    total_time = end_time - start_time
    print(f'Tempo total de execução: {total_time:.2f} segundos')
    print('Métricas coletadas e armazenadas com sucesso!')
