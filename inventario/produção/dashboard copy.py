import streamlit as st
import pandas as pd
from sqlalchemy import create_engine

# Decorador para caching, ajustado para não incluir engine no cache
@st.cache_data(show_spinner=False, ttl=3600)
def load_data():
    """Carrega os dados do banco de dados PostgreSQL."""
    # Configurações do banco de dados
    db_config = {
        'host': 'dev-hub-portal-qa.cbjrpisgumc2.sa-east-1.rds.amazonaws.com',
        'user': 'app-user',
        'password': '123Trocar$',
        'dbname': 'custos_nike'
    }
    # Criação da string de conexão e do engine do SQLAlchemy dentro da função
    DATABASE_URL = f"postgresql://{db_config['user']}:{db_config['password']}@{db_config['host']}/{db_config['dbname']}"
    engine = create_engine(DATABASE_URL)

    query = """
    SELECT a.account_profile, a.account_name, ac.unblended_cost, ac.date_register
    FROM account_costs ac
    JOIN accounts a ON ac.account_id = a.account_id
    ORDER BY a.account_profile, ac.date_register;
    """
    with engine.connect() as conn:
        return pd.read_sql(query, conn)

def create_select_box(df):
    """Cria uma caixa de seleção múltipla no sidebar para filtrar por perfis de conta."""
    account_profiles = df["account_profile"].unique()
    selected_accounts = st.sidebar.multiselect("Selecione suas contas", account_profiles, default=None)
    return selected_accounts

def filter_data(df, selected_accounts):
    """Filtra o DataFrame baseado nos perfis de conta selecionados."""
    return df[df["account_profile"].isin(selected_accounts)]

def plot_data(df):
    """Plota um gráfico de linhas com múltiplas séries baseado nos dados filtrados."""
    st.subheader("Custos mensais das contas")
    if not df.empty:
        st.line_chart(df.pivot_table(values='unblended_cost', index='date_register', columns='account_name', aggfunc='sum'))
    else:
        st.error("Não há dados para mostrar com os filtros selecionados.")

def main():
    st.set_page_config(layout="wide", page_title="Dashboard Custos Nike")
    st.title('Dashboard Custos Contas Nike')

    # Carregamento de dados
    df = load_data()

    with st.sidebar:
        st.title("Filtros")
        # Criação da seleção múltipla de perfis de conta
        selected_accounts = create_select_box(df)

    # Filtragem de dados com base na seleção
    if selected_accounts:
        filtered_df = filter_data(df, selected_accounts)
        plot_data(filtered_df)
        st.dataframe(filtered_df, use_container_width=True)

if __name__ == "__main__":
    main()

