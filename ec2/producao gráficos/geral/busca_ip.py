import boto3
import ipaddress

profiles = [
    "corporateprod", "arcsandbox", "ssrmdev", "ssrmsandbox", 
    "ssrmprod", "corporatedev", "sredev", "dsstage", "dsprod", 
    "dsdev", "datahubprod", "datahubdev"
]

def ip_in_cidr(ip, cidr):
    return ipaddress.ip_address(ip) in ipaddress.ip_network(cidr)

def find_vpc_and_subnet(profile, target_ip):
    session = boto3.Session(profile_name=profile)
    ec2 = session.client('ec2')
    
    vpcs = ec2.describe_vpcs()
    for vpc in vpcs['Vpcs']:
        vpc_id = vpc['VpcId']
        vpc_name = next((tag['Value'] for tag in vpc.get('Tags', []) if tag['Key'] == 'Name'), 'No Name')
        vpc_cidr = vpc['CidrBlock']
        
        if ip_in_cidr(target_ip, vpc_cidr):
            print(f"Profile: {profile}, VPC: {vpc_name}, VPC ID: {vpc_id}, CIDR: {vpc_cidr}")
            
            subnets = ec2.describe_subnets(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}])
            for subnet in subnets['Subnets']:
                subnet_id = subnet['SubnetId']
                subnet_cidr = subnet['CidrBlock']
                subnet_name = next((tag['Value'] for tag in subnet.get('Tags', []) if tag['Key'] == 'Name'), 'No Name')
                network_tag = next((tag['Value'] for tag in subnet.get('Tags', []) if tag['Key'] == 'Network'), 'No Network Tag')
                
                if ip_in_cidr(target_ip, subnet_cidr):
                    print(f"  Subnet: {subnet_name}, Subnet ID: {subnet_id}, CIDR: {subnet_cidr}, Network Tag: {network_tag}")
                    return

target_ip = "10.99.13.215"
for profile in profiles:
    find_vpc_and_subnet(profile, target_ip)
