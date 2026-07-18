
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select insurance_provider_id
from "healthcare_db"."staging"."stg_insurance_providers"
where insurance_provider_id is null



  
  
      
    ) dbt_internal_test