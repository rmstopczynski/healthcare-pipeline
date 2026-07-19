"""
Consumes events from the "patient-events" Kafka topic and writes them
into streaming.patient_events. This is the "Kafka Topic -> Warehouse"
leg of the roadmap's Step 7 diagram.

Deliberately a plain Kafka consumer rather than Spark Structured
Streaming -- see the main README / KAFKA_README.md for why. The core
mechanics (consumer group, offset tracking, at-least-once delivery) are
the same regardless of which client reads the topic.

Bounded, not infinite: stops after CONSUMER_TIMEOUT_MS of no new
messages, so this behaves like every other one-shot script in this
project (docker exec, runs, exits) rather than a daemon you have to
kill manually.

Run via: docker exec healthcare_airflow python3 /opt/airflow/data/kafka_consumer.py
(or scripts/run_kafka_consumer.sh, which wraps that)
"""

import json
import os

import psycopg2
from kafka import KafkaConsumer

BOOTSTRAP_SERVERS = os.environ.get("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
TOPIC = os.environ.get("KAFKA_TOPIC", "patient-events")
GROUP_ID = os.environ.get("KAFKA_GROUP_ID", "patient-events-consumer")
CONSUMER_TIMEOUT_MS = int(os.environ.get("CONSUMER_TIMEOUT_MS", "10000"))

PG_HOST = os.environ.get("PGHOST", "postgres")
PG_PORT = os.environ.get("PGPORT", "5432")
PG_USER = os.environ.get("PGUSER", "healthcare")
PG_PASSWORD = os.environ.get("PGPASSWORD", "healthcare")
PG_DB = os.environ.get("PGDATABASE", "healthcare_db")

INSERT_SQL = """
    INSERT INTO streaming.patient_events (event_id, event_type, patient_id, event_time, payload)
    VALUES (%s, %s, %s, %s, %s)
    ON CONFLICT (event_id) DO NOTHING;
"""


def main():
    consumer = KafkaConsumer(
        TOPIC,
        bootstrap_servers=BOOTSTRAP_SERVERS,
        auto_offset_reset="earliest",
        enable_auto_commit=True,
        group_id=GROUP_ID,
        value_deserializer=lambda v: json.loads(v.decode("utf-8")),
        consumer_timeout_ms=CONSUMER_TIMEOUT_MS,
    )

    conn = psycopg2.connect(
        host=PG_HOST, port=PG_PORT, user=PG_USER, password=PG_PASSWORD, dbname=PG_DB
    )
    cur = conn.cursor()

    print(f"Consuming from '{TOPIC}' on {BOOTSTRAP_SERVERS} "
          f"(group={GROUP_ID}, stops after {CONSUMER_TIMEOUT_MS}ms idle)...")

    counts = {"admission": 0, "lab_result": 0, "vital_sign": 0}
    total = 0

    for message in consumer:
        event = message.value
        cur.execute(
            INSERT_SQL,
            (
                event["event_id"],
                event["event_type"],
                event["patient_id"],
                event["event_time"],
                json.dumps(event),
            ),
        )
        counts[event["event_type"]] = counts.get(event["event_type"], 0) + 1
        total += 1

        if total % 50 == 0:
            conn.commit()
            print(f"  ... {total} events written")

    conn.commit()
    cur.close()
    conn.close()
    consumer.close()

    print(f"Done. Wrote {total} events "
          f"({counts.get('admission', 0)} admissions, "
          f"{counts.get('lab_result', 0)} lab results, "
          f"{counts.get('vital_sign', 0)} vital signs) "
          f"to streaming.patient_events.")


if __name__ == "__main__":
    main()
