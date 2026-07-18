
    
    

select
    visit_id as unique_field,
    count(*) as n_records

from "healthcare_db"."staging"."stg_hospital_visits"
where visit_id is not null
group by visit_id
having count(*) > 1


