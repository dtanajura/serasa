import boto3, csv
from kubernetes import client, config
from botocore.exceptions import NoCredentialsError

def setup_eks_context(cluster_name, aws_profile):
    try:
        # Utilizar um profile específico da AWS
        session = boto3.Session(profile_name=aws_profile)
        eks = session.client('eks')

        # Buscar informações do cluster EKS
        response = eks.describe_cluster(name=cluster_name)
        cluster_info = response['cluster']

        # Configurações para acesso ao cluster
        certificate_authority = cluster_info['certificateAuthority']['data']
        endpoint = cluster_info['endpoint']

        # Configuração do cliente Kubernetes
        configuration = client.Configuration()
        configuration.host = endpoint
        configuration.verify_ssl = True
        configuration.ssl_ca_cert = certificate_authority

        # Autenticar usando o token do AWS IAM Authenticator (assumindo que já está instalado)
        configuration.api_key = {
            'authorization': f'bearer $(aws --profile {aws_profile} eks get-token --cluster-name {cluster_name} | jq -r ".status.token")'
        }

        # Configurar o cliente global padrão para usar esta configuração
        client.Configuration.set_default(configuration)

        print("Contexto do Kubernetes configurado com sucesso para o cluster:", cluster_name)
    except NoCredentialsError:
        print("Credenciais da AWS não encontradas. Por favor, configure suas credenciais.")
    except Exception as e:
        print("Erro ao configurar o contexto do Kubernetes:", str(e))


def list_eks_pods(clusterName, profile):
    # Carregar configuração do kubectl
    config.load_kube_config()

    # Inicializar cliente da API do Kubernetes
    v1 = client.CoreV1Api()

    # Dicionário para guardar os resultados
    results = []

    # Obter todos os pods em todos os namespaces
    pods = v1.list_pod_for_all_namespaces(watch=False)

    # Iterar sobre todos os pods
    for pod in pods.items:
        # Verificar os status dos containers
        if pod.status.container_statuses:
            for container_status in pod.status.container_statuses:
                # Recuperar informações relacionadas ao deployment, se aplicável
                deployment_name = 'N/A'
                if pod.metadata.owner_references:
                    for ref in pod.metadata.owner_references:
                        if ref.kind == "ReplicaSet":
                            deployment_name = ref.name
                # Adicionar ao resultado
                results.append({
                    profile,                                    # account 
                    clusterName,                                # cluster
                    container_status.image_id,                  # sha
                    pod.metadata.namespace,                     # namespace
                    deployment_name,                            # deployment
                    pod.metadata.name                           # pod_name
                })

    return results


# Usar a função
setup_eks_context('eks-nike-tech-01-prod', 'corporateprod')

results = list_eks_pods('eks-nike-tech-01-prod', 'corporateprod')

# Caminho para o arquivo com os SHAs
# filename = 'shas.txt'

# # Carregar SHAs do arquivo
# shas = load_shas_from_file(filename)
# print(shas)
# def find_pods_by_sha(shas):
#     # Carregar configuração do kubectl
#     config.load_kube_config()

#     # Inicializar cliente da API do Kubernetes
#     v1 = client.CoreV1Api()

#     # Dicionário para guardar os resultados
#     results = []

#     # Obter todos os pods em todos os namespaces
#     pods = v1.list_pod_for_all_namespaces(watch=False)

#     # Iterar sobre todos os pods
#     for pod in pods.items:
#         # Verificar os status dos containers
#         print(f"Namespace: {pod.metadata.namespace} Pod Name: {pod.metadata.name}")
#         if pod.status.container_statuses:
#             for container_status in pod.status.container_statuses:
#                 print(f"*******************\n {container_status}")
#                 # Extrair o ID da imagem do container
#                 image_id = container_status.image_id
#                 # Checar se algum SHA está no image_id
#                 for sha in shas:
#                     # print(f"********************** {sha}")
#                     if sha in image_id:
#                         # Recuperar informações relacionadas ao deployment, se aplicável
#                         deployment_name = 'N/A'
#                         if pod.metadata.owner_references:
#                             for ref in pod.metadata.owner_references:
#                                 if ref.kind == "ReplicaSet":
#                                     deployment_name = ref.name
#                         # Adicionar ao resultado
#                         results.append({
#                             'sha': sha,
#                             'namespace': pod.metadata.namespace,
#                             'deployment': deployment_name,
#                             'pod_name': pod.metadata.name
#                         })
                        
#     return results

# # Executar a função e imprimir os resultados
# # results = find_pods_by_sha(shas)
# for result in results:
#     print(result)
# def load_shas_from_file(filename):
#     with open(filename, 'r') as file:
#         shas=[]
#         # shas = [line.strip() for line in file.readlines()]
#         for line in file:
#             inicio = line.find("sha256:")
#             if (inicio > -1): 
#                 fim = line.find("_",inicio)
#                 line=line.strip()
#                 shas.append(line[inicio:fim])
#     return shas

