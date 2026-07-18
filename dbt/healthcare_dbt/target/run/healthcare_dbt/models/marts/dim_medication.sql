
  
    

  create  table "healthcare_db"."analytics"."dim_medication__dbt_tmp"
  
  
    as
  
  (
    select
    medication_id,
    medication_name,
    pharma_company,
    category
from "healthcare_db"."staging"."stg_medications"
  );
  