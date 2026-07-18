
    
    

select
    doctor_id as unique_field,
    count(*) as n_records

from "healthcare_db"."analytics"."dim_doctor"
where doctor_id is not null
group by doctor_id
having count(*) > 1


