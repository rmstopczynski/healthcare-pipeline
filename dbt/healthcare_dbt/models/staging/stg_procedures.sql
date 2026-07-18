select distinct on (procedure_id)
    procedure_id,
    trim(procedure_name) as procedure_name,
    trim(medical_category) as medical_category,
    procedure_charge
from {{ source('raw', 'procedures') }}
order by procedure_id
