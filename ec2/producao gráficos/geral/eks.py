import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
from kubernetes import client, config
from kubernetes.client.rest import ApiException

# profiles = [
#     "corporateprod", "arcsandbox", "ssrmdev", "ssrmsandbox", "ssrmprod", "corporatedev", "sredev", "dsstage",
#     "dsprod", "dsdev", "datahubprod", "datahubdev", "bnsprod", "bnsuat", "dataofficedev", "dataofficeuat", "positivoprod",
#     "datainsightprod", "nikedataservicedev", "nikedataserviceprod", "nikedataserviceuat"
# ]
profiles = [
    "corporateprod"
]

def listar_pods_por_namespace():
    # Configura o acesso ao cluster. Certifique-se de que o kubeconfig está configurado.
    config.load_kube_config()
    
    v1 = client.CoreV1Api()
    
    try:
        # Lista todos os namespaces
        namespaces = v1.list_namespace()
        
        for ns in namespaces.items:
            namespace = ns.metadata.name
            print(f"Namespace: {namespace}")
            
            # Lista todos os pods no namespace
            pods = v1.list_namespaced_pod(namespace)
            
            for pod in pods.items:
                pod_name = pod.metadata.name
                pod_ip = pod.status.pod_ip or "N/A"
                pod_status = pod.status.phase
                node_name = pod.spec.node_name or "N/A"
                
                print(f"  - Pod Name: {pod_name}")
                print(f"    - IP: {pod_ip}")
                print(f"    - Status: {pod_status}")
                print(f"    - Node: {node_name}")
                
    except ApiException as e:
        print(f"Exception when calling CoreV1Api: {e}")

def listarEksClusters(profile):
    sessao = boto3.Session(profile_name=profile)
    eksCliente = sessao.client('eks')
    try:
        resposta = eksCliente.list_clusters()
        clusters = resposta.get('clusters', [])
        print(f"Profile: {profile}")
        for cluster in clusters:
            print(f"  - Cluster: {cluster}")
            # Obter a versão do Kubernetes do cluster
            detalhesCluster = eksCliente.describe_cluster(name=cluster)
            kubernetes_version = detalhesCluster['cluster']['version']
            print(f"    - Kubernetes Version: {kubernetes_version}")
            listarNodegroups(sessao, cluster)
    except (NoCredentialsError, PartialCredentialsError) as e:
        print(f"Não foi possível recuperar clusters para o profile {profile}: {e}")

def listarNodegroups(sessao, cluster):
    eksCliente = sessao.client('eks')
    try:
        resposta = eksCliente.list_nodegroups(clusterName=cluster)
        nodegroups = resposta.get('nodegroups', [])
        for nodegroup in nodegroups:
            print(f"    - Nodegroup: {nodegroup}")
            listarInstanciasNodegroup(sessao, cluster, nodegroup)
    except Exception as e:
        print(f"Não foi possível recuperar nodegroups para o cluster {cluster}: {e}")

def listarInstanciasNodegroup(sessao, cluster, nodegroup):
    eksCliente = sessao.client('eks')
    asgCliente = sessao.client('autoscaling')
    ec2Cliente = sessao.client('ec2')
    try:
        resposta = eksCliente.describe_nodegroup(clusterName=cluster, nodegroupName=nodegroup)
        print(f"NodeGroups: {resposta['nodegroup']['nodegroupName']}")
        asgNames = [asg['name'] for asg in resposta['nodegroup']['resources']['autoScalingGroups']]
        for asgName in asgNames:
            print(f"    - AutoscalingGroup: {asgName}")
            asgResposta = asgCliente.describe_auto_scaling_groups(AutoScalingGroupNames=[asgName])
            instancias = asgResposta['AutoScalingGroups'][0]['Instances']
            for instancia in instancias:
                instance_id = instancia['InstanceId']
                instance_details = ec2Cliente.describe_instances(InstanceIds=[instance_id])
                instance_info = instance_details['Reservations'][0]['Instances'][0]
                
                # Capturando informações da instância
                instance_id = instance_info['InstanceId']
                subnet_id = instance_info['SubnetId']
                private_ip = instance_info.get('PrivateIpAddress', 'N/A')
                
                # Obter o nome da instância das tags
                tag_name = "N/A"
                for tag in instance_info.get('Tags', []):
                    if tag['Key'] == 'Name':
                        tag_name = tag['Value']
                
                print(f"      - Instance ID: {instance_id}")
                print(f"        - Name: {tag_name}")
                print(f"        - Subnet ID: {subnet_id}")
                print(f"        - Private IP: {private_ip}")
    except Exception as e:
        print(f"Não foi possível recuperar instâncias para o nodegroup {nodegroup} no cluster {cluster}: {e}")

for profile in profiles:
    listarEksClusters(profile)
    # Executa a função para listar os pods
    listar_pods_por_namespace()
