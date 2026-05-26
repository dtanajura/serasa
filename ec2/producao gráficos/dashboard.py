import streamlit as st
import pandas as pd
from sqlalchemy import create_engine
import calendar

def load_data(query):
    """Carrega os dados do banco de dados PostgreSQL usando uma consulta específica."""
    db_config = {
        'host': 'dev-hub-portal-qa.cbjrpisgumc2.sa-east-1.rds.amazonaws.com',
        'user': 'app-user',
        'password': '123Trocar$',
        'dbname': 'custos_nike'
    }
    DATABASE_URL = f"postgresql://{db_config['user']}:{db_config['password']}@{db_config['host']}/{db_config['dbname']}"
    engine = create_engine(DATABASE_URL)
    with engine.connect() as conn:
        return pd.read_sql(query, conn)

def get_query(graph_type, graph_types):
    """Retorna a query SQL baseada no tipo de gráfico selecionado."""
    if graph_type == graph_types[0]:
        return """
        SELECT a.account_profile, a.account_name, ac.unblended_cost, ac.date_register
        FROM account_costs ac
        JOIN accounts a ON ac.account_id = a.account_id
        ORDER BY a.account_profile, ac.date_register;
        """
    elif graph_type == graph_types[1]:
        return """
        SELECT r.account_id, a.account_name, r.service, r.unblended_cost, r.date_register
        FROM resource_costs r
        JOIN accounts a ON r.account_id = a.account_id
        ORDER BY a.account_profile, r.date_register, r.unblended_cost DESC;
        """
    elif graph_type == graph_types[2]:
        # Adicione sua própria consulta aqui
        return "Sua outra consulta SQL"

def create_graph_options(graph_types,container_graph):
    """Cria um dropdown no sidebar para selecionar o tipo de gráfico."""

    container_graph.subheader("Selecionar o Gráfico")
    selected_graph_type = container_graph.radio("Gráfico:", graph_types, index=0, label_visibility="visible")
    # selected_graph_type = st.sidebar.selectbox("Selecione o tipo de gráfico", graph_types)

    return selected_graph_type

def plot_graph_0(df):
    """Plota um gráfico de linhas com múltiplas séries baseado nos dados filtrados."""
    st.subheader("Custos mensais das contas")
    if not df.empty:
        st.line_chart(df.pivot_table(values='unblended_cost', index='date_register', columns='account_name', aggfunc='sum'))
    else:
        st.error("Não há dados para mostrar com os filtros selecionados.")


def plot_graph_1(df):
    """Plota um gráfico de barras empilhadas com destaque para os 3 principais serviços e agrupando os demais como 'Outros Serviços'."""
    df = df.copy()
    account_name = df["account_name"].dropna().unique()
    st.subheader(f"Custos mensais da conta {account_name[0]} por Serviço")

    df["date_register"] = pd.to_datetime(df["date_register"])

    # Formatar mês e ano para exibição
    df["month_year"] = df["date_register"].dt.strftime('%Y.%m')

    service_totals = df.groupby('service')['unblended_cost'].sum().sort_values(ascending=False)
    top_services = service_totals.head(5).index
    df['service'] = df['service'].apply(lambda x: x if x in top_services else 'Outros Serviços')

    # Agrupar dados para o pivot mantendo a ordenação correta
    pivot_df = df.pivot_table(values='unblended_cost', index="month_year", columns='service', aggfunc='sum', fill_value=0)

    st.bar_chart(pivot_df)

def create_filter_graph(df,container_filter,graph_type):
    """Cria uma caixa de seleção no sidebar para filtrar dados nos gráficos."""
    if graph_type == 0:
        account_profiles = df["account_profile"].unique()
        selected_accounts = container_filter.multiselect("Selecione suas contas", account_profiles, account_profiles[0], max_selections=5)
        return selected_accounts
    elif graph_type == 1:
        account_names = df["account_name"].dropna().unique()
        selected_accounts = container_filter.selectbox("Selecione a conta", account_names)
        return selected_accounts

def filter_data(df, selected_accounts,graph_type):
    """Filtra o DataFrame baseado nos perfis de conta selecionados."""
    if graph_type == 0:
        return df[df["account_profile"].isin(selected_accounts)]
    elif graph_type == 1:
        return df[df["account_name"] == selected_accounts]

def main():
    graph_types = ["Custo Mensal das Contas","Custos Mensais Top Serviços", "Outro Gráfico"]  # Adicione mais tipos conforme necessário
    st.set_page_config(layout="wide", page_title="Dashboard Custos Nike")
    st.title('Dashboard Custos Contas Nike')
    container1 = st.sidebar.container(border=True)
    container2 = st.sidebar.container(border=True)
    selected_graph_type = create_graph_options(graph_types,container1)
    query = get_query(selected_graph_type, graph_types)
    df = load_data(query)

    if selected_graph_type == graph_types[0]:
        selected_accounts = create_filter_graph(df,container2,0)
        if selected_accounts:
            filtered_df = filter_data(df, selected_accounts,0)
            plot_graph_0(filtered_df)
    elif selected_graph_type == graph_types[1]:
        selected_accounts = create_filter_graph(df,container2,1)
        if selected_accounts:
            filtered_df = filter_data(df, selected_accounts,1)
            plot_graph_1(filtered_df)
    elif selected_graph_type == graph_types[2]:
        # Adicione a função para plotar o outro gráfico aqui
        pass

    st.dataframe(filtered_df, use_container_width=True)

if __name__ == "__main__":
    main()

