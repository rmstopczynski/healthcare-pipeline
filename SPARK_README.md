# PySpark Layer

Adds distributed data processing on top of the pipeline: a PySpark job
reads raw files straight out of MinIO (S3-compatible object storage),
does DataFrame joins/aggregations, writes a partitioned Parquet dataset
back to object storage, and loads a summary table into Postgres via
JDBC. This mirrors the roadmap's "Large Dataset -> Spark -> Warehouse"
pattern.

## Why local PySpark instead of Databricks

Databricks now has a genuinely free tier (Free Edition, no credit card),
but it's a separate hosted workspace disconnected from this repo --
anyone cloning the project wouldn't get that piece by just running
`docker compose up`. Local PySpark uses the identical API (same
DataFrame/transformation/partitioning concepts, same code you'd write
against Databricks) while staying fully reproducible and integrated with
everything else here.

## What gets added

```
docker-compose.yml    <- adds a "spark" service (build-only, not long-running)
Dockerfile.spark      <- Apache Spark + Hadoop-AWS + Postgres JDBC jars
spark_jobs/
└── spark_pipeline.py
scripts/
├── run_spark_job.sh
└── run_all_with_spark.sh
sql/00_setup_schemas.sql   <- adds a spark_analytics schema
```

## Running it

Requires the MinIO layer (Step 5) already in place, since this job reads
from `s3a://healthcare-raw-files/raw/`.

```bash
docker compose up -d --build   # first build downloads ~250MB of jars, several minutes
./scripts/run_all_with_spark.sh
```

Or, if you already have data loaded and just want to run the Spark job
on its own:
```bash
./scripts/run_spark_job.sh
```

## What the job actually does

1. **Reads** `hospital_visits`, `patients`, `doctors`, `hospitals`, and
   `procedures` CSVs directly from `s3a://healthcare-raw-files/raw/` into
   Spark DataFrames.
2. **Joins** them into one enriched DataFrame (visit + patient + doctor +
   hospital + procedure info in a single row per visit), and derives
   `admission_year`, `admission_month`, and `length_of_stay` columns.
3. **Writes** that enriched DataFrame back to MinIO as **partitioned
   Parquet** (`s3a://healthcare-raw-files/processed/hospital_visits_enriched/`,
   partitioned by `admission_year`/`admission_month`) — the standard
   data-lake layout, where a query filtering on a date range only reads
   the relevant partition files instead of scanning everything.
4. **Aggregates** a monthly-per-hospital summary (visit counts, average
   length of stay, total procedure revenue) and **writes it to Postgres**
   via JDBC, landing in `spark_analytics.monthly_hospital_summary`.

## Verifying it worked

```sql
SELECT * FROM spark_analytics.monthly_hospital_summary ORDER BY hospital_name, admission_year, admission_month;
```

And in MinIO's console (`localhost:9001`), browse to
`healthcare-raw-files/processed/hospital_visits_enriched/` — you'll see
subfolders like `admission_year=2024/admission_month=3/` containing the
actual partitioned Parquet files.

## A note on jar versions

`Dockerfile.spark` pins specific `hadoop-aws`/`aws-java-sdk-bundle`
versions matched to Spark 3.5's bundled Hadoop version. If Spark's base
image changes in the future and S3 connectivity breaks, check
`docker compose run --rm spark spark-submit --version` for the actual
Hadoop version in use and adjust the jar versions in `Dockerfile.spark`
to match -- this kind of dependency alignment is a normal (if annoying)
part of real Spark operations, not specific to this project.
