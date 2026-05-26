def process_terragrunt_hcl(file_path):
    # Verificar se a expressão trusted_policy_vars já existe
    in_locals_section = False
    locals_indent = ""
    nome_json = ""
    json_file_name = []
    local_policy_vars = []

    with open(file_path, 'r') as f:
        terragrunt_data = f.readlines()

    for i in range(len(terragrunt_data)):
        if ".json" in terragrunt_data[i]:
            # Extrair o nome do arquivo JSON
            start_index = terragrunt_data[i].find('"') + 1
            end_index = terragrunt_data[i].find('.json') + 5
            nome_json = terragrunt_data[i][start_index:end_index]
            if "/" in nome_json:
                nome_json_parts = nome_json.split("/")
                nome_json = nome_json_parts[-1]
            nome_policy_vars = nome_json.replace(".json", "")
            nome_policy_vars = nome_policy_vars + "_policy_vars"
            json_file_name.append(nome_json)
            local_policy_vars.append(nome_policy_vars)

            # Contar a quantidade de espaços até o primeiro caractere
            indentation_count = len(terragrunt_data[i]) - len(terragrunt_data[i].lstrip(' '))
            
            # Pegar a primeira parte da linha até o "="
            variable_name = terragrunt_data[i].split('=')[0].strip()
            terragrunt_data[i] = ' ' * indentation_count + variable_name + " = local." + nome_policy_vars + ".locals.policy"
    
    # Percorrer o arquivo novamente até a seção "locals {"
    for i in range(len(terragrunt_data)):
        if "locals {" in terragrunt_data[i]:
            in_locals_section = True
            locals_indent = ' ' * (len(terragrunt_data[i]) - len(terragrunt_data[i].lstrip(' ')))
        if "}" in terragrunt_data[i] and in_locals_section:
            in_locals_section = False
        
        if in_locals_section:
            for j in range(len(local_policy_vars)):
                if local_policy_vars[j] in terragrunt_data[i]:
                    # Alterar o valor após " = " para o valor que está na lista json_file_name
                    variable_name = terragrunt_data[i].split('=')[0].strip()
                    terragrunt_data[i] = locals_indent + variable_name + " = \"" + json_file_name[j] + "\"\n"
                    break

    # Adicionar as novas variáveis no final da seção "locals {"
    for i in range(len(terragrunt_data)):
        if "locals {" in terragrunt_data[i]:
            insert_index = i + 1
            break

    for j in range(len(local_policy_vars)):
        variable_exists = False
        for k in range(insert_index, len(terragrunt_data)):
            if local_policy_vars[j] in terragrunt_data[k]:
                variable_exists = True
                break
        
        if not variable_exists:
            new_line = f"{locals_indent}  {local_policy_vars[j]} = \"{json_file_name[j]}\"\n"
            terragrunt_data.insert(insert_index, new_line)
            insert_index += 1

    # Escrever as alterações de volta no arquivo
    # with open(file_path, 'w') as f:
    #     f.writelines(terragrunt_data)
    for i in range(len(terragrunt_data)):
        print(terragrunt_data[i].rstrip())

# def process_terragrunt_hcl(file_path):
#     # Verificar se a expressão trusted_policy_vars já existe
#     in_locals_section = False
#     locals_indent = ""
#     nome_json = ""
#     json_file_name = []
#     local_policy_vars = []

#     with open(file_path, 'r') as f:
#         terragrunt_data = f.readlines()

#     for i in range(len(terragrunt_data)):
#         if ".json" in terragrunt_data[i]:
#             # Extrair o nome do arquivo JSON
#             start_index = terragrunt_data[i].find('"') + 1
#             end_index = terragrunt_data[i].find('.json') + 5
#             nome_json = terragrunt_data[i][start_index:end_index]
#             if "/" in nome_json:
#                 nome_json_parts = nome_json.split("/")
#                 nome_json = nome_json_parts[-1]
#             nome_policy_vars = nome_json.replace(".json", "")
#             nome_policy_vars = nome_policy_vars + "_policy_vars"
#             json_file_name.append(nome_json)
#             local_policy_vars.append(nome_policy_vars)

#             # Contar a quantidade de espaços até o primeiro caractere
#             indentation_count = len(terragrunt_data[i]) - len(terragrunt_data[i].lstrip(' '))
            
#             # Pegar a primeira parte da linha até o "="
#             variable_name = terragrunt_data[i].split('=')[0].strip()
#             terragrunt_data[i] = ' ' * indentation_count + variable_name + " = local." + nome_policy_vars + ".locals.policy"
#             print(terragrunt_data[i])
#     # Percorrer o arquivo novamente até a seção "locals {"

#     for i in range(len(terragrunt_data)):
#         if "locals {" in terragrunt_data[i]:
#             in_locals_section = True
#         if "}" in terragrunt_data[i]:
#             in_locals_section = False
#         print(f"Tô na seção Locals: {in_locals_section}")
     
#         if in_locals_section:
#             for j in range(len(local_policy_vars)):
#                 print(f"local_policy_vars: {local_policy_vars[j]} e json_file_name: {json_file_name[j]}")
#     #             if local_policy_vars[j] in terragrunt_data[i]:
#     #                 # Alterar o valor após " = " para o valor que está na lista json_file_name
#     #                 variable_name = terragrunt_data[i].split('=')[0].strip()
#     #                 # assume_role_policy = local.trusted_policy_vars.locals.trusted_policy
#     #                 terragrunt_data[i] = locals_indent + variable_name + " = \"" + json_file_name[j] + "\""

#     # Escrever as alterações de volta no arquivo
#     # with open(file_path, 'w') as f:
#     #     f.writelines(terragrunt_data)
#     # for i in range(len(terragrunt_data)):
#     #     print(terragrunt_data[i].rstrip())


if __name__ == "__main__":
    process_terragrunt_hcl('terragrunt.hcl')

    