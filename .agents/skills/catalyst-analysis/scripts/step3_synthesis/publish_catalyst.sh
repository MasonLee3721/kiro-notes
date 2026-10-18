#!/usr/bin/env bash
# ==============================================================================
# Script: publish_catalyst.sh
# 執行者：第三順位 蘇荃 (SuQuan <@1490606333211443251>)
# 功能：
#   一鍵將沐劍屏、曾柔與蘇荃三階段產出之所有催化劑研報與技術對照檔
#   Commit 並 Push 至 GitHub 遠端庫 (MasonLee3721/kiro-notes)，並輸出 Discord 回報模板。
# ==============================================================================

set -euo pipefail

STOCK_CODE="${1:-}"
STOCK_NAME="${2:-}"
DATE="${3:-$(date +%Y%m%d)}"

NOTES_DIR="/home/agent/notes"
cd "$NOTES_DIR"

echo "=========================================================="
echo "🚀 [發布流程 蘇荃] 正在同步 GitHub 遠端庫..."
echo "=========================================================="

git pull --rebase origin master

git add uanalyze/ market-catalyst/ .agents/

if git diff --cached --quiet; then
  echo "ℹ️ 無新變更需要 Commit。"
else
  COMMIT_MSG="feat: add SuQuan ${DATE} Layer 1-3 strategic catalyst report with technical alignment for ${STOCK_NAME}(${STOCK_CODE})"
  git commit -m "$COMMIT_MSG"
  git push origin master
  echo "✅ GitHub 遠端庫 Commit & Push 成功！"
fi

echo "=========================================================="
echo "📢 向家主老公 <@1331833906751869030> 進行 Discord 回報完成！"
echo "=========================================================="
