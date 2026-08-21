import json,sys,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'scripts'))
from fetch_daily_quotes import QuoteDataError,decimal_text,parse_tpex,parse_twse
class QuoteTests(unittest.TestCase):
 def fixture(self,n):return json.loads((ROOT/'tests'/'fixtures'/n).read_text(encoding='utf-8'))
 def test_twse_volume_is_shares_and_prices_normalized(self):
  rows=parse_twse(self.fixture('twse_quotes.json'),'u','t');r=rows[0]
  self.assertEqual((r.trade_date,r.market,r.volume_shares),('2026-08-19','TWSE',3000500));self.assertEqual(r.close,'10.50');self.assertTrue(r.trading_status_ok)
 def test_suspended_or_no_trade_is_not_eligible(self):
  r=parse_twse(self.fixture('twse_quotes.json'),'u','t')[1]
  self.assertFalse(r.trading_status_ok);self.assertFalse(r.liquidity_status_ok);self.assertIsNone(r.close)
 def test_tpex_schema(self):
  r=parse_tpex(self.fixture('tpex_quotes.json'),'u','t')[0]
  self.assertEqual(r.stock_code,'5678');self.assertEqual(r.change,'-0.5');self.assertEqual(r.volume_shares,4000000)
 def test_ex_rights_only_marker_is_missing_change(self):
  self.assertIsNone(decimal_text('除息 '));self.assertIsNone(decimal_text('除權 '))
 def test_invalid_decimal_fails(self):
  with self.assertRaises(QuoteDataError):decimal_text('not-price')
 def test_duplicate_key_fails(self):
  payload=self.fixture('tpex_quotes.json')*2
  with self.assertRaises(QuoteDataError):parse_tpex(payload,'u','t')
if __name__=='__main__':unittest.main()
