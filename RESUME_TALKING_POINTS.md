# Resume & Interview Talking Points

Maps specific pieces of this repo to specific things you can say —
resume bullets and the follow-up questions they invite. Each bullet
below includes a **paste-ready resume line** and **what to actually say
if asked to elaborate**, since "I built a Kafka pipeline" invites "okay,
walk me through it" and you want the next 90 seconds ready.

## Picking bullets for a specific job posting

This is one project, but it covers two genuinely different skill sets —
batch/warehouse engineering and streaming/event-driven engineering. Use
whichever section below matches what the job posting actually asks for;
you don't need to use all of them on every application. If a posting
wants both, use the combined bullet.

### If the job wants batch/warehouse/analytics engineering

> Designed and built a batch data pipeline (Postgres, dbt, Airflow,
> S3-compatible object storage, PySpark) migrating a normalized OLTP
> schema to a dimensional star schema, orchestrated end-to-end with
> automatic retries and 60 automated data-quality tests.

> Built a dbt project with 19 models and 60 automated data-quality tests
> (uniqueness, null checks, referential integrity, accepted-value
> constraints), with auto-generated documentation and lineage graphs.

> Orchestrated a 5-task Airflow DAG (extract → load → transform → test →
> validate) with automatic retries, dependency enforcement, and
> centralized logging, replacing a manual multi-command sequence.

> Built a PySpark job reading from S3-compatible object storage,
> performing DataFrame joins/aggregations across 5 datasets, writing
> partitioned Parquet output and loading an aggregate summary table into
> a relational warehouse via JDBC.

### If the job wants streaming/event-driven engineering

> Built a Kafka producer/consumer pipeline simulating real-time
> healthcare events (admissions, lab results, vital signs), using
> consumer groups, partitioned topics, and idempotent writes into a
> relational warehouse.

> Designed an event schema and ingestion path for streaming operational
> data (JSONB payload + indexed columns for common query patterns),
> landing continuous events alongside a separate batch warehouse in the
> same database.

### If the job wants both (or you want to show system design judgment)

> Designed and built a hybrid batch/streaming healthcare data platform
> (Postgres, dbt, Airflow, MinIO/S3, PySpark, Kafka) — a Lambda-style
> architecture with a batch layer for historical records and a speed
> layer for real-time events, unified into one warehouse, fully
> containerized and reproducible with a single command.

## If asked to elaborate

**"Walk me through the architecture."**
Point to `docs/architecture_diagram.svg`. Say it out loud in one breath:
CSVs get generated, land in MinIO (S3-compatible), load into Postgres
`raw`, get cleaned into `staging`, modeled into a dimensional `analytics`
star schema — either via raw SQL or a parallel dbt project with tests.
Airflow orchestrates all of that on a schedule. Separately, a PySpark
job reads the same MinIO data and writes an aggregated summary plus
partitioned Parquet. Also separately, a Kafka producer/consumer pair
simulates real-time patient events into their own table.

**"Why does one project have both batch AND streaming tools — isn't
that overkill?"**
This is a fair challenge to expect, and the answer is the README's
"Architecture: batch and streaming, deliberately" section, memorized:
*"A hospital system has two real data patterns — structured historical
records that arrive in batches, and continuous operational events that
arrive as a stream. This models both, landing in one warehouse, which
is a common hybrid pattern in production platforms — sometimes called
Lambda architecture, a batch layer and a speed layer feeding one serving
layer."* The tell that this is a real answer and not a rationalization:
you can point to the schema differences (`streaming.patient_events` uses
JSONB for flexible event shapes; the batch star schema uses strict typed
columns) as evidence you actually thought about why they're different,
not just that you ran two tools.

