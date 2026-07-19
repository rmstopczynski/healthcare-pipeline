"""
Simulates real-time healthcare events (admissions, lab results, vital
signs) and publishes them to the "patient-events" Kafka topic as JSON.

This is the "Patient Event -> Kafka Topic" leg of the roadmap's Step 7
diagram. Events are generated with a small random delay between sends
to simulate arrival over time, rather than one instantaneous burst.

Run via: docker exec healthcare_airflow python3 /opt/airflow/data/kafka_producer.py
(or scripts/run_kafka_producer.sh, which wraps that)
"""

import json
import os
import random
import time
import uuid
from datetime import datetime, timezone

from faker import Faker
from kafka import KafkaProducer

fake = Faker()

BOOTSTRAP_SERVERS = os.environ.get("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
TOPIC = os.environ.get("KAFKA_TOPIC", "patient-events")
NUM_EVENTS = int(os.environ.get("NUM_EVENTS", "150"))
MIN_DELAY = 0.02
MAX_DELAY = 0.15

# Matches the patient_id range used by generate_synthetic_data.py, so
# these events plausibly reference "real" patients from the rest of the
# pipeline, even though there's no enforced FK relationship.
PATIENT_ID_RANGE = (1, 250)

LAB_TESTS = [
    ("Glucose", "mg/dL", (70, 99)),
    ("Hemoglobin", "g/dL", (12.0, 17.5)),
    ("White Blood Cell Count", "10^3/uL", (4.5, 11.0)),
    ("Creatinine", "mg/dL", (0.6, 1.3)),
    ("Potassium", "mmol/L", (3.5, 5.1)),
    ("Sodium", "mmol/L", (135, 145)),
]

ADMISSION_TYPES = ["Emergency", "Elective", "Urgent", "Newborn"]


def make_admission_event():
    return {
        "event_type": "admission",
        "patient_id": random.randint(*PATIENT_ID_RANGE),
        "admission_type": random.choice(ADMISSION_TYPES),
        "room_no": str(random.randint(100, 499)),
        "diagnosis": fake.sentence(nb_words=4).rstrip("."),
    }


def make_lab_result_event():
    test_name, unit, (low, high) = random.choice(LAB_TESTS)
    # ~15% chance of generating an out-of-range ("abnormal") result
    if random.random() < 0.15:
        value = round(random.uniform(high * 1.1, high * 1.5), 1)
        abnormal = True
    else:
        value = round(random.uniform(low, high), 1)
        abnormal = False
    return {
        "event_type": "lab_result",
        "patient_id": random.randint(*PATIENT_ID_RANGE),
        "test_name": test_name,
        "result_value": value,
        "unit": unit,
        "reference_range": f"{low}-{high}",
        "abnormal_flag": abnormal,
    }


def make_vital_sign_event():
    return {
        "event_type": "vital_sign",
        "patient_id": random.randint(*PATIENT_ID_RANGE),
        "heart_rate_bpm": random.randint(55, 110),
        "systolic_bp": random.randint(95, 150),
        "diastolic_bp": random.randint(60, 95),
        "temperature_f": round(random.uniform(97.0, 100.5), 1),
        "spo2_pct": random.randint(93, 100),
    }


EVENT_GENERATORS = [make_admission_event, make_lab_result_event, make_vital_sign_event]
# Vitals and labs are checked far more often than admissions happen.
EVENT_WEIGHTS = [0.15, 0.40, 0.45]


def main():
    producer = KafkaProducer(
        bootstrap_servers=BOOTSTRAP_SERVERS,
        value_serializer=lambda v: json.dumps(v).encode("utf-8"),
    )

    print(f"Publishing {NUM_EVENTS} events to '{TOPIC}' on {BOOTSTRAP_SERVERS} ...")
    counts = {"admission": 0, "lab_result": 0, "vital_sign": 0}

    for i in range(NUM_EVENTS):
        generator = random.choices(EVENT_GENERATORS, weights=EVENT_WEIGHTS, k=1)[0]
        event = generator()
        event["event_id"] = str(uuid.uuid4())
        event["event_time"] = datetime.now(timezone.utc).isoformat()

        producer.send(TOPIC, value=event)
        counts[event["event_type"]] += 1

        if (i + 1) % 25 == 0:
            print(f"  ... {i + 1}/{NUM_EVENTS} sent")

        time.sleep(random.uniform(MIN_DELAY, MAX_DELAY))

    producer.flush()
    producer.close()

    print(f"Done. Sent {counts['admission']} admissions, "
          f"{counts['lab_result']} lab results, {counts['vital_sign']} vital signs.")


if __name__ == "__main__":
    main()
