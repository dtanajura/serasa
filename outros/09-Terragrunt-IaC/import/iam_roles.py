import boto3
from botocore.exceptions import ClientError
import os
import sys
import json
import argparse

       
def get_tags(iam, role_name):
    try:
        # Obtém as tags da role
        response = iam.list_role_tags(RoleName=role_name)
        tags = response.get('Tags', [])
        return tags
    except Exception as e:
        print(f"Erro ao obter tags para a role {role_name}: {e}")
        return []

def get_inline_policies(iam, role_name):
    response = iam.list_role_policies(RoleName=role_name)
    inline_policies = response.get('PolicyNames', [])
    return inline_policies

def get_policy_document(iam, role_name, policy_name):
    response = iam.get_role_policy(RoleName=role_name, PolicyName=policy_name)
    policy_document = response.get('PolicyDocument', {})
    return policy_document

def create_inline_policy_hcl_files(iam, iamrole_folder, role_name, inline_policies):
    for policy_name in inline_policies:
        policy_document = get_policy_document(iam, role_name, policy_name)
        policy_hcl_content = '''locals {{
  policy = jsonencode({})
}}
'''.format(json.dumps(policy_document, indent=2))
        
        with open(os.path.join(iamrole_folder, f'{policy_name}.hcl'), 'w') as f:
            f.write(policy_hcl_content)
        # print(f"Policy {policy_name} exportada para {iamrole_folder}/{policy_name}.hcl")

def get_instance_profile_name(iam, role_name):
    response = iam.list_instance_profiles_for_role(RoleName=role_name)
    instance_profiles = response.get('InstanceProfiles', [])
    if instance_profiles:
        return instance_profiles[0]['InstanceProfileName']
    else:
        return None
   
def get_attached_policies(iam, role_name):
    response = iam.list_attached_role_policies(RoleName=role_name)
    attached_policies = [policy['PolicyArn'] for policy in response['AttachedPolicies']]
    return attached_policies

def create_trust_policy_file(iamrole_folder, trust_policy):
    trust_policy_content = '''locals {{
  trust_policy = jsonencode({})
}}
'''.format(json.dumps(trust_policy, indent=2))
    
    with open(os.path.join(iamrole_folder, 'trusted_policy.hcl'), 'w') as f:
        f.write(trust_policy_content)

def create_import_file(iamrole_folder, role_name, attached_policies, instance_profile_name, inline_policies):
    
    import_content = f'import {{\n  to = aws_iam_role.this\n  id = "{role_name}"\n}}\n'
    
    if instance_profile_name:
        import_content += f'import {{\n  to = aws_iam_instance_profile.this[0]\n  id = "{instance_profile_name}"\n}}\n'
    
    for policy_arn in attached_policies:
        import_content += f'import {{\n  to = aws_iam_role_policy_attachment.this["{policy_arn}"]\n  id = "{role_name}/{policy_arn}"\n}}\n\n'

    # if inline_policies:
    #     for inline_policy in inline_policies:
    #         import_content += f'import {{\n  to = aws_iam_role_policy.{inline_policy}\n  id = "{role_name}:{inline_policy}"\n}}\n'

    with open(os.path.join(iamrole_folder, 'import.tf'), 'w') as f:
        f.write(import_content)

def create_terragrunt_file(iamrole_folder, role_name, inline_policies, description, attached_policies, instance_profile_name, permissions_boundary, max_session_duration):
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
  trusted_policy_vars = read_terragrunt_config("trusted_policy.hcl")
'''.format()

    # # Adiciona as inline policies na seção locals
    # for policy in inline_policies:
    #     terragrunt_content += f'  policy_vars = read_terragrunt_config("{policy}.hcl")\n'

    terragrunt_content += '''
}}

terraform {{
  source = local.enabled ? "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.4.1" : null
}}

