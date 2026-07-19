#!/usr/bin/env bash
# Publishes simulated patient events to Kafka. Runs INSIDE the
# healthcare_airflow container (has kafka-python installed) -- no host
# dependencies.
#
# NOTE: uses `bash -c "python3 /opt/..."` (command starting with a
# non-slash token) rather than a bare path argument, to avoid Git
# Bash's MSYS path-translation bug documented in the main README's
# Challenges section.
set -euo pipefail

echo "==> Publishing simulated patient events to Kafka..."
docker exec healthcare_airflow bash -c "python3 /opt/airflow/data/kafka_producer.py"
