import boto3
import psycopg2
import traceback
import sys

profiles = [
   "corporateprod","arcsandbox","ssrmdev","ssrmsandbox","ssrmprod","corporatedev","sredev","dsstage",
   "dsprod","dsdev","datahubprod","datahubdev","bnsprod","bnsuat","dataofficedev","dataofficeuat","positivoprod",
   "datainsightprod","nikedataservicedev","nikedataserviceprod","nikedataserviceuat"
]

def getAccountId(cursor, profileName):
    cursor.execute("SELECT account_id FROM accounts WHERE account_profile = %s", (profileName,))
    result = cursor.fetchone()
    return result if result else None

def upsertVpc(cursor, accountId, vpcId, vpcName, cidrBlock):
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

def upsertInstance(cursor, subnetId, instanceId, instanceType, privateIp, publicIp, amiId, os, amiName, iamRole, nameTag, environmentTag, instanceSchedulerTag, vpcId):
    cursor.execute("""
        INSERT INTO instances (subnet_id, instance_id, instance_type, private_ip, public_ip, ami_id, os, ami_name, iam_role, tag_name, tag_env, tag_instance_sched, vpc_id)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
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
            vpc_id = EXCLUDED.vpc_id;
    """, (subnetId, instanceId, instanceType, privateIp, publicIp, amiId, os, amiName, iamRole, nameTag, environmentTag, instanceSchedulerTag, vpcId))

def connectDb():
    try:
        conn = psycopg2.connect(
            host='observabilidade-0.cwhrk1jkkma0.sa-east-1.rds.amazonaws.com',
            user='app-user',
            password='123Trocar$',
            dbname='custos_nike'
        )
        print("Conexão bem-sucedida!")
        return conn
    except Exception as e:
        print(f"Erro ao conectar ao banco de dados: {str(e)}")
        traceback.print_exc()  
        return None

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

def listVpcsSubnetsInstances(profile, cursor, ec2):
    try:   
        accountId = getAccountId(cursor, profile)
        if not accountId:
            print(f"Account ID not found for profile: {profile}")
            return
        
        vpcs = ec2.describe_vpcs()
        for vpc in vpcs['Vpcs']:
            vpcId = vpc['VpcId']
            vpcName = next((tag['Value'] for tag in vpc.get('Tags', []) if tag['Key'] == 'Name'), 'No Name')
            vpcCidr = vpc['CidrBlock']
            print(f"Profile: {profile}, VPC: {vpcName}, VPC ID: {vpcId}, CIDR: {vpcCidr}")
            vpcDbId = upsertVpc(cursor, accountId, vpcId, vpcName, vpcCidr)
            
            subnets = ec2.describe_subnets(Filters=[{'Name': 'vpc-id', 'Values': [vpcId]}])
            for subnet in subnets['Subnets']:
                subnetId = subnet['SubnetId']
                subnetCidr = subnet['CidrBlock']
                subnetName = next((tag['Value'] for tag in subnet.get('Tags', []) if tag['Key'] == 'Name'), 'No Name')
                networkTag = next((tag['Value'] for tag in subnet.get('Tags', []) if tag['Key'] == 'Network'), 'No Network Tag')
                availabilityZone = subnet['AvailabilityZone']
                usedIpCount = subnet['AvailableIpAddressCount']
                totalIpCount = 2**(32 - int(subnetCidr.split('/')[1])) - 5  # Calcula o total de IPs possíveis na subnet
                print(f"  Subnet: {subnetName}, Subnet ID: {subnetId}, CIDR: {subnetCidr}, Network Tag: {networkTag}, AZ: {availabilityZone}, Used IPs: {usedIpCount}, Total IPs: {totalIpCount}")
                subnetDbId = upsertSubnet(cursor, vpcId, subnetId, subnetName, subnetCidr, networkTag, availabilityZone, usedIpCount, totalIpCount)

                instances = ec2.describe_instances(Filters=[{'Name': 'subnet-id', 'Values': [subnetId]}])
                for reservation in instances['Reservations']:
                    for instance in reservation['Instances']:
                        instanceId = instance['InstanceId']
                        privateIp = instance.get('PrivateIpAddress', 'No Private IP')
                        publicIp = instance.get('PublicIpAddress', 'No Public IP')
                        instanceType = instance['InstanceType']
                        amiId = instance['ImageId']
                        iamRole = instance.get('IamInstanceProfile', {}).get('Arn', 'No IAM Role')
                        amiName, platformDetails = getAmiName(ec2, amiId)
                        os = inferOsFromAmiName(amiName, platformDetails)
                        nameTag = 'Empty'
                        environmentTag = 'Empty'
                        instanceSchedulerTag = 'Empty'

                        if 'Tags' in instance:
                            for tag in instance['Tags']:
                                if tag['Key'] == 'Name':
                                    nameTag = tag['Value']
                                elif tag['Key'] == 'Environment':
                                    environmentTag = tag['Value']
                                elif tag['Key'] == 'Instance-Scheduler':
                                    instanceSchedulerTag = tag['Value']

                        print(f"    Instance ID: {instanceId}, Instance Type: {instanceType}, Private IP: {privateIp}, Public IP: {publicIp}, AMI: {amiId}, OS: {os}")
                        upsertInstance(cursor, subnetId, instanceId, instanceType, privateIp, publicIp, amiId, os, amiName, iamRole, nameTag, environmentTag, instanceSchedulerTag, vpcId)
    except Exception as e:
        print(f"Error: {str(e)}")
        traceback.print_exc()

def main():
    conn = connectDb()
    if conn is None:
        return
    cursor = conn.cursor()
    
    try:
        for profile in profiles:
            session = boto3.Session(profile_name=profile)
            ec2 = session.client('ec2')
            listVpcsSubnetsInstances(profile, cursor, ec2)
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"Error: {str(e)}")
        traceback.print_exc()
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    main()
