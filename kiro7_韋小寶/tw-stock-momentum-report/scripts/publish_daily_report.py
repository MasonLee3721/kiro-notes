#!/usr/bin/env python3
from __future__ import annotations
import argparse,json,subprocess
from pathlib import Path
class PublishError(RuntimeError):pass
def command(args:list[str],cwd:Path,check:bool=True)->subprocess.CompletedProcess[str]:
 result=subprocess.run(args,cwd=cwd,text=True,capture_output=True)
 if check and result.returncode:raise PublishError((result.stderr or result.stdout).strip())
 return result
def validate(output_dir:Path)->tuple[str,list[Path]]:
 scores=output_dir/"data"/"daily_scores_latest.json";latest=output_dir/"latest.html"
 if not scores.exists() or not latest.exists():raise PublishError("latest score JSON or HTML is missing")
 doc=json.loads(scores.read_text(encoding="utf-8"));day=str(doc.get("trade_date") or "")
 if len(day)!=10:raise PublishError("invalid latest trade_date")
 stamp=day.replace("-","");dated=output_dir/f"tw_stock_momentum_report_{stamp}.html";report=output_dir/"data"/f"report_{stamp}.json";status=output_dir/"data"/"daily_run_status.json"
 for path in (dated,report,status):
  if not path.exists():raise PublishError(f"missing publish artifact: {path}")
 bundle=json.loads(report.read_text(encoding="utf-8"));dates={bundle.get(k,{}).get("trade_date") for k in ("scores","prices","history")}
 if dates!={day}:raise PublishError(f"report dates differ: {dates}")
 html=latest.read_text(encoding="utf-8")
 if day not in html or "__DATA__" in html or "__ECHARTS__" in html:raise PublishError("latest HTML failed validation")
 return day,[latest,dated,report,status]
def publish(output_dir:Path,remote:str="origin")->dict:
 output_dir=output_dir.resolve();day,paths=validate(output_dir);root=Path(command(["git","rev-parse","--show-toplevel"],output_dir).stdout.strip()).resolve()
 try:rel=[p.resolve().relative_to(root) for p in paths]
 except ValueError as exc:raise PublishError("output directory is outside Git repository") from exc
 branch=command(["git","branch","--show-current"],root).stdout.strip()
 if not branch:raise PublishError("detached HEAD cannot be published")
 command(["git","add","--",*[str(x) for x in rel]],root)
 if command(["git","diff","--cached","--quiet","--"],root,check=False).returncode==0:return {"status":"no_changes","trade_date":day,"branch":branch}
 command(["git","commit","-m",f"data: publish momentum report {day}"],root);command(["git","push",remote,branch],root);sha=command(["git","rev-parse","HEAD"],root).stdout.strip()
 return {"status":"published","trade_date":day,"branch":branch,"commit":sha}
def main()->int:
 p=argparse.ArgumentParser();p.add_argument("--output-dir",type=Path,default=Path("output"));p.add_argument("--remote",default="origin");a=p.parse_args()
 try:print(json.dumps(publish(a.output_dir,a.remote),ensure_ascii=False));return 0
 except (PublishError,OSError,json.JSONDecodeError) as exc:print(f"ERROR: {exc}",file=__import__("sys").stderr);return 2
if __name__=="__main__":raise SystemExit(main())
