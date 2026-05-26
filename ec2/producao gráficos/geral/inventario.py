import boto3
import psycopg2
import traceback
import argparse
import sys
from datetime import datetime, timedelta, time, timezone

# profiles = [
#    "corporateprod","arcsandbox","ssrmdev","ssrmsandbox","ssrmprod","corporatedev","sredev","dsstage",
#    "dsprod","dsdev","datahubprod","datahubdev","bnsprod","bnsuat","dodev","douat","positivoprod",
#    "datainsightprod","nikedatadev","nikedataprod","nikedatauat"
# ]

def get_account_name(cursor, account_id):
    cursor.execute("SELECT account_name FROM accounts WHERE account_id = %s", (account_id,))
    result = cursor.fetchone()
    return result[0] if result else None

def getCpuUtilization(cloudwatch, instance_id):
    end_time = datetime.now(timezone.utc)
    start_time = end_time - timedelta(days=7)
    
    metrics = cloudwatch.get_metric_statistics(
        Namespace='AWS/EC2',
        MetricName='CPUUtilization',
        Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
        StartTime=start_time,
        EndTime=end_time,
        Period=3600,
        Statistics=['Average']
    )
    
    datapoints = metrics['Datapoints']
    
    # Filtrar os dados para considerar apenas dias úteis e horário comercial (9h - 17h)
    filtered_datapoints = [
        dp for dp in datapoints 
        if dp['Timestamp'].weekday() < 5 and time(9, 0) <= dp['Timestamp'].time() <= time(17, 0)
    ]
    
    if filtered_datapoints:
        avg_cpu = sum(dp['Average'] for dp in filtered_datapoints) / len(filtered_datapoints)
        return avg_cpu
    else:
        return None

def coletarInformacoesEks(cursor, profile, eks, autoscaling):
    try:
        accountId = getAccountId(cursor, profile)
        if not accountId:
            print(f"Account ID not found for profile: {profile}")
            return
        
        clusters = eks.list_clusters()['clusters']
        if not clusters:
            print(f"No EKS clusters found for profile: {profile}")
            return

        for clusterName in clusters:
            clusterInfo = eks.describe_cluster(name=clusterName)['cluster']
            clusterId = clusterInfo['name']
            kubernetesVersion = clusterInfo['version']
            
            print(f"Inserting into eks_clusters: account_id={accountId}, cluster_id={clusterId}, cluster_name={clusterName}, kubernetes_version={kubernetesVersion}")
            cursor.execute("""
                INSERT INTO eks_clusters (account_id, cluster_id, cluster_name, kubernetes_version)
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (cluster_name) DO NOTHING
            """, (accountId, clusterId, clusterName, kubernetesVersion))

            nodegroups = eks.list_nodegroups(clusterName=clusterName)['nodegroups']
            if not nodegroups:
                continue

            for nodegroupName in nodegroups:
                nodegroupInfo = eks.describe_nodegroup(clusterName=clusterName, nodegroupName=nodegroupName)['nodegroup']
                nodegroupId = nodegroupInfo['nodegroupName']
                autoscalingGroupName = nodegroupInfo['resources']['autoScalingGroups'][0]['name']
                launchTemplateId = nodegroupInfo['launchTemplate']['id']
                launchTemplateVersion = nodegroupInfo['launchTemplate']['version']
                
                print(f"Inserting into eks_nodegroups: cluster_id={clusterId}, nodegroup_id={nodegroupId}, autoscaling_group_name={autoscalingGroupName}, launch_template_id={launchTemplateId}, launch_template_version={launchTemplateVersion}")
                cursor.execute("""
                    INSERT INTO eks_nodegroups (cluster_id, nodegroup_id, autoscaling_group_name, launch_template_id, launch_template_version)
                    VALUES (%s, %s, %s, %s, %s)
                    ON CONFLICT (nodegroup_id) DO NOTHING
                """, (clusterId, nodegroupId, autoscalingGroupName, launchTemplateId, launchTemplateVersion))

                response = autoscaling.describe_auto_scaling_groups(AutoScalingGroupNames=[autoscalingGroupName])
                instances = response['AutoScalingGroups'][0]['Instances']
                
                for instance in instances:
                    instanceId = instance['InstanceId']
                    print(f"Inserting into eks_nodes: cluster_id={clusterId}, nodegroup_id={nodegroupId}, instance_id={instanceId}")
                    cursor.execute("""
                        INSERT INTO eks_nodes (cluster_id, nodegroup_id, instance_id)
                        VALUES (%s, %s, %s)
                        ON CONFLICT (nodegroup_id) DO NOTHING
                    """, (clusterId, nodegroupId, instanceId))
    except Exception as e:
        print(f"Error: {str(e)}")
        traceback.print_exc()

