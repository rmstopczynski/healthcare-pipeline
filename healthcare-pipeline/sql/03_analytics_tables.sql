-- =====================================================================
-- ANALYTICS TABLES (Postgres)
-- Same star schema as the Snowflake version. Date functions are
-- swapped for Postgres equivalents (generate_series, EXTRACT, AGE)
-- since DATEADD/SEQ4/GENERATOR/DAYNAME/MONTHNAME/DATEDIFF are
-- Snowflake-specific.
-- =====================================================================

SET search_path TO analytics;

CREATE TABLE IF NOT EXISTS analytics.medication_dim (
    medication_id    INTEGER PRIMARY KEY,
    medication_name  VARCHAR(200),
    pharma_company   VARCHAR(200),
    category         VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS analytics.doctor_dim (
    doctor_id          INTEGER PRIMARY KEY,
    first_name         VARCHAR(100),
    last_name          VARCHAR(100),
    specialty          VARCHAR(100),
    doc_phone_no       VARCHAR(50),
    hospital_affi      VARCHAR(200),
    hospital_state     VARCHAR(100),
    hospital_city      VARCHAR(100),
    hospital_zip       VARCHAR(10),
    hospital_phone_no  VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS analytics.patient_dim (
    patient_id            INTEGER PRIMARY KEY,
    first_name            VARCHAR(100),
    last_name             VARCHAR(100),
    dob                   DATE,
    age                   INTEGER,
    age_group             VARCHAR(20),
    sex                   VARCHAR(10),
    patient_phone_no      VARCHAR(50),
    blood_type            VARCHAR(5),
    primary_insur_prov    VARCHAR(200),
    primary_plan_type     VARCHAR(100),
    secondary_insur_prov  VARCHAR(200),
    secondary_plan_type   VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS analytics.procedure_dim (
    procedure_id      INTEGER PRIMARY KEY,
    procedure_name    VARCHAR(200),
    medical_category  VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS analytics.julian_date_dim (
    julian_day    INTEGER PRIMARY KEY,  -- YYYYMMDD surrogate key
    actual_dt     DATE,
    day_name      VARCHAR(20),
    day_abbrev    VARCHAR(5),
    day_in_year   INTEGER,
    day_in_month  INTEGER,
    day_in_week   INTEGER,
    month_name    VARCHAR(20),
    month_abbrev  VARCHAR(5),
    month_num     INTEGER,
    year_name     VARCHAR(10),
    year_num      INTEGER,
    quarter       INTEGER
);

CREATE TABLE IF NOT EXISTS analytics.prescription_fact (
    prescription_id  INTEGER PRIMARY KEY,
    patient_id       INTEGER REFERENCES analytics.patient_dim(patient_id),
    doctor_id        INTEGER REFERENCES analytics.doctor_dim(doctor_id),
    medication_id    INTEGER REFERENCES analytics.medication_dim(medication_id),
    prescribed_date  INTEGER REFERENCES analytics.julian_date_dim(julian_day),
    quantity         INTEGER,
    dosage           VARCHAR(100),
    frequency        VARCHAR(100),
    medication_cost  NUMERIC(12,2),
    total_cost       NUMERIC(12,2),
    refill_allowed   BOOLEAN,
    refill_count     INTEGER
);

CREATE TABLE IF NOT EXISTS analytics.hospital_visit_fact (
    visit_id             INTEGER PRIMARY KEY,
    admission_date       INTEGER REFERENCES analytics.julian_date_dim(julian_day),
    discharge_date       INTEGER REFERENCES analytics.julian_date_dim(julian_day),
    patient_id           INTEGER REFERENCES analytics.patient_dim(patient_id),
    doctor_id            INTEGER REFERENCES analytics.doctor_dim(doctor_id),
    hospital             VARCHAR(200),
    insurance_provider   VARCHAR(200),
    room_no              VARCHAR(20),
    admission_type       VARCHAR(50),
    diagnosis            VARCHAR(500),
    procedure_id         INTEGER REFERENCES analytics.procedure_dim(procedure_id),
    procedure_charge     NUMERIC(12,2),
    room_charge          NUMERIC(12,2),
    misc_charge          NUMERIC(12,2),
    billing_amount       NUMERIC(12,2),
    length_of_stay       INTEGER
);

-- ---------------------------------------------------------------------
-- TRANSFORM: staging -> analytics
-- ---------------------------------------------------------------------

-- Julian date dimension: one row per calendar day, 2010-01-01 through
-- 2029-12-31 (~20 years). Adjust the range to fit your data.
TRUNCATE analytics.julian_date_dim CASCADE;
INSERT INTO analytics.julian_date_dim
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER                    AS julian_day,
    d                                                    AS actual_dt,
    TRIM(TO_CHAR(d, 'Day'))                              AS day_name,
    TO_CHAR(d, 'Dy')                                     AS day_abbrev,
    EXTRACT(doy FROM d)::INTEGER                          AS day_in_year,
    EXTRACT(day FROM d)::INTEGER                          AS day_in_month,
    EXTRACT(isodow FROM d)::INTEGER                        AS day_in_week,
    TRIM(TO_CHAR(d, 'Month'))                               AS month_name,
    TO_CHAR(d, 'Mon')                                        AS month_abbrev,
    EXTRACT(month FROM d)::INTEGER                            AS month_num,
    TO_CHAR(d, 'YYYY')                                         AS year_name,
    EXTRACT(year FROM d)::INTEGER                               AS year_num,
    EXTRACT(quarter FROM d)::INTEGER                              AS quarter
FROM generate_series('2010-01-01'::DATE, '2029-12-31'::DATE, '1 day'::INTERVAL) AS d;

-- medication_dim: 1:1 from staging
TRUNCATE analytics.medication_dim CASCADE;
INSERT INTO analytics.medication_dim
SELECT medication_id, medication_name, pharma_company, category
FROM staging.medications;

-- procedure_dim: 1:1 from staging
TRUNCATE analytics.procedure_dim CASCADE;
INSERT INTO analytics.procedure_dim
SELECT procedure_id, procedure_name, medical_category
FROM staging.procedures;

-- doctor_dim: denormalize hospital + address chain onto each doctor
TRUNCATE analytics.doctor_dim CASCADE;
INSERT INTO analytics.doctor_dim
SELECT
    doc.doctor_id,
    doc.first_name,
    doc.last_name,
    doc.specialty,
    doc.doc_phone_no,
    hosp.hospital_name       AS hospital_affi,
    st.state_name             AS hospital_state,
    ci.city_name                AS hospital_city,
    addr.zip                     AS hospital_zip,
    hosp.hospital_phone_no
FROM staging.doctors doc
LEFT JOIN staging.hospitals hosp ON doc.hospital_affi = hosp.hospital_id
LEFT JOIN staging.addresses addr ON hosp.address_id = addr.address_id
LEFT JOIN staging.cities ci ON addr.city_id = ci.city_id
LEFT JOIN staging.states st ON ci.state_id = st.state_id;

-- patient_dim: compute age/age group, pull primary + secondary insurance
TRUNCATE analytics.patient_dim CASCADE;
INSERT INTO analytics.patient_dim
WITH ranked_insurance AS (
    SELECT
        pi.patient_id,
        ip.provider_name,
        ip.plan_type,
        ROW_NUMBER() OVER (PARTITION BY pi.patient_id ORDER BY ip.insurance_provider_id) AS rn
    FROM staging.patient_insurance pi
    JOIN staging.insurance_providers ip ON pi.insurance_provider_id = ip.insurance_provider_id
)
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    p.dob,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.dob))::INTEGER                            AS age,
    CASE
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.dob)) < 18 THEN 'Under 18'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.dob)) BETWEEN 18 AND 34 THEN '18-34'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.dob)) BETWEEN 35 AND 54 THEN '35-54'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.dob)) BETWEEN 55 AND 74 THEN '55-74'
        ELSE '75+'
    END                                                                             AS age_group,
    p.sex,
    NULL                                                                            AS patient_phone_no,  -- not present in source
    p.blood_type,
    pri.provider_name                                                               AS primary_insur_prov,
    pri.plan_type                                                                   AS primary_plan_type,
    sec.provider_name                                                               AS secondary_insur_prov,
    sec.plan_type                                                                   AS secondary_plan_type
