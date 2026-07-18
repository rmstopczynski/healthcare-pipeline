"""
End-to-end healthcare pipeline DAG.

    generate_synthetic_data
            |
            v
        load_raw_data
            |
            v
          dbt_run
            |
            v
          dbt_test
            |
            v
     validate_migration

Each task is a thin BashOperator wrapping a command you already run
manually -- the DAG's job is sequencing, retries, and giving you a
scheduled, monitored, one-click "run the whole pipeline" button instead
of running five commands by hand in order.
"""

from __future__ import annotations

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

PG_HOST = "postgres"          # docker-compose service name, not 127.0.0.1
PG_CONN = f"-h {PG_HOST} -p 5432 -U healthcare -d healthcare_db"
DBT_PROJECT_DIR = "/opt/airflow/dbt/healthcare_dbt"
DBT_PROFILES_DIR = "/opt/airflow/airflow_profiles"

default_args = {
    "owner": "healthcare-pipeline",
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

with DAG(
    dag_id="healthcare_pipeline",
    description="RAW -> STAGING -> ANALYTICS healthcare pipeline, end to end",
    default_args=default_args,
    schedule="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["healthcare", "portfolio"],
) as dag:

    generate_synthetic_data = BashOperator(
        task_id="generate_synthetic_data",
        bash_command="cd /opt/airflow/data && python3 generate_synthetic_data.py",
    )

    load_raw_data = BashOperator(
        task_id="load_raw_data",
        bash_command=(
            f"cd /opt/airflow/data && "
            f"PGPASSWORD=healthcare psql {PG_CONN} -f /opt/airflow/load_synthetic_data.sql"
        ),
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt run --profiles-dir {DBT_PROFILES_DIR}"
        ),
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt test --profiles-dir {DBT_PROFILES_DIR}"
        ),
    )

    validate_migration = BashOperator(
        task_id="validate_migration",
        bash_command=(
            f"PGPASSWORD=healthcare psql {PG_CONN} -f /opt/airflow/sql/04_validate_migration.sql"
        ),
    )

    generate_synthetic_data >> load_raw_data >> dbt_run >> dbt_test >> validate_migration
