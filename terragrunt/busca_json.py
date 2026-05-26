import os
import argparse
# import boto3

    # adjust_terragrunt(root, policy_path)

# def adjust_terragrunt(root, policy_path):
#     terragrunt_path = os.path.join(root, "terragrunt.hcl")
#     result=parse_terragrunt_file(terragrunt_path)
#     # print(result)
#     updated_data = []
#     locals_section_found = False
#     policy_vars_found = False
#     locals_indentation = 0

#     for section, indentation, key, value in result:
#         if section == "locals":
#             locals_section_found = True
#             locals_indentation = indentation
#             if key == "policy_vars":
#                 policy_vars_found = True
#                 value = policy_path
       
#         updated_data.append((section, indentation, key, value))

def parse_terragrunt_file(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    result = []
    current_section = None
    inside_section = False

    for line in lines:
        stripped_line = line.strip()
        
        # Skip empty lines
        if not stripped_line:
            continue
        
        # Check for section headers
        if stripped_line.endswith('{'):
            current_section = stripped_line[:-1].strip()
            inside_section = True
            continue
        
        # Check for section end
        if stripped_line == '}':
            inside_section = False
            continue
        
        # Process key-value pairs inside a section
        if inside_section:
            parts = line.split('=', 1)
            if len(parts) == 2:
                key = parts[0].strip()
                value = parts[1].strip()
                indentation = len(line) - len(line.lstrip())
                result.append((current_section, indentation, key, value))
    
    return result

def write_terragrunt_file(parsed_data, output_file_path):
    with open(output_file_path, 'w') as file:
        current_section = None

        for section, indentation, key, value in parsed_data:
            if section != current_section:
                if current_section is not None:
                    file.write('}\n\n')
                file.write(f'{section} {{\n')
                current_section = section

            indent_spaces = ' ' * indentation
            file.write(f'{indent_spaces}{key} = {value}\n')

        if current_section is not None:
            file.write('}\n')

def convert_json_to_hcl(diretorio_base, root, file):
    json_path = os.path.join(root, file) # Caminho completo até o arquivo de policy
    nome = root[len(diretorio_base):].lstrip(os.sep)
    sub_folder="\\"
    if "\\" in nome:
        nome = nome.split("\\")[0]
        sub_folder=root.split("\\")[-1]

    with open(json_path, 'r') as f:
        data = f.readlines()
        
    # Criar o conteúdo do arquivo HCL
    hcl_content = []
    hcl_content.append('locals {')
    hcl_content.append('  policy = jsonencode({')
    # Adicionar o conteúdo do JSON com indentação
    for line in data[1:-1]:
        print(f"antes:{line}")
        line = line.rstrip()
        if ":" in line and line.strip().startswith("\"") and line.strip().endswith(","):
            line_parts = line.split(":", 1)
            line_part1 = line_parts[0].replace("\"", "").strip()
            print(line_part1)
            line_part2 = line_parts[1].replace(",", "").strip()
            print(line_part2)
            line = f'{line_part1} = {line_part2}'
        print(f"depois:{line}")
        print("***************************************")
        hcl_content.append(f'  {line}')
    hcl_content.append('  })')
    hcl_content.append('}')

    # Criar o arquivo HCL com o conteúdo convertido
    policy_path = os.path.join(root, file.replace('.json', '.hcl'))
    # Escrever o conteúdo de hcl_content no arquivo policy_path
    # with open(policy_path, 'w') as f:
    #     for line in hcl_content:
    #         f.write(line + '\n')



#     if locals_section_found and not policy_vars_found:
#         updated_data.append(("locals", locals_indentation, "policy_vars", policy_path))

#     print(updated_data)


    # print(terragrunt_path)
    # if os.path.exists(terragrunt_path):

    #     with open(terragrunt_path, 'r') as f:
    #         lines = f.readlines()

    #     # Novo conteúdo ajustado
    #     novo_conteudo = []
    #     for line in lines:
    #         if line.strip().startswith("locals {"):
    #             novo_conteudo.append(f"locals {{\n  enabled     = true\n  policy_vars = read_terragrunt_config(\"{sub_folder}/{file}\")\n}}\n")
    #         elif line.strip().startswith("inputs = {"):
    #             novo_conteudo.append("inputs = {\n...  policy = local.policy_vars.locals.policy\n")
    #         else:
    #             novo_conteudo.append(line)

    #     with open(terragrunt_path, 'w') as f:
    #         f.writelines(novo_conteudo)


def percorrer_pastas(diretorio_base):
    i=0
    for root, dirs, files in os.walk(diretorio_base):
        for file in files:
            if i>0:
                break
            if file.endswith('.json'):
                convert_json_to_hcl(diretorio_base, root, file)
                i=i+1



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Percorre pastas a partir de um diretório base.')
    parser.add_argument('diretorio_base', type=str, help='O diretório base para começar a percorrer as pastas.')
    parser.add_argument('--profile', type=str, required=True, help='O profile da conta da AWS.')
    args = parser.parse_args()

    # Crie uma sessão com o boto3 usando o profile fornecido
    # session = boto3.Session(profile_name=args.profile)

    percorrer_pastas(args.diretorio_base)