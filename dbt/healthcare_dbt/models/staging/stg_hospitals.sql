select distinct on (hospital_id)
    hospital_id,
    trim(hospital_name) as hospital_name,
    address_id,
    trim(hospital_phone_no) as hospital_phone_no
from {{ source('raw', 'hospitals') }}
order by hospital_id
