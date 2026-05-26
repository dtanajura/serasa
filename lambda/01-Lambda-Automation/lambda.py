import json
import boto3

def lambda_handler(event, context):
    tag_all_resources()
    return {
        'statusCode': 200,
        'body': json.dumps('Função Lambda concluida')
    }

def tag_all_resources():
    session = boto3.session.Session()
    sts = session.client('sts')
    identity = sts.get_caller_identity()
    account_id = identity['Account']
    tag_ec2_instances(session,account_id)
    tag_rds_instances(session,account_id)
    print(account_id)
    

def tag_ec2_instances(session, account_id):
    ec2 = session.client('ec2')
    response = ec2.describe_instances()
    instances = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            # Filtra instâncias pelo nome iniciado com "node_group"
            if 'Tags' in instance:
                # Verifica se a instância tem uma tag de Name que começa com "node_group"
                if not any(tag['Key'] == 'Name' and tag['Value'].startswith('node_group') for tag in instance['Tags']):
                    instances.append(instance['InstanceId'])
            else:
                # Inclui instâncias sem tag Name
                instances.append(instance['InstanceId'])
    if instances:
        ec2.create_tags(
            Resources=instances,
            Tags=[
                {
                    'Key': 'Instance-Scheduler',
                    'Value': 'br-saopaulo-office-hours'
                },
            ]
        )
    print(f"Tagged {len(instances)} EC2 instances.")


def tag_rds_instances(session,account_id):
    rds = session.client('rds')
    response = rds.describe_db_instances()
    dbs = [db['DBInstanceIdentifier'] for db in response['DBInstances']]
    for db in dbs:
        rds.add_tags_to_resource(
            ResourceName=f"arn:aws:rds:{session.region_name}:{account_id}:db:{db}",
            Tags=[
                {
                    'Key': 'Instance-Scheduler',
                    'Value': 'br-saopaulo-office-hours'
                },
            ]
        )
    print(f"Tagged {len(dbs)} RDS instances.")
