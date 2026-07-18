#!/usr/bin/env bash
# Uploads the synthetic CSVs to MinIO (S3-compatible object storage).
# Runs INSIDE the healthcare_airflow container (has boto3 installed) --
# no host dependencies.
set -euo pipefail

echo "==> Uploading synthetic CSVs to MinIO..."
docker exec healthcare_airflow bash -c "python3 /opt/airflow/data/upload_to_object_storage.py"
