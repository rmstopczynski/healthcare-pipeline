
  
    

  create  table "healthcare_db"."analytics"."dim_doctor__dbt_tmp"
  
  
    as
  
  (
    select
    doc.doctor_id,
    doc.first_name,
    doc.last_name,
    doc.specialty,
    doc.doc_phone_no,
    hosp.hospital_name       as hospital_affi,
    st.state_name             as hospital_state,
    ci.city_name               as hospital_city,
    addr.zip                    as hospital_zip,
    hosp.hospital_phone_no
from "healthcare_db"."staging"."stg_doctors" doc
left join "healthcare_db"."staging"."stg_hospitals" hosp on doc.hospital_affi = hosp.hospital_id
left join "healthcare_db"."staging"."stg_addresses" addr on hosp.address_id = addr.address_id
left join "healthcare_db"."staging"."stg_cities" ci on addr.city_id = ci.city_id
left join "healthcare_db"."staging"."stg_states" st on ci.state_id = st.state_id
  );
  