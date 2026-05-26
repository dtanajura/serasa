import boto3
from botocore.exceptions import ClientError
import os
import sys
import json
import argparse

def get_bucket_policy(s3_client, bucket_name):
    try:
        policy = s3_client.get_bucket_policy(Bucket=bucket_name)
        return json.loads(policy['Policy'])
    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchBucketPolicy':
            return None
        else:
            raise e

def get_bucket_payer(s3_client, bucket_name):
    try:
        bucket_request_payment = s3_client.get_bucket_request_payment(Bucket=bucket_name)
        return bucket_request_payment['Payer']
    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchBucketRequestPayment':
            return "Requester"
        else:
            raise e

def get_bucket_tags(s3_client, bucket_name):
    try:
        tags = s3_client.get_bucket_tagging(Bucket=bucket_name)
        return {tag['Key']: tag['Value'] for tag in tags['TagSet']}
    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchTagSet':
            return {}
        else:
            raise e

def get_bucket_versioning(s3_client, bucket_name):
    try:
        versioning = s3_client.get_bucket_versioning(Bucket=bucket_name)
        return versioning.get('Status', 'Disabled')
    except ClientError as e:
        return 'Disabled'

def get_bucket_ownership(s3_client, bucket_name):
    try:
        ownership = s3_client.get_bucket_ownership_controls(Bucket=bucket_name)
        return ownership['OwnershipControls']['Rules'][0]['ObjectOwnership']
    except ClientError as e:
        return 'BucketOwnerEnforced'

def get_bucket_block_public_policy(s3_client, bucket_name):
    try:
        block_public_access = s3_client.get_public_access_block(Bucket=bucket_name)
        config = block_public_access['PublicAccessBlockConfiguration']
        return config['BlockPublicPolicy']
    except ClientError as e:
        return 'false'

def get_bucket_sse_algorithm(s3_client, bucket_name):
    try:
        encryption = s3_client.get_bucket_encryption(Bucket=bucket_name)
        return encryption['ServerSideEncryptionConfiguration']['Rules'][0]['ApplyServerSideEncryptionByDefault']['SSEAlgorithm']
    except ClientError as e:
        return 'None'

def create_import_file(bucket_folder, bucket_name, policy_exists):
    import_content = f'import {{\n  to = aws_s3_bucket.this\n  id = "{bucket_name}"\n}}\n'
    if policy_exists:
        import_content += f'import {{\n  to = aws_s3_bucket_policy.this[0]\n  id = "{bucket_name}"\n}}\n'
    with open(os.path.join(bucket_folder, 'import.tf'), 'w') as f:
        f.write(import_content)

import os

def create_terragrunt_file(bucket_folder, bucket_name, policy_exists, payer, versioning_status, object_ownership, block_public_policy, sse_algorithm):
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
  source = local.enabled ? "git::https://code.experian.local/scm/nikesre/terraform-s3.git?ref=v1.6.5" : null
}}

