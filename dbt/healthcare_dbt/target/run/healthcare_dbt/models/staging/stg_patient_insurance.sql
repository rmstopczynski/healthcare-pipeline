
  create view "healthcare_db"."staging"."stg_patient_insurance__dbt_tmp"
    
    
  as (
    select distinct
    patient_id,
    insurance_provider_id
from "healthcare_db"."raw"."patient_insurance"
  );