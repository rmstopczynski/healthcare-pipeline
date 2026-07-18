
    
    

select
    julian_day as unique_field,
    count(*) as n_records

from "healthcare_db"."analytics"."dim_date"
where julian_day is not null
group by julian_day
having count(*) > 1


