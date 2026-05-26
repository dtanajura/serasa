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

    # Define o período de tempo para a consulta (a partir de 01/10 até hoje)
    end_date = datetime.today().date()
    start_date = datetime.strptime('2023-10-01', '%Y-%m-%d').date()

    print(f"Processando: {profile_name}, {tag_name}")
    # Faz a consulta ao Cost Explorer para obter os custos dia-a-dia
    try:
        response = ce_client.get_cost_and_usage(
            TimePeriod={
                'Start': start_date.strftime('%Y-%m-%d'),
                'End': end_date.strftime('%Y-%m-%d')
            },
            Granularity='DAILY',
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
    daily_costs = {day: 0.0 for day in [(start_date + timedelta(days=i)).strftime('%Y-%m-%d') for i in range((end_date - start_date).days + 1)]}

    # Processa os resultados da consulta
    for result in response['ResultsByTime']:
        time_period = result['TimePeriod']
        day = time_period['Start']  # Extrai o dia no formato 'YYYY-MM-DD'
        if 'Groups' in result and result['Groups']:  # Verifica se 'Groups' existe e não está vazio
            for group in result['Groups']:
                service = group['Keys'][0]
                amount = float(group['Metrics']['UnblendedCost']['Amount'])
                total_cost += amount
                services_found.add(service)
                daily_costs[day] += amount
                print(f"Período: {time_period}, Serviço: {service}, Valor: {amount}")
        else:
            print(f"Período: {time_period}, Nenhum serviço encontrado")

    # Exibe o custo total e os serviços encontrados
    print(f"Custo total: {total_cost}")
    print(f"Serviços encontrados: {', '.join(services_found)}")

    return total_cost, services_found, daily_costs

def process_excel_and_generate_csv(excel_file):
    try:
        # Abre o arquivo Excel
        wb = openpyxl.load_workbook(excel_file)
        ws = wb.active
    except Exception as e:
        print(f"Erro ao abrir o arquivo Excel {excel_file}: {e}")
        return

    # Gera uma lista de todos os dias no período, incluindo o dia corrente
    end_date = datetime.today().date()
    start_date = datetime.strptime('2023-10-01', '%Y-%m-%d').date()
    all_days = [(start_date + timedelta(days=i)).strftime('%Y-%m-%d') for i in range((end_date - start_date).days + 1)]

    # Cria o arquivo CSV e escreve os dados
    with open('cost_report.csv', mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file, delimiter=';')
        
        # Escreve o cabeçalho
        header = ['Profile', 'Tag Name', 'Total Cost', 'Services Found'] + all_days
        writer.writerow(header)
        
        # Processa cada linha do Excel
        for row in ws.iter_rows(min_row=2, values_only=True):
            profile_name, tag_name = row[1], row[4]
            total_cost, services_found, daily_costs = get_cost_and_usage(profile_name, tag_name)
            if total_cost is None:
                continue
            
            # Escreve os dados no CSV
            csv_row = [profile_name, tag_name, f"{total_cost:,.2f}".replace(",", "X").replace(".", ",").replace("X", "."), ', '.join(services_found)]
            for day in all_days:
                amount = daily_costs[day]
                # Converte o valor para float no formato brasileiro ##,00 sem pontos
                amount_brl = f"{amount:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
                csv_row.append(amount_brl)
            writer.writerow(csv_row)

# Nome do arquivo Excel
excel_file = 'Bain Action Plan.xlsx'

# Processa o arquivo Excel e gera o CSV
process_excel_and_generate_csv(excel_file)

print("Relatório de custos gerado: cost_report.csv")
