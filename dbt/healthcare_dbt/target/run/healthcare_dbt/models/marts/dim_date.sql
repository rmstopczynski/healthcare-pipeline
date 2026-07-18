
  
    

  create  table "healthcare_db"."analytics"."dim_date__dbt_tmp"
  
  
    as
  
  (
    

with days as (
    select generate_series(
        '2010-01-01'::date,
        '2029-12-31'::date,
        '1 day'::interval
    )::date as actual_dt
)

select
    to_char(actual_dt, 'YYYYMMDD')::integer as julian_day,
    actual_dt,
    trim(to_char(actual_dt, 'Day'))          as day_name,
    to_char(actual_dt, 'Dy')                 as day_abbrev,
    extract(doy from actual_dt)::integer     as day_in_year,
    extract(day from actual_dt)::integer     as day_in_month,
    extract(isodow from actual_dt)::integer  as day_in_week,
    trim(to_char(actual_dt, 'Month'))        as month_name,
    to_char(actual_dt, 'Mon')                as month_abbrev,
    extract(month from actual_dt)::integer   as month_num,
    to_char(actual_dt, 'YYYY')               as year_name,
    extract(year from actual_dt)::integer    as year_num,
    extract(quarter from actual_dt)::integer as quarter
from days
  );
  