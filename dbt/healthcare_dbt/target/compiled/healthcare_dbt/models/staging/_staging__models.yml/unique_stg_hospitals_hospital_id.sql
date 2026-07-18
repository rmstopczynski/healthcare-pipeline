
    
    

select
    hospital_id as unique_field,
    count(*) as n_records

from "healthcare_db"."staging"."stg_hospitals"
where hospital_id is not null
group by hospital_id
having count(*) > 1


