# market-catalyst-fetch

針對台股個股，三層分工產出結構化催化劑分析報告。

## 觸發方式

```
/market-catalyst-fetch {股票代號} {公司名稱}
/market-catalyst-fetch {股票代號} {公司名稱} --force
```

**繁體中文觸發關鍵字（以下任一均可）：**
- `催化劑分析 {代號} {公司}`
- `研究 {公司} 催化劑`
- `跑催化劑 {代號} {公司}`
- `查 {公司} 市場預期`
- `幫我看 {公司} 的故事面`

## 分工

| 角色 | 負責 |
|------|------|
| 劍屏 | 前置檢查 + uanalyze-query |
| 曾柔 | Layer 1：優分析 + 近期新聞整合 |
| 蘇荃 | Layer 2 市場共識 + Layer 3 反共識推理 + 出報告 |

## 三層架構

- **Layer 1**：事實蒐集（優分析報告 + 近 14 天新聞）
- **Layer 2**：市場共識（分析師評級、目標價、隱含本益比）
- **Layer 3**：反共識推理（市場低估/高估的變數、蘇荃判斷 vs 市場共識）

## 產出路徑

```
/home/agent/notes/market-catalyst/{公司名稱}({代號})_YYYYMMDD.md
```

GitHub：`MasonLee3721/kiro-notes` → `market-catalyst/`

## 檔案說明

| 檔案 | 說明 |
|------|------|
| SKILL.md | 主入口，完整執行流程與分工 |
| report-template.md | 報告輸出格式模板 |
| sources.md | 各層資料來源清單 |
| examples/sample-report.md | 範例報告（新應材 4749） |
