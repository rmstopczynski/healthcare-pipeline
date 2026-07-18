-- =====================================================================
-- STAGING TABLES (Postgres)
-- Typed, constrained tables + transform SQL that trims/standardizes
-- and dedupes from raw. Postgres has no QUALIFY, so dedup uses a CTE
-- + ROW_NUMBER() instead. Postgres also has no "INSERT OVERWRITE", so
-- each load is TRUNCATE + INSERT.
-- =====================================================================

SET search_path TO staging;

CREATE TABLE IF NOT EXISTS staging.states (
    state_id    INTEGER PRIMARY KEY,
    state_name  VARCHAR(100),
    state_abbr  VARCHAR(2)
);

CREATE TABLE IF NOT EXISTS staging.cities (
    city_id    INTEGER PRIMARY KEY,
    city_name  VARCHAR(100),
    state_id   INTEGER REFERENCES staging.states(state_id)
);

CREATE TABLE IF NOT EXISTS staging.addresses (
    address_id      INTEGER PRIMARY KEY,
    street_address  VARCHAR(200),
    city_id         INTEGER REFERENCES staging.cities(city_id),
    zip             VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS staging.hospitals (
    hospital_id        INTEGER PRIMARY KEY,
    hospital_name      VARCHAR(200),
    address_id         INTEGER REFERENCES staging.addresses(address_id),
    hospital_phone_no  VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS staging.doctors (
    doctor_id      INTEGER PRIMARY KEY,
    first_name     VARCHAR(100),
    last_name      VARCHAR(100),
    hospital_affi  INTEGER REFERENCES staging.hospitals(hospital_id),
    specialty      VARCHAR(100),
    doc_phone_no   VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS staging.medications (
    medication_id    INTEGER PRIMARY KEY,
    medication_name  VARCHAR(200),
    pharma_company   VARCHAR(200),
    category         VARCHAR(100),
    medication_cost  NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS staging.procedures (
    procedure_id      INTEGER PRIMARY KEY,
    procedure_name    VARCHAR(200),
    medical_category  VARCHAR(100),
    procedure_charge  NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS staging.insurance_providers (
    insurance_provider_id  INTEGER PRIMARY KEY,
    provider_name          VARCHAR(200),
    plan_type              VARCHAR(100),
    phone_no               VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS staging.patients (
    patient_id  INTEGER PRIMARY KEY,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    dob         DATE,
    sex         VARCHAR(10),
    blood_type  VARCHAR(5)
);

CREATE TABLE IF NOT EXISTS staging.patient_insurance (
    patient_id             INTEGER REFERENCES staging.patients(patient_id),
    insurance_provider_id  INTEGER REFERENCES staging.insurance_providers(insurance_provider_id),
    PRIMARY KEY (patient_id, insurance_provider_id)
);

CREATE TABLE IF NOT EXISTS staging.prescriptions (
    prescription_id  INTEGER PRIMARY KEY,
    patient_id       INTEGER REFERENCES staging.patients(patient_id),
    doctor_id        INTEGER REFERENCES staging.doctors(doctor_id),
    medication_id    INTEGER REFERENCES staging.medications(medication_id),
    quantity         INTEGER,
    dosage           VARCHAR(100),
    frequency        VARCHAR(100),
    prescribed_date  DATE,
    refill_allowed   BOOLEAN,
    refill_count     INTEGER
);

CREATE TABLE IF NOT EXISTS staging.hospital_visits (
    visit_id               INTEGER PRIMARY KEY,
    admission_date         DATE,
    discharge_date         DATE,
    patient_id             INTEGER REFERENCES staging.patients(patient_id),
    doctor_id              INTEGER REFERENCES staging.doctors(doctor_id),
    hospital_id            INTEGER REFERENCES staging.hospitals(hospital_id),
    insurance_provider_id  INTEGER REFERENCES staging.insurance_providers(insurance_provider_id),
    room_no                VARCHAR(20),
    admission_type         VARCHAR(50),
    procedure_id           INTEGER REFERENCES staging.procedures(procedure_id),
    diagnosis               VARCHAR(500)
);

-- ---------------------------------------------------------------------
-- TRANSFORM: raw -> staging
-- ---------------------------------------------------------------------

TRUNCATE staging.states CASCADE;
INSERT INTO staging.states
SELECT DISTINCT ON (state_id) state_id, TRIM(state_name), UPPER(TRIM(state_abbr))
FROM raw.states
ORDER BY state_id;

TRUNCATE staging.cities CASCADE;
INSERT INTO staging.cities
SELECT DISTINCT ON (city_id) city_id, TRIM(city_name), state_id
FROM raw.cities
ORDER BY city_id;

TRUNCATE staging.addresses CASCADE;
INSERT INTO staging.addresses
SELECT DISTINCT ON (address_id) address_id, TRIM(street_address), city_id, TRIM(zip)
FROM raw.addresses
ORDER BY address_id;

TRUNCATE staging.hospitals CASCADE;
INSERT INTO staging.hospitals
SELECT DISTINCT ON (hospital_id) hospital_id, TRIM(hospital_name), address_id, TRIM(hospital_phone_no)
FROM raw.hospitals
ORDER BY hospital_id;

TRUNCATE staging.doctors CASCADE;
INSERT INTO staging.doctors
SELECT DISTINCT ON (doctor_id) doctor_id, TRIM(first_name), TRIM(last_name), hospital_affi, TRIM(specialty), TRIM(doc_phone_no)
FROM raw.doctors
ORDER BY doctor_id;

TRUNCATE staging.medications CASCADE;
INSERT INTO staging.medications
SELECT DISTINCT ON (medication_id) medication_id, TRIM(medication_name), TRIM(pharma_company), TRIM(category), medication_cost
FROM raw.medications
ORDER BY medication_id;

TRUNCATE staging.procedures CASCADE;
INSERT INTO staging.procedures
SELECT DISTINCT ON (procedure_id) procedure_id, TRIM(procedure_name), TRIM(medical_category), procedure_charge
FROM raw.procedures
ORDER BY procedure_id;

TRUNCATE staging.insurance_providers CASCADE;
INSERT INTO staging.insurance_providers
SELECT DISTINCT ON (insurance_provider_id) insurance_provider_id, TRIM(provider_name), TRIM(plan_type), TRIM(phone_no)
FROM raw.insurance_providers
ORDER BY insurance_provider_id;

TRUNCATE staging.patients CASCADE;
INSERT INTO staging.patients
SELECT DISTINCT ON (patient_id) patient_id, TRIM(first_name), TRIM(last_name), dob, UPPER(TRIM(sex)), UPPER(TRIM(blood_type))
FROM raw.patients
ORDER BY patient_id;

TRUNCATE staging.patient_insurance CASCADE;
INSERT INTO staging.patient_insurance
SELECT DISTINCT patient_id, insurance_provider_id
FROM raw.patient_insurance;

TRUNCATE staging.prescriptions CASCADE;
INSERT INTO staging.prescriptions
SELECT DISTINCT ON (prescription_id)
    prescription_id, patient_id, doctor_id, medication_id, quantity,
    TRIM(dosage), TRIM(frequency), prescribed_date, refill_allowed, refill_count
FROM raw.prescriptions
ORDER BY prescription_id;

TRUNCATE staging.hospital_visits CASCADE;
INSERT INTO staging.hospital_visits
SELECT DISTINCT ON (visit_id)
    visit_id, admission_date, discharge_date, patient_id, doctor_id, hospital_id,
    insurance_provider_id, TRIM(room_no), TRIM(admission_type), procedure_id, TRIM(diagnosis)
FROM raw.hospital_visits
ORDER BY visit_id;
