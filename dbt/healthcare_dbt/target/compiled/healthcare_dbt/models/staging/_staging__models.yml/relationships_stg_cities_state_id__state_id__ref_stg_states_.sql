
    
    

with child as (
    select state_id as from_field
    from "healthcare_db"."staging"."stg_cities"
    where state_id is not null
),

parent as (
    select state_id as to_field
    from "healthcare_db"."staging"."stg_states"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


