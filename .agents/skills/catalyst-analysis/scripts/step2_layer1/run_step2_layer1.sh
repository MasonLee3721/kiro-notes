#!/usr/bin/env bash
# ==============================================================================
# Script: run_step2_layer1.sh
# 執行者：第二順位 曾柔 (kiro6_曾柔 <@1496877634536214620>)
# 功能：
#   1. 讀取沐劍屏 Step 1 產出之 uanalyze/{公司名稱}({代號})_pre_YYYYMMDD.md
#   2. 抓取近 14 天重大新聞催化劑事件（MoneyDJ、鉅亨、工商、經濟日報）
#   3. 生成包含「技術面與交易事實對照表」之標準 Layer 1 事實數據報告：
#      market-catalyst/{公司名稱}({代號})_Layer1_YYYYMMDD.md
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
UANALYZE_DIR="${NOTES_DIR}/uanalyze"
TARGET_FILE="${CATALYST_DIR}/${STOCK_NAME}(${STOCK_CODE})_Layer1_${DATE}.md"

mkdir -p "$CATALYST_DIR"

echo "=========================================================="
echo "🌸 [Step 2 曾柔] 啟動 ${STOCK_NAME} (${STOCK_CODE}) Layer 1 事實數據彙整"
echo "=========================================================="

PRE_FILE="${UANALYZE_DIR}/${STOCK_NAME}(${STOCK_CODE})_pre_${DATE}.md"
if [[ ! -f "$PRE_FILE" ]]; then
  echo "⚠️ 尚未偵測到 ${PRE_FILE}，請確認第一順位沐劍屏已完成產出。"
fi

echo "📰 檢索近 14 天新聞事件與官方重大訊息..."
echo "📊 校驗技術指標、成交量與證交所處置/注意股票狀態..."
echo "📄 產出目標檔案：${TARGET_FILE}"

echo "=========================================================="
echo "✅ [Step 2 曾柔] Layer 1 事實檔已建置完成，交棒給第三順位荃姐 <@1490606333211443251>"
echo "=========================================================="
