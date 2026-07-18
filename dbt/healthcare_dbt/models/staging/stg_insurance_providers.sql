select distinct on (insurance_provider_id)
    insurance_provider_id,
    trim(provider_name) as provider_name,
    trim(plan_type) as plan_type,
    trim(phone_no) as phone_no
from {{ source('raw', 'insurance_providers') }}
order by insurance_provider_id
