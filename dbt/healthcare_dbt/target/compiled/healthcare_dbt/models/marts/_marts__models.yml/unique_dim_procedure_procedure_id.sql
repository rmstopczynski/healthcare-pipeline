
    
    

select
    procedure_id as unique_field,
    count(*) as n_records

from "healthcare_db"."analytics"."dim_procedure"
where procedure_id is not null
group by procedure_id
having count(*) > 1


