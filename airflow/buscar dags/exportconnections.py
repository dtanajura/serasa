from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.models import Connection
from airflow.settings import Session
from datetime import datetime
import json


def export_connections_to_s3():
    session = Session()
    conns = session.query(Connection).all()

    result = []

    for c in conns:
        if c.conn_type != "emr":
            continue

        env_value = None

        if c.extra:
            try:
                extra_json = json.loads(c.extra)
                tags = extra_json.get("Tags") or extra_json.get("tags") or []

                for tag in tags:
                    if tag.get("Key") == "Environment":
                        env_value = tag.get("Value")

            except Exception:
                pass

        # 🔥 REGRA PRINCIPAL
        # só pega se for diferente de prd (case sensitive)
        if env_value != "prd":
            result.append({
                "conn_id": c.conn_id,
                "environment": env_value
            })

    print(f"Total EMR connections com problema: {len(result)}")

    print("==== CONNECTIONS COM ENVIRONMENT DIFERENTE DE 'prd' ====")
    print(json.dumps(result, indent=2))


with DAG(
    dag_id="export_emr_connections_invalid_env",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
):
    PythonOperator(
        task_id="export",
        python_callable=export_connections_to_s3
    )