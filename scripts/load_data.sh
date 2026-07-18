#!/usr/bin/env bash
# Generates synthetic CSVs and loads them into raw.* -- runs INSIDE the
# healthcare_airflow container, which already has python3 + faker
# installed. Your host machine doesn't need Python at all.
set -euo pipefail

echo "==> Generating synthetic data (inside the airflow container)..."
docker exec healthcare_airflow bash -c "cd /opt/airflow/data && python3 generate_synthetic_data.py"

echo "==> Loading into raw.* (inside the airflow container)..."
docker exec healthcare_airflow bash -c "cd /opt/airflow/data && PGPASSWORD=healthcare psql -h postgres -p 5432 -U healthcare -d healthcare_db -f /opt/airflow/load_synthetic_data.sql"

echo "==> Data loaded."
