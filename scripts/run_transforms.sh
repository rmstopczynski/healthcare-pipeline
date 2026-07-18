#!/usr/bin/env bash
# Re-runs the staging + analytics transforms now that raw has data.
# Same files as setup_db.sh -- running them again is safe, they
# TRUNCATE before inserting.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> Transforming raw -> staging..."
docker exec -i healthcare_pg psql -U healthcare -d healthcare_db < sql/02_staging_tables.sql

echo "==> Transforming staging -> analytics..."
docker exec -i healthcare_pg psql -U healthcare -d healthcare_db < sql/03_analytics_tables.sql

echo "==> Transforms complete."
