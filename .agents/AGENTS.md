# Kiro Team Agent Shared Rules & SOP

## 📦 GitHub 產出交付與回報 SOP (強制執行規範)

1. **產出即 Commit & Push**：
   所有 Agent 產出之分析檔（含 沐劍屏 之優分析 UAnalyze 前置筆記、曾柔 之 Layer 1 數據與 蘇荃 之催化劑報告），產出後必須立即 Commit 並 Push 至 GitHub 遠端儲存庫 `MasonLee3721/kiro-notes`。

2. **回報預設檢附 GitHub URL**：
   任務完成或階段性回報時，預設一律直接附上 GitHub 檔案與目錄的完整 URL 連結（例如 `https://github.com/MasonLee3721/kiro-notes/blob/master/uanalyze/...`），嚴禁僅提供本地檔案路徑。

3. **跨環境同步機制**：
   每次執行任務前，應先執行 `git pull --rebase` 確保同步最新團隊資料庫。

4. **UAnalyze 查詢與存檔 SOP 規範 (沐劍屏 SOP)**：
   - **標竿參考標的**：[日月光投控(3711)_20260713.md](https://github.com/MasonLee3721/kiro-notes/blob/master/uanalyze/%E6%97%A5%E6%9C%88%E5%85%89%E6%8A%95%E6%8E%A7(3711)_20260713.md)
   - **100% 無加工 Raw Text 原則**：寫入 `notes/uanalyze/` 的數據檔案，必須 100% 完整保存 API 調用回傳的真實 raw text 全文內容，絕不允許私自進行人工摘要或截斷。
   - **17 大主題完整查詢**：必須依序將 SKILL.md 所列之 17+ 項主題全部連線查詢完畢並完整保留內容。`uanalyze/{股票名稱}({代號})_{YYYYMMDD}.md` 必須具備 100KB~170KB+ 規模之 Full Raw Text 完整度，嚴禁僅輸出 8KB~10KB 之簡化摘要檔。
   - **雙檔案機制**：每次查詢必須同步產生 `_pre` 原始全數據檔案與 17 主題全解析研報檔案。
   - **網頁改版與異常如實記錄原則**：若優分析網頁或 API 改版導致特定主題/欄位資料為空、無法取得或連線失敗，必須如實於報告對應章節中標註「[資料為空/API未回傳]」或完整記錄錯誤狀態，絕不可私自截斷、忽略或造假填補，以便定位系統問題。


