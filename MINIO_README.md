# MinIO / S3-Pattern Ingestion Layer

Adds an object-storage hop to the pipeline: CSVs land in MinIO (an
S3-compatible object store) before being loaded into `raw.*`, instead of
being loaded straight off local disk. This mirrors the real
cloud-warehouse pattern (files in S3, `COPY INTO` / `aws_s3.table_import_from_s3`
pulling from there into the warehouse) without needing an AWS account.

## Why MinIO instead of real AWS S3

AWS now requires a credit/debit card at signup even for free-tier usage,
which isn't worth the risk for a local portfolio project. MinIO exposes
the *exact same API* as S3 -- the upload/load scripts here use the
standard `boto3` S3 client, unmodified from what you'd write against
real AWS. Pointing this at real S3 later is a matter of changing
`endpoint_url` and credentials, not rewriting any logic. The genuine
gap: this skips the IAM/console side of real AWS, since there's no
AWS account here to configure.

## What gets added

```
docker-compose.yml     <- adds "minio" and "minio-init" services
Dockerfile.airflow     <- adds boto3 + psycopg2-binary
data/
├── upload_to_object_storage.py
└── load_from_object_storage.py
scripts/
├── generate_data.sh        (generation only, no load)
├── upload_to_s3.sh
├── load_from_s3.sh
└── run_all_via_s3.sh        (full pipeline via the S3 path)
```

## Running it

```bash
docker compose up -d --build   # brings up minio + minio-init alongside everything else
./scripts/run_all_via_s3.sh
```

This runs: schema setup -> generate synthetic CSVs -> upload to MinIO ->
load from MinIO into `raw.*` -> staging/analytics transforms -> validate.

Browse what actually landed in object storage at
**http://localhost:9001** (login: `minioadmin` / `minioadmin`) -- you'll
see a `healthcare-raw-files` bucket with a `raw/` prefix containing all
12 CSVs, exactly as they'd sit in a real S3 bucket.

## How this differs from `run_all.sh`

`run_all.sh` (from Step 4) loads CSVs directly from local disk via
`psql \copy`. `run_all_via_s3.sh` takes the same CSVs through MinIO
first. Both reach the identical end state in `raw.*` -- this isn't a
better or worse pipeline, it's demonstrating the additional pattern.

## Credentials

`minioadmin` / `minioadmin` are MinIO's well-known default dev
credentials -- fine to keep in a public repo for a local-only demo
service, same reasoning as the Postgres `healthcare`/`healthcare` creds
elsewhere in this project. Don't reuse these for anything with real data.
