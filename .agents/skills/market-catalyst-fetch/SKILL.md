---
name: market-catalyst-fetch
description: 針對指定股票，依序由劍屏、曾柔、蘇荃三層分工，蒐集優分析資料、近期新聞、市場預期，整合產出結構化催化劑分析報告。觸發時機：使用者提供股票代號或公司名稱，要求分析催化劑、研究產業、或產出報告時使用。
argument-hint: [股票代號] [公司名稱] [--force]
allowed-tools: WebFetch WebSearch
disable-model-invocation: true
---

# Skill: market-catalyst-fetch

## 觸發方式
```
/market-catalyst-fetch {股票代號} {公司名稱}
例：/market-catalyst-fetch 4749 新應材
例：/market-catalyst-fetch 4749 新應材 --force
```

**繁體中文觸發關鍵字（以下任一均可）：**
- `催化劑分析 {代號} {公司}`
- `研究 {公司} 催化劑`
- `跑催化劑 {代號} {公司}`
- `查 {公司} 市場預期`
- `幫我看 {公司} 的故事面`

---

## 執行流程

### 前置檢查（劍屏 <@1496877381171023973> 執行）
1. 解析 `$ARGUMENTS`，取得股票代號與公司名稱
2. 檢查 `/home/agent/notes/market-catalyst/{公司名稱}({代號})_YYYYMMDD.md` 是否存在
   - 存在且無 `--force` → 回報「當日報告已存在，跳過」，流程結束
   - 存在且有 `--force` → 覆蓋，繼續執行
   - 不存在 → 繼續執行
3. 執行 `uanalyze-query` 取得優分析資料，恪守雙檔案 SOP 寫入 `/home/agent/notes/uanalyze/`：
   - 產生 `_pre` 檔（5 大屬性評分 + 5 步驟拆解）
   - 產生 100KB~170KB+ 無加工 17 主題 Full Raw Text 研報檔（標竿對齊 `日月光投控(3711)_20260713.md`）
   - 若資料為空或 API 未回傳，如實標註「`[資料為空/API未回傳]`」
4. 完成後 mention <@1496877634536214620>（曾柔）

### Layer 1（曾柔 <@1496877634536214620> 執行）
收到通知後：
1. 讀取劍屏產出的優分析資料（`/home/agent/notes/uanalyze/` 最新檔案）
2. 補抓近期新聞（Bloomberg、Reuters、MoneyDJ、鉅亨），時間範圍：近 14 天
3. 整合成 Layer 1 暫存檔，存至 `/home/agent/notes/market-catalyst/.layer1_{代號}_{YYYYMMDD}.tmp`
4. 完成後 mention <@1490606333211443251>（蘇荃）

### Layer 2 + 3 + 出報告（蘇荃 <@1490606333211443251> 執行）
收到通知後：
1. 讀取 Layer 1 暫存檔（`.layer1_{代號}_{YYYYMMDD}.tmp`）
2. **Layer 2（市場共識）**：分析師評級、目標價中位數、目前股價隱含本益比
3. **Layer 3（反共識推理）**：市場可能低估/高估的變數，我的判斷與市場的差異
4. 整合 Layer 1-3，依 `report-template.md` 產出完整報告
5. 存檔至 `/home/agent/notes/market-catalyst/{公司名稱}({代號})_YYYYMMDD.md`
6. 刪除 Layer 1 暫存檔：`rm /home/agent/notes/market-catalyst/.layer1_{代號}_{YYYYMMDD}.tmp`
7. push GitHub：
   ```bash
   cd /home/agent/notes
   git add market-catalyst/
   git commit -m "add: {公司}({代號}) 市場催化劑報告 $(date +%Y%m%d)"
   git push
   ```
8. 完成後 mention <@1331833906751869030>（老公）

---

## 支援檔案
- 報告格式：[report-template.md](report-template.md)
- 資料來源清單：[sources.md](sources.md)
- 範例報告：[examples/sample-report.md](examples/sample-report.md)

---

## 注意事項
- 所有資料必須來自真實網路來源，不得捏造
- 優分析報告若不存在，劍屏需先跑 uanalyze-query
- Layer 3 反共識推理需有邏輯依據，不得空泛
- 三層資料來源需在報告中標明
- kiro-notes repo remote：`https://{TOKEN}@github.com/MasonLee3721/kiro-notes.git`
