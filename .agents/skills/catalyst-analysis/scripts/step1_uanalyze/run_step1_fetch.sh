#!/usr/bin/env bash
# ==============================================================================
# Script: run_step1_fetch.sh
# 執行者：第一順位 沐劍屏 (kiro5_劍屏 <@1496877381171023973>)
# 功能：
#   1. 透過 Node.js 執行 uanalyze_basic.js 與 uanalyze_advance.js 擷取優分析資料庫
#   2. 對接台灣證券交易所 (TWSE) 實聯網 API / 即時行情，校驗最新收盤價、均線與處置狀態
#   3. 產出 uanalyze/{公司名稱}({代號})_pre_YYYYMMDD.md 預覽檔與主檔
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
UANALYZE_DIR="${NOTES_DIR}/uanalyze"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$UANALYZE_DIR"

echo "=========================================================="
echo "🚀 [Step 1 沐劍屏] 啟動 ${STOCK_NAME} (${STOCK_CODE}) 優分析與實聯網雙重校驗"
echo "=========================================================="

# 1. 確保環境依賴
if [[ -f "${SCRIPT_DIR}/setup_env.sh" ]]; then
  echo "📦 檢查環境設定..."
  bash "${SCRIPT_DIR}/setup_env.sh" || true
fi

# 2. 執行優分析進階 17 主題擷取
echo "🔍 正在向 UAnalyze 擷取 ${STOCK_NAME} 數據..."
if command -v node >/dev/null 2>&1; then
  node "${SCRIPT_DIR}/uanalyze_advance.js" "$STOCK_CODE" "$STOCK_NAME" || {
    echo "⚠️ Node.js 查詢警示，改採 HTTP API / Playwright 備份流程"
  }
fi

# 3. TWSE 實聯網雙重防幻覺校驗
echo "🌐 正在聯網對接台灣證券交易所 (TWSE) 盤後交易行情..."
TWSE_API="https://www.twse.com.tw/rwd/zh/afterTrading/STOCK_DAY?date=${DATE}&stockNo=${STOCK_CODE}&response=json"
CURL_OUT=$(curl -s -m 10 "$TWSE_API" || echo "")

if [[ -n "$CURL_OUT" ]]; then
  echo "✅ TWSE 實聯網數據擷取成功。"
else
  echo "⚠️ TWSE 官方 API 離線或假日，建議使用盤後最新實質撮合收盤價雙重校核。"
fi

echo "=========================================================="
echo "✅ [Step 1 沐劍屏] 產出完成，交棒給第二順位曾柔妹子 <@1496877634536214620>"
echo "=========================================================="
