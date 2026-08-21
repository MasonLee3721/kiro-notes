#!/usr/bin/env python3
from __future__ import annotations
import argparse,json
from datetime import datetime,timezone
from decimal import Decimal
from pathlib import Path
from typing import Any
from momentum_core import rating_for_score
from score_model import chip_score,continuity_score,foreign_score,investment_score,technical_scores
class DailyScoreError(RuntimeError):pass
def load(path:Path)->dict[str,Any]:
 try:return json.loads(path.read_text(encoding="utf-8"))
 except (OSError,json.JSONDecodeError) as exc:raise DailyScoreError(f"cannot load {path}: {exc}") from exc
def keyed(rows):
 out={}
 for x in rows:
  key=(x.get("market"),x.get("stock_code"))
  if key in out:raise DailyScoreError(f"duplicate key {key}")
  out[key]=x
 return out
def build(dataset_path:Path,screened_path:Path,history_path:Path,technical_path:Path)->dict[str,Any]:
 docs=[load(x) for x in (dataset_path,screened_path,history_path,technical_path)];dates={x.get("trade_date") for x in docs}
 if len(dates)!=1:raise DailyScoreError(f"input dates differ: {dates}")
 day=next(iter(dates));dataset=keyed([x for x in docs[0].get("records",[]) if x.get("preselection",{}).get("passed")]);screened=keyed(docs[1].get("records",[]));history=keyed(docs[2].get("records",[]));technical=keyed(docs[3].get("records",[]))
 if not (set(dataset)==set(screened)==set(history)==set(technical)):raise DailyScoreError("candidate identities differ across inputs")
 records=[]
 for key,x in dataset.items():
  s=screened[key];h=history[key]["sitc_history"];t=technical[key]["technical"];sitc=[z.get("sitc_net_shares") for z in h];foreign=[z.get("foreign_net_shares") for z in h]
  if any(v is None for v in sitc+foreign):raise DailyScoreError(f"institutional history contains missing values: {key}")
  cumulative=Decimal(sum(sitc))/Decimal(x["issued_shares"])*100;sections={"investment_ratio":investment_score(x["investment_ratio_pct"],x["positive_ratio_rank"]),"sitc_continuity":continuity_score(s["sitc_buy_streak"],sitc[-3:]),"chip_position":chip_score(estimated_pct=cumulative),"foreign_sync":foreign_score(sitc[-3:],foreign[-3:],"actual")};sections.update(technical_scores(t));total=sum(v["score"] for v in sections.values());records.append({"market":key[0],"stock_code":key[1],"stock_name":x["stock_name"],"trade_date":day,"investment_ratio_pct":x["investment_ratio_pct"],"positive_ratio_rank":x["positive_ratio_rank"],"volume_lots":x["volume_lots"],"paid_in_capital_twd":x["paid_in_capital_twd"],"sitc_buy_streak":s["sitc_buy_streak"],"sitc_net_shares_3d_sum":sum(sitc[-3:]),"foreign_net_shares_3d_sum":sum(foreign[-3:]),"cumulative_buy_ratio_estimated_pct":format(cumulative,"f"),"aggressive_passed":s["aggressive_passed"],"conservative_passed":s["conservative_passed"],"technical":t,"sections":sections,"total_score":total,"rating":rating_for_score(total),"confidence":"中","confidence_reason":"期間累計買超比例為估算；其餘本次評分來源為官方資料"})
 records.sort(key=lambda x:(-x["total_score"],x["positive_ratio_rank"],x["stock_code"]));return {"schema_version":"1.0","trade_date":day,"generated_at":datetime.now(timezone.utc).isoformat(),"data_status":"official_market_and_history_with_estimated_cumulative_ratio","warnings":["期間累計買超比例不是實際投信持股比例"],"counts":{"candidates":len(records),"strong":sum(x["total_score"]>=80 for x in records),"watch":sum(70<=x["total_score"]<80 for x in records)},"records":records}
def main()->int:
 p=argparse.ArgumentParser();p.add_argument("--dataset",type=Path,required=True);p.add_argument("--screened",type=Path,required=True);p.add_argument("--history",type=Path,required=True);p.add_argument("--technical",type=Path,required=True);p.add_argument("--output",type=Path,required=True);a=p.parse_args();r=build(a.dataset,a.screened,a.history,a.technical);a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(r,ensure_ascii=False,indent=2)+"\n",encoding="utf-8");print(json.dumps(r["counts"],ensure_ascii=False));return 0
if __name__=="__main__":
 try:raise SystemExit(main())
 except DailyScoreError as exc:print(f"ERROR: {exc}",file=__import__("sys").stderr);raise SystemExit(2)
