-- =====================================================================
-- LOAD SYNTHETIC DATA INTO raw.*
-- Run with:
--   psql -h 127.0.0.1 -p 5432 -U healthcare -d healthcare_db -f load_synthetic_data.sql
--
-- IMPORTANT: run this from the folder that CONTAINS the synthetic_data/
-- subfolder (i.e. wherever you saved this file alongside it), since the
-- \copy paths below are relative to your current directory, not the
-- database server's.
--
-- Order matters: parent tables (states, cities...) load before tables
-- that reference them, even though raw has no FK constraints enforced —
-- this just keeps the data logically consistent as you load it.
-- =====================================================================

\copy raw.states FROM 'synthetic_data/states.csv' WITH (FORMAT csv, HEADER true);
\copy raw.cities FROM 'synthetic_data/cities.csv' WITH (FORMAT csv, HEADER true);
\copy raw.addresses FROM 'synthetic_data/addresses.csv' WITH (FORMAT csv, HEADER true);
\copy raw.hospitals FROM 'synthetic_data/hospitals.csv' WITH (FORMAT csv, HEADER true);
\copy raw.doctors FROM 'synthetic_data/doctors.csv' WITH (FORMAT csv, HEADER true);
\copy raw.medications FROM 'synthetic_data/medications.csv' WITH (FORMAT csv, HEADER true);
\copy raw.procedures FROM 'synthetic_data/procedures.csv' WITH (FORMAT csv, HEADER true);
\copy raw.insurance_providers FROM 'synthetic_data/insurance_providers.csv' WITH (FORMAT csv, HEADER true);
\copy raw.patients FROM 'synthetic_data/patients.csv' WITH (FORMAT csv, HEADER true);
\copy raw.patient_insurance FROM 'synthetic_data/patient_insurance.csv' WITH (FORMAT csv, HEADER true);
\copy raw.prescriptions FROM 'synthetic_data/prescriptions.csv' WITH (FORMAT csv, HEADER true);
\copy raw.hospital_visits FROM 'synthetic_data/hospital_visits.csv' WITH (FORMAT csv, HEADER true);

-- Quick sanity check
SELECT 'raw.patients' AS table_name, COUNT(*) FROM raw.patients
UNION ALL SELECT 'raw.hospital_visits', COUNT(*) FROM raw.hospital_visits
UNION ALL SELECT 'raw.prescriptions', COUNT(*) FROM raw.prescriptions;
