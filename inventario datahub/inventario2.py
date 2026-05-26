
import boto3
import pandas as pd
import argparse
import sys
from botocore.exceptions import ClientError, ProfileNotFound

def get_service_from_arn(arn):
    """Extrai o nome do serviço do ARN."""
    try:
        return arn.split(':')[2]
    except Exception:
        return "unknown"

def scan_and_export_to_excel(region, profile_name=None, output_file='recursos_aws.xlsx'):
    try:
        print("Autenticando e criando sessão Boto3...")
        session = boto3.Session(profile_name=profile_name)

        # Verifica identidade
        try:
            sts_client = session.client('sts', region_name=region)
            identity = sts_client.get_caller_identity()
            print(f"Sessão criada com sucesso!")
            print(f"  Conta AWS:    {identity['Account']}")
            print(f"  Identidade:   {identity['Arn']}")
        except ClientError as e:
            print(f"Aviso: Não foi possível verificar identidade: {e}")

        # Cliente para tags
        tag_client = session.client('resourcegroupstaggingapi', region_name=region)
        paginator = tag_client.get_paginator('get_resources')
        pages = paginator.paginate(ResourcesPerPage=100)

        dados = []
        todas_tags = set()
        total_resources_found = 0
        resources_with_tags = 0

        print("\n--- Iniciando varredura de recursos e tags ---")
        for page in pages:
            for resource in page.get('ResourceTagMappingList', []):
                total_resources_found += 1
                arn = resource['ResourceARN']
                tags_list = resource.get('Tags', [])
                tags_dict = {tag['Key']: tag['Value'] for tag in tags_list}
                service_type = get_service_from_arn(arn)

                if tags_dict:
                    resources_with_tags += 1

                registro = {'arn': arn, 'service_type': service_type}
                registro.update(tags_dict)
                dados.append(registro)
                todas_tags.update(tags_dict.keys())

        # Cria DataFrame
        df = pd.DataFrame(dados)
        for tag in todas_tags:
            if tag not in df.columns:
                df[tag] = None

        # Exporta para Excel
        df.to_excel(output_file, index=False)
        print(f"\nArquivo Excel '{output_file}' gerado com sucesso.")
        print("\n--- Relatório Final ---")
        print(f"Total de recursos analisados: {total_resources_found}")
        print(f"Recursos com pelo menos uma tag: {resources_with_tags}")
        print(f"Recursos sem tags: {total_resources_found - resources_with_tags}")

    except ProfileNotFound:
        print(f"Erro: O perfil AWS '{profile_name}' não foi encontrado.")
        sys.exit(1)
    except ClientError as e:
        print(f"Erro ao conectar ou buscar recursos: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Erro inesperado: {e}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Busca recursos AWS e exporta para Excel.")
    parser.add_argument("--region", "-r", required=True, help="Região AWS (ex: sa-east-1)")
    parser.add_argument("--profile", "-p", required=False, default=None, help="Perfil AWS (ex: datahubprod)")
    parser.add_argument("--output", "-o", required=False, default="recursos_aws.xlsx", help="Nome do arquivo Excel")
    args = parser.parse_args()

    scan_and_export_to_excel(region=args.region, profile_name=args.profile, output_file=args.output)
