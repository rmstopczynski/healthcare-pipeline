
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select julian_day
from "healthcare_db"."analytics"."dim_date"
where julian_day is null



  
  
      
    ) dbt_internal_test