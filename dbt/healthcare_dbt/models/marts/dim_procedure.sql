select
    procedure_id,
    procedure_name,
    medical_category
from {{ ref('stg_procedures') }}
