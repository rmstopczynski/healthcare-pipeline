
  create view "healthcare_db"."staging"."stg_states__dbt_tmp"
    
    
  as (
    select distinct on (state_id)
    state_id,
    trim(state_name) as state_name,
    upper(trim(state_abbr)) as state_abbr
from "healthcare_db"."raw"."states"
order by state_id
  );