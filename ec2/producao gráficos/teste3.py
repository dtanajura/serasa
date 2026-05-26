import boto3
from datetime import datetime, timedelta
import sys
import csv

def get_cost_and_usage(profile_name, tag_name):
    # Configura o profile da AWS
    session = boto3.Session(profile_name=profile_name)
    ce_client = session.client('ce')

    # Define o período de tempo para a consulta (últimos 12 meses + mês corrente)
    end_date = datetime.today().date()
    start_date = end_date - timedelta(days=365)

    # Faz a consulta ao Cost Explorer para obter os custos mês a mês
    print(f"Tô aqui {tag_name} {profile_name}")
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
    # Adicione esta linha para verificar o conteúdo completo da resposta
    print(response)


    # response = ce_client.get_cost_and_usage(
    #     TimePeriod={
    #         'Start': start_date.strftime('%Y-%m-%d'),
    #         'End': end_date.strftime('%Y-%m-%d')
    #     },
    #     Granularity='MONTHLY',
    #     Filter={
    #         'Tags': {
    #             'Key': 'Name',
    #             'Values': [tag_name]
    #         }
    #     },
    #     Metrics=['UnblendedCost']
    #     # GroupBy=[
    #     #     {
    #     #         'Type': 'DIMENSION',
    #     #         'Key': 'SERVICE'
    #     #     }
    #     # ]
    # )

    # Organiza os custos por serviço
    service_costs = {}
    for result in response['ResultsByTime']:
        time_period = result['TimePeriod']
        for group in result['Groups']:
            service = group['Keys'][0]
            amount = group['Metrics']['UnblendedCost']['Amount']
            if service not in service_costs:
                service_costs[service] = []
            service_costs[service].append((time_period, amount))

    # Gera uma lista de todos os meses no período, incluindo o mês corrente
    all_months = [(start_date + timedelta(days=i*30)).strftime('%Y-%m') for i in range(13)]

    # Cria o arquivo CSV e escreve os dados
    with open('cost_report.csv', mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file, delimiter=';')
        
        # Escreve o cabeçalho
        header = ['Profile', 'Tag Name', 'Service'] + all_months
        writer.writerow(header)
        
        # Escreve os dados
        for service, costs in service_costs.items():
            row = [profile_name, tag_name, service]
            for month in all_months:
                amount = "0"
                for time_period, cost in costs:
                    if time_period['Start'].startswith(month):
                        amount = cost
                        break
                # Converte o valor para float no formato brasileiro US$ ##,00 sem pontos
                amount_float = float(amount)
                amount_brl = f"US$ {amount_float:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
                row.append(amount_brl)
            writer.writerow(row)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python teste3.py <profile_name> <tag_name>")
        sys.exit(1)

    profile_name = sys.argv[1]
    tag_name = sys.argv[2]
    get_cost_and_usage(profile_name, tag_name)

print("Relatório de custos gerado: cost_report.csv")
