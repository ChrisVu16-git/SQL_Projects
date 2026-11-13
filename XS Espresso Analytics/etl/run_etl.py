"""Validate headerless XS Espresso CSV exports and optionally load PostgreSQL.

Run from project root:
    python etl/run_etl.py --data-dir data
    python etl/run_etl.py --data-dir data --load

The original CSV files are never modified. PostgreSQL changes are transactional.
"""
import argparse
import os
import sys
from pathlib import Path

import pandas as pd

STORE = [
    "store_id", "store_name", "opening_date_model", "opening_date_precision",
    "ownership_type", "opening_date_source", "notes", "dataset_start",
    "dataset_end", "store_size_model", "base_weekday_sales_aud_model",
    "size_classification_note",
]
DAILY = [
    "date", "store_id", "store_name", "store_size", "trading_status",
    "transactions", "gross_sales_aud", "discount_aud", "net_sales_aud",
    "cogs_aud", "gross_profit_aud", "currency", "year", "gross_wages_aud",
    "employer_super_aud", "total_employer_cost_aud", "paid_hours",
    "operating_expenses_aud", "occupancy_cost_aud",
    "operating_profit_before_central_costs_aud", "delivery_sales_aud",
    "delivery_commission_aud", "month", "day_of_week", "season",
]
HOURLY = [
    "date", "store_id", "hour", "hour_start", "hour_end", "transactions",
    "net_sales_aud", "gross_sales_aud", "discount_aud", "cogs_aud",
    "food_sales_aud", "drink_sales_aud", "forecast_hourly_revenue_aud",
    "forecast_source", "forecast_variance_aud",
]
FILES = {
    "dim_store": ("dim_store.csv", STORE),
    "fact_daily_financial": ("xs.fact_daily_financial.csv", DAILY),
    "fact_hourly_demand": ("xs.fact_hourly_demand.csv", HOURLY),
}
NUMERICS = {
    "dim_store": ["base_weekday_sales_aud_model"],
    "fact_daily_financial": [
        "transactions", "gross_sales_aud", "discount_aud", "net_sales_aud",
        "cogs_aud", "gross_profit_aud", "year", "gross_wages_aud",
        "employer_super_aud", "total_employer_cost_aud", "paid_hours",
        "operating_expenses_aud", "occupancy_cost_aud",
        "operating_profit_before_central_costs_aud", "delivery_sales_aud",
        "delivery_commission_aud",
    ],
    "fact_hourly_demand": [
        "hour", "transactions", "net_sales_aud", "gross_sales_aud",
        "discount_aud", "cogs_aud", "food_sales_aud", "drink_sales_aud",
        "forecast_hourly_revenue_aud", "forecast_variance_aud",
    ],
}
DATE_FIELDS = {
    "dim_store": ["opening_date_model", "dataset_start", "dataset_end"],
    "fact_daily_financial": ["date"],
    "fact_hourly_demand": ["date"],
}
TOLERANCE_AUD = 0.011


class QualityError(Exception):
    pass


def check(condition, description, checks):
    failures = int((~condition).sum())
    checks.append((description, failures))
    if failures:
        raise QualityError(f"{description}: {failures:,} invalid records")


def near(a, b):
    return (a - b).abs() <= TOLERANCE_AUD


def read_csvs(data_dir):
    frames = {}
    for key, (filename, columns) in FILES.items():
        path = data_dir / filename
        if not path.is_file():
            raise QualityError(f"Missing {path}; provide all three source exports")
        # These three exports are headerless: the first line is data.
        frame = pd.read_csv(
            path, header=None, names=columns, encoding="utf-8-sig",
            keep_default_na=False, dtype=str, low_memory=False,
        )
        if frame.empty or frame.shape[1] != len(columns):
            raise QualityError(f"{path}: missing rows or unexpected column count")
        for field in NUMERICS[key]:
            converted = pd.to_numeric(frame[field], errors="coerce")
            if converted.isna().any():
                raise QualityError(f"{filename}: invalid numeric value in {field}")
            frame[field] = converted
        for field in DATE_FIELDS[key]:
            converted = pd.to_datetime(frame[field], format="%Y-%m-%d", errors="coerce")
            if converted.isna().any():
                raise QualityError(f"{filename}: invalid date in {field}")
            frame[field] = converted
        frames[key] = frame
    return frames


