
    
    

select
    doctor_id as unique_field,
    count(*) as n_records

from "healthcare_db"."staging"."stg_doctors"
where doctor_id is not null
group by doctor_id
having count(*) > 1


