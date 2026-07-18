-- =====================================================================
-- RAW TABLES (Postgres)
-- Untouched mirror of the source structure. Loosely typed, no
-- constraints — this is where manual CSV exports land.
-- =====================================================================

SET search_path TO raw;

CREATE TABLE IF NOT EXISTS raw.states (
    state_id    INTEGER,
    state_name  TEXT,
    state_abbr  TEXT
);

CREATE TABLE IF NOT EXISTS raw.cities (
    city_id    INTEGER,
    city_name  TEXT,
    state_id   INTEGER
);

CREATE TABLE IF NOT EXISTS raw.addresses (
    address_id      INTEGER,
    street_address  TEXT,
    city_id         INTEGER,
    zip             TEXT
);

CREATE TABLE IF NOT EXISTS raw.hospitals (
    hospital_id        INTEGER,
    hospital_name      TEXT,
    address_id         INTEGER,
    hospital_phone_no  TEXT
);

CREATE TABLE IF NOT EXISTS raw.doctors (
    doctor_id      INTEGER,
    first_name     TEXT,
    last_name      TEXT,
    hospital_affi  INTEGER,
    specialty      TEXT,
    doc_phone_no   TEXT
);

CREATE TABLE IF NOT EXISTS raw.medications (
    medication_id    INTEGER,
    medication_name  TEXT,
    pharma_company   TEXT,
    category         TEXT,
    medication_cost  NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS raw.procedures (
    procedure_id      INTEGER,
    procedure_name    TEXT,
    medical_category  TEXT,
    procedure_charge  NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS raw.insurance_providers (
    insurance_provider_id  INTEGER,
    provider_name          TEXT,
    plan_type              TEXT,
    phone_no               TEXT
);

CREATE TABLE IF NOT EXISTS raw.patients (
    patient_id  INTEGER,
    first_name  TEXT,
    last_name   TEXT,
    dob         DATE,
    sex         TEXT,
    blood_type  TEXT
);

CREATE TABLE IF NOT EXISTS raw.patient_insurance (
    patient_id             INTEGER,
    insurance_provider_id  INTEGER
);

CREATE TABLE IF NOT EXISTS raw.prescriptions (
    prescription_id  INTEGER,
    patient_id       INTEGER,
    doctor_id        INTEGER,
    medication_id    INTEGER,
    quantity         INTEGER,
    dosage           TEXT,
    frequency        TEXT,
    prescribed_date  DATE,
    refill_allowed   BOOLEAN,
    refill_count     INTEGER
);

CREATE TABLE IF NOT EXISTS raw.hospital_visits (
    visit_id               INTEGER,
    admission_date         DATE,
    discharge_date         DATE,
    patient_id             INTEGER,
    doctor_id              INTEGER,
    hospital_id            INTEGER,
    insurance_provider_id  INTEGER,
    room_no                TEXT,
    admission_type         TEXT,
    procedure_id           INTEGER,
    diagnosis               TEXT
);

-- No PK/FK constraints in raw on purpose — see 02_staging for cleanup.
