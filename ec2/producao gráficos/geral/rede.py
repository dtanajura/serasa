import boto3

profiles = [
    "corporateprod", "arcsandbox", "ssrmdev", "ssrmsandbox", 
    "ssrmprod", "corporatedev", "sredev", "dsstage", "dsprod", 
    "dsdev", "datahubprod", "datahubdev"
]

def listVpcsAndSubnets(profile):
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

for profile in profiles:
    listVpcsAndSubnets(profile)
