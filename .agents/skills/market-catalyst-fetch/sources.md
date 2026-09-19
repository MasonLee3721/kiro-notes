# 資料來源清單

本文件列出 market-catalyst-fetch 各層使用的資料來源與查詢方式。

---

## Layer 1：事實蒐集

### 優分析（UAnalyze）
- 用途：產業研究、公司基本面、EPS 預估
- 來源：`/home/agent/notes/uanalyze/` 最新檔案（由劍屏跑 uanalyze-query 產出）

### 近期新聞
| 來源 | URL 格式 | 用途 |
|------|---------|------|
| MoneyDJ | `https://www.moneydj.com/KMDJ/News/NewsViewer.aspx?a={id}` | 台股財經新聞 |
| 鉅亨網 | `https://news.cnyes.com/news/cat/tw_stock` | 台股即時新聞 |
| Reuters | `https://www.reuters.com/search/news?blob={關鍵字}` | 國際財經 |
| Bloomberg | `https://www.bloomberg.com/search?query={關鍵字}` | 國際財經 |

---

## Layer 2：市場共識

| 來源 | URL 格式 | 用途 |
|------|---------|------|
| Yahoo Finance | `https://finance.yahoo.com/quote/{代號}.TW/analysis` | 分析師評級、目標價 |
| Finviz | `https://finviz.com/quote.ashx?t={代號}` | 技術面 + 分析師評級 |
| TWSE 公告 | `https://mops.twse.com.tw/mops/web/t05st01` | 重大訊息公告 |

---

## Layer 3：反共識推理

| 來源 | URL 格式 | 用途 |
|------|---------|------|
| 台灣期交所 | `https://www.taifex.com.tw/cht/3/futContractsDate` | 外資期貨淨部位 |
| TWSE 籌碼 | `https://www.twse.com.tw/fund/T86?response=json&date={YYYYMMDD}&selectType=ALL` | 三大法人買賣超 |

---

## 注意事項
- 所有來源必須實際抓取，不得憑記憶填寫
- 新聞時間範圍：近 14 天
- 若來源無法存取，在報告中標注「無法取得」
