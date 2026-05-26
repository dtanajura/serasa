import boto3
from botocore.exceptions import ClientError, ProfileNotFound
import sys
import argparse
import os   # Usado para criar pastas e caminhos
import json # Usado para criar os arquivos JSON

# --- CONFIGURAÇÃO ---
# Nome da pasta onde os JSONs serão salvos
RESOURCES_DIR = "resources"
# --------------------

def sanitize_filename(arn):
    """
    Converte um ARN (que contém caracteres inválidos para nomes de arquivo)
    em um nome de arquivo seguro.
    Substitui ':' por '_' e '/' por '-'.
    """
    return arn.replace(':', '_').replace('/', '-') + '.json'

def get_service_from_arn(arn):
    """
    Tenta extrair o nome do serviço (ec2, s3, rds) do ARN.
    Formato do ARN: arn:partition:service:region:account-id:resource
    """
    try:
        # O serviço é a terceira parte do ARN
        service = arn.split(':')[2]
        return service
    except Exception:
        # Retorna 'unknown' se o ARN for malformado
        return "unknown"

def scan_and_save_resources(region, profile_name=None):
    """
    Busca todos os recursos, imprime na tela e salva
    um JSON individual para cada um na pasta 'resources'.
    """
   
    try:
        # --- ETAPA 1: Criar a Sessão Boto3 ---
        print("Autenticando e criando sessão Boto3...")
        session = boto3.Session(profile_name=profile_name)
       
        # --- ETAPA 2: Confirmação de Identidade (STS) ---
        try:
            sts_client = session.client('sts', region_name=region)
            identity = sts_client.get_caller_identity()
            print(f"Sessão criada com sucesso!")
            print(f"  Conta AWS:    {identity['Account']}")
            print(f"  Identidade:   {identity['Arn']}")
        except ClientError as e:
            print(f"Aviso: Não foi possível verificar a identidade com STS (sts:GetCallerIdentity): {e}")
            print("  Continuando mesmo assim...\n")
       
        # --- ETAPA 3: Criar a pasta de saída ---
        print(f"Garantindo que a pasta de saída './{RESOURCES_DIR}' exista...")
        os.makedirs(RESOURCES_DIR, exist_ok=True)
       
        # --- ETAPA 4: Varredura de Recursos e Tags ---
        print(f"\n--- Iniciando varredura de recursos e tags ---")
        print(f"  Perfil AWS: {profile_name or 'default'}")
        print(f"  Região Alvo: {region}")
        print(f"  Salvando arquivos em: ./{RESOURCES_DIR}/\n")
        print("Recursos encontrados:")

        tag_client = session.client('resourcegroupstaggingapi', region_name=region)
       
        paginator = tag_client.get_paginator('get_resources')
        pages = paginator.paginate(ResourcesPerPage=100)

        total_resources_found = 0
        resources_with_tags = 0

        for page in pages:
            resource_mappings = page.get('ResourceTagMappingList', [])
            for resource in resource_mappings:
                total_resources_found += 1
               
                # Extrai dados básicos
                arn = resource['ResourceARN']
                tags_list = resource.get('Tags', [])
                tags_dict = {tag['Key']: tag['Value'] for tag in tags_list}
                service_type = get_service_from_arn(arn)
               
                if tags_dict:
                    resources_with_tags += 1
               
                # 1. Imprimir na tela (Conforme solicitado)
                print(f"  [Serviço: {service_type}] - {arn}")

                # 2. Preparar dados para o JSON
                resource_data = {
                    'arn': arn,
                    'service_type': service_type,
                    'tags': tags_dict
                }
               
                # 3. Criar nome do arquivo e salvar
                filename = sanitize_filename(arn)
                filepath = os.path.join(RESOURCES_DIR, filename)
               
                try:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        json.dump(resource_data, f, indent=2, ensure_ascii=False)
                except Exception as e:
                    print(f"    !! ERRO: Não foi possível salvar o arquivo {filename}: {e}")

        print("\nVarredura concluída.")

    except ProfileNotFound:
        print(f"Erro: O perfil AWS '{profile_name}' não foi encontrado.")
        print("Verifique seu arquivo ~/.aws/credentials.")
        sys.exit(1)
    except ClientError as e:
        error_code = e.response.get("Error", {}).get("Code")
        if error_code == 'AccessDeniedException':
            print(f"Erro de Permissão (AccessDenied) ao usar o perfil '{profile_name}'.")
            print("Verifique se o perfil tem a permissão 'resourcegroupstaggingapi:GetResources'.")
        else:
            print(f"Erro ao conectar ou buscar recursos na região {region}: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Erro inesperado ao processar a região {region}: {e}")
        sys.exit(1)

    # --- ETAPA 5: Relatório Final (Resumo) ---
    print("\n--- Relatório Final ---")
    print(f"Total de recursos analisados: {total_resources_found}")
    print(f"Total de arquivos JSON criados: {total_resources_found} (em ./{RESOURCES_DIR})")
    print(f"Recursos com pelo menos uma tag: {resources_with_tags}")
    print(f"Recursos sem tags: {total_resources_found - resources_with_tags}")

# --- Execução do Script ---
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Busca todos os recursos AWS em uma região e salva cada um como um JSON."
    )
   
    parser.add_argument(
        "-p", "--profile",
        required=False,
        default=None,
        help="O nome do perfil AWS (do arquivo ~/.aws/credentials) a ser usado."
    )
   
    parser.add_argument(
        "-r", "--region",
        required=False,
        default=None,
        help="Região AWS (Opcional. Se omitido, tenta detectar do perfil)."
    )
   
    args = parser.parse_args()

    target_profile = args.profile
    target_region = args.region

    # Lógica de detecção de região (se não for fornecida)
    if not target_region:
        print("Região não fornecida. Tentando detectar do perfil...")
        try:
            session = boto3.Session(profile_name=target_profile)
            target_region = session.region_name
           
            if target_region:
                print(f"Região detectada do perfil: {target_region}\n")
            else:
                print(f"\nErro: Não foi possível detectar uma região padrão para o perfil '{target_profile or 'default'}'.")
                print("Por favor, especifique a região com --region ou configure-a no seu arquivo ~/.aws/config")
                sys.exit(1)
       
        except ProfileNotFound:
            print(f"Erro: O perfil AWS '{target_profile}' não foi encontrado.")
            sys.exit(1)
        except Exception as e:
            print(f"Erro ao tentar ler a sessão do Boto3: {e}")
            sys.exit(1)

    # Chama a função principal
    scan_and_save_resources(region=target_region, profile_name=target_profile)
