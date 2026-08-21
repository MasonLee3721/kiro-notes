#!/usr/bin/env python3
"""Fetch and normalize current official TWSE/TPEx daily close quotes."""
from __future__ import annotations
import argparse,json,time
from dataclasses import asdict,dataclass
from datetime import date,datetime,timezone
from decimal import Decimal,InvalidOperation
from pathlib import Path
from typing import Any
from urllib.error import HTTPError,URLError
from urllib.request import Request,urlopen
TWSE_URL='https://openapi.twse.com.tw/v1/exchangeReport/STOCK_DAY_ALL'
TPEX_URL='https://www.tpex.org.tw/openapi/v1/tpex_mainboard_daily_close_quotes'
class QuoteDataError(RuntimeError):pass
@dataclass(frozen=True)
class QuoteRecord:
 trade_date:str;market:str;stock_code:str;stock_name:str;open:str|None;high:str|None;low:str|None;close:str|None
 change:str|None;volume_shares:int|None;trading_status_ok:bool;liquidity_status_ok:bool;source_name:str;source_url:str;fetched_at:str

def roc_to_iso(value:Any)->str:
 text=str(value).strip()
 if len(text)!=7 or not text.isdigit():raise QuoteDataError(f'invalid ROC date: {value!r}')
 try:return date(int(text[:3])+1911,int(text[3:5]),int(text[5:7])).isoformat()
 except ValueError as exc:raise QuoteDataError(f'invalid ROC date: {value!r}') from exc

def integer(value:Any)->int|None:
 if value is None:return None
 text=str(value).strip().replace(',','')
 if text in {'','--','---','N/A'}:return None
 try:return int(text)
 except ValueError as exc:raise QuoteDataError(f'invalid integer: {value!r}') from exc

def decimal_text(value:Any)->str|None:
 if value is None:return None
 text=str(value).strip().replace(',','')
 if text in {'','--','---','N/A'}:return None
 text=text.replace('X','').replace('除權','').replace('除息','').strip()
 if not text:return None
 try:return format(Decimal(text),'f')
 except InvalidOperation as exc:raise QuoteDataError(f'invalid decimal: {value!r}') from exc

def _record(market:str,row:dict[str,Any],url:str,stamp:str,keys:dict[str,str],source:str)->QuoteRecord:
 code=str(row.get(keys['code'],'')).strip()
 if not code:raise QuoteDataError(f'{market} quote code missing')
 values={name:decimal_text(row.get(keys[name])) for name in ('open','high','low','close','change')}
 volume=integer(row.get(keys['volume']))
 trading=all(values[name] is not None for name in ('open','high','low','close'))
 liquidity=volume is not None and volume>0
 return QuoteRecord(roc_to_iso(row.get(keys['date'])),market,code,str(row.get(keys['name'],'')).strip(),values['open'],values['high'],values['low'],values['close'],values['change'],volume,trading,liquidity,source,url,stamp)

def _unique(records:list[QuoteRecord])->list[QuoteRecord]:
 seen=set()
 for r in records:
  key=(r.trade_date,r.market,r.stock_code)
  if key in seen:raise QuoteDataError(f'duplicate quote key: {key}')
  seen.add(key)
 return records

def parse_twse(payload:Any,url:str,stamp:str)->list[QuoteRecord]:
 if not isinstance(payload,list):raise QuoteDataError('TWSE quote response must be an array')
 keys={'date':'Date','code':'Code','name':'Name','open':'OpeningPrice','high':'HighestPrice','low':'LowestPrice','close':'ClosingPrice','change':'Change','volume':'TradeVolume'}
 return _unique([_record('TWSE',r,url,stamp,keys,'TWSE STOCK_DAY_ALL') for r in payload if isinstance(r,dict)])

def parse_tpex(payload:Any,url:str,stamp:str)->list[QuoteRecord]:
 if not isinstance(payload,list):raise QuoteDataError('TPEx quote response must be an array')
 keys={'date':'Date','code':'SecuritiesCompanyCode','name':'CompanyName','open':'Open','high':'High','low':'Low','close':'Close','change':'Change','volume':'TradingShares'}
 return _unique([_record('TPEx',r,url,stamp,keys,'TPEx mainboard daily close quotes') for r in payload if isinstance(r,dict)])

def fetch_json(url:str,timeout:float=20,attempts:int=3)->tuple[Any,str]:
 error=None
 for attempt in range(attempts):
  try:
   request=Request(url,headers={'User-Agent':'tw-stock-momentum-report/1.0','Accept':'application/json'})
   with urlopen(request,timeout=timeout) as response:raw=response.read();stamp=datetime.now(timezone.utc).isoformat()
   return json.loads(raw.decode('utf-8-sig')),stamp
  except (HTTPError,URLError,TimeoutError,json.JSONDecodeError,UnicodeDecodeError) as exc:
   error=exc
   if attempt+1<attempts:time.sleep(2**attempt)
 raise QuoteDataError(f'official quote fetch failed: {error}')

def fetch_market(market:str)->list[QuoteRecord]:
 url=TWSE_URL if market=='twse' else TPEX_URL;payload,stamp=fetch_json(url)
 return parse_twse(payload,url,stamp) if market=='twse' else parse_tpex(payload,url,stamp)

def main()->int:
 p=argparse.ArgumentParser();p.add_argument('--market',choices=('twse','tpex','all'),default='all');p.add_argument('--date',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 markets=('twse','tpex') if a.market=='all' else (a.market,);records=[]
 for market in markets:records.extend(fetch_market(market))
 dates={r.trade_date for r in records}
 if dates!={a.date}:raise QuoteDataError(f'official quote dates {sorted(dates)}, expected {a.date}')
 _unique(records)
 doc={'schema_version':'1.0','trade_date':a.date,'generated_at':datetime.now(timezone.utc).isoformat(),
      'units':{'volume_shares':'shares'},'counts':{'records':len(records),'not_trading':sum(not r.trading_status_ok for r in records),'no_liquidity':sum(not r.liquidity_status_ok for r in records)},'records':[asdict(r) for r in records]}
 a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(doc,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print(f"wrote {len(records)} quotes; {doc['counts']['not_trading']} without complete OHLC")
 return 0
if __name__=='__main__':
 try:raise SystemExit(main())
 except QuoteDataError as exc:print(f'ERROR: {exc}',file=__import__('sys').stderr);raise SystemExit(2)
