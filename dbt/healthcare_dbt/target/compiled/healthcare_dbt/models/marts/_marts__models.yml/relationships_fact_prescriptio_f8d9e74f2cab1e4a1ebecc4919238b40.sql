
    
    

with child as (
    select patient_id as from_field
    from "healthcare_db"."analytics"."fact_prescription"
    where patient_id is not null
),

parent as (
    select patient_id as to_field
    from "healthcare_db"."analytics"."dim_patient"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


