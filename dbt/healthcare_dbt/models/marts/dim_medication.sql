select
    medication_id,
    medication_name,
    pharma_company,
    category
from {{ ref('stg_medications') }}
