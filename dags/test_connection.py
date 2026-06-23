from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datetime import datetime

def check_db():
    # Esto intenta conectarse usando la conexión 'postgres_default' que acabas de guardar
    hook = PostgresHook(postgres_conn_id='postgres_default')
    conn = hook.get_conn()
    cursor = conn.cursor()
    cursor.execute("SELECT 1;")
    result = cursor.fetchone()
    print(f"Conexión exitosa, resultado: {result}")

with DAG(
    dag_id='test_db_connection', 
    start_date=datetime(2026, 1, 1), 
    schedule_interval=None, 
    catchup=False
) as dag:
    task = PythonOperator(task_id='test_db', python_callable=check_db)