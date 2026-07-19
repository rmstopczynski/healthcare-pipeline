-- =====================================================================
-- STREAMING TABLES
-- Destination for events consumed off the "patient-events" Kafka topic.
-- One table, JSONB payload column -- admissions, lab results, and vital
-- signs all land here with different payload shapes, distinguished by
-- event_type. This is a common real-world pattern for event streams:
-- normalize into typed tables downstream (in dbt/SQL) once you know
-- which event shapes actually matter, rather than pre-designing a
-- rigid schema per event type before you've seen real traffic.
-- =====================================================================

CREATE TABLE IF NOT EXISTS streaming.patient_events (
    event_id     UUID PRIMARY KEY,
    event_type   VARCHAR(50) NOT NULL,   -- 'admission', 'lab_result', 'vital_sign'
    patient_id   INTEGER NOT NULL,
    event_time   TIMESTAMP NOT NULL,
    payload      JSONB NOT NULL,
    consumed_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_patient_events_type ON streaming.patient_events (event_type);
CREATE INDEX IF NOT EXISTS idx_patient_events_patient ON streaming.patient_events (patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_events_time ON streaming.patient_events (event_time);
