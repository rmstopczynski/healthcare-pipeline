#!/usr/bin/env bash
# Runs the ENTIRE pipeline end to end with one command: schema setup,
# data generation/load, transforms, and validation. Requires nothing on
# the host except Docker Desktop and the containers already running
# (docker compose up -d --build).
set -euo pipefail
cd "$(dirname "$0")"

./setup_db.sh
./load_data.sh
./run_transforms.sh
./validate.sh

echo ""
echo "==> Full pipeline run complete."
echo "==> (This ran the raw-SQL transform path. To run the dbt path instead"
echo "==>  of/in addition to sql/02+03, use ./run_dbt.sh.)"
