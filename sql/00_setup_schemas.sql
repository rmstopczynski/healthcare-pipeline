-- =====================================================================
-- STEP 1: SCHEMA ARCHITECTURE (Postgres)
-- The database itself (healthcare_db) is created automatically by
-- docker-compose (POSTGRES_DB=healthcare_db). Connect to it, then run
-- this to create the layers.
--
-- psql:  psql -h localhost -U healthcare -d healthcare_db
-- password: healthcare
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS spark_analytics;

-- healthcare_db
--   raw              -> untouched source data
--   staging          -> cleaned/transformed tables
--   analytics        -> business-ready star schema (SQL + dbt paths both write here)
--   spark_analytics   -> tables written by PySpark jobs (spark_jobs/spark_pipeline.py)

-- NOTE: Postgres has no separate "warehouse" (compute) concept like
-- Snowflake -- storage and compute aren't decoupled. There's nothing to
-- create here for compute; the Postgres server itself is your engine.
