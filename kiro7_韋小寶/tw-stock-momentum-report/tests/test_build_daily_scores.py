import json,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/"scripts"))
from build_daily_scores import DailyScoreError,build,keyed
class DailyScoreTests(unittest.TestCase):
 def test_duplicate_key_fails(self):
  with self.assertRaises(DailyScoreError):keyed([{"market":"TWSE","stock_code":"1"},{"market":"TWSE","stock_code":"1"}])
 def test_date_mismatch_fails_closed(self):
  with tempfile.TemporaryDirectory() as d:
   paths=[]
   for i,day in enumerate(["2026-08-20","2026-08-20","2026-08-19","2026-08-20"]):
    p=Path(d)/f"{i}.json";p.write_text(json.dumps({"trade_date":day,"records":[]}),encoding="utf-8");paths.append(p)
   with self.assertRaises(DailyScoreError):build(*paths)
if __name__=="__main__":unittest.main()
