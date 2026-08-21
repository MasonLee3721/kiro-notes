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
 def test_writes_machine_readable_report_bundle(self):
  with tempfile.TemporaryDirectory() as d:
   root=Path(d);ps=[]
   docs=[{'trade_date':'2026-08-21','records':[],'counts':{'strong':0,'watch':0},'warnings':[]},{'trade_date':'2026-08-21','records':[]},{'trade_date':'2026-08-21','records':[]}]
   for i,doc in enumerate(docs):
    x=root/f'{i}.json';x.write_text(json.dumps(doc),encoding='utf-8');ps.append(x)
   latest,dated=render(*ps,root/'out');report=root/'out'/'data'/'report_20260821.json'
   self.assertTrue(latest.exists());self.assertTrue(dated.exists());self.assertTrue(report.exists());self.assertIn('scores',json.loads(report.read_text()));html=latest.read_text();self.assertIn('\"":"&quot;',html);self.assertNotIn('""":"&quot;',html);self.assertIn('class=\\"chart-toggle\\"',html);self.assertIn("addEventListener(\"click\"",html);self.assertNotIn("onclick=\"toggleChart",html);self.assertNotIn("cdn.jsdelivr.net",html);self.assertNotIn("__ECHARTS__",html)
if __name__=="__main__":unittest.main()
