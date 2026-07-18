#!/usr/bin/env bash
# Runs the full pipeline via the S3-pattern ingestion path:
#   generate CSVs -> upload to MinIO -> load from MinIO into raw ->
#   transform -> validate
#
# This is the same end state as run_all.sh, but takes the detour through
# object storage that a real cloud pipeline would (CSV -> S3 -> COPY INTO
# warehouse), rather than loading files directly off local disk.
set -euo pipefail
cd "$(dirname "$0")"

./setup_db.sh
./generate_data.sh
./upload_to_s3.sh
./load_from_s3.sh
./run_transforms.sh
./validate.sh

echo ""
echo "==> Full pipeline run (via MinIO/S3 path) complete."
echo "==> Browse the uploaded files at http://localhost:9001"
echo "==> (login: minioadmin / minioadmin)"
