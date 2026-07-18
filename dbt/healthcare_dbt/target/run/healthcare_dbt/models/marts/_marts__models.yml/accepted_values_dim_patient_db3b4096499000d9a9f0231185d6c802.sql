
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        age_group as value_field,
        count(*) as n_records

    from "healthcare_db"."analytics"."dim_patient"
    group by age_group

)

select *
from all_values
where value_field not in (
    'Under 18','18-34','35-54','55-74','75+'
)



  
  
      
    ) dbt_internal_test