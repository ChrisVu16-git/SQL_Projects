# XS Espresso Python ETL

This folder adds a reproducible **Extract → Validate/Transform → Load** workflow for the three original **headerless** XS Espresso CSV exports. It uses the existing `sql/01_schema.sql` definitions; it does **not** generate substitute data or alter raw CSVs.

## Inputs

| Expected filename | Existing target table | Grain |
|---|---|---|
| `dim_store.csv` | `xs.dim_store` | Store |
| `xs.fact_daily_financial.csv` | `xs.fact_daily_financial` | Store × date |
| `xs.fact_hourly_demand.csv` | `xs.fact_hourly_demand` | Store × date × hour |

Place the three CSVs in `XS Espresso Analytics/data/`. Only `dim_store.csv` is included in the public repository as of this implementation. Keep large raw exports local; they are not included in this commit. Source files must be headerless and have exactly the column order documented in `run_etl.py`.

## Local setup

Run these commands from the **XS Espresso Analytics project directory**:

```bash
python -m pip install -r etl/requirements.txt
python etl/run_etl.py --data-dir data
python -m pytest etl/tests -q
```

The first run **validates only** and does not modify PostgreSQL. The program prints record counts and validation statuses and exits nonzero if a check fails.

For database loading, set `DATABASE_URL` in your local shell (do not commit credentials):

```powershell
# Windows PowerShell example
$env:DATABASE_URL = "postgresql://USER:PASSWORD@localhost:5432/xs_espresso"
python etl/run_etl.py --data-dir data --load
```

The `xs` schema and tables must already exist (see `sql/01_schema.sql`). For a brand-new database, optionally run `python etl/run_etl.py --data-dir data --load --init-schema`. Only use this on a controlled database you are allowed to modify.

## ETL behavior and checks

**Extract:** Read all three files using pandas with explicit, real source column names. Parse dates and numbers and reject invalid records.

**Validate:** Confirm unique store IDs, unique store/date and store/date/hour keys, store foreign keys, financial arithmetic, valid trading hour, valid dates, daily cost/profit calculations, and store-day reconciliation of hourly net sales and transactions to daily totals. An AUD tolerance of 0.011 is applied to financial comparisons.

**Load:** Only after validation passes, the optional `--load` writes all three tables into the existing PostgreSQL `xs` schema using psycopg 3 `COPY`. The database operations run in a single connection transaction and roll back if an error occurs.

**Important:** `--load` uses `TRUNCATE` and a full reload for these three tables. Do not run it on production or irreplaceable tables. The three-table reload is *not* an incremental upsert. No payroll, monthly P&L, or transaction-level source exports are present, so this pipeline does not claim to validate those reconciliations. The existing SQL project contains additional quality-check queries for the complete dataset.

## Verification status

The three original uploaded CSV exports were previously validated and reconciled locally. The checked-in pipeline supports the same data contract. **A live PostgreSQL load was not executed in this session** and should be tested against your local PostgreSQL database before treating the pipeline as deployment-ready.

## Next steps

Add separate source files and ETL mappings for transaction-level sales, payroll shifts, and monthly P&L when those exports are available. Use `sql/03_quality_checks.sql` to validate the full, multi-grain model after all source tables have been loaded.
