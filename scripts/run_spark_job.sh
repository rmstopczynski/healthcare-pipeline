#!/usr/bin/env bash
# Runs the PySpark job via `docker compose run` (not `docker exec`,
# since spark isn't a long-running service -- each run is a fresh
# one-off container, same as how spark-submit normally works).
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> Running Spark job (reads from MinIO, writes Parquet + Postgres summary)..."
# MSYS_NO_PATHCONV=1 disables Git Bash's automatic POSIX-path-to-Windows-path
# translation for this command. Without it, any argument starting with "/"
# gets silently rewritten to a Windows path before docker ever sees it --
# harmless on Mac/Linux, a no-op there, but required on Windows Git Bash.
MSYS_NO_PATHCONV=1 docker compose run --rm spark /opt/spark/bin/spark-submit /opt/spark_jobs/spark_pipeline.py
