import boto3
from botocore.exceptions import ClientError
import os
import sys
import json
import argparse

       
def get_tags(iam, policy_arn):
    try:
        # Obtém as tags da política
        response = iam.list_policy_tags(PolicyArn=policy_arn)
        tags = response.get('Tags', [])
        return tags
    except Exception as e:
        print(f"Erro ao obter tags para a política {policy_arn}: {e}")
        return []

def create_import_file(iampolicy_folder, policy_arn, policy_exists):
    import_content = f'import {{\n  to = aws_iam_policy.this\n  id = "{policy_arn}"\n}}\n'
    # if policy_exists:
    #     import_content += f'import {{\n  to = aws_s3_bucket_policy.this[0]\n  id = "{policy_name}"\n}}\n'
    with open(os.path.join(iampolicy_folder, 'import.tf'), 'w') as f:
        f.write(import_content)

def create_terragrunt_file(iampolicy_folder, policy_name, policy_exists, description):
    terragrunt_content = '''# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration
include "root" {{
  path   = find_in_parent_folders()
  expose = true
}}

locals {{
  enabled     = true
'''.format()

    if policy_exists:
        terragrunt_content += '  policy_vars = read_terragrunt_config("policy.hcl")\n'

    terragrunt_content += '''
}}

terraform {{
  source = local.enabled ? "git::https://code.experian.local/scm/nikesre/terraform-iam-policy.git?ref=v1.2.5" : null
}}

inputs = {{
  env                           = include.root.locals.env
  name                          = "{policy_name}"
  description                   = "{description}"
'''.format(policy_name=policy_name, description=description)

    if policy_exists:
        terragrunt_content += '''  policy                        = local.policy_vars.locals.policy
'''

    terragrunt_content += '}'

    with open(os.path.join(iampolicy_folder, 'terragrunt.hcl'), 'w') as f:
        f.write(terragrunt_content)

def create_tags_file(iampolicy_folder, tags):
    excluded_keys = {"AppID", "CostString", "CreateBy", "Environment", "ManagedBy", "map-migrated", "Repo"}
    tags_content = ""
    
    if tags:
        filtered_tags = [tag for tag in tags if tag['Key'] not in excluded_keys]
        if filtered_tags:
            tags_content = "locals {\n"
            for tag in filtered_tags:
                Key = tag['Key']
                Value = tag['Value']
                tags_content += f'  {Key} = "{Value}"\n'
            tags_content += "}\n"
    
    with open(os.path.join(iampolicy_folder, 'tags.hcl'), 'w') as f:
        f.write(tags_content)
 

def create_policy_hcl_file(iampolicy_folder, policy):
    policy_hcl_content = '''locals {{
  policy = jsonencode({})
}}
'''.format(json.dumps(policy, indent=2))
    
    with open(os.path.join(iampolicy_folder, 'policy.hcl'), 'w') as f:
        f.write(policy_hcl_content)

def get_policy(iam, policy_arn):
    # Obtém a versão mais recente da política
    policy = iam.get_policy(PolicyArn=policy_arn)
    version_id = policy['Policy']['DefaultVersionId']
    
    # Obtém o documento da política na versão mais recente
    policy_version = iam.get_policy_version(
        PolicyArn=policy_arn,
        VersionId=version_id
    )
    
    # Retorna o documento da política em formato JSON
    policy_document = policy_version['PolicyVersion']['Document']
    return policy_document

def list_user_created_policies(iam):
    # Lista todas as políticas
    paginator = iam.get_paginator('list_policies')
    response_iterator = paginator.paginate(Scope='Local')
    
    policies = []
    
    for response in response_iterator:
        for policy in response['Policies']:
            policy_name = policy['PolicyName']
            policy_arn = policy['Arn']
            # Exclui políticas que começam com 'service-role/' ou 'AWS'
            if not policy_name.startswith('eec') and 'service-role' not in policy_arn:
                policies.append([policy_arn,policy_name])
    
    return policies

def main(profile_name, destination_folder):
    try:
        # Cria uma sessão usando o profile fornecido
        session = boto3.Session(profile_name=profile_name)
        iam = session.client('iam')
    except Exception as e:
        print(f"Erro ao criar sessão com o profile '{profile_name}': {e}")
        sys.exit(1)

    policies = list_user_created_policies(iam)
    for policy in policies:
        policy_arn, policy_name = policy  # Desempacota a lista
        # print(f"ARN: {policy_arn}, Name: {policy_name}")

        iampolicy_folder = os.path.join(destination_folder, policy_name)

        # Verifica se a pasta da política já existe
        if not os.path.exists(iampolicy_folder):
            os.makedirs(iampolicy_folder)
            policy_data = iam.get_policy(PolicyArn=policy_arn)
            # print(policy_data)
            policy=get_policy(iam, policy_arn)
            policy_exists = policy is not None

            if policy_exists:
                # description = policy_data['Policy']['Description']
                description = policy_data['Policy'].get('Description')
                if description == None :
                    description = ""
                print(f"description = {description}")
                create_policy_hcl_file(iampolicy_folder, policy)
                create_import_file(iampolicy_folder, policy_arn, policy_exists)
                create_terragrunt_file(iampolicy_folder, policy_name, policy_exists, description)

                tags = get_tags(iam, policy_arn)
                create_tags_file(iampolicy_folder, tags)
                print(f"IAM: {policy_arn}")
                # print(f"IAM: {policy_name}\nPolicy: {json.dumps(policy, indent=4)}\n")
            else:
                print(f"IAM: {policy_name}\nPolicy: policy padrão\n")

    #         payer = get_bucket_payer(s3, policy_name)
    #         versioning_status = get_bucket_versioning(s3, policy_name)
    #         object_ownership = get_bucket_ownership(s3, policy_name)
    #         block_public_policy = get_bucket_block_public_policy(s3, policy_name)
    #         block_public_policy = str(block_public_policy).lower()
    #         sse_algorithm = get_bucket_sse_algorithm(s3, policy_name)
            
    #     else:
    #         print(f"Pasta para o bucket {policy_name} já existe. Pulando...\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Script para listar iam policies')
    parser.add_argument('profile', type=str, help='Nome do profile AWS')
    parser.add_argument('destination', type=str, help='Pasta de destino para salvar as policies')

    args = parser.parse_args()
    main(args.profile, args.destination)