**"Why Postgres and not Snowflake / MinIO and not S3 / local Spark and
not Databricks?"**
This is the best question you can get, because the honest answer is a
strength, not a confession. Say: *"I designed it against Snowflake's
architecture first — the raw DDL for that is still in `snowflake/` —
but Snowflake's only free option is a 30-day trial, and I wanted
something I could keep running and iterating on indefinitely. Postgres,
MinIO, and local Spark all expose the same APIs/SQL dialect as their
cloud counterparts, so the actual code and concepts transfer directly —
I made a deliberate, reasoned substitution, not a shortcut."* This shows
judgment, not just tool familiarity — you can name the trade-off and
defend it.

**"What was the hardest bug you hit?"**
You have real ones, ranked by how good a story they make:
1. **The FK-cascade bug** (`sql/02_staging_tables.sql` originally):
   three `VARCHAR(20)` phone columns were too narrow for generated data,
   causing three table loads to fail — but the *error surfaced* three
   tables downstream, on tables with no data problem at all, because
   their foreign keys pointed at the tables that failed. Good story
   because it's about root-causing past a misleading symptom, not just
   fixing an error message.
2. **The recurring Git Bash path bug**: same root cause (MSYS2
   translating `/opt/...` paths into Windows paths) surfaced twice, in
   two different commands, because the first fix addressed the symptom
   in one script rather than the actual trigger condition. Good story
   because it's honest about a fix that didn't generalize, and what you
   learned from that specifically.
3. **The Spark/S3 JAR alignment**: had to verify actual Docker Hub tags
   existed rather than guessing a version number, then track down that
   `spark-submit` wasn't on `PATH` in that particular base image. Good
   story for "how do you debug something you've never used before."

**"How do you know the data is correct?"**
60 dbt tests running after every model build — not just "it ran without
error," but unique/not-null constraints on every primary key and
referential-integrity checks on every fact-table foreign key. Also point
to the row-count validation script (`sql/04_validate_migration.sql`)
that confirms zero data loss across all three schema layers on every
run.

**"Is this in production anywhere / who uses it?"**
Be straightforward: it's a portfolio project built to demonstrate the
pipeline patterns end to end, using synthetic data since real healthcare
data wasn't available. What's real is the architecture, the debugging,
and the working code — not a live user base. Don't oversell this part;
interviewers can tell, and the honest framing is more credible anyway.

**"Where did this project come from / whose idea was the schema?"**
Also a fair question to expect, and again the honest answer is a
strength: *"The schema design — the star schema, the date dimension —
came out of a group project for a data warehousing course. The paper
that project produced actually recommended migrating to a real cloud
warehouse as a next step, but never did it. This project is that
recommendation, executed solo, plus a lot the original scope never
touched — dbt, Airflow, MinIO, Spark, Kafka."* This is a good answer
because it's specific and verifiable, not vague "inspired by" hand-waving.

## What NOT to claim

- Don't say "production" or "real users" — it's a portfolio project, say so.
- Don't claim Databricks/AWS S3 experience specifically — you used
  Databricks-*compatible* patterns (PySpark, DataFrame API) and an
  S3-*compatible* API (MinIO/boto3), which is true and still valuable,
  but naming the actual services you didn't touch is the kind of
  inflation that falls apart under two follow-up questions.
- Don't claim "Spark Streaming" — you built a Kafka consumer, which
  covers the same core mechanics, but say what you actually built.
- Don't claim you designed the schema from scratch — the star schema and
  date dimension came from group coursework; the entire pipeline
  implementation on top of it is yours. Both halves of that sentence
  are worth saying, not just the flattering half.

## Quick reference: what's actually in each layer

| Layer | Real skill demonstrated | File to point to |
|---|---|---|
| Postgres/Docker | Schema design, containerization | `sql/`, `docker-compose.yml` |
| dbt | Data modeling, testing, documentation | `dbt/healthcare_dbt/models/` |
| Airflow | Orchestration, scheduling, retries | `dags/healthcare_pipeline_dag.py` |
| MinIO | Object storage, S3 API (boto3) | `data/upload_to_object_storage.py` |
| PySpark | Distributed processing, DataFrames, partitioning | `spark_jobs/spark_pipeline.py` |
| Kafka | Event streaming, producers/consumers | `data/kafka_producer.py`, `data/kafka_consumer.py` |
| Debugging | Root-causing past misleading symptoms | README's Challenges section |

