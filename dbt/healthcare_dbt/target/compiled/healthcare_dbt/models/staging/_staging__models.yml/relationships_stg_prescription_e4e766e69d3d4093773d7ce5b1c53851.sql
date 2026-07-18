
    
    

with child as (
    select medication_id as from_field
    from "healthcare_db"."staging"."stg_prescriptions"
    where medication_id is not null
),

parent as (
    select medication_id as to_field
    from "healthcare_db"."staging"."stg_medications"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


