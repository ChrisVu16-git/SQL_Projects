"""Validate the three café CSVs and publish a full snapshot to BigQuery."""
import argparse
import os
import shutil
import sys
from pathlib import Path
from tempfile import TemporaryDirectory
from uuid import uuid4

from google.cloud import bigquery

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "XS Espresso Analytics" / "etl"))
from run_etl import DATE_FIELDS, FILES, NUMERICS, read_csvs, validate


def field_type(table, column):
    if column in DATE_FIELDS[table]:
        return "DATE"
    if column in {"hour", "year", "transactions"}:
        return "INT64"
    if column in NUMERICS[table]:
        return "NUMERIC"
    return "STRING"


def load_snapshot(data_dir, project):
    # Use exactly the same input bytes for validation and upload.
    with TemporaryDirectory() as work:
        for filename, _ in FILES.values():
            shutil.copyfile(data_dir / filename, Path(work) / filename)
        frames = read_csvs(Path(work))
        validate(frames)
        client = bigquery.Client(project=project)
        dataset = client.get_dataset("xs")
        run_id = uuid4().hex
        staging = []
        statements = []
        try:
            for table, (filename, columns) in FILES.items():
                schema = [bigquery.SchemaField(c, field_type(table, c)) for c in columns]
                target = dataset.table(table)
                stage = dataset.table(f"_load_{run_id}_{table}")
                staging.append(stage)
                config = bigquery.LoadJobConfig(schema=schema, source_format="CSV",
                                                allow_quoted_newlines=True, write_disposition="WRITE_EMPTY")
                with (Path(work) / filename).open("rb") as stream:
                    job = client.load_table_from_file(stream, stage, job_config=config)
                    job.result()
                if job.output_rows != len(frames[table]):
                    raise ValueError(f"Unexpected BigQuery row count for {table}")
                client.create_table(bigquery.Table(target, schema=schema), exists_ok=True)
                fields = ", ".join(f"`{c}`" for c in columns)
                statements.extend([f"DELETE FROM `{target}` WHERE TRUE;",
                                   f"INSERT INTO `{target}` ({fields}) SELECT {fields} FROM `{stage}`;"])
            # All three target snapshots advance together, including on a retry.
            sql = "\n".join(["BEGIN TRANSACTION;", *statements, "COMMIT TRANSACTION;"])
            client.query(sql, location=dataset.location).result()
        finally:
            for stage in staging:
                client.delete_table(stage, not_found_ok=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("data_dir", type=Path)
    args = parser.parse_args()
    load_snapshot(args.data_dir, os.environ["GOOGLE_CLOUD_PROJECT"])
