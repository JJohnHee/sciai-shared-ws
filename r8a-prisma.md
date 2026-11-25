# R8-A · DPP-4 抑制剂动物实验全量留档（PRISMA 式）

> 检索纪律：遵循 CLAUDE.md，MeSH 精准限定 + 相关度排序 + retmax 全量截取，
> 原始检索结果留档（raw_esearch.json），摘要逐篇入库（r8a_index.tsv）。

## 1. 检索式
- **数据库**：PubMed (NCBI E-utilities: esearch + esummary)
- **检索式**：`(Dipeptidyl-Peptidase IV Inhibitors[MeSH]) AND (Disease Models, Animal[MeSH])`
- **排序**：`sort=relevance`
- **截取上限**：`retmax=200`
- **日期**：2026-11-21 (UTC)

## 2. 命中数
- esearch 报告全量匹配（count）：**439**
- 按纪律截取（retmax=200, relevance）：**200**

## 3. PRISMA 式四联数（识别 → 截取 → 筛前 → 纳入）

| 阶段 | 数量 | 说明 |
|------|------|------|
| ① 识别 (Identification) | **439** | esearch 全量匹配数 |
| ② 截取 (Retrieved) | **200** | sort=relevance 前 200，全量留档上限 |
| ③ 筛前 (Screened) | **200** | 进入标题/摘要筛检 |
| ④ 纳入 (Included) | **200** | 全量留档，未施加二次排除 |

- 剔除 = ②-④ = **0**（本次为全量留档，不做筛选排除）。
- 截断余量 = ①-② = **239**（受 retmax 限制未入库，已在留档说明中登记）。

## 4. 入库概览
- 字段：`PMID / Title / Journal / Year`（tab 分隔，见 r8a_index.tsv）
- 年份区间：**2007 – 2026**
- 逐篇 esummary 字段：PMID、title、journal、year

## 5. 留档文件
- `raw_esearch.json` — esearch 原始 JSON（含 200 条 PMID 及全量 count=439）
- `raw_esummary.json` — esummary 原始 JSON
- `r8a_index.tsv` — 全量入库索引（200 行 + 表头）
- `r8a-prisma.md` — 本汇总
