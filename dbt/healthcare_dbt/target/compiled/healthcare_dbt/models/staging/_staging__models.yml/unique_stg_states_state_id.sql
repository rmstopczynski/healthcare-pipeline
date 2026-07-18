
    
    

select
    state_id as unique_field,
    count(*) as n_records

from "healthcare_db"."staging"."stg_states"
where state_id is not null
group by state_id
having count(*) > 1


