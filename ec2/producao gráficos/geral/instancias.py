import boto3

# profiles = [
#     "corporateprod", "arcsandbox", "ssrmdev", "ssrmsandbox", 
#     "ssrmprod", "corporatedev", "sredev", "dsstage", "dsprod", 
#     "dsdev", "datahubprod", "datahubdev"
# ]

profiles = [
   "corporateprod","arcsandbox","ssrmdev","ssrmsandbox","ssrmprod","corporatedev","sredev","dsstage",
   "dsprod","dsdev","datahubprod","datahubdev","bnsprod","bnsuat","dodev","douat","positivoprod",
   "datainsightprod","nikedatadev","nikedataprod","nikedatauat"
]

def getAmiName(ec2, amiId):
    amiDetails = ec2.describe_images(ImageIds=[amiId])
    if amiDetails['Images']:
        image = amiDetails['Images'][0]  # Acessa o primeiro item da lista
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

def listVpcsSubnetsInstances(profile):
    session = boto3.Session(profile_name=profile)
    ec2 = session.client('ec2')
    
    vpcs = ec2.describe_vpcs()
    for vpc in vpcs['Vpcs']:
        vpcId = vpc['VpcId']
        vpcName = next((tag['Value'] for tag in vpc.get('Tags', []) if tag['Key'] == 'Name'), 'No Name')
        vpcCidr = vpc['CidrBlock']
        print(f"Profile: {profile}, VPC: {vpcName}, VPC ID: {vpcId}, CIDR: {vpcCidr}")
        
        subnets = ec2.describe_subnets(Filters=[{'Name': 'vpc-id', 'Values': [vpcId]}])
        for subnet in subnets['Subnets']:
            subnetId = subnet['SubnetId']
            subnetCidr = subnet['CidrBlock']
            subnetName = next((tag['Value'] for tag in subnet.get('Tags', []) if tag['Key'] == 'Name'), 'No Name')
            networkTag = next((tag['Value'] for tag in subnet.get('Tags', []) if tag['Key'] == 'Network'), 'No Network Tag')
            print(f"  Subnet: {subnetName}, Subnet ID: {subnetId}, CIDR: {subnetCidr}, Network Tag: {networkTag}")
            
            instances = ec2.describe_instances(Filters=[{'Name': 'subnet-id', 'Values': [subnetId]}])
            for reservation in instances['Reservations']:
                for instance in reservation['Instances']:
                    instanceId = instance['InstanceId']
                    privateIp = instance.get('PrivateIpAddress', 'No Private IP')
                    publicIp = instance.get('PublicIpAddress', 'No Public IP')
                    amiId = instance['ImageId']
                    iamRole = instance.get('IamInstanceProfile', {}).get('Arn', 'No IAM Role')
                    amiName, platformDetails = getAmiName(ec2, amiId)
                    os = inferOsFromAmiName(amiName, platformDetails)
                    print(f"    Instance ID: {instanceId}, Private IP: {privateIp}, Public IP: {publicIp}, AMI: {amiId}, OS: {os}")

# IAM Role: {iamRole}, AMI Name: {amiName}
for profile in profiles:
    listVpcsSubnetsInstances(profile)
