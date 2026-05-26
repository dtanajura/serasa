import boto3
import psycopg2
import os

def main():
    # Definir variáveis de ambiente diretamente na função
    os.environ['DB_HOST'] = 'observabilidade-0.cwhrk1jkkma0.sa-east-1.rds.amazonaws.com'
    os.environ['DB_USER'] = 'app-user'
    os.environ['DB_PASSWORD'] = '123Trocar$'
    os.environ['DB_NAME'] = 'custos_nike'

    # Criação da sessão com boto3 utilizando o profile 'dsstage'
    session = boto3.Session(profile_name='dsstage')
    ec2_client = session.client('ec2', region_name='sa-east-1')
    ssm = session.client('ssm', region_name='sa-east-1')
    
    # Listar instâncias ativas
    response = ec2_client.describe_instances(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
    )
    
    instance_ids = [instance['InstanceId'] for reservation in response['Reservations'] for instance in reservation['Instances']]
    
    for instance_id in instance_ids:
        response = ssm.send_command(
            DocumentName='ColetarMetricas',
            Targets=[{'Key': 'instanceIds', 'Values': [instance_id]}],
            TimeoutSeconds=600,
            MaxConcurrency='50',
            MaxErrors='0'
        )
        command_id = response['Command']['CommandId']

        # Aguarde a conclusão do comando
        waiter = ssm.get_waiter('command_executed')
        waiter.wait(CommandId=command_id, InstanceId=instance_id)

        # Obtenha os resultados
        response = ssm.list_command_invocations(
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
            
            if not cpu_usage:
                cpu_usage = '0.0'
            if not mem_usage:
                mem_usage = '0.0'
            if not disk_usage:
                disk_usage = '0.0'
        else:
            print(f"Erro ao processar a saída para a instância {instance_id}: {linhas}")
            continue

        # Armazene os resultados no banco de dados PostgreSQL
        connection = psycopg2.connect(
            host=os.environ['DB_HOST'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD'],
            dbname=os.environ['DB_NAME']
        )
        cursor = connection.cursor()
        print(f"instance_id: {instance_id}, cpu_usage: {cpu_usage}, mem_usage: {mem_usage} , disk_usage: {disk_usage}")
        sql = "INSERT INTO metricas (instance_id, cpu_usage, mem_usage, disk_usage) VALUES (%s, %s, %s, %s)"
        cursor.execute(sql, (instance_id, cpu_usage, mem_usage, disk_usage))
        connection.commit()
        cursor.close()
        connection.close()

    print('Métricas coletadas e armazenadas com sucesso!')

if __name__ == "__main__":
    main()