#!/usr/bin/env bash
# Prints row counts across raw/staging/analytics to confirm the pipeline
# ran cleanly, with no data loss between layers.
set -euo pipefail
cd "$(dirname "$0")/.."

docker exec -i healthcare_pg psql -U healthcare -d healthcare_db < sql/04_validate_migration.sql
