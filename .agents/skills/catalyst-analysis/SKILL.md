---
name: catalyst-analysis
version: 1.1.0
owner: suquan
entrypoint: SKILL.md
supported_platforms: [linux]
required_tools: [bash]
required_secrets: []
network_access: false
external_side_effects: false
side_effects: []
writes_to: []
last_verified: 2026-10-05
description: 執行台股個股催化劑分析 (Catalyst Analysis) 的標準三層 (Layer 1-3) 評估架構知識庫。當使用者詢問或輸入「催化劑分析」、「Catalyst」、「個股戰略研報」、「Layer 1-3 分析」、「反共識推理」、「技術點位對照」或要求對指定個股進行深度評估時自動觸發。
---


# 台股催化劑分析知識庫 (Catalyst Analysis Knowledge Base)

## 一、技能簡介
本技能定義台股個股 **Layer 1 (基礎數據事實)**、**Layer 2 (市場共識與多空論述)** 及 **Layer 3 (反共識推理與戰略決策)** 的純知識評估標準，包含 **技術面點位與最新收盤價對照 SOP** 及 **防數據幻覺實聯網校驗條款**。

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


