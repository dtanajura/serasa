import boto3, csv, argparse
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
    f = open('list_pods.csv', 'a', encoding='UTF8', newline="")
    writer = csv.writer(f)

    header = ['account', 'cluster', 'sha', 'namespace', 'deployment', 'pod_name']
    writer.writerow(header)

    # Inicializar cliente da API do Kubernetes
    v1 = client.CoreV1Api()

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
                pod_data=[profile,clusterName,container_status.image_id,pod.metadata.namespace,deployment_name,pod.metadata.name]
                writer.writerow(pod_data)

    f.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='List discovered resources in specified AWS regions for a specific AWS CLI profile.')
    parser.add_argument('profile', help='The name of the AWS CLI profile to use')
    parser.add_argument('cluster', help='The name of EKS cluster to analise')

    args = parser.parse_args()
    profile_name=args.profile
    cluster_name=args.cluster

# Usar a função
setup_eks_context(cluster_name, profile_name)

list_eks_pods(cluster_name, profile_name)
