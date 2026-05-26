import psycopg2
import pandas as pd
from datetime import datetime, timedelta

# Configuração do banco de dados
db_config = {
    'host': 'observabilidade-0.cwhrk1jkkma0.sa-east-1.rds.amazonaws.com',
    'user': 'app-user',
    'password': '123Trocar$',
    'dbname': 'custos_nike'
}

# Gerar uma lista de colunas de meses desde Dez/23 até Nov/24
def get_months_range():
    start_month = datetime(2023, 12, 1)
    end_month = datetime(2024, 11, 1)
    months = []
    while start_month <= end_month:
        months.append(start_month.strftime('%Y-%m'))
        start_month += timedelta(days=31)
        start_month = start_month.replace(day=1)
    return months

# Consulta para buscar os custos mensais
def fetch_monthly_costs(cursor, account_name, service, tag_name, months):
    # query = """
    #     SELECT 
    #         to_char(t.date_register, 'YYYY-MM') AS month, 
    #         SUM(t.unblended_cost) AS cost
    #     FROM 
    #         tag_details_costs t
    #     JOIN 
    #         accounts a ON t.account_id = a.account_id
    #     JOIN 
    #         servicos s ON t.service LIKE '%' || s.short_name || '%'
    #     WHERE 
    #         a.account_name = %s
    #         AND s.short_name LIKE %s
    #         AND t.tag_name = %s
    #         AND t.date_register BETWEEN %s AND %s
    #     GROUP BY 
    #         month
    #     ORDER BY 
    #         month;
    # """
    query = """
        SELECT service, tag_name FROM tag_details_costs WHERE tag_name = %s;
    """
    cursor.execute(query, (tag_name,))
    results = cursor.fetchall()

    start_date = months[0] + '-01'
    end_date = months[-1] + '-31'
    # print(f"{start_date}, {end_date}")
    # # cursor.execute(query, (account_name, '%' + service + '%', tag_name, start_date, end_date))
    # cursor.execute(query, (service))
    # results = cursor.fetchall()
    if not results:
        print("Nenhum resultado encontrado para a consulta de custos mensais.")
        return {}
    print("Resultados da consulta de custos mensais:", results)


    # return {row[0]: row[1] for row in results}
   
 
# Carregar a planilha existente
file_path = 'Bain Action Plan.xlsx'
df_planilha = pd.read_excel(file_path, sheet_name='Sheet1')

# Conectar ao banco de dados
try:
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()

    # Preparar DataFrame com colunas de meses
    months = get_months_range()
    df_result = df_planilha[['Account', 'Service', 'Name']].drop_duplicates().copy()
    for month in months:
        df_result[month] = 0.0

    # Preencher os custos por mês
    for index, row in df_result.iterrows():
        account = row['Account']
        service = row['Service']
        name = row['Name']
        print(f"\n dados: {account}, {service}, {name}")
        
        monthly_costs = fetch_monthly_costs(cursor, account, service, name, months)
        # print("Custos mensais:", monthly_costs)
        # for month in months:
        #     if month in monthly_costs:
        #         df_result.at[index, month] = monthly_costs[month]

        # monthly_costs = fetch_monthly_costs(cursor, account, service, name, months)
        # print(monthly_costs)
        # for month in months:
        #     if month in monthly_costs:
        #         df_result.at[_, month] = monthly_costs[month]

#     # Salvar a planilha atualizada
#     output_path = 'Consolidated_Monthly_Costs_Report.xlsx'
#     df_result.to_excel(output_path, index=False)
#     print(f"Planilha consolidada criada com sucesso: {output_path}")

except Exception as e:
    print(f"Erro: {e}")
finally:
    if conn:
        cursor.close()
        conn.close()
