import io
from datetime import datetime
import pandas as pd

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook

# =========================
# CONFIG
# =========================
CONN_ID = "external_postgres"
CSV_PATH = "/opt/airflow/data/e-commerce-data.csv"

EXPECTED_COLUMNS = [
    "invoiceno", "stockcode", "description", "quantity",
    "invoicedate", "unitprice", "customerid", "country",
]

# =========================
# FUNCIONES AUXILIARES
# =========================
def load_bronze():
    hook = PostgresHook(postgres_conn_id=CONN_ID)
    conn = hook.get_conn()
    cur = conn.cursor()

    # Leemos el DDL de creación cruda (asegúrate de que 01_bronze.sql use SCHEMA bronze)
    with open("/opt/airflow/sql/01_bronze.sql", "r") as f:
        cur.execute(f.read())
    conn.commit()

    # Procesamiento con Pandas
    df = pd.read_csv(CSV_PATH, encoding="ISO-8859-1")
    df.columns = [c.strip().lower().replace(" ", "") for c in df.columns]
    df = df[EXPECTED_COLUMNS]

    # Carga eficiente a Postgres
    buffer = io.StringIO()
    df.to_csv(buffer, index=False, header=False)
    buffer.seek(0)

    cur.copy_expert(
        """
        COPY bronze.ecommerce
        (invoiceno, stockcode, description, quantity,
         invoicedate, unitprice, customerid, country)
        FROM STDIN WITH CSV
        """,
        buffer,
    )
    conn.commit()
    cur.close()
    conn.close()
    print(f"Bronze cargado correctamente: {len(df)} filas")

# =========================
# DAG DEFINITION
# =========================
with DAG(
    dag_id="ecommerce_etl",
    description="Pipeline medallion ecommerce (Bronze → Silver → Gold)",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=["ecommerce", "medallion"],
    template_searchpath=["/opt/airflow"], 
) as dag:

    bronze_layer = PythonOperator(
        task_id="bronze_layer",
        python_callable=load_bronze,
    )

    silver_layer = PostgresOperator(
        task_id="silver_layer",
        postgres_conn_id=CONN_ID,
        sql="sql/02_silver.sql",
    )

    gold_layer = PostgresOperator(
        task_id="gold_layer",
        postgres_conn_id=CONN_ID,
        sql="sql/03_gold.sql",
    )

    # ORDEN DE EJECUCIÓN
    bronze_layer >> silver_layer >> gold_layer