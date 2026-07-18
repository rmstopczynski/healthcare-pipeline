#!/usr/bin/env bash
# Loads CSVs from MinIO into raw.* -- the "S3 -> warehouse" leg.
# Runs INSIDE the healthcare_airflow container (has boto3 + psycopg2
# installed) -- no host dependencies.
set -euo pipefail

echo "==> Loading raw.* from MinIO..."
docker exec healthcare_airflow bash -c "python3 /opt/airflow/data/load_from_object_storage.py"
