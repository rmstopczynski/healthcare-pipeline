#!/usr/bin/env bash
# Builds the raw/staging/analytics schema and tables.
# Runs psql INSIDE the healthcare_pg container -- your host machine
# doesn't need psql installed at all. Local .sql files are piped in
# over stdin (docker exec -i), so nothing needs to be pre-mounted.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> Setting up schemas..."
docker exec -i healthcare_pg psql -U healthcare -d healthcare_db < sql/00_setup_schemas.sql

echo "==> Creating raw tables..."
docker exec -i healthcare_pg psql -U healthcare -d healthcare_db < sql/01_raw_tables.sql

echo "==> Creating staging tables (empty until data is loaded)..."
docker exec -i healthcare_pg psql -U healthcare -d healthcare_db < sql/02_staging_tables.sql

echo "==> Creating analytics tables (empty until data is loaded)..."
docker exec -i healthcare_pg psql -U healthcare -d healthcare_db < sql/03_analytics_tables.sql

echo "==> Schema setup complete."
