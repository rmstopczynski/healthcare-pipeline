
    
    

select
    visit_id as unique_field,
    count(*) as n_records

from "healthcare_db"."analytics"."fact_hospital_visit"
where visit_id is not null
group by visit_id
having count(*) > 1


