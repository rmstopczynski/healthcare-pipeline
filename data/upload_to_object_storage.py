"""
Uploads the synthetic CSVs to object storage (MinIO, S3-compatible).

This simulates the "Healthcare Files -> S3" leg of the roadmap's Step 5
diagram. It's written against the standard boto3 S3 client -- the exact
same code works against real AWS S3 by changing endpoint_url and
credentials, nothing else.

Run via: docker exec healthcare_airflow python3 /opt/airflow/data/upload_to_object_storage.py
(or scripts/upload_to_s3.sh, which wraps that)
"""

import os
import boto3
from pathlib import Path

# Connection details. Defaults match the docker-compose "minio" service --
# override via env vars if pointing this at real AWS S3 instead.
ENDPOINT_URL = os.environ.get("S3_ENDPOINT_URL", "http://minio:9000")
ACCESS_KEY = os.environ.get("S3_ACCESS_KEY", "minioadmin")
SECRET_KEY = os.environ.get("S3_SECRET_KEY", "minioadmin")
BUCKET = os.environ.get("S3_BUCKET", "healthcare-raw-files")
PREFIX = "raw"

DATA_DIR = Path(__file__).parent / "synthetic_data"

s3 = boto3.client(
    "s3",
    endpoint_url=ENDPOINT_URL,
    aws_access_key_id=ACCESS_KEY,
    aws_secret_access_key=SECRET_KEY,
)


def main():
    if not DATA_DIR.exists():
        raise SystemExit(
            f"{DATA_DIR} not found. Run generate_synthetic_data.py first."
        )

    csv_files = sorted(DATA_DIR.glob("*.csv"))
    if not csv_files:
        raise SystemExit(f"No CSVs found in {DATA_DIR}.")

    print(f"Uploading {len(csv_files)} files to s3://{BUCKET}/{PREFIX}/ ...")
    for path in csv_files:
        key = f"{PREFIX}/{path.name}"
        s3.upload_file(str(path), BUCKET, key)
        size_kb = path.stat().st_size / 1024
        print(f"  uploaded {path.name} ({size_kb:.1f} KB) -> s3://{BUCKET}/{key}")

    print("Done.")


if __name__ == "__main__":
    main()
