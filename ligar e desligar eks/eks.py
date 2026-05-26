import boto3
from botocore.exceptions import ClientError
from kubernetes import client, config
import json
import sys
import tempfile
import subprocess

def create_bucket_if_not_exists(session, bucket_name, region):
    s3 = session.client('s3')
    try:
        s3.head_bucket(Bucket=bucket_name)
        print(f"Bucket {bucket_name} already exists.")
    except ClientError:
        if region == 'us-east-1':
            s3.create_bucket(Bucket=bucket_name)
        else:
            s3.create_bucket(
                Bucket=bucket_name,
                CreateBucketConfiguration={'LocationConstraint': region}
            )
        print(f"Bucket {bucket_name} created.")

def save_to_s3(session, bucket_name, file_name, content):
    s3 = session.client('s3')
    s3.put_object(Bucket=bucket_name, Key=file_name, Body=content)

def load_from_s3(session, bucket_name, file_name):
    s3 = session.client('s3')
    obj = s3.get_object(Bucket=bucket_name, Key=file_name)
    return obj['Body'].read().decode('utf-8')

# def get_k8s_client(session, cluster_name, region):
#     eks = session.client('eks')
#     cluster_info = eks.describe_cluster(name=cluster_name)
#     cluster_endpoint = cluster_info['cluster']['endpoint']
#     cluster_cert = cluster_info['cluster']['certificateAuthority']['data']
#     cluster_name = cluster_info['cluster']['name']

#     # Obter um token usando o AWS IAM Authenticator
#     token = session.client('sts').get_caller_identity()['Arn']

#     # Configuração do kubeconfig temporário
#     kubeconfig_content = f"""
# apiVersion: v1
# clusters:
# - cluster:
#     server: {cluster_endpoint}
#     certificate-authority-data: {cluster_cert}
#   name: {cluster_name}
# contexts:
# - context:
#     cluster: {cluster_name}
#     user: aws
#   name: {cluster_name}
# current-context: {cluster_name}
# kind: Config
# preferences: {{}}
# users:
# - name: aws
#   user:
#     exec:
#       apiVersion: client.authentication.k8s.io/v1alpha1
#       command: aws
#       args:
#         - "eks"
#         - "get-token"
#         - "--cluster-name"
#         - "{cluster_name}"
#         - "--region"
#         - "{region}"
#     """

#     with tempfile.NamedTemporaryFile(delete=False) as kubeconfig_file:
#         kubeconfig_file.write(kubeconfig_content.encode('utf-8'))
#         kubeconfig_path = kubeconfig_file.name

#     config.load_kube_config(config_file=kubeconfig_path)
#     return client.AppsV1Api()

def get_k8s_client(cluster_name, profile, region):
    # Cria um arquivo kubeconfig temporário
    with tempfile.NamedTemporaryFile(delete=False) as kubeconfig_file:
        kubeconfig_path = kubeconfig_file.name

    # Executa o comando aws eks update-kubeconfig
    subprocess.run([
        'aws', 'eks', 'update-kubeconfig',
        '--name', cluster_name,
        '--region', region,
        '--kubeconfig', kubeconfig_path,
        '--profile', profile
    ], check=True)

    # Carrega a configuração do kubeconfig temporário
    config.load_kube_config(config_file=kubeconfig_path)
    return client.AppsV1Api()

def get_pod_count(k8s_client):
    deployments = k8s_client.list_deployment_for_all_namespaces().items

    pod_counts = {}
    for deployment in deployments:
        pod_counts[deployment.metadata.name] = deployment.status.replicas

    return pod_counts

def scale_down_deployments(k8s_client):
    deployments = k8s_client.list_deployment_for_all_namespaces().items
    for deployment in deployments:
        namespace = deployment.metadata.namespace
        name = deployment.metadata.name
        k8s_client.patch_namespaced_deployment_scale(
            name=name,
            namespace=namespace,
            body={"spec": {"replicas": 0}}
        )

def scale_up_deployments(k8s_client, pod_counts):
    for deployment_name, replicas in pod_counts.items():
        # Assume that the deployments are in the default namespace or handle namespaces accordingly
        namespace = 'default'  # Adjust this line if namespaces vary
        k8s_client.patch_namespaced_deployment_scale(
            name=deployment_name,
            namespace=namespace,
            body={"spec": {"replicas": replicas}}
        )

def get_node_count(session, cluster_name):
    eks = session.client('eks')
    response = eks.list_nodegroups(clusterName=cluster_name)
    node_groups = response['nodegroups']
    
    node_counts = {}
    for node_group in node_groups:
        node_group_info = eks.describe_nodegroup(clusterName=cluster_name, nodegroupName=node_group)
        node_counts[node_group] = node_group_info['nodegroup']['scalingConfig']['desiredSize']
    
    return node_counts, node_groups

def scale_down_nodes(session, cluster_name, node_groups):
    eks = session.client('eks')
    for node_group in node_groups:
        eks.update_nodegroup_config(
            clusterName=cluster_name,
            nodegroupName=node_group,
            scalingConfig={
                'desiredSize': 0
            }
        )

def scale_up_nodes(session, cluster_name, node_counts):
    eks = session.client('eks')
    for node_group, desired_size in node_counts.items():
        eks.update_nodegroup_config(
            clusterName=cluster_name,
            nodegroupName=node_group,
            scalingConfig={
                'desiredSize': desired_size
            }
        )

def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ["ligar", "desligar"]:
        print("Usage: script.py <ligar|desligar>")
        sys.exit(1)

    action = sys.argv[1]
    
    profile = 'arcsandbox'
    bucket_name = "workhours-optimization-"+profile
    cluster_name = 'nike-tech-dev'
    region = 'sa-east-1'

    session = boto3.Session(profile_name=profile, region_name=region)
    create_bucket_if_not_exists(session, bucket_name, region)
    
    k8s_client = get_k8s_client(profile, cluster_name, region)

    if action == "desligar":
        pod_counts = get_pod_count(k8s_client)
        print(pod_counts)
        # node_counts, node_groups = get_node_count(session, cluster_name)

        # pods_content = json.dumps(pod_counts, indent=2)
        # nodes_content = json.dumps(node_counts, indent=2)

        # save_to_s3(session, bucket_name, 'pods.txt', pods_content)
        # save_to_s3(session, bucket_name, 'nodes.txt', nodes_content)

        # scale_down_deployments(k8s_client)
        # scale_down_nodes(session, cluster_name, node_groups)
    
    elif action == "ligar":
        pods_content = load_from_s3(session, bucket_name, 'pods.txt')
        nodes_content = load_from_s3(session, bucket_name, 'nodes.txt')

        pod_counts = json.loads(pods_content)
        node_counts = json.loads(nodes_content)

        scale_up_deployments(k8s_client, pod_counts)
        scale_up_nodes(session, cluster_name, node_counts)

if __name__ == '__main__':
    main()