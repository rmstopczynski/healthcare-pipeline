#!/usr/bin/env bash
# Consumes patient events from Kafka into streaming.patient_events.
# Runs INSIDE the healthcare_airflow container -- no host dependencies.
# Bounded: exits automatically after ~10s of no new messages.
set -euo pipefail

echo "==> Consuming patient events from Kafka into Postgres..."
docker exec healthcare_airflow bash -c "python3 /opt/airflow/data/kafka_consumer.py"
