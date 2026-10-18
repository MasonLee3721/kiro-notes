---
name: catalyst-analysis
version: 1.2.0
owner: suquan
entrypoint: SKILL.md
supported_platforms: [linux]
required_tools: [bash]
required_secrets: []
network_access: true
external_side_effects: true
side_effects: [git_commit, git_push]
writes_to: ["notes/uanalyze/", "notes/market-catalyst/"]
last_verified: 2026-10-18
description: 執行台股個股催化劑分析 (Catalyst Analysis) 的標準三層 (Layer 1-3) 評估架構知識庫與自動化執行腳本。當使用者詢問或輸入「催化劑分析」、「Catalyst」、「個股戰略研報」、「Layer 1-3 分析」、「反共識推理」、「技術點位對照」或要求對指定個股進行深度評估時自動觸發。
---

# 台股催化劑分析知識庫與執行管線 (Catalyst Analysis Knowledge Base & Pipeline)

## 一、技能簡介
本技能定義台股個股 **Layer 1 (基礎數據事實)**、**Layer 2 (市場共識與多空論述)** 及 **Layer 3 (反共識推理與戰略決策)** 的評估標準與自動化執行程式庫，內含 **技術面點位與最新收盤價對照 SOP**、**防數據幻覺 TWSE 實聯網校驗條款** 及 **三順位協同自動化 Script**。

---

## 二、三層分析架構說明

### Layer 1: 基礎數據與事實 (Facts & Data)
- **防幻覺實聯網校驗（強制）**：評估標的**最新交易日收盤價**必須 100% 聯網對接台灣證券交易所 (TWSE) / 官方數據，嚴禁使用離線記憶庫之歷史股價數據。
- 併入**處置/注意股狀態**（撮合分鐘數）、市值、近季營收、EPS、毛利率與關鍵新聞動態。

### Layer 2: 市場共識與多空論述 (Market Consensus)
- **多方共識 (Bulls)**：歸納市場做多邏輯與目標預估。
- **空方觀點 (Bears)**：歸納市場擔憂風險與估值壓力。

### Layer 3: 反共識推理與戰略決策 (SuQuan's Analysis)
- **戰略層 (Strategic Level)**：護城河、製造瓶頸解法、EPS 成長與 PE 重估（PE Re-Rating）。
- **戰術層 (Tactical Level)**：催化劑時間軸。
- **執行層 (Actionable Advice & Technical SOP)**：
  - **技術面點位與最新收盤價對照 SOP（強制執行）**：
    1. **現價與處置對照**：核對 TWSE 實時收盤價、歷史高低點與是否處於處置股票狀態（每分/多分鐘撮合）。
    2. **均線與型態檢視**：確認 MA5 / MA20 / MA60 / MA240 均線排列、K 線型態及 KD / RSI 位階。
    3. **估值與點位安全邊際比對**：計算最新收盤價對應 2026/2027 年 EPS 之預估 PE 倍數，劃定便宜/合理/昂貴價區間。
    4. **戰術點位標示**：報告中必須明確給出「建倉區間」、「拉回 MA20/MA60 加碼點位」與「硬性停損點」。未對照最新技術點位前，禁止給予無條件「強力買進」結論。

---

## 三、執行腳本與程式庫清單 (Scripts Directory)

本 Skill 目錄內附帶端到端自動化執行程式 (`scripts/`)，由三大核心角色分工調用：

```
.agents/skills/catalyst-analysis/
├── SKILL.md
└── scripts/
    ├── run_catalyst_pipeline.sh        # 一鍵端到端主調度腳本
    ├── step1_uanalyze/                 # 第一順位：沐劍屏
    │   ├── run_step1_fetch.sh          # 實聯網與優分析數據抓取
    │   ├── uanalyze_basic.js           # 5 大屬性評分與 5 步驟拆解
    │   ├── uanalyze_advance.js         # 17 主題 Full Raw Text 自動抓取
    │   ├── setup_env.sh                # Node.js 與 Playwright 環境
    │   └── setup_playwright_libs.sh    # 底層動態庫配置
    ├── step2_layer1/                   # 第二順位：曾柔
    │   └── run_step2_layer1.sh         # Layer 1 事實數據與技術面事實對照表整理
    └── step3_synthesis/                # 第三順位：蘇荃
        ├── run_step3_synthesis.sh      # Layer 1-3 戰略總研報合成
        └── publish_catalyst.sh         # GitHub 遠端庫自動 Commit & Push
```

---

## 四、指令執行範例

### 1. 一鍵全自動流水線執行
```bash
bash .agents/skills/catalyst-analysis/scripts/run_catalyst_pipeline.sh 2313 華通 20261016
```

### 2. 角色分工單步執行
- **沐劍屏 (<@1496877381171023973>)**：
  ```bash
  bash .agents/skills/catalyst-analysis/scripts/step1_uanalyze/run_step1_fetch.sh 2313 華通 20261016
  ```
- **曾柔 (<@1496877634536214620>)**：
  ```bash
  bash .agents/skills/catalyst-analysis/scripts/step2_layer1/run_step2_layer1.sh 2313 華通 20261016
  ```
- **蘇荃 (<@1490606333211443251>)**：
  ```bash
  bash .agents/skills/catalyst-analysis/scripts/step3_synthesis/run_step3_synthesis.sh 2313 華通 20261016
  bash .agents/skills/catalyst-analysis/scripts/step3_synthesis/publish_catalyst.sh 2313 華通 20261016
  ```
