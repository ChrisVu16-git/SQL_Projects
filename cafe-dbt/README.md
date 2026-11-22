# Café reporting in dbt

Load the three café exports into PostgreSQL using the [existing ETL](../XS%20Espresso%20Analytics/etl/). The project reads the xs schema and writes two views to cafe_reporting. Store-day sales feed store-level gross margin. The reconciliation test independently sums hourly sales and transactions for each store-day.

From this directory, with PGHOST, PGUSER, PGPASSWORD and PGDATABASE set for your database, run:

    python -m pip install dbt-postgres
    cp profiles.example.yml profiles.yml
    dbt build --profiles-dir .

The [BigQuery loader](../bigquery/) runs these same models against validated BigQuery inputs.