FROM staging.patients p
LEFT JOIN ranked_insurance pri ON p.patient_id = pri.patient_id AND pri.rn = 1
LEFT JOIN ranked_insurance sec ON p.patient_id = sec.patient_id AND sec.rn = 2;

-- prescription_fact
TRUNCATE analytics.prescription_fact CASCADE;
INSERT INTO analytics.prescription_fact
SELECT
    rx.prescription_id,
    rx.patient_id,
    rx.doctor_id,
    rx.medication_id,
    TO_CHAR(rx.prescribed_date, 'YYYYMMDD')::INTEGER    AS prescribed_date,
    rx.quantity,
    rx.dosage,
    rx.frequency,
    m.medication_cost,
    rx.quantity * m.medication_cost                     AS total_cost,
    rx.refill_allowed,
    rx.refill_count
FROM staging.prescriptions rx
LEFT JOIN staging.medications m ON rx.medication_id = m.medication_id;

-- hospital_visit_fact
TRUNCATE analytics.hospital_visit_fact CASCADE;
INSERT INTO analytics.hospital_visit_fact
SELECT
    hv.visit_id,
    TO_CHAR(hv.admission_date, 'YYYYMMDD')::INTEGER     AS admission_date,
    TO_CHAR(hv.discharge_date, 'YYYYMMDD')::INTEGER     AS discharge_date,
    hv.patient_id,
    hv.doctor_id,
    hosp.hospital_name                                   AS hospital,
    ip.provider_name                                      AS insurance_provider,
    hv.room_no,
    hv.admission_type,
    hv.diagnosis,
    hv.procedure_id,
    proc.procedure_charge,
    NULL                                                    AS room_charge,  -- not present in source
    NULL                                                    AS misc_charge,  -- not present in source
    COALESCE(proc.procedure_charge, 0)                       AS billing_amount,
    (hv.discharge_date - hv.admission_date)                  AS length_of_stay
FROM staging.hospital_visits hv
LEFT JOIN staging.hospitals hosp ON hv.hospital_id = hosp.hospital_id
LEFT JOIN staging.insurance_providers ip ON hv.insurance_provider_id = ip.insurance_provider_id
LEFT JOIN staging.procedures proc ON hv.procedure_id = proc.procedure_id;
