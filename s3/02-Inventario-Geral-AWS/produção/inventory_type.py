import psycopg2

# Configurações do banco de dados
db_config = {
    'host': 'dev-hub-portal-qa.cbjrpisgumc2.sa-east-1.rds.amazonaws.com',
    'user': 'app-user',
    'password': '123Trocar$',
    'dbname': 'inventario'
}

# Conectando ao banco de dados
conn = psycopg2.connect(**db_config)
cursor = conn.cursor()

# Ler arquivo
resource_file_path = 'aws_resource_types.txt'

with open(resource_file_path, 'r') as file:
    resource_types = file.readlines()

# Inserir no banco de dados
for resource_type in resource_types:
    print(resource_type)
    query = "INSERT INTO resources_type (types) VALUES (%s)"
    cursor.execute(query,(resource_type.strip(),))
    conn.commit()

# Fechando a conexão com o banco de dados
cursor.close()
conn.close()

print("Dados inseridos com sucesso!")
