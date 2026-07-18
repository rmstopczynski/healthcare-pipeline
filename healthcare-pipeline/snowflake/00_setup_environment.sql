-- =====================================================================
-- STEP 1: DATABASE + SCHEMA ARCHITECTURE
-- =====================================================================

CREATE DATABASE IF NOT EXISTS HEALTHCARE_DB;
USE DATABASE HEALTHCARE_DB;

CREATE SCHEMA IF NOT EXISTS RAW;         -- untouched source data (mirrors Oracle 1:1)
CREATE SCHEMA IF NOT EXISTS STAGING;     -- cleaned / typed / deduped tables
CREATE SCHEMA IF NOT EXISTS ANALYTICS;   -- business-ready dimensional model

-- HEALTHCARE_DB
--   RAW        -> untouched source data (from your Oracle ER diagram)
--   STAGING    -> cleaned/transformed tables
--   ANALYTICS  -> business-ready star schema (fact + dimension tables)

-- =====================================================================
-- STEP 2: WAREHOUSE (COMPUTE)
-- =====================================================================

CREATE WAREHOUSE IF NOT EXISTS HEALTHCARE_WH
WITH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Database  = where data lives
-- Warehouse = compute power that reads/writes it
