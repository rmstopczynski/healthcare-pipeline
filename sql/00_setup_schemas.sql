-- =====================================================================
-- STEP 1: SCHEMA ARCHITECTURE (Postgres)
-- The database itself (healthcare_db) is created automatically by
-- docker-compose (POSTGRES_DB=healthcare_db). Connect to it, then run
-- this to create the three layers.
--
-- psql:  psql -h localhost -U healthcare -d healthcare_db
-- password: healthcare
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;

-- healthcare_db
--   raw        -> untouched source data
--   staging    -> cleaned/transformed tables
--   analytics  -> business-ready star schema

-- NOTE: Postgres has no separate "warehouse" (compute) concept like
-- Snowflake — storage and compute aren't decoupled. There's nothing to
-- create here for compute; the Postgres server itself is your engine.
