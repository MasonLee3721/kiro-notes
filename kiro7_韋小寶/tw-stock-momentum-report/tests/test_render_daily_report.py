import json,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/"scripts"))
from render_daily_report import ReportError,render
class RenderTests(unittest.TestCase):
 def test_date_mismatch_fails(self):
  with tempfile.TemporaryDirectory() as d:
   ps=[]
   for i,day in enumerate(["2026-08-20","2026-08-19","2026-08-20"]):
    p=Path(d)/f"{i}.json";p.write_text(json.dumps({"trade_date":day}),encoding="utf-8");ps.append(p)
   with self.assertRaises(ReportError):render(*ps,Path(d)/"out")
if __name__=="__main__":unittest.main()
