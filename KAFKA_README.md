# Kafka Streaming Layer

Adds real-time-style event ingestion: a producer simulates patient
events (admissions, lab results, vital signs) and publishes them to a
Kafka topic; a consumer reads them into Postgres. This is the "Patient
Event -> Kafka Topic -> Warehouse" pattern from the roadmap.

## Why a plain Kafka consumer instead of Spark Structured Streaming

The roadmap diagram specifies Kafka -> **Spark Streaming** -> warehouse.
Spark's Kafka connector needs a second, separately version-pinned JAR
chain (`spark-sql-kafka`, matching `kafka-clients`, `commons-pool2`) on
top of the Hadoop-AWS/JDBC jars already in `Dockerfile.spark` from the
Spark layer -- genuinely one of the more fragile Spark integrations to
get exactly right, and we'd already been through two rounds of
JAR/image-version debugging for the S3 connector. A plain Kafka consumer
(`kafka-python`) demonstrates the same core mechanics -- topics,
partitions, consumer groups, offset commits, at-least-once delivery --
without that specific risk. Under the hood, Spark's Kafka source *is*
just a Kafka consumer with checkpointing bolted on; this isn't a
different set of concepts, just a lighter-weight client.

## What gets added

```
docker-compose.yml    <- adds "kafka", "kafka-init", "kafka-ui" services
Dockerfile.airflow    <- adds kafka-python
sql/
├── 00_setup_schemas.sql     <- adds a "streaming" schema
└── 06_streaming_tables.sql  <- streaming.patient_events table
data/
├── kafka_producer.py
└── kafka_consumer.py
scripts/
├── run_kafka_producer.sh
├── run_kafka_consumer.sh
├── run_kafka_demo.sh        <- both, in sequence
└── setup_db.sh              <- updated to include the streaming table
```

## Running it

```bash
docker compose up -d --build   # brings up kafka, kafka-init, kafka-ui alongside everything else
./scripts/setup_db.sh          # if not already run since this layer was added
./scripts/run_kafka_demo.sh
```

This publishes ~150 simulated events (a mix of admissions, lab results,
and vital signs, with small random delays between sends to imitate
real-time arrival) to the `patient-events` topic, then consumes them
into `streaming.patient_events`.

## Verifying it worked

```sql
SELECT event_type, COUNT(*) FROM streaming.patient_events GROUP BY event_type;
```

Or browse the topic directly in **Kafka UI** at `http://localhost:8084`
— you can see individual messages, partition assignment, and consumer
group offsets, which is worth a screenshot for a portfolio README the
same way the dbt lineage graph and MinIO bucket browser are.

## Design notes

- **Bounded, not infinite.** The consumer stops after ~10 seconds of no
  new messages rather than running forever, matching every other
  one-shot script in this project (`docker exec`, runs, exits) instead
  of requiring you to manually kill a daemon.
- **JSONB payload + typed columns.** `streaming.patient_events` stores
  the full event as JSONB *and* pulls out `event_type`/`patient_id`/
  `event_time` into indexed columns. This is a common real-world
  pattern for event streams with varying shapes per event type — keep
  the raw payload for flexibility, index the columns you know you'll
  filter/join on.
- **Idempotent consumer.** Inserts use `ON CONFLICT (event_id) DO
  NOTHING`, so re-running the consumer (e.g. after a restart) won't
  create duplicate rows even if some messages get reprocessed.
- **3 partitions on the topic** (set in `kafka-init`), even though a
  single consumer instance here reads all of them — this is there so
  the topic *could* support multiple parallel consumers in the same
  group later, which is the actual point of partitioning in Kafka.
