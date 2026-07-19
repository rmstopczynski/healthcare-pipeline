#!/usr/bin/env bash
# Runs the full Kafka demo: publish simulated events, then consume them
# into Postgres. This is the complete "Patient Event -> Kafka Topic ->
# Warehouse" pattern in one command.
set -euo pipefail
cd "$(dirname "$0")"

./run_kafka_producer.sh
./run_kafka_consumer.sh

echo ""
echo "==> Kafka streaming demo complete."
echo "==> Check streaming.patient_events in Postgres, or browse the"
echo "==> 'patient-events' topic directly at http://localhost:8084 (Kafka UI)."
