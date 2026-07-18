
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select admission_date as from_field
    from "healthcare_db"."analytics"."fact_hospital_visit"
    where admission_date is not null
),

parent as (
    select julian_day as to_field
    from "healthcare_db"."analytics"."dim_date"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test