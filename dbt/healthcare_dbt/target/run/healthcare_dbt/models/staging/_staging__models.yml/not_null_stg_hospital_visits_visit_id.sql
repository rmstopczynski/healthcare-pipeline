
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select visit_id
from "healthcare_db"."staging"."stg_hospital_visits"
where visit_id is null



  
  
      
    ) dbt_internal_test