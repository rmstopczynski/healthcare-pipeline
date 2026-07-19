#!/usr/bin/env bash
# Runs the full pipeline via the S3 path, then the Spark job on top --
# the complete "files -> MinIO -> Postgres, MinIO -> Spark -> Postgres"
# picture in one command.
set -euo pipefail
cd "$(dirname "$0")"

./run_all_via_s3.sh
./run_spark_job.sh

echo ""
echo "==> Full pipeline (S3 path + Spark) complete."
echo "==> Check spark_analytics.monthly_hospital_summary in Postgres,"
echo "==> and s3://healthcare-raw-files/processed/ in MinIO (localhost:9001)"
echo "==> for the partitioned Parquet output."
