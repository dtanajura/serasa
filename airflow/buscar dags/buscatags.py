import boto3
import re
import requests
import json
import base64

# ========================
# CONFIG
# ========================
PROFILE = "datahubprod"
BUCKET = "airflow-mwaa97d2522122f0f00b-prod-415071355886"
PREFIX = "dags/"
MWAA_ENV = "airflow-mwaa-datahub-prod"

# ========================
# SESSION
# ========================
session = boto3.Session(profile_name=PROFILE)
s3 = session.client("s3")
mwaa = session.client("mwaa")

print("🔍 Iniciando auditoria (READ-ONLY)...\n")

# ========================
# 1. LISTAR DAGS
# ========================
dag_files = []

paginator = s3.get_paginator("list_objects_v2")
for page in paginator.paginate(Bucket=BUCKET, Prefix=PREFIX):
    for obj in page.get("Contents", []):
        key = obj["Key"]
        if key.endswith(".py"):
            dag_files.append(key)

print(f"📦 Arquivos DAG encontrados: {len(dag_files)}")

# ========================
# 2. EXTRAIR INFO DAS DAGS
# ========================
dag_map = []

dag_pattern = r'dag_id\s*=\s*[\'"]([^\'"]+)[\'"]'
conn_pattern = r'emr_conn_id\s*=\s*[\'"]([^\'"]+)[\'"]'

for key in dag_files:
    try:
        obj = s3.get_object(Bucket=BUCKET, Key=key)
        content = obj["Body"].read().decode("utf-8", errors="ignore")

        dag_ids = re.findall(dag_pattern, content)
        conn_ids = re.findall(conn_pattern, content)

        for dag_id in dag_ids:
            for conn_id in conn_ids:
                dag_map.append({
                    "dag_id": dag_id,
                    "conn_id": conn_id,
                    "file": key
                })

    except Exception as e:
        print(f"⚠️ Erro ao processar {key}: {e}")

print(f"🔗 Relações DAG → EMR connection: {len(dag_map)}")

# ========================
# 3. OBTER CONNECTIONS MWAA
# ========================
print("🔐 Lendo connections (MWAA CLI)...")

token = mwaa.create_cli_token(Name=MWAA_ENV)

url = f"https://{token['WebServerHostname']}/aws_mwaa/cli"

response = requests.post(
    url,
    headers={"Authorization": f"Bearer {token['CliToken']}"},
    data="connections export"
)

if response.status_code != 200:
    raise Exception("Erro ao chamar MWAA CLI")

decoded = base64.b64decode(response.text).decode("utf-8")
connections_json = json.loads(decoded)

print(f"📡 Connections carregadas: {len(connections_json)}")

# ========================
# 4. INDEXAR TAGS
# ========================
conn_env_map = {}

for conn in connections_json:
    conn_id = conn.get("conn_id")
    extra = conn.get("extra")

    env_value = None

    if extra:
        try:
            extra_json = json.loads(extra)

            # pode estar em formatos diferentes
            tags = extra_json.get("Tags") or extra_json.get("tags") or []

            for tag in tags:
                if tag.get("Key") == "Environment":
                    env_value = tag.get("Value")

        except:
            pass

    conn_env_map[conn_id] = env_value

# ========================
# 5. RESULTADO
# ========================
print("\n📊 RESULTADO FINAL\n")

count_problem = 0

for item in dag_map:
    dag = item["dag_id"]
    conn = item["conn_id"]
    file = item["file"]

    env = conn_env_map.get(conn, "N/A")

    is_problem = env and env.upper() == "PROD"

    if is_problem:
        count_problem += 1
        status = "❌ PROD (ajustar)"
    else:
        status = "✅ OK"

    print(f"DAG: {dag}")
    print(f"  File: {file}")
    print(f"  Connection: {conn}")
    print(f"  Environment: {env}")
    print(f"  Status: {status}")
    print("-" * 60)

print("\n==============================")
print(f"❌ Total com problema: {count_problem}")
print("==============================")