This is the best question you can get, because the honest answer is a
strength, not a confession. Say: *"I designed it against Snowflake's
architecture first — the raw DDL for that is still in `snowflake/` —
but Snowflake's only free option is a 30-day trial, and I wanted
something I could keep running and iterating on indefinitely. Postgres,
MinIO, and local Spark all expose the same APIs/SQL dialect as their
cloud counterparts, so the actual code and concepts transfer directly —
I made a deliberate, reasoned substitution, not a shortcut."* This shows
judgment, not just tool familiarity — you can name the trade-off and
defend it.

**"What was the hardest bug you hit?"**
You have real ones, ranked by how good a story they make:
1. **The FK-cascade bug** (`sql/02_staging_tables.sql` originally):
   three `VARCHAR(20)` phone columns were too narrow for generated data,
   causing three table loads to fail — but the *error surfaced* three
   tables downstream, on tables with no data problem at all, because
   their foreign keys pointed at the tables that failed. Good story
   because it's about root-causing past a misleading symptom, not just
   fixing an error message.
2. **The recurring Git Bash path bug**: same root cause (MSYS2
   translating `/opt/...` paths into Windows paths) surfaced twice, in
   two different commands, because the first fix addressed the symptom
   in one script rather than the actual trigger condition. Good story
   because it's honest about a fix that didn't generalize, and what you
   learned from that specifically.
3. **The Spark/S3 JAR alignment**: had to verify actual Docker Hub tags
   existed rather than guessing a version number, then track down that
   `spark-submit` wasn't on `PATH` in that particular base image. Good
   story for "how do you debug something you've never used before."

**"How do you know the data is correct?"**
60 dbt tests running after every model build — not just "it ran without
error," but unique/not-null constraints on every primary key and
referential-integrity checks on every fact-table foreign key. Also point
to the row-count validation script (`sql/04_validate_migration.sql`)
that confirms zero data loss across all three schema layers on every
run.

**"Is this in production anywhere / who uses it?"**
Be straightforward: it's a portfolio project built to demonstrate the
pipeline patterns end to end, using synthetic data since real healthcare
data wasn't available. What's real is the architecture, the debugging,
and the working code — not a live user base. Don't oversell this part;
interviewers can tell, and the honest framing is more credible anyway.

## What NOT to claim

- Don't say "production" or "real users" — it's a portfolio project, say so.
- Don't claim Databricks/AWS S3 experience specifically — you used
  Databricks-*compatible* patterns (PySpark, DataFrame API) and an
  S3-*compatible* API (MinIO/boto3), which is true and still valuable,
  but naming the actual services you didn't touch is the kind of
  inflation that falls apart under two follow-up questions.
- Don't claim "Spark Streaming" — you built a Kafka consumer, which
  covers the same core mechanics, but say what you actually built.

## Quick reference: what's actually in each layer

| Layer | Real skill demonstrated | File to point to |
|---|---|---|
| Postgres/Docker | Schema design, containerization | `sql/`, `docker-compose.yml` |
| dbt | Data modeling, testing, documentation | `dbt/healthcare_dbt/models/` |
| Airflow | Orchestration, scheduling, retries | `dags/healthcare_pipeline_dag.py` |
| MinIO | Object storage, S3 API (boto3) | `data/upload_to_object_storage.py` |
| PySpark | Distributed processing, DataFrames, partitioning | `spark_jobs/spark_pipeline.py` |
| Kafka | Event streaming, producers/consumers | `data/kafka_producer.py`, `data/kafka_consumer.py` |
| Debugging | Root-causing past misleading symptoms | README's Challenges section |
