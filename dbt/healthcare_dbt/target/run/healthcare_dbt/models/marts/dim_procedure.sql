
  
    

  create  table "healthcare_db"."analytics"."dim_procedure__dbt_tmp"
  
  
    as
  
  (
    select
    procedure_id,
    procedure_name,
    medical_category
from "healthcare_db"."staging"."stg_procedures"
  );
  