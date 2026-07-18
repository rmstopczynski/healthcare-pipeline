select
    hv.visit_id,
    to_char(hv.admission_date, 'YYYYMMDD')::integer as admission_date,
    to_char(hv.discharge_date, 'YYYYMMDD')::integer as discharge_date,
    hv.patient_id,
    hv.doctor_id,
    hosp.hospital_name  as hospital,
    ip.provider_name     as insurance_provider,
    hv.room_no,
    hv.admission_type,
    hv.diagnosis,
    hv.procedure_id,
    proc.procedure_charge,
    cast(null as numeric) as room_charge,  -- not present in source
    cast(null as numeric) as misc_charge,  -- not present in source
    coalesce(proc.procedure_charge, 0) as billing_amount,
    (hv.discharge_date - hv.admission_date) as length_of_stay
from "healthcare_db"."staging"."stg_hospital_visits" hv
left join "healthcare_db"."staging"."stg_hospitals" hosp on hv.hospital_id = hosp.hospital_id
left join "healthcare_db"."staging"."stg_insurance_providers" ip on hv.insurance_provider_id = ip.insurance_provider_id
left join "healthcare_db"."staging"."stg_procedures" proc on hv.procedure_id = proc.procedure_id