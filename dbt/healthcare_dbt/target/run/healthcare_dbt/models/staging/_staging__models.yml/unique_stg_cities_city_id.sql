
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    city_id as unique_field,
    count(*) as n_records

from "healthcare_db"."staging"."stg_cities"
where city_id is not null
group by city_id
having count(*) > 1



  
  
      
    ) dbt_internal_test