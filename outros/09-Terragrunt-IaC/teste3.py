import os
import argparse
import json

# def convert_to_hcl(data, indent=0):
#     """
#     Converte um objeto JSON em uma string HCL no padrão AWS.
#     :param data: Objeto JSON a ser convertido.
#     :param indent: Nível de indentação atual.
#     :return: String no formato HCL.
#     """
#     hcl_str = ""
#     indent_str = "  " * indent

#     if isinstance(data, dict):
#         for key, value in data.items():
#             # Escrever a primeira letra maiúscula
#             hcl_key = key.capitalize()

#             if isinstance(value, dict):
#                 hcl_str += f"{indent_str}{hcl_key} {{\n{convert_to_hcl(value, indent + 1)}{indent_str}}},\n"
#             elif isinstance(value, list):
#                 # Tratar listas com objetos como uma lista dentro do HCL
#                 if key.lower() == "statement" and all(isinstance(item, dict) for item in value):
#                     hcl_str += f"{indent_str}{hcl_key} = [\n"
#                     for index, item in enumerate(value):
#                         hcl_str += f"{indent_str}  {{\n{convert_to_hcl(item, indent + 2)}{indent_str}  }}"
#                         if index < len(value) - 1:  # Adicionar vírgula apenas se não for o último item
#                             hcl_str += ","
#                         hcl_str += "\n"
#                     hcl_str += f"{indent_str}]\n"  # Fechar statement sem vírgula
#                 else:
#                     hcl_str += f"{indent_str}{hcl_key} = [\n"
#                     for index, item in enumerate(value):
#                         if isinstance(item, str):
#                             hcl_str += f"{indent_str}  \"{item}\""
#                         else:
#                             hcl_str += f"{indent_str}  {item}"
#                         if index < len(value) - 1:  # Adicionar vírgula apenas se não for o último item
#                             hcl_str += ","
#                         hcl_str += "\n"
#                     hcl_str += f"{indent_str}],\n"
#             else:
#                 hcl_str += f"{indent_str}{hcl_key} = \"{value}\",\n" if isinstance(value, str) else f"{indent_str}{hcl_key} = {value},\n"
#     elif isinstance(data, list):
#         for index, item in enumerate(data):
#             if isinstance(item, dict):
#                 hcl_str += f"{convert_to_hcl(item, indent)}"
#             else:
#                 hcl_str += f"{indent_str}\"{item}\"" if isinstance(item, str) else f"{indent_str}{item}"
#                 if index < len(data) - 1:  # Adicionar vírgula apenas se não for o último item
#                     hcl_str += ","
#                 hcl_str += "\n"
#     return hcl_str

def convert_to_hcl(data, indent=0):
    """
    Converte um objeto JSON em uma string HCL no padrão AWS.
    :param data: Objeto JSON a ser convertido.
    :param indent: Nível de indentação atual.
    :return: String no formato HCL.
    """
    hcl_str = ""
    indent_str = "  " * indent

    if isinstance(data, dict):
        for key, value in data.items():
            # Escrever a primeira letra maiúscula
            hcl_key = key.capitalize()

            if isinstance(value, dict):
                hcl_str += f"{indent_str}{hcl_key} = {{\n{convert_to_hcl(value, indent + 1)}{indent_str}}},\n"
            elif isinstance(value, list):
                # Tratar listas com objetos como uma lista dentro do HCL
                if key.lower() == "statement" and all(isinstance(item, dict) for item in value):
                    hcl_str += f"{indent_str}{hcl_key} = [\n"
                    for index, item in enumerate(value):
                        hcl_str += f"{indent_str}  {{\n{convert_to_hcl(item, indent + 2)}{indent_str}  }}"
                        if index < len(value) - 1:  # Adicionar vírgula apenas se não for o último item
                            hcl_str += ","
                        hcl_str += "\n"
                    hcl_str += f"{indent_str}]\n"  # Fechar statement sem vírgula
                else:
                    hcl_str += f"{indent_str}{hcl_key} = [\n"
                    for index, item in enumerate(value):
                        if isinstance(item, str):
                            hcl_str += f"{indent_str}  \"{item}\""
                        else:
                            hcl_str += f"{indent_str}  {item}"
                        if index < len(value) - 1:  # Adicionar vírgula apenas se não for o último item
                            hcl_str += ","
                        hcl_str += "\n"
                    hcl_str += f"{indent_str}],\n"
            else:
                if key.lower() == "principal":
                    hcl_str += f"{indent_str}{hcl_key} = {{\n"
                    if isinstance(value, dict):
                        for sub_key, sub_value in value.items():
                            sub_key = sub_key.upper() if sub_key.lower() == "aws" else sub_key
                            hcl_str += f"{indent_str}  {sub_key} = \"{sub_value}\"\n"
                        hcl_str += f"{indent_str}}},\n"
                else:
                    hcl_str += f"{indent_str}{hcl_key} = \"{value}\"\n" if isinstance(value, str) else f"{indent_str}{hcl_key} = {value}\n"
    elif isinstance(data, list):
        for index, item in enumerate(data):
            if isinstance(item, dict):
                hcl_str += f"{convert_to_hcl(item, indent)}"
            else:
                hcl_str += f"{indent_str}\"{item}\"" if isinstance(item, str) else f"{indent_str}{item}"
                if index < len(data) - 1:  # Adicionar vírgula apenas se não for o último item
                    hcl_str += ","
                hcl_str += "\n"
    return hcl_str

def json_to_hcl(json_path, hcl_path):
    # Carregar o JSON do arquivo


    with open(json_path, 'r') as json_file:
        json_data = json.load(json_file)

    # Converter JSON para HCL diretamente
    hcl_output = convert_to_hcl(json_data)
    header = """locals {
  policy = jsonencode({
"""
    footer = """  })
}
"""
    # Dividir hcl_output em linhas
    lines = hcl_output.split('\n')

    # Adicionar indentação de 4 espaços a partir da segunda linha
    indented_lines = ['    ' + line for line in lines]

    # Juntar as linhas novamente
    hcl_output = '\n'.join(indented_lines)


    hcl_output = header + hcl_output + '\n' + footer
    # Salvar em arquivo HCL (opcional)
    with open(hcl_path, 'w') as hcl_file:
        hcl_file.write(hcl_output)

    # Exibir o resultado
    print(hcl_output)


def percorrer_pastas(diretorio_base):
    i=0
    for root, dirs, files in os.walk(diretorio_base):
        for file in files:
            # if i>0:
            #     break
            if file.endswith('.json'):
                json_path = os.path.join(root, file) # Caminho completo até o arquivo de policy
                hcl_path = os.path.join(root, file.replace('.json', '.hcl'))
                json_to_hcl(json_path, hcl_path)
                i=i+1



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Percorre pastas a partir de um diretório base.')
    parser.add_argument('diretorio_base', type=str, help='O diretório base para começar a percorrer as pastas.')
    parser.add_argument('--profile', type=str, required=True, help='O profile da conta da AWS.')
    args = parser.parse_args()

    percorrer_pastas(args.diretorio_base)