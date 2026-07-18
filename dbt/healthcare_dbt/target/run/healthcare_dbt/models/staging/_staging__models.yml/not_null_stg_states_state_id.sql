
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select state_id
from "healthcare_db"."staging"."stg_states"
where state_id is null



  
  
      
    ) dbt_internal_test