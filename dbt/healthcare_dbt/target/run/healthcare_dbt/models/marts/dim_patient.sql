
  
    

  create  table "healthcare_db"."analytics"."dim_patient__dbt_tmp"
  
  
    as
  
  (
    with ranked_insurance as (
    select
        pi.patient_id,
        ip.provider_name,
        ip.plan_type,
        row_number() over (partition by pi.patient_id order by ip.insurance_provider_id) as rn
    from "healthcare_db"."staging"."stg_patient_insurance" pi
    join "healthcare_db"."staging"."stg_insurance_providers" ip on pi.insurance_provider_id = ip.insurance_provider_id
)

select
    p.patient_id,
    p.first_name,
    p.last_name,
    p.dob,
    extract(year from age(current_date, p.dob))::integer as age,
    case
        when extract(year from age(current_date, p.dob)) < 18 then 'Under 18'
        when extract(year from age(current_date, p.dob)) between 18 and 34 then '18-34'
        when extract(year from age(current_date, p.dob)) between 35 and 54 then '35-54'
        when extract(year from age(current_date, p.dob)) between 55 and 74 then '55-74'
        else '75+'
    end as age_group,
    p.sex,
    cast(null as varchar) as patient_phone_no,  -- not present in source
    p.blood_type,
    pri.provider_name  as primary_insur_prov,
    pri.plan_type      as primary_plan_type,
    sec.provider_name  as secondary_insur_prov,
    sec.plan_type      as secondary_plan_type
from "healthcare_db"."staging"."stg_patients" p
left join ranked_insurance pri on p.patient_id = pri.patient_id and pri.rn = 1
left join ranked_insurance sec on p.patient_id = sec.patient_id and sec.rn = 2
  );
  