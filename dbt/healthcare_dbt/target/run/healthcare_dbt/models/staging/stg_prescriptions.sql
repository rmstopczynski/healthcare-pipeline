
  create view "healthcare_db"."staging"."stg_prescriptions__dbt_tmp"
    
    
  as (
    select distinct on (prescription_id)
    prescription_id,
    patient_id,
    doctor_id,
    medication_id,
    quantity,
    trim(dosage) as dosage,
    trim(frequency) as frequency,
    prescribed_date,
    refill_allowed,
    refill_count
from "healthcare_db"."raw"."prescriptions"
order by prescription_id
  );