
  
    

  create  table "healthcare_db"."analytics"."fact_prescription__dbt_tmp"
  
  
    as
  
  (
    select
    rx.prescription_id,
    rx.patient_id,
    rx.doctor_id,
    rx.medication_id,
    to_char(rx.prescribed_date, 'YYYYMMDD')::integer as prescribed_date,
    rx.quantity,
    rx.dosage,
    rx.frequency,
    m.medication_cost,
    rx.quantity * m.medication_cost as total_cost,
    rx.refill_allowed,
    rx.refill_count
from "healthcare_db"."staging"."stg_prescriptions" rx
left join "healthcare_db"."staging"."stg_medications" m on rx.medication_id = m.medication_id
  );
  