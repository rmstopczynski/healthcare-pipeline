
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select procedure_id as from_field
    from "healthcare_db"."staging"."stg_hospital_visits"
    where procedure_id is not null
),

parent as (
    select procedure_id as to_field
    from "healthcare_db"."staging"."stg_procedures"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test