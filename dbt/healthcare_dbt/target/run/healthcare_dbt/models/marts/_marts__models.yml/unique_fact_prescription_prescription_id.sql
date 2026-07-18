
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    prescription_id as unique_field,
    count(*) as n_records

from "healthcare_db"."analytics"."fact_prescription"
where prescription_id is not null
group by prescription_id
having count(*) > 1



  
  
      
    ) dbt_internal_test