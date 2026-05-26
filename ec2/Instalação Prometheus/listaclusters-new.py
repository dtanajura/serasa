import boto3
from datetime import datetime, timezone

def describe_cluster(cluster_id):
    response = emr_client.describe_cluster(ClusterId=cluster_id)
    return response.get('Cluster', {})

def list_emr_clusters():
    clusters = emr_client.list_clusters()['Clusters']
    return clusters

def print_clusters_details(clusters):
    # Iterar sobre cada cluster
    for cluster in clusters:
        cluster_id = cluster['Id']
        cluster_details = describe_cluster(cluster_id)
        cluster_name = cluster_details['Name']
        creation_date = cluster_details['Status']['Timeline']['CreationDateTime']
        state = cluster_details['Status']['State']
        is_active = state in ['STARTING', 'BOOTSTRAPPING', 'RUNNING', 'WAITING']
        

        print(f"Cluster {cluster_id}")
        print(f"Cluster Name {cluster_name}")
        print(f"Creation Date {creation_date}")
        print(f"Is Active {is_active}")
 
if __name__ == "__main__":
    # Configuração do perfil AWS
    profile_aws = "ssrmprod" #"dsprod"
    region = "sa-east-1"

    # Criar uma sessão usando o perfil AWS
    session = boto3.Session(profile_name=profile_aws, region_name=region)
    emr_client = session.client('emr')
    clusters = list_emr_clusters()
    print_clusters_details(clusters)


#     print_cluster_info(clusters_info)

# # Função para listar clusters ativos
# def list_clusters():
#     # response = emr_client.list_clusters(ClusterStates=['STARTING', 'BOOTSTRAPPING', 'RUNNING', 'WAITING'])
#     return response.get('Clusters', [])

#     # Lista todos os clusters EMR
    
#     cluster_info_list = []
    
#     for cluster in clusters:
#         cluster_id = cluster['Id']
#         cluster_name = cluster['Name']
#         creation_date = cluster['Status']['Timeline']['CreationDateTime']
#         state = cluster['Status']['State']
#         is_active = state in ['STARTING', 'BOOTSTRAPPING', 'RUNNING', 'WAITING']
        
#         # Obtém detalhes do cluster
#         cluster_details = emr_client.describe_cluster(ClusterId=cluster_id)['Cluster']
        
#         # Obtém o bootstrap (se houver)
#         bootstrap_actions = cluster_details.get('BootstrapActions', [])
#         if bootstrap_actions:
#             bootstrap_name = bootstrap_actions[0]['Name']
#             bootstrap_path = bootstrap_actions[0]['ScriptBootstrapAction']['Path']
#         else:
#             bootstrap_name = 'N/A'
#             bootstrap_path = 'N/A'
        
#         # Armazena as informações do cluster
#         cluster_info_list.append({
#             'ClusterID': cluster_id,
#             'ClusterName': cluster_name,
#             'BootstrapName': bootstrap_name,
#             'BootstrapPath': bootstrap_path,
#             'CreationDate': creation_date,
#             'IsActive': is_active
#         })
    
#     return cluster_info_list




# # Função para descrever um cluster
# def describe_cluster(cluster_id):
#     response = emr_client.describe_cluster(ClusterId=cluster_id)
#     return response.get('Cluster', {})

# # Função para obter o nome EC2 do cluster a partir dos tags
# def get_cluster_ec2_name(cluster_details):
#     tags = cluster_details.get('Tags', [])
#     ec2_name = None
#     for tag in tags:
#         if tag['Key'] == 'Name':
#             ec2_name = tag['Value']
#             break
#     return ec2_name

# # Função para verificar e exibir ações de bootstrap
# def check_bootstrap_actions(cluster_details):
#     bootstrap_actions = cluster_details.get('BootstrapActions', [])


#     if bootstrap_actions:
#         print(f"# Bootstrap Actions for Cluster {cluster_details['Name']}")
#         for action in bootstrap_actions:
#             action_name = action['Name']
#             script_path = action['ScriptBootstrapAction']['Path']
#             script_args = ", ".join(action['ScriptBootstrapAction']['Args'])
#             print(f"# Name: {action_name}")
#             # Uncomment the lines below if needed
#             # print(f"Script Path: {script_path}")
#             # print(f"Arguments: {script_args}")
#     else:
#         print(f"# No Bootstrap Actions for Cluster {cluster_details['Id']}")

# # Inicializar listas para clusters considerados e não considerados
# considered_clusters = set()
# ignored_clusters = []

# # Abrir o arquivo para escrita
# with open("scrap-config.yaml", "w") as yaml_file:
#     print("************************************")
#     print(f"Conta: {profile_aws}")

#     # Obter lista de clusters
#     clusters = list_clusters()

#     # Iterar sobre cada cluster
#     for cluster in clusters:
#         cluster_id = cluster['Id']
#         cluster_details = describe_cluster(cluster_id)
#         cluster_name = cluster_details.get('Name', '')
#         cluster_ec2_name = get_cluster_ec2_name(cluster_details)

#         # Verificar se o cluster EC2 Name está vazio ou None
#         if not cluster_ec2_name:
#             ignored_clusters.append(cluster_id)
#             continue

#         # Evitar duplicatas de nomes de clusters
#         if cluster_name in considered_clusters:
#             continue
#         considered_clusters.add(cluster_name)

#         print(f"# Cluster ID: {cluster_id}  Cluster Name: {cluster_name}   Cluster EC2 Names: {cluster_ec2_name}")
#         check_bootstrap_actions(cluster_details)

#         yaml_output = f"""
#   - job_name: '{cluster_name}'
#     ec2_sd_configs:
#       - region: {region}
#     relabel_configs:
#       - source_labels: [__meta_ec2_tag_Name]
#         regex: '{cluster_ec2_name}'
#         action: keep
#       - source_labels: [__meta_ec2_private_ip]
#         target_label: __address__
#         replacement: '${{1}}:9100'
# """
#         print(yaml_output)
#         yaml_file.write(yaml_output)

# # Listar clusters que não foram considerados
# if ignored_clusters:
#     print("\nClusters não considerados devido à ausência de EC2 Name:")
#     for ignored_cluster in ignored_clusters:
#         print(f"Cluster ID: {ignored_cluster}")

