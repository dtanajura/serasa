import boto3

def tag_ec2_instances(region_name='sa-east-1'):
    # Cria um cliente EC2
    
    ec2 = boto3.client('ec2', region_name=region_name)
    
    # Lista todas as instâncias EC2
    response = ec2.describe_instances()
    instances = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instances.append(instance['InstanceId'])
    
    # Aplica a tag às instâncias EC2
    if instances:
        ec2.create_tags(
            Resources=instances,
            Tags=[
                {
                    'Key': 'instance scheduler',
                    'Value': 'sim'
                },
            ]
        )
    print(f"Tagged {len(instances)} EC2 instances in {region_name}.")

def tag_rds_instances(region_name='sa-east-1'):
    # Cria um cliente RDS
    rds = boto3.client('rds', region_name=region_name)
    
    # Lista todos os bancos de dados RDS
    response = rds.describe_db_instances()
    dbs = [db['DBInstanceIdentifier'] for db in response['DBInstances']]
    
    # Aplica a tag aos bancos de dados RDS
    for db in dbs:
        rds.add_tags_to_resource(
            ResourceName=f"arn:aws:rds:{region_name}:<account-id>:db:{db}",
            Tags=[
                {
                    'Key': 'instance scheduler',
                    'Value': 'sim'
                },
            ]
        )
    print(f"Tagged {len(dbs)} RDS instances in {region_name}.")

def tag_all_resources(region_name='sa-east-1'):
    tag_ec2_instances(region_name)
    tag_rds_instances(region_name)

# Chame esta função para aplicar as tags
tag_all_resources('sa-east-1')
