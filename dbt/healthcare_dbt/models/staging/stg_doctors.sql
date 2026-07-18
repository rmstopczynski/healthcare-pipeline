select distinct on (doctor_id)
    doctor_id,
    trim(first_name) as first_name,
    trim(last_name) as last_name,
    hospital_affi,
    trim(specialty) as specialty,
    trim(doc_phone_no) as doc_phone_no
from {{ source('raw', 'doctors') }}
order by doctor_id
