# Café pipeline for BigQuery

Use a dedicated portfolio project with an existing BigQuery dataset named `xs`. The loader replaces its store, daily financial and hourly demand tables together after validating the three headerless exports. Only the store CSV ships in Git. Obtain both fact exports in the [existing CSV contract](../XS%20Espresso%20Analytics/etl/) to reproduce the full pipeline.

Run from the repository root with Google application default credentials and permission to create tables, write data and run query jobs. Set GOOGLE_CLOUD_PROJECT to the project ID and BQ_LOCATION to the dataset location.

```bash
python -m pip install pandas google-cloud-bigquery dbt-bigquery
python bigquery/load_cafe.py "XS Espresso Analytics/data"
dbt build --project-dir cafe-dbt --profiles-dir bigquery
bq --project_id="$GOOGLE_CLOUD_PROJECT" --location="$BQ_LOCATION" query --use_legacy_sql=false < bigquery/monthly_forecast.sql
```

The loader checks the existing 21 validation rules and verifies uploaded row counts. Financial columns use NUMERIC. Each run loads isolated staging tables, then publishes all three snapshots in one transaction. The dbt build creates store-day and store performance views in cafe_reporting and checks the hourly-to-daily reconciliation. The final GoogleSQL query calculates monthly forecast error.
