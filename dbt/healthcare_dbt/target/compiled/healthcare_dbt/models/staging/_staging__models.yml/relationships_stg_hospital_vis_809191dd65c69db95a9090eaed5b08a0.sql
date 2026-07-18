
    
    

with child as (
    select hospital_id as from_field
    from "healthcare_db"."staging"."stg_hospital_visits"
    where hospital_id is not null
),

parent as (
    select hospital_id as to_field
    from "healthcare_db"."staging"."stg_hospitals"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


