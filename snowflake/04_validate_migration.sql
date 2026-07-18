-- =====================================================================
-- STEP 7: VALIDATE MIGRATION
-- Run these after loading RAW and running the STAGING/ANALYTICS
-- transforms. Row counts should match your old Oracle counts at the
-- RAW layer, and stay consistent (or explainably shrink, if you deduped)
-- through STAGING.
-- =====================================================================

USE DATABASE HEALTHCARE_DB;

SELECT 'RAW.PATIENTS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM RAW.PATIENTS
UNION ALL
SELECT 'STAGING.PATIENTS', COUNT(*) FROM STAGING.PATIENTS
UNION ALL
SELECT 'ANALYTICS.PATIENT_DIM', COUNT(*) FROM ANALYTICS.PATIENT_DIM
UNION ALL
SELECT 'RAW.HOSPITAL_VISITS', COUNT(*) FROM RAW.HOSPITAL_VISITS
UNION ALL
SELECT 'STAGING.HOSPITAL_VISITS', COUNT(*) FROM STAGING.HOSPITAL_VISITS
UNION ALL
SELECT 'ANALYTICS.HOSPITAL_VISIT_FACT', COUNT(*) FROM ANALYTICS.HOSPITAL_VISIT_FACT
UNION ALL
SELECT 'RAW.PRESCRIPTIONS', COUNT(*) FROM RAW.PRESCRIPTIONS
UNION ALL
SELECT 'STAGING.PRESCRIPTIONS', COUNT(*) FROM STAGING.PRESCRIPTIONS
UNION ALL
SELECT 'ANALYTICS.PRESCRIPTION_FACT', COUNT(*) FROM ANALYTICS.PRESCRIPTION_FACT
ORDER BY TABLE_NAME;

-- If old Oracle counts are: patients=100000, hospital_visits=X, prescriptions=Y
-- compare against RAW counts above — RAW should match exactly.
-- STAGING may be lower if duplicate keys were removed (expected).
-- ANALYTICS fact tables may be lower if a row's PATIENT_ID or DOCTOR_ID
-- had no valid match after joins — investigate any drop there.
