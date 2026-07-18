select distinct on (address_id)
    address_id,
    trim(street_address) as street_address,
    city_id,
    trim(zip) as zip
from {{ source('raw', 'addresses') }}
order by address_id
