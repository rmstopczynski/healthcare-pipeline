
    
    

with child as (
    select procedure_id as from_field
    from "healthcare_db"."analytics"."fact_hospital_visit"
    where procedure_id is not null
),

parent as (
    select procedure_id as to_field
    from "healthcare_db"."analytics"."dim_procedure"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


