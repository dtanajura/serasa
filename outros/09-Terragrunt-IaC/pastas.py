import os
import argparse
import boto3

# def tarefa_03(root, dir):
#     caminho_completo = os.path.join(root, dir)
#     terragrunt_hcl_path = os.path.join(caminho_completo, 'terragrunt.hcl')
#     trusted_policy_hcl_path = os.path.join(caminho_completo, 'trusted_policy.hcl')
    
#     if os.path.exists(terragrunt_hcl_path) and os.path.exists(trusted_policy_hcl_path):
#         # Ler o conteúdo do arquivo terragrunt.hcl
#         with open(terragrunt_hcl_path, 'r') as f:
#             terragrunt_data = f.readlines()
        
#         # Verificar se a expressão já existe
#         expression_exists = any('trusted_policy_vars")' in line for line in terragrunt_data)
        
#         if not expression_exists:
#             # Encontrar a seção locals e adicionar a string antes da última chave dessa seção
#             in_locals_section = False
#             for i in range(len(terragrunt_data)):
#                 if terragrunt_data[i].strip() == 'locals {':
#                     in_locals_section = True
#                 elif in_locals_section and terragrunt_data[i].strip() == '}':
#                     terragrunt_data.insert(i, '  trusted_policy_vars = read_terragrunt_config("trusted_policy.hcl")\n')
#                     break
            
#             # Escrever o conteúdo atualizado de volta no arquivo terragrunt.hcl
#             with open(terragrunt_hcl_path, 'w') as f:
#                 f.writelines(terragrunt_data)
            
#             print(f"Arquivo terragrunt.hcl atualizado em: {caminho_completo}")

def tarefa_03(root, dir):
    caminho_completo = os.path.join(root, dir)
    terragrunt_hcl_path = os.path.join(caminho_completo, 'terragrunt.hcl')
    trusted_policy_hcl_path = os.path.join(caminho_completo, 'trusted_policy.hcl')
    
    if os.path.exists(terragrunt_hcl_path) and os.path.exists(trusted_policy_hcl_path):
        # Ler o conteúdo do arquivo terragrunt.hcl
        with open(terragrunt_hcl_path, 'r') as f:
            terragrunt_data = f.readlines()
        
        # Verificar se a expressão trusted_policy_vars já existe
        in_locals_section = False
        expression_exists = False
        locals_indent = ""
        for i in range(len(terragrunt_data)):
            if terragrunt_data[i].strip() == 'locals {':
                in_locals_section = True
                locals_indent = terragrunt_data[i][:terragrunt_data[i].index('locals {')]
            elif in_locals_section and 'trusted_policy_vars =' in terragrunt_data[i]:
                terragrunt_data[i] = f'{locals_indent}  trusted_policy_vars = read_terragrunt_config("trusted_policy.hcl")\n'
                expression_exists = True
                break
            elif in_locals_section and terragrunt_data[i].strip() == '}':
                if not expression_exists:
                    terragrunt_data.insert(i, f'{locals_indent}  trusted_policy_vars = read_terragrunt_config("trusted_policy.hcl")\n')
                break
        
        # Verificar se a expressão assume_role_policy já existe na seção inputs
        in_inputs_section = False
        assume_role_policy_exists = False
        inputs_indent = ""
        for i in range(len(terragrunt_data)):
            if terragrunt_data[i].strip() == 'inputs = {':
                in_inputs_section = True
                inputs_indent = terragrunt_data[i][:terragrunt_data[i].index('inputs = {')]
            elif in_inputs_section and 'assume_role_policy =' in terragrunt_data[i]:
                terragrunt_data[i] = f'{inputs_indent}  assume_role_policy = local.trusted_policy_vars.locals.trusted_policy\n'
                assume_role_policy_exists = True
                break
            elif in_inputs_section and terragrunt_data[i].strip() == '}':
                if not assume_role_policy_exists:
                    terragrunt_data.insert(i, f'{inputs_indent}  assume_role_policy = local.trusted_policy_vars.locals.trusted_policy\n')
                break
        
        # Escrever o conteúdo atualizado de volta no arquivo terragrunt.hcl
        with open(terragrunt_hcl_path, 'w') as f:
            f.writelines(terragrunt_data)
        
        print(f"Arquivo terragrunt.hcl atualizado em: {caminho_completo}")

