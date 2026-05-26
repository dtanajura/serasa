import re
import csv
import boto3
import argparse
import psycopg2
from datetime import datetime, timedelta
import traceback

def getAccountName(accountId):
    print("\n**************** get_account_name")
    filePath = "C:/Users/c96531a/.saml2aws"
    pattern = r"Account: ([\w-]+) \((\d+)\)"  # Define o padrão para capturar o nome e número da conta
    try:
        with open(filePath, 'r') as file:
            for line in file:
                match = re.search(pattern, line)
                if match:
                    account_name = match.group(1)
                    account_number = match.group(2)
                    if (account_number == accountId): return account_name
    except FileNotFoundError:
        print("Arquivo não encontrado!")
    except Exception as e:
        print(f"Error reading the file: {e}")
        return None
    return None


def coletarInformacoesEks(accountId, accountName, session, output):
    eks = session.client('eks')
    autoscaling = session.client('autoscaling')
    clusters = eks.list_clusters()['clusters']
    if not clusters:
        print(f"No EKS clusters found for account: {accountName}")
        output.append(f"No EKS clusters found for account: {accountName}")
        return
    else:
        print(f"EKS clusters for account: {accountName}")
        output.append(f"EKS clusters for account: {accountName}")

    for clusterName in clusters:
        clusterInfo = eks.describe_cluster(name=clusterName)['cluster']
        clusterId = clusterInfo['name']
        kubernetesVersion = clusterInfo['version']
        
        print(f"eks_clusters: account_id={accountId}, cluster_id={clusterId}, cluster_name={clusterName}, kubernetes_version={kubernetesVersion}")
        output.append(f"eks_clusters: account_id={accountId}, cluster_id={clusterId}, cluster_name={clusterName}, kubernetes_version={kubernetesVersion}")

        nodegroups = eks.list_nodegroups(clusterName=clusterName)['nodegroups']
        if not nodegroups:
            print("No nodegroups")
            output.append("No nodegroups")
            continue

        for nodegroupName in nodegroups:
            nodegroupInfo = eks.describe_nodegroup(clusterName=clusterName, nodegroupName=nodegroupName)['nodegroup']
            nodegroupId = nodegroupInfo['nodegroupName']
            autoscalingGroupName = nodegroupInfo['resources']['autoScalingGroups'][0]['name']
            launchTemplateId = nodegroupInfo['launchTemplate']['id']
            launchTemplateVersion = nodegroupInfo['launchTemplate']['version']
            
            print(f"Details eks_nodegroups: nodegroup_id={nodegroupId}, autoscaling_group_name={autoscalingGroupName}, launch_template_id={launchTemplateId}, launch_template_version={launchTemplateVersion}")
            output.append(f"Details eks_nodegroups: nodegroup_id={nodegroupId}, autoscaling_group_name={autoscalingGroupName}, launch_template_id={launchTemplateId}, launch_template_version={launchTemplateVersion}")
            response = autoscaling.describe_auto_scaling_groups(AutoScalingGroupNames=[autoscalingGroupName])
            instances = response['AutoScalingGroups'][0]['Instances']
            if not instances:
                print("No instances")
                output.append("No instances")
                continue

            for instance in instances:
                instanceId = instance['InstanceId']
                print(f"Details eks_nodes: instance_id={instanceId}")
                output.append(f"Details eks_nodes: instance_id={instanceId}")
                listInstances(instanceId,session,output)

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

def listInstances(instanceId,session,output):
    ec2 = session.client('ec2')
    # Obtém detalhes da instância
    response = ec2.describe_instances(InstanceIds=[instanceId])

    # Extrai as informações desejadas
    instanceDetails = response['Reservations'][0]['Instances'][0]
    amiId = instanceDetails['ImageId']
    amiName, platformDetails = getAmiName(ec2, amiId)
    os = inferOsFromAmiName(amiName, platformDetails)

    instanceInfo = {
        'InstanceType': instanceDetails['InstanceType'],
        'PrivateIpAddress': instanceDetails.get('PrivateIpAddress', 'N/A'),
        'State': instanceDetails['State']['Name'],
        'Architecture': instanceDetails['Architecture'],
        'VolumeId': instanceDetails['BlockDeviceMappings'][0]['Ebs']['VolumeId'],
        'Tags': instanceDetails.get('Tags', [])
    }

    # Exibe as informações
    # Formata e exibe as informações
    output.append("Instance Details:")
    output.append(f"  Instance Type: {instanceInfo['InstanceType']}")
    output.append(f"  Private IP Address: {instanceInfo['PrivateIpAddress']}")
    output.append(f"  State: {instanceInfo['State']}")
    output.append(f"  Architecture: {instanceInfo['Architecture']}")
    output.append(f"  Volume ID: {instanceInfo['VolumeId']}")
    output.append(f"  OS: {os}")
    output.append("  Tags:")
    for tag in instanceInfo['Tags']:
        output.append(f"    {tag['Key']}: {tag['Value']}")


def main():
    parser = argparse.ArgumentParser(description='Script para coletar custos e recursos de contas AWS.')
    parser.add_argument('profile', help='Perfil AWS CLI a ser usado')
    args = parser.parse_args()

    profileName = args.profile
    session = boto3.Session(profile_name=profileName)
    sts = session.client('sts')
    accountId = sts.get_caller_identity()['Account']
    output = []
    # eks = session.client('eks')
    # ec2 = session.client('ec2')
    # autoscaling = session.client('autoscaling')
    # cloudwatch = session.client('cloudwatch')
    defaultRegion = session.region_name

    # Obtem o nome da conta
    accountName = getAccountName(accountId)
    fileName=f"instance_details_{profileName}.txt"
    output.append(f"Nome da conta {accountName}")

    # coletar informacoes dos clusters Eks
    coletarInformacoesEks(accountId, accountName, session, output)

    with open(fileName, 'w') as file:
        for line in output:
            file.write(line + '\n')

    print("As informações da instância foram escritas no arquivo 'instance_details.txt'.")




if __name__ == "__main__":
    main()

