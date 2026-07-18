
  create view "healthcare_db"."staging"."stg_insurance_providers__dbt_tmp"
    
    
  as (
    select distinct on (insurance_provider_id)
    insurance_provider_id,
    trim(provider_name) as provider_name,
    trim(plan_type) as plan_type,
    trim(phone_no) as phone_no
from "healthcare_db"."raw"."insurance_providers"
order by insurance_provider_id
  );