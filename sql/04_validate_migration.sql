-- =====================================================================
-- VALIDATE MIGRATION (Postgres)
-- =====================================================================

SELECT 'raw.patients' AS table_name, COUNT(*) AS row_count FROM raw.patients
UNION ALL
SELECT 'staging.patients', COUNT(*) FROM staging.patients
UNION ALL
SELECT 'analytics.patient_dim', COUNT(*) FROM analytics.patient_dim
UNION ALL
SELECT 'raw.hospital_visits', COUNT(*) FROM raw.hospital_visits
UNION ALL
SELECT 'staging.hospital_visits', COUNT(*) FROM staging.hospital_visits
UNION ALL
SELECT 'analytics.hospital_visit_fact', COUNT(*) FROM analytics.hospital_visit_fact
UNION ALL
SELECT 'raw.prescriptions', COUNT(*) FROM raw.prescriptions
UNION ALL
SELECT 'staging.prescriptions', COUNT(*) FROM staging.prescriptions
UNION ALL
SELECT 'analytics.prescription_fact', COUNT(*) FROM analytics.prescription_fact
ORDER BY table_name;
