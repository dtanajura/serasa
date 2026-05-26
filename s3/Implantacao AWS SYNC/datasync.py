import boto3
import argparse
import time

def monitor_datasync_task(profile, task_execution_arn):
    session = boto3.Session(profile_name=profile)
    datasync_client = session.client('datasync')

    while True:
        response = datasync_client.describe_task_execution(TaskExecutionArn=task_execution_arn)
        status = response['Status']
        print(f"Status da execução da tarefa: {status}")

        if status in ['SUCCESS', 'ERROR']:
            break
        
        time.sleep(15)  # Aguarde 15 segundos antes de verificar novamente

    return status

def get_existing_location_arn(profile, bucket_name, subdirectory):
    session = boto3.Session(profile_name=profile)
    datasync_client = session.client('datasync')

    locations = datasync_client.list_locations()
    for location in locations['Locations']:
        if location['LocationUri'] == f's3://{bucket_name}{subdirectory}':
            print(f"Location encontrada: {profile} - {bucket_name}{subdirectory}")
            return location['LocationArn']
    return None

def create_datasync_location(profile, bucket_name, role_arn, subdirectory='/'):
    existing_location_arn = get_existing_location_arn(profile, bucket_name, subdirectory)
    if existing_location_arn:
        return existing_location_arn

    session = boto3.Session(profile_name=profile)
    datasync_client = session.client('datasync')

    response = datasync_client.create_location_s3(
        S3Config={
            'BucketAccessRoleArn': role_arn
        },
        Subdirectory=subdirectory,
        S3BucketArn=f'arn:aws:s3:::{bucket_name}'
    )
    print(f"Location criada: {profile} - {bucket_name}{subdirectory}")
    return response['LocationArn']

def get_existing_task_arn(profile, source_location_arn, destination_location_arn):
    session = boto3.Session(profile_name=profile)
    datasync_client = session.client('datasync')

    tasks = datasync_client.list_tasks()
    for task in tasks['Tasks']:
        task_details = datasync_client.describe_task(TaskArn=task['TaskArn'])
        if (task_details['SourceLocationArn'] == source_location_arn and
                task_details['DestinationLocationArn'] == destination_location_arn):
            print(f"Task encontrada: {profile} - {source_location_arn} - {destination_location_arn}")
            return task['TaskArn']
    return None

def create_log_group(profile, log_group_name):
    session = boto3.Session(profile_name=profile)
    logs_client = session.client('logs')

    # Verificar se o log group já existe
    existing_log_groups = logs_client.describe_log_groups(logGroupNamePrefix=log_group_name)
    for log_group in existing_log_groups['logGroups']:
        if log_group['logGroupName'] == log_group_name:
            print(f"Log group já existe: {log_group_name}")
            return log_group['arn']

    # Criar o log group se não existir
    response = logs_client.create_log_group(
        logGroupName=log_group_name
    )
    print(f"Log group criado: {log_group_name}")
    return f"arn:aws:logs:{session.region_name}:{session.client('sts').get_caller_identity()['Account']}:log-group:{log_group_name}"

def create_datasync_task(profile, source_location_arn, destination_location_arn, log_group_arn):
    existing_task_arn = get_existing_task_arn(profile, source_location_arn, destination_location_arn)
    if existing_task_arn:
        return existing_task_arn

    session = boto3.Session(profile_name=profile)
    datasync_client = session.client('datasync')

    response = datasync_client.create_task(
        SourceLocationArn=source_location_arn,
        DestinationLocationArn=destination_location_arn,
        Name='DataSyncTask',
        CloudWatchLogGroupArn=log_group_arn,
        Options={
            'LogLevel': 'TRANSFER'  # Pode ser OFF, BASIC ou TRANSFER
        }
    )
    print(f"Task criada: {profile} - {source_location_arn} - {destination_location_arn}")
    return response['TaskArn']

# def create_datasync_task(profile, source_location_arn, destination_location_arn): 
# #, log_group_arn):
#     existing_task_arn = get_existing_task_arn(profile, source_location_arn, destination_location_arn)
#     if existing_task_arn:
#         return existing_task_arn

#     session = boto3.Session(profile_name=profile)
#     datasync_client = session.client('datasync')

#     response = datasync_client.create_task(
#         SourceLocationArn=source_location_arn,
#         DestinationLocationArn=destination_location_arn,
#         Name='DataSyncTask',
#         # CloudWatchLogGroupArn=log_group_arn,
#         # Options={
#         #     'LogLevel': 'TRANSFER'  # Define o nível de log para registrar todos os objetos e arquivos transferidos
#         # }
#     )
#     print(f"Task criada: {profile} - {source_location_arn} - {destination_location_arn}")
#     return response['TaskArn']

def start_datasync_task(profile, task_arn):
    session = boto3.Session(profile_name=profile)
    datasync_client = session.client('datasync')

    response = datasync_client.start_task_execution(
        TaskArn=task_arn
    )
    print(f"Task iniciada: {profile} - {task_arn}")

    return response['TaskExecutionArn']

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Setup DataSync locations and task.')
    parser.add_argument('--source-profile', required=True, help='Source AWS profile')
    parser.add_argument('--source-bucket', required=True, help='Source S3 bucket name')
    parser.add_argument('--destination-bucket', required=True, help='Destination S3 bucket name')
    parser.add_argument('--source-role-arn', required=True, help='Source role ARN')
    parser.add_argument('--subdirectory', default='/', help='Subdirectory path in the bucket')

    args = parser.parse_args()

    # Verificação dos argumentos
    if not all([args.source_profile, args.source_bucket, args.destination_bucket, args.source_role_arn]):
        print("Os argumentos não estão corretos. Use o script da seguinte forma:")
        print("python datasync_setup.py --source-profile source-profile --source-bucket source-bucket --destination-bucket destination-bucket --source-role-arn arn:aws:iam::source-account-id:role/source-role --subdirectory path/to/files/")
    else:
        source_location_arn = create_datasync_location(args.source_profile, args.source_bucket, args.source_role_arn, args.subdirectory)
        destination_location_arn = create_datasync_location(args.source_profile, args.destination_bucket, args.source_role_arn, args.subdirectory)

        log_group_name = f"DataSyncTaskLogGroup-{source_location_arn.split('/')[-1]}-{destination_location_arn.split('/')[-1]}"
        log_group_arn = create_log_group(args.source_profile, log_group_name)

        task_arn = create_datasync_task(args.source_profile, source_location_arn, destination_location_arn , log_group_arn)

        task_execution_arn = start_datasync_task(args.source_profile, task_arn)

        final_status = monitor_datasync_task(args.source_profile, task_execution_arn)
        print(f"Status final da execução da tarefa: {final_status}")

# python3 datasync.py --source-profile nikedatauat --source-bucket experian-reports-extraction-files-uat --source-role-arn arn:aws:iam::713881783816:role/BURoleForDataSyncService --subdirectory /BASHDP_VCGCATUA/extraction/transfer/ --destination-bucket serasaexperian-coe-data-platform-dev-landing
