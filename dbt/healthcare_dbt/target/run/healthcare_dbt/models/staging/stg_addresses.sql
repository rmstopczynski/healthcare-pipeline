
  create view "healthcare_db"."staging"."stg_addresses__dbt_tmp"
    
    
  as (
    select distinct on (address_id)
    address_id,
    trim(street_address) as street_address,
    city_id,
    trim(zip) as zip
from "healthcare_db"."raw"."addresses"
order by address_id
  );