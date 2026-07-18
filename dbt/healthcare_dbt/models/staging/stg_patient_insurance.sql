select distinct
    patient_id,
    insurance_provider_id
from {{ source('raw', 'patient_insurance') }}
