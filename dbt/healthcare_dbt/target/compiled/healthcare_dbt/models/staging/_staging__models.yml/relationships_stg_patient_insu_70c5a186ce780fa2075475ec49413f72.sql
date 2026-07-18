
    
    

with child as (
    select insurance_provider_id as from_field
    from "healthcare_db"."staging"."stg_patient_insurance"
    where insurance_provider_id is not null
),

parent as (
    select insurance_provider_id as to_field
    from "healthcare_db"."staging"."stg_insurance_providers"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