def validate(frames):
    store = frames["dim_store"]
    daily = frames["fact_daily_financial"]
    hourly = frames["fact_hourly_demand"]
    checks = []

    def unique(frame, keys, label):
        count = int(frame.duplicated(keys).sum())
        checks.append((label, count))
        if count:
            raise QualityError(f"{label}: {count:,} duplicate keys")

    unique(store, ["store_id"], "Unique store_id")
    unique(daily, ["store_id", "date"], "Unique daily store/date")
    unique(hourly, ["store_id", "date", "hour"], "Unique hourly store/date/hour")
    valid_stores = set(store["store_id"])
    check(daily["store_id"].isin(valid_stores), "Daily store foreign keys", checks)
    check(hourly["store_id"].isin(valid_stores), "Hourly store foreign keys", checks)
    check(daily["transactions"].ge(0), "Daily transactions nonnegative", checks)
    check(hourly["transactions"].ge(0), "Hourly transactions nonnegative", checks)
    check(hourly["hour"].between(0, 23), "Hourly 24-hour clock range", checks)
    check(daily["currency"].eq("AUD"), "Daily currency AUD", checks)
    check(daily["year"].eq(daily["date"].dt.year), "Daily year matches date", checks)
    check(
        daily["month"].eq(daily["date"].dt.strftime("%Y-%m")),
        "Daily month matches date", checks,
    )
    check(
        near(daily["gross_sales_aud"] - daily["discount_aud"], daily["net_sales_aud"]),
        "Daily gross minus discount equals net", checks,
    )
    check(
        near(daily["net_sales_aud"] - daily["cogs_aud"], daily["gross_profit_aud"]),
        "Daily net minus COGS equals gross profit", checks,
    )
    check(
        near(daily["gross_wages_aud"] + daily["employer_super_aud"],
             daily["total_employer_cost_aud"]),
        "Daily wages plus super equals labour cost", checks,
    )
    check(
        near(
            daily["gross_profit_aud"] - daily["total_employer_cost_aud"]
            - daily["operating_expenses_aud"] - daily["occupancy_cost_aud"]
            - daily["delivery_commission_aud"],
            daily["operating_profit_before_central_costs_aud"],
        ),
        "Daily operating profit arithmetic", checks,
    )
    check(
        near(hourly["gross_sales_aud"] - hourly["discount_aud"], hourly["net_sales_aud"]),
        "Hourly gross minus discount equals net", checks,
    )
    check(
        near(hourly["food_sales_aud"] + hourly["drink_sales_aud"],
             hourly["net_sales_aud"]),
        "Hourly food plus drinks equals net", checks,
    )
    check(
        near(hourly["net_sales_aud"] - hourly["forecast_hourly_revenue_aud"],
             hourly["forecast_variance_aud"]),
        "Hourly forecast variance arithmetic", checks,
    )
    aggregates = hourly.groupby(["store_id", "date"], as_index=False).agg(
        hourly_transactions=("transactions", "sum"),
        hourly_net_sales=("net_sales_aud", "sum"),
    )
    comparison = daily[
        ["store_id", "date", "transactions", "net_sales_aud"]
    ].merge(
        aggregates, on=["store_id", "date"], how="outer",
        indicator=True, validate="one_to_one",
    )
    check(comparison["_merge"].eq("both"), "Daily/hourly key coverage", checks)
    check(
        comparison["transactions"].eq(comparison["hourly_transactions"]),
        "Hourly transactions reconcile to daily", checks,
    )
    check(
        near(comparison["net_sales_aud"], comparison["hourly_net_sales"]),
        "Hourly net revenue reconciles to daily", checks,
    )
    return checks


def load_postgres(data_dir, init_schema, ddl_file):
    try:
        import psycopg
        from psycopg import sql
    except ImportError as exc:
        raise QualityError("Install dependencies: pip install -r etl/requirements.txt") from exc
    dsn = os.environ.get("DATABASE_URL")
    if not dsn:
        raise QualityError("DATABASE_URL environment variable is not set")
    # psycopg connection context rolls back all changes on any failure.
    with psycopg.connect(dsn) as conn:
        if init_schema:
            if not ddl_file.is_file():
                raise QualityError(f"SQL schema file not found: {ddl_file}")
            conn.execute(ddl_file.read_text(encoding="utf-8"))
        for name, (filename, columns) in FILES.items():
            table = sql.Identifier("xs", name)
            quoted_columns = sql.SQL(", ").join(map(sql.Identifier, columns))
            with conn.cursor() as cur:
                cur.execute(sql.SQL("TRUNCATE TABLE {}").format(table))
                statement = sql.SQL(
                    "COPY {} ({}) FROM STDIN WITH (FORMAT CSV)"
                ).format(table, quoted_columns)
                with cur.copy(statement) as copier:
                    with (data_dir / filename).open("rb") as f:
                        while block := f.read(1024 * 1024):
                            copier.write(block)
            print(f"  Loaded xs.{name}")
    print("PostgreSQL load committed successfully")


def main(argv=None):
    project = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data-dir", type=Path, default=project / "data")
    parser.add_argument("--load", action="store_true",
                        help="Load the validated CSVs into the existing PostgreSQL xs schema")
    parser.add_argument("--init-schema", action="store_true",
                        help="Apply existing sql/01_schema.sql before --load")
    args = parser.parse_args(argv)
    if args.init_schema and not args.load:
        parser.error("--init-schema requires --load")
    data_dir = args.data_dir.expanduser().resolve()
    print("Extracting CSVs...")
    frames = read_csvs(data_dir)
    for name, frame in frames.items():
        print(f"  {name}: {len(frame):,} rows")
    print("Validating source quality and reconciliation...")
    for label, count in validate(frames):
        print(f"  PASS {label}: {count} exceptions")
    if args.load:
        load_postgres(data_dir, args.init_schema, project / "sql" / "01_schema.sql")
    else:
        print("Validation passed; database not modified (add --load to import).")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (QualityError, OSError, ValueError) as exc:
        print(f"ETL FAILED: {exc}", file=sys.stderr)
        sys.exit(1)
