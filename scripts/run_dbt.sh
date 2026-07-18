#!/usr/bin/env bash
# Runs dbt build + test INSIDE the healthcare_airflow container, which
# already has dbt-core/dbt-postgres installed. Alternative to
# run_transforms.sh (raw SQL) -- use one or the other, not both, since
# they build the same staging/analytics tables two different ways.
set -euo pipefail

echo "==> Running dbt models..."
docker exec healthcare_airflow bash -c "cd /opt/airflow/dbt/healthcare_dbt && dbt run --profiles-dir /opt/airflow/airflow_profiles"

echo "==> Running dbt tests..."
docker exec healthcare_airflow bash -c "cd /opt/airflow/dbt/healthcare_dbt && dbt test --profiles-dir /opt/airflow/airflow_profiles"

echo "==> dbt run + test complete."
