# Airflow Orchestration Layer

Turns the manual command sequence (generate synthetic data → load into
`raw` → `dbt run` → `dbt test` → validate) into a scheduled, monitored
Airflow DAG.

## What gets added

```
healthcare-pipeline/
├── docker-compose.yml          <- replaces your existing one (adds an "airflow" service)
├── Dockerfile.airflow          <- new: official Airflow image + psql + dbt
├── dags/
│   └── healthcare_pipeline_dag.py
└── airflow_profiles/
    └── profiles.yml            <- dbt profile used ONLY inside the Airflow container
```

`airflow_profiles/profiles.yml` is separate from `dbt/profiles.yml.sample`.
Same database, different hostname: your host machine reaches Postgres at
`127.0.0.1`, but the Airflow container reaches it at `postgres` (the
docker-compose service name) — containers talk to each other over
Docker's internal network, not through your machine's loopback address.

## Setup

1. **Replace your `docker-compose.yml`** with the one in this bundle (or
   manually merge the `airflow` service block into your existing file —
   the new one is a strict superset, nothing was removed).
2. **Copy `Dockerfile.airflow`** into your repo root, alongside
   `docker-compose.yml`.
3. **Copy `dags/` and `airflow_profiles/`** into your repo root.

## Running it

```bash
docker compose up -d --build
```

The `--build` matters here specifically — it's what triggers building the
custom Airflow image (installing psql + dbt on top of the base image).
First run will take several minutes; subsequent runs reuse the built
image and start in seconds.

Watch the logs until it's ready:
```bash
docker logs -f healthcare_airflow
```
Look for a line containing `Airflow is ready` and a printed
username/password (standalone mode auto-generates an admin login on
first boot — it's usually `admin` / a random password printed directly
in the logs, sometimes also saved to a `standalone_admin_password.txt`
file inside the container).

## Using it

1. Open **http://localhost:8083**
2. Log in with the admin credentials from the logs
3. Find `healthcare_pipeline` in the DAG list
4. Click the toggle to un-pause it (if not already active)
5. Click the ▶ (Trigger DAG) button to run it manually right now, or just
   wait — it's scheduled `@daily`

Click into a run to see the graph view: five tasks in a line
(`generate_synthetic_data → load_raw_data → dbt_run → dbt_test →
validate_migration`), each one colored by status (green = success,
red = failed, sitting on retry = orange). Click any task box → **Logs**
to see exactly what it did — this is the same output you'd get running
the command by hand, just captured and organized per-task.

## Why this matters over just running the commands yourself

- **Retries** — each task retries once automatically on failure (configured
  in `default_args` in the DAG file) before it's marked failed
- **Scheduling** — `@daily` means this can run unattended every day without
  you remembering to kick it off
- **Observability** — task-level logs, run history, and a visual graph of
  what succeeded/failed and when, instead of scrolling back through
  terminal history
- **Dependency enforcement** — Airflow won't run `dbt_test` if `dbt_run`
  failed; the manual command sequence has no such guardrail

## A note on "standalone" mode

This uses Airflow's `standalone` command — a single container, SQLite
metadata database, `SequentialExecutor`. That's a deliberate simplification
for a local demo project: it's one command instead of the ~5 services
(webserver, scheduler, worker, Redis, Postgres-for-Airflow-itself) that
`CeleryExecutor` production setups require. It also means everything runs
sequentially, one task at a time — fine here, since the DAG's tasks are
already meant to run in strict order anyway. If you wanted to demonstrate
parallel task execution for a portfolio piece, that would need
`LocalExecutor` with a dedicated Postgres metadata database instead —
worth mentioning as a known simplification if this comes up in an
interview.
