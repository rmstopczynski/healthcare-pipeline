
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    julian_day as unique_field,
    count(*) as n_records

from "healthcare_db"."analytics"."dim_date"
where julian_day is not null
group by julian_day
having count(*) > 1



  
  
      
    ) dbt_internal_test