def getAccountId(cursor, profileName):
    cursor.execute("SELECT account_id FROM accounts WHERE account_profile = %s", (profileName,))
    result = cursor.fetchone()
    return result[0] if result else None

def upsertVpc(cursor, accountId, vpcId, vpcName, cidrBlock):
    print(f"Inserting into vpcs: account_id={accountId}, vpc_id={vpcId}, vpc_name={vpcName}, cidr_block={cidrBlock}")
    cursor.execute("""
        INSERT INTO vpcs (account_id, vpc_id, vpc_name, cidr_block)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT (vpc_id) DO UPDATE SET
            account_id = EXCLUDED.account_id,
            vpc_name = EXCLUDED.vpc_name,
            cidr_block = EXCLUDED.cidr_block
        RETURNING id;
    """, (accountId, vpcId, vpcName, cidrBlock))
    return cursor.fetchone()

def upsertSubnet(cursor, vpcId, subnetId, subnetName, cidrBlock, networkTag, availabilityZone, usedIpCount, totalIpCount):
    print(f"Inserting into subnets: vpc_id={vpcId}, subnet_id={subnetId}, subnet_name={subnetName}, cidr_block={cidrBlock}, network_tag={networkTag}, availability_zone={availabilityZone}, used_ip_count={usedIpCount}, total_ip_count={totalIpCount}")
    cursor.execute("""
        INSERT INTO subnets (vpc_id, subnet_id, subnet_name, cidr_block, network_tag, availability_zone, used_ip_count, total_ip_count)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (subnet_id) DO UPDATE SET
            vpc_id = EXCLUDED.vpc_id,
            subnet_name = EXCLUDED.subnet_name,
            cidr_block = EXCLUDED.cidr_block,
            network_tag = EXCLUDED.network_tag,
            availability_zone = EXCLUDED.availability_zone,
            used_ip_count = EXCLUDED.used_ip_count,
            total_ip_count = EXCLUDED.total_ip_count
        RETURNING id;
    """, (vpcId, subnetId, subnetName, cidrBlock, networkTag, availabilityZone, usedIpCount, totalIpCount))
    return cursor.fetchone()

def upsertInstance(cursor, subnetId, instanceId, instanceType, privateIp, publicIp, amiId, os, amiName, iamRole, nameTag, environmentTag, instanceSchedulerTag, vpcId, avgCpuUtilization, accountId):
    accountName = get_account_name(cursor, accountId)
    if accountName is None:
        print(f"Account name not found for account_id: {accountId}")
        return

    print(f"Inserting into instances: subnet_id={subnetId}, instance_id={instanceId}, instance_type={instanceType}, private_ip={privateIp}, public_ip={publicIp}, ami_id={amiId}, os={os}, ami_name={amiName}, iam_role={iamRole}, tag_name={nameTag}, tag_env={environmentTag}, tag_instance_sched={instanceSchedulerTag}, vpc_id={vpcId}, avg_cpu_utilization={avgCpuUtilization}, account_name={accountName}")
    cursor.execute("""
        INSERT INTO instances (subnet_id, instance_id, instance_type, private_ip, public_ip, ami_id, os, ami_name, iam_role, tag_name, tag_env, tag_instance_sched, vpc_id, avg_cpu_utilization, account_name)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (instance_id) DO UPDATE SET
            subnet_id = EXCLUDED.subnet_id,
            instance_type = EXCLUDED.instance_type,
            private_ip = EXCLUDED.private_ip,
            public_ip = EXCLUDED.public_ip,
            ami_id = EXCLUDED.ami_id,
            os = EXCLUDED.os,
            ami_name = EXCLUDED.ami_name,
            iam_role = EXCLUDED.iam_role,
            tag_name = EXCLUDED.tag_name, 
            tag_env = EXCLUDED.tag_env,
            tag_instance_sched = EXCLUDED.tag_instance_sched,
            vpc_id = EXCLUDED.vpc_id,
            avg_cpu_utilization = EXCLUDED.avg_cpu_utilization,
            account_name = EXCLUDED.account_name;
    """, (subnetId, instanceId, instanceType, privateIp, publicIp, amiId, os, amiName, iamRole, nameTag, environmentTag, instanceSchedulerTag, vpcId, avgCpuUtilization, accountName))

