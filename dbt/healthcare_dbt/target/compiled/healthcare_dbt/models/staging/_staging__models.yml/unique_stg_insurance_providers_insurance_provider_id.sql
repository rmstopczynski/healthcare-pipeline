
    
    

select
    insurance_provider_id as unique_field,
    count(*) as n_records

from "healthcare_db"."staging"."stg_insurance_providers"
where insurance_provider_id is not null
group by insurance_provider_id
having count(*) > 1