def tarefa_02(root, file):
    json_path = os.path.join(root, file)
    if os.path.exists(json_path):
        # Ler o conteúdo do arquivo JSON como texto
        with open(json_path, 'r') as f:
            data = f.readlines()
        
        # Criar o conteúdo do arquivo HCL
        hcl_content = []
        hcl_content.append('locals {')
        hcl_content.append('  policy = jsonencode({')
        
        # Adicionar o conteúdo do JSON com indentação
        for line in data[1:-1]:
            line = line.rstrip()
            if ":" in line and not line.strip().startswith("\"arn:"):
                line_parts = line.split(":", 1)
                line_part1 = line_parts[0].replace("\"", "")
                line_part2 = line_parts[1].replace(",", "")
                line = line_part1 + " = " + line_part2

            hcl_content.append(f'  {line}')
        
        hcl_content.append('  })')
        hcl_content.append('}')
        
        # Criar o arquivo HCL com o conteúdo convertido
        policy_path = os.path.join(root, file.replace('.json', '.hcl'))
        with open(policy_path, 'w') as f:
            f.write('\n'.join(hcl_content))
        print(f"Arquivo {policy_path} criado.")

# def tarefa_02(root, dir):
#     caminho_completo = os.path.join(root, dir)
#     trust_json_path = os.path.join(caminho_completo, 'trust.json')
#     if os.path.exists(trust_json_path):
#         # Ler o conteúdo do arquivo trust.json como texto
#         with open(trust_json_path, 'r') as f:
#             data = f.readlines()
        
#         # Criar o conteúdo do arquivo HCL
#         hcl_content = []
#         hcl_content.append('locals {')
#         hcl_content.append('  trusted_policy = jsonencode({')
        
#         # Adicionar o conteúdo do JSON com indentação
#         for line in data[1:-1]:
#             line = line.rstrip()
#             if ":" in line and not line.strip().startswith("\"arn:"):
#                 # print(line.strip().startswith("\"arn:"))
#                 # print(line)
#                 line_parts = line.split(":", 1)
#                 line_part1 = line_parts[0].replace("\"", "")
#                 line_part2 = line_parts[1].replace(",", "")
#                 line = line_part1 + " = " + line_part2

#             hcl_content.append(f'  {line}')
        
#         hcl_content.append('  })')
#         hcl_content.append('}')
        
#         # Criar o arquivo trusted_policy.hcl com o conteúdo convertido
#         trusted_policy_path = os.path.join(caminho_completo, 'trusted_policy.hcl')
#         with open(trusted_policy_path, 'w') as f:
#             f.write('\n'.join(hcl_content))
#         print(f"Arquivo trusted_policy.hcl criado em: {caminho_completo}")


def tarefa_01(root, rolename, session):
    caminho_completo = os.path.join(root, rolename)
    iam = session.client('iam')
    instance_profile_created = False
    try:
        # Verifica se existe um instance profile com o mesmo nome da role
        instance_profile = iam.get_instance_profile(InstanceProfileName=rolename)
        if instance_profile:
            instance_profile_created = True
    except:
        print("deu pau!!")
    
    print(f"    instace_profile_created = {instance_profile_created}")

    
    # Exemplo de ação: criar um arquivo de texto em cada pasta
    with open(os.path.join(caminho_completo, 'arquivo_exemplo.txt'), 'w') as f:
        f.write('Este é um arquivo de exemplo.')

# def percorrer_pastas(diretorio_base, session):
#     for root, dirs, files in os.walk(diretorio_base):
#         for dir in dirs:
#             # tarefa_01(root, dir, session)
#             tarefa_02(root, dir)
#             tarefa_03(root, dir)
#             # break

def percorrer_pastas(diretorio_base):
    for root, dirs, files in os.walk(diretorio_base):
        for file in files:
            if file.endswith('.json'):
                tarefa_02(root, file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Percorre pastas a partir de um diretório base.')
    parser.add_argument('diretorio_base', type=str, help='O diretório base para começar a percorrer as pastas.')
    parser.add_argument('--profile', type=str, required=True, help='O profile da conta da AWS.')
    args = parser.parse_args()

    # Crie uma sessão com o boto3 usando o profile fornecido
    session = boto3.Session(profile_name=args.profile)

    percorrer_pastas(args.diretorio_base, session)