def upsertEni(cursor, eniId, privateIp, interfaceType, status, description, subnetId, vpcId, availabilityZone, instanceId, deviceIndex, attachTime, deleteOnTermination):
    # Verifica e ajusta valores inválidos
    if attachTime == 'No Attach Time':
        attachTime = None
    if instanceId == 'No Instance':
        instanceId = None
    if deviceIndex == 'No Device Index':
        deviceIndex = None

    print(f"Inserting into enis: eni_id={eniId}, private_ip={privateIp}, interface_type={interfaceType}, status={status}, description={description}, subnet_id={subnetId}, vpc_id={vpcId}, availability_zone={availabilityZone}, instance_id={instanceId}, device_index={deviceIndex}, attach_time={attachTime}, delete_on_termination={deleteOnTermination}")
    cursor.execute("""
        INSERT INTO enis (eni_id, private_ip, interface_type, status, description, subnet_id, vpc_id, availability_zone, instance_id, device_index, attach_time, delete_on_termination)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (eni_id) DO UPDATE SET
            private_ip = EXCLUDED.private_ip,
            interface_type = EXCLUDED.interface_type,
            status = EXCLUDED.status,
            description = EXCLUDED.description,
            subnet_id = EXCLUDED.subnet_id,
            vpc_id = EXCLUDED.vpc_id,
            availability_zone = EXCLUDED.availability_zone,
            instance_id = EXCLUDED.instance_id,
            device_index = EXCLUDED.device_index,
            attach_time = EXCLUDED.attach_time,
            delete_on_termination = EXCLUDED.delete_on_termination;
    """, (eniId, privateIp, interfaceType, status, description, subnetId, vpcId, availabilityZone, instanceId, deviceIndex, attachTime, deleteOnTermination))

def getAmiName(ec2, amiId):
    amiDetails = ec2.describe_images(ImageIds=[amiId])
    if amiDetails['Images']:
        image = amiDetails['Images'][0]
        amiName = image.get('Name', 'Unknown AMI Name')
        platformDetails = image.get('PlatformDetails', 'Unknown OS')
        return amiName, platformDetails
    return "Unknown AMI Name", "Unknown OS"

def inferOsFromAmiName(amiName, platformDetails):
    if 'amzn_lnx_2023' in amiName:
        return 'Amazon Linux 2023'
    elif 'amzn-lnx_2' in amiName:
        return 'Amazon Linux 2'
    elif 'amzn-lnx' in amiName or 'amazon-linux' in amiName:
        return 'Amazon Linux'
    elif 'bottlerocket' in amiName:
        return 'AWS Bottlerocket'
    elif 'ubuntu' in amiName:
        return 'Ubuntu'
    elif '_sles_' in amiName:
        return 'SUSE Linux Enterprise Server'
    elif 'windows_2022' in amiName:
        return 'Windows 2022'
    elif 'windows_2019' in amiName:
        return 'Windows 2019'
    elif 'windows' in amiName:
        return 'Windows'
    elif 'rhel' in amiName or 'redhat' in amiName:
        return 'Red Hat Enterprise Linux'
    elif 'Hadoop_Spark' in amiName:
        return 'Linux com Hadoop e Spark'
    elif 'Ganglia_Hadoop_Spark' in amiName:
        return 'Linux com Ganglia, Hadoop e Spark'
    elif 'centos' in amiName:
        return 'CentOS'
    else:
        return platformDetails


import traceback

