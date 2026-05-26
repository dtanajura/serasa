import psycopg2

if __name__ == '__main__':
    db_config = {
        'host': 'dev-hub-portal-qa.cbjrpisgumc2.sa-east-1.rds.amazonaws.com',
        'user': 'app-user',
        'password': '123Trocar$',
        'dbname': 'inventario'
    }

    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()


    file_name = "aws_resource_types.txt"
    with open(file_name,'r') as file:
        for line in file:
            type_name = line.strip()
            print(type_name)

            if type_name:
                cursor.execute("""
                    INSERT INTO resources_type (types) VALUES (%s);
                """, (type_name,))
    
    conn.commit()
    cursor.close()
    conn.close()
