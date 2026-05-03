from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

PROJECT_DIR = "/opt/airflow/project"

with DAG(
    dag_id="financial_mlops_training_pipeline",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["mlops", "financial", "training"],
) as dag:

    ingest = BashOperator(
        task_id="ingest_market_data",
        bash_command=f"cd {PROJECT_DIR} && PYTHONPATH=. python src/data_ingestion.py",
    )

    features = BashOperator(
        task_id="build_features",
        bash_command=f"cd {PROJECT_DIR} && PYTHONPATH=. python src/feature_engineering.py",
    )

    train = BashOperator(
        task_id="train_model_mlflow",
        bash_command=f"cd {PROJECT_DIR} && PYTHONPATH=. MLFLOW_TRACKING_URI=http://mlflow:5001 python src/train.py",
    )

    monitor = BashOperator(
        task_id="run_evidently_monitoring",
        bash_command=f"cd {PROJECT_DIR} && PYTHONPATH=. python monitoring/run_evidently.py",
    )

    ingest >> features >> train >> monitor