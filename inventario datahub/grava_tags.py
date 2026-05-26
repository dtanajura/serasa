import boto3
import pandas as pd
import sys

def aplicar_tags_excel(nome_planilha: str, aws_profile: str, aws_region: str):
    """
    Lê uma planilha Excel e aplica tags nos recursos AWS listados.
    Todos os valores são tratados como texto, preservando zeros à esquerda e removendo decimais desnecessários.
    """
    # Configura sessão AWS
    boto3.setup_default_session(profile_name=aws_profile, region_name=aws_region)
    client = boto3.client('resourcegroupstaggingapi')

    # Lê a planilha forçando tudo como texto
    df = pd.read_excel(nome_planilha, dtype=str)

    if df.empty or df.shape[1] < 4:
        raise ValueError("Planilha inválida: precisa ter pelo menos 4 colunas (ARN + tags).")

    # Colunas de tags (a partir da quarta coluna)
    tag_keys = list(df.columns[3:])

    for idx, row in df.iterrows():
        arn = str(row.iloc[0]).strip()
        if not arn.startswith("arn:"):
            print(f"[Aviso] Linha {idx+2}: ARN inválido, ignorando.")
            continue

        tags = {}
        for key in tag_keys:
            value = row[key]
            if pd.notna(value):
                # Remove espaços e converte para string
                value_str = str(value).strip()
                # Remove ".0" se existir
                if value_str.endswith(".0"):
                    value_str = value_str[:-2]
                tags[key] = value_str

        if tags:
            try:
                client.tag_resources(ResourceARNList=[arn], Tags=tags)
                print(f"[OK] Tags aplicadas no recurso: {arn}")
            except Exception as e:
                print(f"[Erro] Falha ao aplicar tags no recurso {arn}: {e}")
        else:
            print(f"[Aviso] Nenhuma tag para aplicar no recurso: {arn}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Uso: grava_tags.py <planilha.xlsx> <aws_profile> <aws_region>")
        sys.exit(1)

    nome_planilha = sys.argv[1]
    aws_profile = sys.argv[2]
    aws_region = sys.argv[3]

    aplicar_tags_excel(nome_planilha, aws_profile, aws_region)
