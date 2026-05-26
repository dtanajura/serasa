import boto3
from datetime import datetime, timedelta
import sys
import csv
import openpyxl

def get_cost_and_usage(profile_name, tag_name):
    try:
        # Configura o profile da AWS
        session = boto3.Session(profile_name=profile_name)
        ce_client = session.client('ce')
    except Exception as e:
        print(f"Erro ao configurar o profile {profile_name}: {e}")
        return None, None, None

    # Define o período de tempo para a consulta (últimos 12 meses + mês corrente)
    end_date = datetime.today().date()
    start_date = end_date - timedelta(days=365)

    print(f"Processando: {profile_name}, {tag_name}")
    # Faz a consulta ao Cost Explorer para obter os custos mês a mês
    try:
        response = ce_client.get_cost_and_usage(
            TimePeriod={
                'Start': start_date.strftime('%Y-%m-%d'),
                'End': end_date.strftime('%Y-%m-%d')
            },
            Granularity='MONTHLY',
            Filter={
                'Tags': {
                    'Key': 'Name',
                    'Values': [tag_name]
                }
            },
            Metrics=['UnblendedCost'],
            GroupBy=[
                {
                    'Type': 'DIMENSION',
                    'Key': 'SERVICE'
                }
            ]
        )
    except Exception as e:
        print(f"Erro ao obter custos para {profile_name} com a tag {tag_name}: {e}")
        return None, None, None

    # Inicializa variáveis para armazenar o custo total e os serviços encontrados
    total_cost = 0.0
    services_found = set()
    monthly_costs = {month: 0.0 for month in [(start_date + timedelta(days=i*30)).strftime('%Y-%m') for i in range(13)]}

    # Processa os resultados da consulta
    for result in response['ResultsByTime']:
        time_period = result['TimePeriod']
        month = time_period['Start'][:7]  # Extrai o mês no formato 'YYYY-MM'
        if 'Groups' in result and result['Groups']:  # Verifica se 'Groups' existe e não está vazio
            for group in result['Groups']:
                service = group['Keys'][0]
                amount = float(group['Metrics']['UnblendedCost']['Amount'])
                total_cost += amount
                services_found.add(service)
                monthly_costs[month] += amount
                print(f"Período: {time_period}, Serviço: {service}, Valor: {amount}")
        else:
            print(f"Período: {time_period}, Nenhum serviço encontrado")

    # Exibe o custo total e os serviços encontrados
    print(f"Custo total: {total_cost}")
    print(f"Serviços encontrados: {', '.join(services_found)}")

    return total_cost, services_found, monthly_costs

def process_excel_and_generate_csv(excel_file):
    try:
        # Abre o arquivo Excel
        wb = openpyxl.load_workbook(excel_file)
        ws = wb.active
    except Exception as e:
        print(f"Erro ao abrir o arquivo Excel {excel_file}: {e}")
        return

    # Gera uma lista de todos os meses no período, incluindo o mês corrente
    end_date = datetime.today().date()
    start_date = end_date - timedelta(days=365)
    all_months = [(start_date + timedelta(days=i*30)).strftime('%Y-%m') for i in range(13)]

    # Cria o arquivo CSV e escreve os dados
    with open('cost_report.csv', mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file, delimiter=';')
        
        # Escreve o cabeçalho
        header = ['Profile', 'Tag Name', 'Total Cost', 'Services Found'] + all_months
        writer.writerow(header)
        
        # Processa cada linha do Excel
        for row in ws.iter_rows(min_row=2, values_only=True):
            profile_name, tag_name = row[1], row[4]
            total_cost, services_found, monthly_costs = get_cost_and_usage(profile_name, tag_name)
            if total_cost is None:
                continue
            
            # Escreve os dados no CSV
            csv_row = [profile_name, tag_name, f"{total_cost:,.2f}".replace(",", "X").replace(".", ",").replace("X", "."), ', '.join(services_found)]
            for month in all_months:
                amount = monthly_costs[month]
                # Converte o valor para float no formato brasileiro ##,00 sem pontos
                amount_brl = f"{amount:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
                csv_row.append(amount_brl)
            writer.writerow(csv_row)

# Nome do arquivo Excel
excel_file = 'Bain Action Plan.xlsx'

# Processa o arquivo Excel e gera o CSV
process_excel_and_generate_csv(excel_file)

print("Relatório de custos gerado: cost_report.csv")
