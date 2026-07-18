select distinct on (city_id)
    city_id,
    trim(city_name) as city_name,
    state_id
from {{ source('raw', 'cities') }}
order by city_id
