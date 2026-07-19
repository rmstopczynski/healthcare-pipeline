"""
Spark job demonstrating the "Large Healthcare Dataset -> Spark ->
Warehouse" pattern: reads raw files from object storage (MinIO,
S3-compatible), does DataFrame transformations (joins, aggregations),
writes a partitioned Parquet dataset back to object storage, and loads
a summary table into Postgres via JDBC.

Run via: docker compose run --rm spark spark-submit /opt/spark_jobs/spark_pipeline.py
(or scripts/run_spark_job.sh, which wraps that)
"""

import os
from pyspark.sql import SparkSession
from pyspark.sql import functions as F

S3_ENDPOINT = os.environ.get("S3_ENDPOINT_URL", "http://minio:9000")
S3_ACCESS_KEY = os.environ.get("S3_ACCESS_KEY", "minioadmin")
S3_SECRET_KEY = os.environ.get("S3_SECRET_KEY", "minioadmin")
S3_BUCKET = os.environ.get("S3_BUCKET", "healthcare-raw-files")

PG_HOST = os.environ.get("PGHOST", "postgres")
PG_PORT = os.environ.get("PGPORT", "5432")
PG_DB = os.environ.get("PGDATABASE", "healthcare_db")
PG_USER = os.environ.get("PGUSER", "healthcare")
PG_PASSWORD = os.environ.get("PGPASSWORD", "healthcare")
JDBC_URL = f"jdbc:postgresql://{PG_HOST}:{PG_PORT}/{PG_DB}"


def main():
    spark = (
        SparkSession.builder.appName("healthcare-spark-pipeline")
        .config("spark.hadoop.fs.s3a.endpoint", S3_ENDPOINT)
        .config("spark.hadoop.fs.s3a.access.key", S3_ACCESS_KEY)
        .config("spark.hadoop.fs.s3a.secret.key", S3_SECRET_KEY)
        .config("spark.hadoop.fs.s3a.path.style.access", "true")
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
        .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false")
        .getOrCreate()
    )
    spark.sparkContext.setLogLevel("WARN")

    base = f"s3a://{S3_BUCKET}/raw"

    # ---------------------------------------------------------------
    # READ: raw CSVs straight out of object storage into DataFrames
    # ---------------------------------------------------------------
    visits = spark.read.option("header", True).option("inferSchema", True).csv(f"{base}/hospital_visits.csv")
    patients = spark.read.option("header", True).option("inferSchema", True).csv(f"{base}/patients.csv")
    doctors = spark.read.option("header", True).option("inferSchema", True).csv(f"{base}/doctors.csv")
    hospitals = spark.read.option("header", True).option("inferSchema", True).csv(f"{base}/hospitals.csv")
    procedures = spark.read.option("header", True).option("inferSchema", True).csv(f"{base}/procedures.csv")

    print(f"Loaded {visits.count()} hospital visits, {patients.count()} patients from s3a://{S3_BUCKET}/raw/")

    # ---------------------------------------------------------------
    # TRANSFORM: join visits against its dimensions, derive columns
    # for partitioning, compute length of stay
    # ---------------------------------------------------------------
    enriched = (
        visits
        .join(patients, on="patient_id", how="left")
        .join(doctors.select(
            F.col("doctor_id"),
            F.col("first_name").alias("doctor_first_name"),
            F.col("last_name").alias("doctor_last_name"),
            F.col("specialty"),
        ), on="doctor_id", how="left")
        .join(hospitals.select(
            F.col("hospital_id"),
            F.col("hospital_name"),
        ), on="hospital_id", how="left")
        .join(procedures.select(
            F.col("procedure_id"),
            F.col("procedure_name"),
            F.col("medical_category"),
            F.col("procedure_charge"),
        ), on="procedure_id", how="left")
        .withColumn("admission_year", F.year("admission_date"))
        .withColumn("admission_month", F.month("admission_date"))
        .withColumn(
            "length_of_stay",
            F.datediff(F.col("discharge_date"), F.col("admission_date")),
        )
    )

    # ---------------------------------------------------------------
    # WRITE (1): partitioned Parquet back to object storage.
    # Partitioning by year/month is the standard data-lake pattern --
    # downstream queries filtering on a date range only read the
    # relevant partition files instead of scanning everything.
    # ---------------------------------------------------------------
    parquet_path = f"s3a://{S3_BUCKET}/processed/hospital_visits_enriched"
    (
        enriched
        .repartition("admission_year", "admission_month")
        .write.mode("overwrite")
        .partitionBy("admission_year", "admission_month")
        .parquet(parquet_path)
    )
    print(f"Wrote partitioned Parquet dataset to {parquet_path}")

    # ---------------------------------------------------------------
    # TRANSFORM (2): aggregate summary -- monthly admissions, avg
    # length of stay, and revenue per hospital
    # ---------------------------------------------------------------
    summary = (
        enriched.groupBy("hospital_name", "admission_year", "admission_month")
        .agg(
            F.count("*").alias("total_visits"),
            F.round(F.avg("length_of_stay"), 1).alias("avg_length_of_stay"),
            F.round(F.sum("procedure_charge"), 2).alias("total_procedure_revenue"),
        )
        .orderBy("hospital_name", "admission_year", "admission_month")
    )

    # ---------------------------------------------------------------
    # WRITE (2): summary into Postgres via JDBC -- the "Spark ->
    # warehouse" leg of the pattern.
    # ---------------------------------------------------------------
    (
        summary.write
        .mode("overwrite")
        .format("jdbc")
        .option("url", JDBC_URL)
        .option("dbtable", "spark_analytics.monthly_hospital_summary")
        .option("user", PG_USER)
        .option("password", PG_PASSWORD)
        .option("driver", "org.postgresql.Driver")
        .save()
    )
    print("Wrote summary table to spark_analytics.monthly_hospital_summary")

    summary.show(20, truncate=False)

    spark.stop()


if __name__ == "__main__":
    main()