inputs = {{
  env                           = include.root.locals.env
  name                          = "{role_name}"
  description                   = "{description}"
  assume_role_policy            = local.trusted_policy_vars.locals.trust_policy
'''.format(role_name=role_name, description=description)

    # Adiciona as inline policies na seção inputs
    # for policy in inline_policies:
    #     terragrunt_content += f'  inline_policy             = local.policy_vars.locals.policy\n'

    # Adiciona a lista de ARNs na seção inputs
    policy_arns_str = ', '.join(f'"{arn}"' for arn in attached_policies)
    terragrunt_content += f'  policy_arns                   = [{policy_arns_str}]\n'
    if instance_profile_name:
        terragrunt_content += f'  instance_profile_created      = true \n'
        terragrunt_content += f'  instance_profile_name         = "{instance_profile_name}" \n'
    else:
        terragrunt_content += f'  instance_profile_created      = false \n'
    if permissions_boundary:
        terragrunt_content += f'  permissions_boundary          = "{permissions_boundary}" \n'
    if max_session_duration:
        terragrunt_content += f'  max_session_duration          = {max_session_duration} \n'

    terragrunt_content += '}'


    with open(os.path.join(iamrole_folder, 'terragrunt.hcl'), 'w') as f:
        f.write(terragrunt_content)

def create_tags_file(iamrole_folder, tags):
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
    
    with open(os.path.join(iamrole_folder, 'tags.hcl'), 'w') as f:
        f.write(tags_content)

def create_role_hcl_file(iamrole_folder, role):
    role_hcl_content = '''locals {{
  role = jsonencode({})
}}
'''.format(json.dumps(role, indent=2))
    
    with open(os.path.join(iamrole_folder, 'role.hcl'), 'w') as f:
        f.write(role_hcl_content)

def get_role(iam, role_arn):
    # Obtém a versão mais recente da política
    role = iam.get_role(roleArn=role_arn)
    version_id = role['role']['DefaultVersionId']
    
    # Obtém o documento da política na versão mais recente
    role_version = iam.get_role_version(
        roleArn=role_arn,
        VersionId=version_id
    )
    
    # Retorna o documento da política em formato JSON
    role_document = role_version['roleVersion']['Document']
    return role_document

def list_user_created_roles(iam):
    # Lista todas as roles
    paginator = iam.get_paginator('list_roles')
    response_iterator = paginator.paginate()

    roles = []

    for response in response_iterator:
        for role in response['Roles']:
            role_name = role['RoleName']
            role_arn = role['Arn']
            # Exclui roles que começam com 'service-role/' ou 'AWS'
            if role_name.lower().startswith('burolefor'):
                roles.append([role_arn, role_name])

    return roles

def main(profile_name, destination_folder):
    try:
        # Cria uma sessão usando o profile fornecido
        session = boto3.Session(profile_name=profile_name)
        iam = session.client('iam')
    except Exception as e:
        print(f"Erro ao criar sessão com o profile '{profile_name}': {e}")
        sys.exit(1)

    roles = list_user_created_roles(iam)
    for role in roles:
        role_arn, role_name = role  # Desempacota a lista
        print(f"ARN: {role_arn}, Name: {role_name}")

        iamrole_folder = os.path.join(destination_folder, role_name)

        # Verifica se a pasta da política já existe
        if not os.path.exists(iamrole_folder):
            os.makedirs(iamrole_folder)
            role_data = iam.get_role(RoleName=role_name)
            role_data = role_data['Role']
            role_exists = role is not None

            if role_exists:
                description = role_data.get('Description')
                if description == None :
                    description = ""
                # print(f"description = {description}")
                permissions_boundary = role_data.get('PermissionsBoundary', {}).get('PermissionsBoundaryArn', '')
                max_session_duration = role_data.get('MaxSessionDuration', '')
                instance_profile_name = get_instance_profile_name(iam, role_name)
                attached_policies = get_attached_policies(iam, role_name)
                create_trust_policy_file(iamrole_folder, role_data['AssumeRolePolicyDocument'])
                inline_policies = get_inline_policies(iam, role_name)
                create_inline_policy_hcl_files(iam, iamrole_folder, role_name, inline_policies)

                create_import_file(iamrole_folder, role_name, attached_policies, instance_profile_name, inline_policies)
                create_terragrunt_file(iamrole_folder, role_name, inline_policies, description, attached_policies, instance_profile_name, permissions_boundary, max_session_duration)

                tags = get_tags(iam, role_name)
                create_tags_file(iamrole_folder, tags)
            else:
                print(f"IAM: {role_name}\nrole: role padrão\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Script para listar iam roles')
    parser.add_argument('profile', type=str, help='Nome do profile AWS')
    parser.add_argument('destination', type=str, help='Pasta de destino para salvar as roles')

    args = parser.parse_args()
    main(args.profile, args.destination)