
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    state_id as unique_field,
    count(*) as n_records

from "healthcare_db"."staging"."stg_states"
where state_id is not null
group by state_id
having count(*) > 1



  
  
      
    ) dbt_internal_test