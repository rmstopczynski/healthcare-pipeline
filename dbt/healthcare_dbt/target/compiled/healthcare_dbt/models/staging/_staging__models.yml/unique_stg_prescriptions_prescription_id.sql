
    
    

select
    prescription_id as unique_field,
    count(*) as n_records

from "healthcare_db"."staging"."stg_prescriptions"
where prescription_id is not null
group by prescription_id
having count(*) > 1


