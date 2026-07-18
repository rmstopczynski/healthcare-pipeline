select distinct on (state_id)
    state_id,
    trim(state_name) as state_name,
    upper(trim(state_abbr)) as state_abbr
from {{ source('raw', 'states') }}
order by state_id