inputs = {{
  env                           = include.root.locals.env
  bucket_name                   = "{bucket_name}"
  payer                         = "{payer}"
'''.format(bucket_name=bucket_name, payer=payer)

    if versioning_status != "Disabled":
        terragrunt_content += '  versioning_configuration_status = "{versioning_status}"\n'.format(versioning_status=versioning_status)
    if object_ownership != "BucketOwnerEnforced":
        terragrunt_content += '  object_ownership              = "{object_ownership}"\n'.format(object_ownership=object_ownership)
    if not block_public_policy:
        terragrunt_content += '  block_public_policy           = {block_public_policy}\n'.format(block_public_policy=str(block_public_policy).lower())
    if sse_algorithm != "AES256":
        terragrunt_content += '  sse_algorithm                 = "{sse_algorithm}"\n'.format(sse_algorithm=sse_algorithm)

    if policy_exists:
        terragrunt_content += '''  bucket_policy_created = true
  bucket_policy         = local.policy_vars.locals.policy
'''

    terragrunt_content += '}'

    with open(os.path.join(bucket_folder, 'terragrunt.hcl'), 'w') as f:
        f.write(terragrunt_content)

# def create_terragrunt_file(bucket_folder, bucket_name, policy_exists, payer, versioning_status, object_ownership, block_public_policy, sse_algorithm):
#     terragrunt_content = '''# ---------------------------------------------------------------------------------------------------------------------
# # TERRAGRUNT CONFIGURATION
# # This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# # maintainable: https://github.com/gruntwork-io/terragrunt
# # ---------------------------------------------------------------------------------------------------------------------

# # Include the root `terragrunt.hcl` configuration
# include "root" {{
#   path   = find_in_parent_folders()
#   expose = true
# }}

# locals {{
#   enabled     = true
# '''.format()

#     if policy_exists:
#         terragrunt_content += '  policy_vars = read_terragrunt_config("policy.hcl")\n'

#     terragrunt_content += '''
# }}

# terraform {{
#   source = local.enabled ? "git::https://code.experian.local/scm/nikesre/terraform-s3.git?ref=v1.6.5" : null
# }}

# inputs = {{
#   env                           = include.root.locals.env
#   bucket_name                   = "{bucket_name}"
#   payer                         = "{payer}"
#   versioning_configuration_status = "{versioning_status}"
#   object_ownership              = "{object_ownership}"
#   block_public_policy           = {block_public_policy}
#   sse_algorithm                 = "{sse_algorithm}"
# '''.format(bucket_name=bucket_name, payer=payer, versioning_status=versioning_status, object_ownership=object_ownership, block_public_policy=str(block_public_policy).lower(), sse_algorithm=sse_algorithm)

#     if policy_exists:
#         terragrunt_content += '''  bucket_policy_created = true
#   bucket_policy         = local.policy_vars.locals.policy
# '''

#     terragrunt_content += '}'

#     with open(os.path.join(bucket_folder, 'terragrunt.hcl'), 'w') as f:
#         f.write(terragrunt_content)

# def create_tags_file(bucket_folder, tags):
#     tags_content = "locals {\n"
#     for key, value in tags.items():
#         tags_content += f'  {key} = "{value}"\n'
#     tags_content += "}\n"
    
#     with open(os.path.join(bucket_folder, 'tags.hcl'), 'w') as f:
#         f.write(tags_content)

def create_tags_file(bucket_folder, tags):
    excluded_keys = {"AppID", "CostString", "CreateBy", "Environment", "ManagedBy", "map-migrated", "Repo"}
    default_tags = {
        "Asset_Category": "N/A",
        "Data_Type": "N/A",
        "Data_Category": "N/A"
    }
    
    # Adiciona as tags padrão se não existirem no dicionário tags
    for key, value in default_tags.items():
        if key not in tags:
            tags[key] = value
    
    tags_content = "locals {\n"
    for key, value in tags.items():
        if key not in excluded_keys:
            tags_content += f'  {key} = "{value}"\n'
    tags_content += "}\n"
    
    with open(os.path.join(bucket_folder, 'tags.hcl'), 'w') as f:
        f.write(tags_content)

          
def create_policy_hcl_file(bucket_folder, policy):
    policy_hcl_content = '''locals {{
  policy = jsonencode({})
}}
'''.format(json.dumps(policy, indent=2))
    
    with open(os.path.join(bucket_folder, 'policy.hcl'), 'w') as f:
        f.write(policy_hcl_content)

def main(profile_name, destination_folder):
    try:
        # Cria uma sessão usando o profile fornecido
        session = boto3.Session(profile_name=profile_name)
        s3 = session.client('s3')
    except Exception as e:
        print(f"Erro ao criar sessão com o profile '{profile_name}': {e}")
        sys.exit(1)

    # Lista todos os buckets
    response = s3.list_buckets()
    buckets = response['Buckets']

    for bucket in buckets:
        bucket_name = bucket['Name']
        bucket_folder = os.path.join(destination_folder, bucket_name)

        # Verifica se a pasta do bucket já existe
        if not os.path.exists(bucket_folder):
            os.makedirs(bucket_folder)
            policy = get_bucket_policy(s3, bucket_name)
            policy_exists = policy is not None

            if policy_exists:
                create_policy_hcl_file(bucket_folder, policy)
                print(f"Bucket: {bucket_name}\nPolicy: {json.dumps(policy, indent=4)}\n")
            else:
                print(f"Bucket: {bucket_name}\nPolicy: policy padrão\n")

            payer = get_bucket_payer(s3, bucket_name)
            versioning_status = get_bucket_versioning(s3, bucket_name)
            object_ownership = get_bucket_ownership(s3, bucket_name)
            block_public_policy = get_bucket_block_public_policy(s3, bucket_name)
            block_public_policy = str(block_public_policy).lower()
            sse_algorithm = get_bucket_sse_algorithm(s3, bucket_name)
            create_import_file(bucket_folder, bucket_name, policy_exists)
            create_terragrunt_file(bucket_folder, bucket_name, policy_exists, payer, versioning_status, object_ownership, block_public_policy, sse_algorithm)

            tags = get_bucket_tags(s3, bucket_name)
            create_tags_file(bucket_folder, tags)
            
        else:
            print(f"Pasta para o bucket {bucket_name} já existe. Pulando...\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Script para listar buckets e suas policies.')
    parser.add_argument('profile', type=str, help='Nome do profile AWS')
    parser.add_argument('destination', type=str, help='Pasta de destino para salvar as policies')

    args = parser.parse_args()
    main(args.profile, args.destination)