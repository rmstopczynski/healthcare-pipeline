
    
    

with child as (
    select doctor_id as from_field
    from "healthcare_db"."analytics"."fact_hospital_visit"
    where doctor_id is not null
),

parent as (
    select doctor_id as to_field
    from "healthcare_db"."analytics"."dim_doctor"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


