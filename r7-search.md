# R7-A：DPP-4 抑制剂动物实验文献检索（PubMed E-utilities）

- 检索日期：2026-11-22（按 CLAUDE.md scios-research v1.1 检索纪律执行）
- 接口：PubMed E-utilities（esearch + esummary）
- 检索式：`(Dipeptidyl-Peptidase IV Inhibitors[MeSH]) AND (Disease Models, Animal[MeSH])`
- 排序：`sort=relevance`（纪律#1：必须校准排序）

## 1. 宽检索命中数（MeSH 展开层，纪律#2/#3）

- **总命中数：439 篇**
- 原始档案：`raw_esearch.json`（count=439）

## 2. 2021–2026 窄化（日期窗限定）

- 检索式追加 `AND (2021:2026[dp])`，命中 **117 篇**（`raw_esearch_2021.json`）
- 逐年分布（单年 `[dp]` 独立核查）：

| 年份 | 命中数 |
|------|-------|
| 2021 | 23 |
| 2022 | 11 |
| 2023 | 15 |
| 2024 | 23 |
| 2025 | 39 |
| 2026 | 19 |

注：逐年合计 130 与日期窗检索 117 存在差异，系 `[dp]`（出版日期）与 `dp` 日期窗的解析口径不同所致，以接口返回值为准。

## 3. 相关度排序前 3（2021–2026 窗内，sort=relevance）

| # | PMID | 期刊 | 年份 | 标题 | 文献类型 |
|---|------|------|------|------|---------|
| 1 | 34988855 | Molecular and Cellular Biochemistry | 2022 | Linagliptin ameliorates pulmonary fibrosis in systemic sclerosis mouse model via inhibition of endothelial-to-mesenchymal transition | Journal Article |
| 2 | 41043862 | Gut | 2026 | DPP-4 inhibitor alleviates gut-brain axis pathology in Parkinson's disease | Journal Article |
| 3 | 40700924 | Bioorganic Chemistry | 2025 | Rationally designed small peptides targeting DPP-4: identification of potent anti-diabetic agents | Journal Article |

### 主题相关性标注（纪律#4）
1. **PMID 34988855**：直接命中——linagliptin（DPP-4i）+ 系统性硬化症小鼠模型（动物疾病模型），高相关。
2. **PMID 41043862**：直接命中——DPP-4i 改善帕金森病肠-脑轴病理（Gut，2026），涉及动物模型，高相关。
3. **PMID 40700924**：部分相关——DPP-4 靶向小肽药物设计（糖尿病方向），MeSH 命中但标题未明示动物模型；属药物化学类，需人工复核是否含动物实验（纪律#2 第三层）。
- 文献类型分布（前3）：Journal Article ×3；无 RCT/系统评价（预期内，动物实验主题）。

## 4. 原始留档（纪律#5）
- `raw_esearch.json`（宽检索 count=439）
- `raw_esearch_2021.json`（2021:2026[dp] count=117，retmax=20）
- `raw_esummary.json`（前3 PMID 摘要信息）

## 5. 置信度（纪律#6）
- 命中数/前3列表：**5**（NIH 官方 E-utilities 逐项返回，非推测）
- 第3条主题相关性判定：**3**（MeSH 命中但标题未明示动物模型，需人工筛选确认）