def listVpcsSubnetsInstances(profile, cursor, ec2, cloudwatch):
    try:   
        accountId = getAccountId(cursor, profile)
        if not accountId:
            print(f"Account ID not found for profile: {profile}")
            return
        
        vpcs = ec2.describe_vpcs().get('Vpcs', [])
        if not vpcs:
            print(f"No VPCs found for profile: {profile}")
            return

        for vpc in vpcs:
            vpcId = vpc['VpcId']
            vpcName = next((tag['Value'] for tag in vpc.get('Tags', []) if tag['Key'] == 'Name'), 'No Name')
            vpcCidr = vpc['CidrBlock']
            vpcDbId = upsertVpc(cursor, accountId, vpcId, vpcName, vpcCidr)
            
            subnets = ec2.describe_subnets(Filters=[{'Name': 'vpc-id', 'Values': [vpcId]}]).get('Subnets', [])
            for subnet in subnets:
                subnetId = subnet['SubnetId']
                subnetCidr = subnet['CidrBlock']
                subnetName = next((tag['Value'] for tag in subnet.get('Tags', []) if tag['Key'] == 'Name'), 'No Name')
                networkTag = next((tag['Value'] for tag in subnet.get('Tags', []) if tag['Key'] == 'Network'), 'No Network Tag')
                availabilityZone = subnet['AvailabilityZone']
                totalIpCount = 2**(32 - int(subnetCidr.split('/')[1])) - 5
                usedIpCount = totalIpCount - subnet['AvailableIpAddressCount']
                upsertSubnet(cursor, vpcId, subnetId, subnetName, subnetCidr, networkTag, availabilityZone, usedIpCount, totalIpCount)

                instances = ec2.describe_instances(Filters=[
                    {'Name': 'subnet-id', 'Values': [subnetId]},
                    {'Name': 'instance-state-name', 'Values': ['pending', 'running']}
                ]).get('Reservations', [])
                
                for reservation in instances:
                    for instance in reservation['Instances']:
                        instanceId = instance['InstanceId']
                        privateIp = instance.get('PrivateIpAddress', 'No Private IP')
                        publicIp = instance.get('PublicIpAddress', 'No Public IP')
                        instanceType = instance['InstanceType']
                        amiId = instance['ImageId']
                        iamRole = instance.get('IamInstanceProfile', {}).get('Arn', 'No IAM Role')
                        amiName, platformDetails = getAmiName(ec2, amiId)
                        os = inferOsFromAmiName(amiName, platformDetails)
                        avgCpuUtilization = getCpuUtilization(cloudwatch, instanceId)
                        nameTag = 'Empty'
                        environmentTag = 'Empty'
                        instanceSchedulerTag = 'Empty'

                        for tag in instance.get('Tags', []):
                            if tag['Key'] == 'Name':
                                nameTag = tag['Value']
                            elif tag['Key'] == 'Environment':
                                environmentTag = tag['Value']
                            elif tag['Key'] == 'Instance-Scheduler':
                                instanceSchedulerTag = tag['Value']

                        upsertInstance(cursor, subnetId, instanceId, instanceType, privateIp, publicIp, amiId, os, amiName, iamRole, nameTag, environmentTag, instanceSchedulerTag, vpcId, avgCpuUtilization, accountId)

                # Adiciona a coleta de ENIs
                enis = ec2.describe_network_interfaces(Filters=[
                    {'Name': 'subnet-id', 'Values': [subnetId]}
                ]).get('NetworkInterfaces', [])
                
                for eni in enis:
                    eniId = eni['NetworkInterfaceId']
                    privateIp = eni['PrivateIpAddress']
                    interfaceType = eni['InterfaceType']
                    status = eni['Status']
                    description = eni.get('Description', 'No Description')
                    subnetId = eni['SubnetId']
                    vpcId = eni['VpcId']
                    availabilityZone = eni['AvailabilityZone']
                    attachment = eni.get('Attachment', {})
                    instanceId = attachment.get('InstanceId', 'No Instance')
                    deviceIndex = attachment.get('DeviceIndex', 'No Device Index')
                    attachTime = attachment.get('AttachTime', 'No Attach Time')
                    deleteOnTermination = attachment.get('DeleteOnTermination', False)

                    upsertEni(cursor, eniId, privateIp, interfaceType, status, description, subnetId, vpcId, availabilityZone, instanceId, deviceIndex, attachTime, deleteOnTermination)

    except Exception as e:
        print(f"Error: {str(e)}")
        traceback.print_exc()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='List discovered resources for a specific AWS CLI profile.')
    parser.add_argument('profile', help='The name of the AWS CLI profile to use')
    args = parser.parse_args()
    account = args.profile      # nome do profile da conta

    # Obtém o número da conta da AWS
    session = boto3.Session(profile_name=account, region_name='sa-east-1') 

    sts_client = session.client('sts')
    account_id = sts_client.get_caller_identity()['Account']
    eks = session.client('eks')
    ec2 = session.client('ec2')
    autoscaling = session.client('autoscaling')
    cloudwatch = session.client('cloudwatch')

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

    try:
        # print("Truncate older data...")
        # cursor.execute("TRUNCATE TABLE eks_clusters, eks_nodegroups, eks_nodes, vpcs, subnets, instances;")
                
        coletarInformacoesEks(cursor, account, eks, autoscaling)
        listVpcsSubnetsInstances(account, cursor, ec2, cloudwatch)
        
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"Error: {str(e)}")
        traceback.print_exc()
    finally:
        cursor.close()
        conn.close()
