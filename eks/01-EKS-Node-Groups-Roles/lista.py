import sys
import boto3

def list_eks_nodegroups_and_roles(profile_name):
    # Configurando a sessão usando o profile
    # Obtém o número da conta da AWS
    session = boto3.Session(profile_name=profile_name)
    sts_client = session.client('sts')
    account_id = sts_client.get_caller_identity()['Account']
    client = session.client('eks')
    
    # Listando todos os clusters
    clusters = client.list_clusters()['clusters']
    print(f"Conta: {profile_name} - {account_id}")
    
    # Iterando sobre todos os clusters para listar seus nodegroups e IAM Roles
    for cluster in clusters:
        print(f"Cluster: {cluster}")
        nodegroups = client.list_nodegroups(clusterName=cluster)['nodegroups']
        
        for nodegroup in nodegroups:
            # Obtendo detalhes do nodegroup
            ng_details = client.describe_nodegroup(clusterName=cluster, nodegroupName=nodegroup)
            iam_role = ng_details['nodegroup']['nodeRole']
            print(f"  Nodegroup: {nodegroup}")
            print(f"    IAM Role: {iam_role}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <aws-profile-name>")
        sys.exit(1)
    
    profile_name = sys.argv[1]
    list_eks_nodegroups_and_roles(profile_name)

