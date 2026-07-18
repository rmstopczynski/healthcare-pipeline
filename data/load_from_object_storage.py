"""
Loads CSVs from object storage (MinIO, S3-compatible) into raw.* --
simulating the "S3 -> Snowflake" (here: S3 -> Postgres) leg of the
roadmap's Step 5 diagram. This is the pattern real warehouses use:
Snowflake's COPY INTO and Postgres's aws_s3.table_import_from_s3 both
do exactly this -- read a file that lives in S3, load it straight into
a table.

This script downloads each file to a temp path, then loads it with
psycopg2's COPY, which is the fastest bulk-load method Postgres has
(same underlying mechanism as \\copy in psql, just driven from Python
instead of the command line).

Run via: docker exec healthcare_airflow python3 /opt/airflow/data/load_from_object_storage.py
(or scripts/load_from_s3.sh, which wraps that)
"""

import os
import tempfile
from pathlib import Path

import boto3
import psycopg2

ENDPOINT_URL = os.environ.get("S3_ENDPOINT_URL", "http://minio:9000")
ACCESS_KEY = os.environ.get("S3_ACCESS_KEY", "minioadmin")
SECRET_KEY = os.environ.get("S3_SECRET_KEY", "minioadmin")
BUCKET = os.environ.get("S3_BUCKET", "healthcare-raw-files")
PREFIX = "raw"

PG_HOST = os.environ.get("PGHOST", "postgres")
PG_PORT = os.environ.get("PGPORT", "5432")
PG_USER = os.environ.get("PGUSER", "healthcare")
PG_PASSWORD = os.environ.get("PGPASSWORD", "healthcare")
PG_DB = os.environ.get("PGDATABASE", "healthcare_db")

# File name (without .csv) -> destination table. Order matters for
# readability even though raw has no FK constraints to enforce it.
FILE_TO_TABLE = [
    ("states", "raw.states"),
    ("cities", "raw.cities"),
    ("addresses", "raw.addresses"),
    ("hospitals", "raw.hospitals"),
    ("doctors", "raw.doctors"),
    ("medications", "raw.medications"),
    ("procedures", "raw.procedures"),
    ("insurance_providers", "raw.insurance_providers"),
    ("patients", "raw.patients"),
    ("patient_insurance", "raw.patient_insurance"),
    ("prescriptions", "raw.prescriptions"),
    ("hospital_visits", "raw.hospital_visits"),
]

s3 = boto3.client(
    "s3",
    endpoint_url=ENDPOINT_URL,
    aws_access_key_id=ACCESS_KEY,
    aws_secret_access_key=SECRET_KEY,
)


def main():
    conn = psycopg2.connect(
        host=PG_HOST, port=PG_PORT, user=PG_USER, password=PG_PASSWORD, dbname=PG_DB
    )
    conn.autocommit = False
    cur = conn.cursor()

    print(f"Loading from s3://{BUCKET}/{PREFIX}/ into raw.* ...")
    try:
        with tempfile.TemporaryDirectory() as tmp:
            for file_stem, table in FILE_TO_TABLE:
                key = f"{PREFIX}/{file_stem}.csv"
                local_path = Path(tmp) / f"{file_stem}.csv"

                s3.download_file(BUCKET, key, str(local_path))

                # TRUNCATE first so re-running this script is idempotent
                # (same reasoning as load_synthetic_data.sql -- otherwise
                # re-running doubles every row instead of replacing them).
                cur.execute(f"TRUNCATE {table} CASCADE;")
                with open(local_path, "r", encoding="utf-8") as f:
                    cur.copy_expert(
                        f"COPY {table} FROM STDIN WITH (FORMAT csv, HEADER true)", f
                    )
                print(f"  loaded {table} from s3://{BUCKET}/{key}")

        conn.commit()
        print("Done. Committed.")
    except Exception:
        conn.rollback()
        print("Error occurred -- rolled back all changes.")
        raise
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    main()
