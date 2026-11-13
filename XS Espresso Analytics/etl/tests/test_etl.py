"""Smoke-test source parsing, reconciliation and failure detection."""
import sys
import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from run_etl import QualityError, read_csvs, validate


class ETLTests(unittest.TestCase):
    def test_headerless_inputs_and_reconciliation(self):
        with TemporaryDirectory() as tmp:
            p = Path(tmp)
            (p / "dim_store.csv").write_text(
                "XS001,Test Cafe,2020-01-01,day,company,user,notes,"
                "2023-01-01,2025-03-31,small,1540,note\n",
                encoding="utf-8",
            )
            (p / "xs.fact_daily_financial.csv").write_text(
                "2023-01-02,XS001,Test Cafe,small,open,2,100,5,95,30,65,"
                "AUD,2023,20,2,22,1,10,5,25,0,3,2023-01,Monday,summer\n",
                encoding="utf-8",
            )
            (p / "xs.fact_hourly_demand.csv").write_text(
                "2023-01-02,XS001,9,09:00,10:00,2,95,100,5,30,60,35,90,baseline,5\n",
                encoding="utf-8",
            )
            frames = read_csvs(p)
            self.assertEqual(len(frames["dim_store"]), 1)
            self.assertEqual(len(validate(frames)), 21)
            frames["fact_hourly_demand"].loc[0, "net_sales_aud"] = 94
            with self.assertRaises(QualityError):
                validate(frames)


if __name__ == "__main__":
    unittest.main()
