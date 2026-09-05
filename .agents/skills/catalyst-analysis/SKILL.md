---
name: catalyst-analysis
version: 1.0.0
owner: suquan
entrypoint: SKILL.md
supported_platforms: [linux]
required_tools: [bash, curl]
required_secrets: []
network_access: true
external_side_effects: false
last_verified: 2026-09-05
description: 執行台股個股催化劑分析 (Catalyst Analysis) 的標準三層 (Layer 1-3) 評估流程與 GitHub 同步規範。當使用者要求「催化劑分析」、「個股分析」時自動觸發。
---

# 台股催化劑分析技能 (Catalyst Analysis Skill)

## 一、技能簡介
本技能定義台股個股 **Layer 1 (基礎數據事實)**、**Layer 2 (市場共識與多空論述)** 及 **Layer 3 (反共識推理與戰略決策)** 的標準分析流程。

## 二、三層分析規範

### Layer 1: 基礎數據與事實 (Facts & Data)
- 收集標的股價、市值、近季營收、EPS、毛利率、存銷比及主力籌碼。
- 整理最新重大新聞與產業催化劑節點。

### Layer 2: 市場共識與多空論述 (Market Consensus)
- **多方共識 (Bulls)**：列出市場做多之核心邏輯、目標價區間與成長動能。
- **空方觀點 (Bears)**：列出主要風險、估值過熱疑慮與潛在利空。

### Layer 3: 反共識推理與戰略決策 (SuQuan's Analysis)
- **戰略層 (Strategic Level)**：核心護城河、製造瓶頸解法、估值與本益比/本銷比定錨。
- **戰術層 (Tactical Level)**：短中長期催化劑時間軸與關鍵指標。
- **執行層 (Actionable Advice)**：
  - **Do (建議)**：明確進場價格區間與倉位分配。
  - **Don't (禁止)**：追高條件與停損安全邊際。

## 三、存檔與 Git 同步規範
- 報告存檔於相對路徑：`market-catalyst/{股票名稱}({代號})_{YYYYMMDD}.md`
- 報告生成後完成 Git commit 並推送至 GitHub 儲存庫。
