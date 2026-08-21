import json,sys,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'scripts'))
from fetch_price_history import PriceHistoryError,cached_month,collect,decimal_text,parse_tpex_month,parse_twse_month,previous_month
from datetime import date,timedelta
from unittest.mock import patch
class PriceTests(unittest.TestCase):
 def fixture(self,n):return json.loads((ROOT/'tests'/'fixtures'/n).read_text(encoding='utf-8'))
 def test_twse_month_volume_is_shares(self):
  r=parse_twse_month(self.fixture('twse_price_month.json'))[0]
  self.assertEqual(r['volume_shares'],3000500);self.assertEqual(r['trade_date'],'2026-08-19');self.assertEqual(r['close'],'10.5')
 def test_tpex_month_lots_convert_to_shares(self):
  r=parse_tpex_month(self.fixture('tpex_price_month.json'))[0]
  self.assertEqual(r['volume_shares'],3001000);self.assertEqual(r['close'],'20.5')
 def test_previous_month_year_boundary(self):self.assertEqual(previous_month(date(2026,1,1)),date(2025,12,1))
 def test_ex_rights_change_marker_keeps_numeric_value(self):self.assertEqual(decimal_text('X0.00'),'0.00')
 def test_short_rows_fail(self):
  p=self.fixture('tpex_price_month.json');p['tables'][0]['data']=[['x']]
  with self.assertRaises(PriceHistoryError):parse_tpex_month(p)
 def test_month_cache_prevents_second_fetch(self):
  rows=[{'trade_date':'2026-08-19','close':'10'}]
  with tempfile.TemporaryDirectory() as d:
   with patch('fetch_price_history.fetch_month',return_value=rows) as fetch:
    self.assertEqual(cached_month('TWSE','1477',date(2026,8,1),Path(d)),rows)
    self.assertEqual(cached_month('TWSE','1477',date(2026,8,1),Path(d)),rows)
    self.assertEqual(fetch.call_count,1)
 def test_invalid_cache_fails_closed(self):
  with tempfile.TemporaryDirectory() as d:
   p=Path(d)/'twse'/'1477'/'202608.json';p.parent.mkdir(parents=True);p.write_text('{bad',encoding='utf-8')
   with self.assertRaises(PriceHistoryError):cached_month('TWSE','1477',date(2026,8,1),Path(d))
 def test_one_target_failure_does_not_abort_batch(self):
  with tempfile.TemporaryDirectory() as d:
   target_path=Path(d)/'targets.json'
   target_path.write_text(json.dumps({'trade_date':'2026-08-19','targets':[{'market':'TWSE','stock_code':'BAD'},{'market':'TWSE','stock_code':'GOOD'}]}),encoding='utf-8')
   rows=[{'trade_date':(date(2026,8,19)-timedelta(days=59-i)).isoformat()} for i in range(60)]
   def fake(market,code,month,cache_dir,refresh):
    if code=='BAD':raise PriceHistoryError('rate limited')
    return rows
   with patch('fetch_price_history.cached_month',side_effect=fake):result=collect(target_path,'2026-08-19',60,max_months=1)
   self.assertEqual(result['completed_count'],1);self.assertEqual(result['failed_count'],1)
   self.assertEqual(result['records'][0]['stock_code'],'GOOD');self.assertIn('rate limited',result['failures'][0]['reason'])

if __name__=='__main__':unittest.main()
