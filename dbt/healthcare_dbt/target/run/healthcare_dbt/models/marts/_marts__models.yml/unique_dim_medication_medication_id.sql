
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    medication_id as unique_field,
    count(*) as n_records

from "healthcare_db"."analytics"."dim_medication"
where medication_id is not null
group by medication_id
having count(*) > 1



  
  
      
    ) dbt_internal_test