-- =====================================================================
-- STEP 5: RAW TABLES
-- Do not redesign here. This preserves the exact structure from your
-- Oracle ER diagram (normalized/3NF) so the first migration is a
-- faithful copy, not a redesign.
-- =====================================================================

USE DATABASE HEALTHCARE_DB;
USE SCHEMA RAW;

CREATE OR REPLACE TABLE RAW.STATES (
    STATE_ID        NUMBER(38,0),
    STATE_NAME      STRING,
    STATE_ABBR      STRING
);

CREATE OR REPLACE TABLE RAW.CITIES (
    CITY_ID         NUMBER(38,0),
    CITY_NAME       STRING,
    STATE_ID        NUMBER(38,0)
);

CREATE OR REPLACE TABLE RAW.ADDRESSES (
    ADDRESS_ID      NUMBER(38,0),
    STREET_ADDRESS  STRING,
    CITY_ID         NUMBER(38,0),
    ZIP             STRING
);

CREATE OR REPLACE TABLE RAW.HOSPITALS (
    HOSPITAL_ID       NUMBER(38,0),
    HOSPITAL_NAME     STRING,
    ADDRESS_ID        NUMBER(38,0),
    HOSPITAL_PHONE_NO STRING
);

CREATE OR REPLACE TABLE RAW.DOCTORS (
    DOCTOR_ID       NUMBER(38,0),
    FIRST_NAME      STRING,
    LAST_NAME       STRING,
    HOSPITAL_AFFI   NUMBER(38,0),
    SPECIALTY       STRING,
    DOC_PHONE_NO    STRING
);

CREATE OR REPLACE TABLE RAW.MEDICATIONS (
    MEDICATION_ID     NUMBER(38,0),
    MEDICATION_NAME   STRING,
    PHARMA_COMPANY    STRING,
    CATEGORY          STRING,
    MEDICATION_COST   NUMBER(12,2)
);

CREATE OR REPLACE TABLE RAW.PROCEDURES (
    PROCEDURE_ID      NUMBER(38,0),
    PROCEDURE_NAME    STRING,
    MEDICAL_CATEGORY  STRING,
    PROCEDURE_CHARGE  NUMBER(12,2)
);

CREATE OR REPLACE TABLE RAW.INSURANCE_PROVIDERS (
    INSURANCE_PROVIDER_ID  NUMBER(38,0),
    PROVIDER_NAME          STRING,
    PLAN_TYPE              STRING,
    PHONE_NO               STRING
);

CREATE OR REPLACE TABLE RAW.PATIENTS (
    PATIENT_ID   NUMBER(38,0),
    FIRST_NAME   STRING,
    LAST_NAME    STRING,
    DOB          DATE,
    SEX          STRING,
    BLOOD_TYPE   STRING
);

CREATE OR REPLACE TABLE RAW.PATIENT_INSURANCE (
    PATIENT_ID             NUMBER(38,0),
    INSURANCE_PROVIDER_ID  NUMBER(38,0)
);

CREATE OR REPLACE TABLE RAW.PRESCRIPTIONS (
    PRESCRIPTION_ID  NUMBER(38,0),
    PATIENT_ID       NUMBER(38,0),
    DOCTOR_ID        NUMBER(38,0),
    MEDICATION_ID    NUMBER(38,0),
    QUANTITY         NUMBER(10,0),
    DOSAGE           STRING,
    FREQUENCY        STRING,
    PRESCRIBED_DATE  DATE,
    REFILL_ALLOWED   BOOLEAN,
    REFILL_COUNT     NUMBER(5,0)
);

CREATE OR REPLACE TABLE RAW.HOSPITAL_VISITS (
    VISIT_ID               NUMBER(38,0),
    ADMISSION_DATE          DATE,
    DISCHARGE_DATE          DATE,
    PATIENT_ID              NUMBER(38,0),
    DOCTOR_ID                NUMBER(38,0),
    HOSPITAL_ID              NUMBER(38,0),
    INSURANCE_PROVIDER_ID    NUMBER(38,0),
    ROOM_NO                  STRING,
    ADMISSION_TYPE           STRING,
    PROCEDURE_ID              NUMBER(38,0),
    DIAGNOSIS                 STRING
);

-- No PK/FK constraints in RAW on purpose: this layer should accept
-- whatever comes out of the source system, including dirty rows.
-- Constraints/cleanup happen in STAGING.
