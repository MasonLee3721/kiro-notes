# Kiro Team Agent Shared Rules & SOP

## 📦 GitHub 產出交付與回報 SOP (強制執行規範)

1. **產出即 Commit & Push**：
   所有 Agent 產出之分析檔（含 沐劍屏 之優分析 UAnalyze 前置筆記、曾柔 之 Layer 1 數據與 蘇荃 之催化劑報告），產出後必須立即 Commit 並 Push 至 GitHub 遠端儲存庫 `MasonLee3721/kiro-notes`。

2. **回報預設檢附 GitHub URL**：
   任務完成或階段性回報時，預設一律直接附上 GitHub 檔案與目錄的完整 URL 連結（例如 `https://github.com/MasonLee3721/kiro-notes/blob/master/uanalyze/...`），嚴禁僅提供本地檔案路徑。

3. **跨環境同步機制**：
   每次執行任務前，應先執行 `git pull --rebase` 確保同步最新團隊資料庫。

4. **UAnalyze 查詢與存檔 SOP 規範 (無加工 raw text)**：
   - 寫入 `notes/uanalyze/` 的數據檔案，必須 100% 完整保存 API 調用回傳的真實 raw text 全文內容，絕不允許私自進行人工摘要或截斷。
   - 必須依序將 SKILL.md 所列之 17+ 項小助理主題全部連線查詢完畢並完整保留內容。
   - 每次查詢必須同步產生 `_pre` 原始全數據檔案與 17 主題全解析研報檔案。
