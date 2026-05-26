import os
import json
import pandas as pd

# Caminho da pasta contendo os arquivos JSON
pasta = './resources'

# Lista para armazenar os dados extraídos
dados = []

# Conjunto para armazenar todos os nomes de tags únicos
todas_tags = set()

# Itera sobre todos os arquivos JSON na pasta
for arquivo in os.listdir(pasta):
    if arquivo.endswith('.json'):
        caminho_arquivo = os.path.join(pasta, arquivo)
        print(f"Processando: {arquivo}")  # <-- Aqui mostra o andamento
        try:
            with open(caminho_arquivo, 'r', encoding='utf-8') as f:
                conteudo = json.load(f)
                registro = {
                    'arn': conteudo.get('arn'),
                    'service_type': conteudo.get('service_type')
                }
                tags = conteudo.get('tags', {})
                todas_tags.update(tags.keys())
                registro.update(tags)
                dados.append(registro)
        except Exception as e:
            print(f"Erro ao processar '{arquivo}': {e}")

# Cria o DataFrame
df = pd.DataFrame(dados)

# Garante que todas as colunas de tags estejam presentes
for tag in todas_tags:
    if tag not in df.columns:
        df[tag] = None

# Exporta para Excel
df.to_excel('recursos_aws.xlsx', index=False)
print("Arquivo Excel 'recursos_aws.xlsx' gerado com sucesso.")