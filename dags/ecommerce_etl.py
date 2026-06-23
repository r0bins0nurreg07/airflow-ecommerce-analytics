from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime  # <--- Corregido: antes decía 'datatime'

def print_hello():
    print("Hello, Airflow!")

with DAG(
    dag_id="ecommerce_etl",
    start_date=datetime(2026, 6, 1), # Ajustado a 2026 para que se muestre activo hoy
    schedule_interval="@daily",
    catchup=False,
) as dag:
    
    hello_task = PythonOperator(
        task_id="hello_task",
        python_callable=print_hello,
    )