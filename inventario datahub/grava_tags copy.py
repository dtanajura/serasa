import boto3
import pandas as pd
import sys

def aplicar_tags_excel(nome_planilha: str, aws_profile: str, aws_region: str):
    """
    Lê uma planilha Excel e aplica tags nos recursos AWS listados.
    """
    # Configura sessão AWS
    boto3.setup_default_session(profile_name=aws_profile, region_name=aws_region)
    client = boto3.client('resourcegroupstaggingapi')

    # Lê a planilha
    df = pd.read_excel(nome_planilha)

    if df.empty or df.shape[1] < 4:
        raise ValueError("Planilha inválida: precisa ter pelo menos 4 colunas (ARN + tags).")

    tag_keys = list(df.columns[2:]) 

    for idx, row in df.iterrows():
        arn = row.iloc[0]
        if not isinstance(arn, str) or not arn.startswith("arn:"):
            print(f"[Aviso] Linha {idx+2}: ARN inválido, ignorando.")
            continue

        tags = {key: str(row[key]) for key in tag_keys if pd.notna(row[key])}

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