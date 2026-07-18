select distinct on (medication_id)
    medication_id,
    trim(medication_name) as medication_name,
    trim(pharma_company) as pharma_company,
    trim(category) as category,
    medication_cost
from "healthcare_db"."raw"."medications"
order by medication_id