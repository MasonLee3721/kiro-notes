#!/usr/bin/env bash
# ==============================================================================
# Script: run_catalyst_pipeline.sh
# 執行者：三順位流水線總協調 (蘇荃主持、沐劍屏、曾柔協同)
# 功能：
#   端到端一鍵調度執行台股催化劑三層分析流水線：
#   Step 1 (沐劍屏): 優分析數據庫查詢 + TWSE 實聯網雙重防幻覺校驗
#   Step 2 (曾柔): Layer 1 事實數據檔整理 + 近 14 天重大新聞 + 技術面事實對照表
#   Step 3 (蘇荃): Layer 1-3 戰略總研報合成 + 反共識推理 + 四步技術點位對照 + GitHub Push
# ==============================================================================

set -euo pipefail

STOCK_CODE="${1:-}"
STOCK_NAME="${2:-}"
DATE="${3:-$(date +%Y%m%d)}"

if [[ -z "$STOCK_CODE" || -z "$STOCK_NAME" ]]; then
  echo "❌ 使用方式: $0 <股票代號> <公司名稱> [YYYYMMDD]"
  echo "   例如: $0 2313 華通 20261016"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "🎯 啟動台股催化劑三層分析流水線 (Catalyst Pipeline)"
echo "   標的：${STOCK_NAME} (${STOCK_CODE})"
echo "   日期：${DATE}"
echo "=========================================================="

# 執行 Step 1
echo ""
echo ">>> [第一順位] 沐劍屏 <@1496877381171023973> 執行優分析與實聯網雙重校驗..."
bash "${SCRIPT_DIR}/step1_uanalyze/run_step1_fetch.sh" "$STOCK_CODE" "$STOCK_NAME" "$DATE"

# 執行 Step 2
echo ""
echo ">>> [第二順位] 曾柔 <@1496877634536214620> 產出 Layer 1 事實與技術面對照表..."
bash "${SCRIPT_DIR}/step2_layer1/run_step2_layer1.sh" "$STOCK_CODE" "$STOCK_NAME" "$DATE"

# 執行 Step 3
echo ""
echo ">>> [第三順位] 蘇荃 <@1490606333211443251> 進行 Layer 1-3 戰略總研報合成..."
bash "${SCRIPT_DIR}/step3_synthesis/run_step3_synthesis.sh" "$STOCK_CODE" "$STOCK_NAME" "$DATE"

# 發布至遠端庫
echo ""
echo ">>> [遠端發布] 蘇荃 執行 Commit & Push 至 GitHub 遠端庫..."
bash "${SCRIPT_DIR}/step3_synthesis/publish_catalyst.sh" "$STOCK_CODE" "$STOCK_NAME" "$DATE"

echo ""
echo "🎉 全流程圓滿閉環！向老公 <@1331833906751869030> 回報完成。"
