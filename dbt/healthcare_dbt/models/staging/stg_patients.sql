select distinct on (patient_id)
    patient_id,
    trim(first_name) as first_name,
    trim(last_name) as last_name,
    dob,
    upper(trim(sex)) as sex,
    upper(trim(blood_type)) as blood_type
from {{ source('raw', 'patients') }}
order by patient_id
