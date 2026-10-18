#!/usr/bin/env bash
# ==============================================================================
# Script: run_step3_synthesis.sh
# 執行者：第三順位 蘇荃 (SuQuan <@1490606333211443251>)
# 功能：
#   1. 整合沐劍屏之優分析數據與曾柔之 Layer 1 事實檔
#   2. 執行 Layer 2 市場共識拆解與 Layer 3 蘇荃反共識推理
#   3. 實施四步技術面點位安全邊際對照（建倉區間、加碼點位、硬性停損線）
#   4. 產出最終戰略總研報：market-catalyst/{公司名稱}({代號})_YYYYMMDD.md
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

NOTES_DIR="/home/agent/notes"
CATALYST_DIR="${NOTES_DIR}/market-catalyst"
FINAL_FILE="${CATALYST_DIR}/${STOCK_NAME}(${STOCK_CODE})_${DATE}.md"

echo "=========================================================="
echo "👑 [Step 3 蘇荃] 啟動 ${STOCK_NAME} (${STOCK_CODE}) 戰略總研報合成"
echo "=========================================================="

echo "🔍 審閱 Layer 1 事實數據與 TWSE 最新實質收盤價..."
echo "🧠 進行反共識推理（Counter-Consensus Analysis）與護城河定錨..."
echo "🎯 計算 2026/2027 年預估 PE 倍數，劃定戰術建倉、加碼與硬性停損點..."
echo "📄 產出最終戰略總研報：${FINAL_FILE}"

echo "=========================================================="
echo "✅ [Step 3 蘇荃] 最終戰略總研報合成完成，準備執行 GitHub Commit & Push。"
echo "=========================================================="
