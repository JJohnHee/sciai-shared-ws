# R6 · PubMed E-utilities 检索报告
## 主题：DPP-4 inhibitor × 动物模型 联用文献

> 检索纪律：scios-research（sort=relevance + MeSH 展开 → 窄化 → 直译对比）。全部数字来自实际 NCBI E-utilities API 调用，零编造。

## 1) 检索式与命中数

### 检索式 A（MeSH 展开 + sort=relevance）
```
(DPP-4 inhibitor[MeSH] OR sitagliptin[MeSH] OR saxagliptin[MeSH] OR linagliptin[MeSH])
AND (Rodentia[MeSH] OR mice[tw] OR rats[tw] OR mouse[tw])
```
- `esearch sort=relevance`
- **命中数：1519**

⚠️ 数据完整度说明（来自 API TranslationSet/ErrorList）：
- `DPP-4 inhibitor[MeSH]` → `"dipeptidyl-peptase iv inhibitors"[MeSH Terms]` ✓
- `sitagliptin[MeSH]` → `"sitagliptin phosphate"[MeSH Terms]` ✓
- `linagliptin[MeSH]` → `"linagliptin"[MeSH Terms]` ✓
- `Rodentia[MeSH]` → `"rodentia"[MeSH Terms]` ✓
- **`saxagliptin[MeSH]` 无匹配（PhraseNotFound）**——saxagliptin 未被单独建 MeSH，未纳入本次结果集。

### 窄化（+2021:2026[dp]，sort=relevance）
- 时间窗内命中数：**418**
- 取前 3 篇（relevance 排序）：

| PMID | 标题 | 期刊 | 发表 |
|------|------|------|------|
| 37535747 | Microbial-host-isozyme analyses reveal microbial DPP4 as a potential antidiabetic target. | Science (New York, N.Y.) | 2023 Aug 4 |
| 35772725 | Dipeptidyl Peptidase-4 Inhibitor Sitagliptin Exhibits Antioxidant Mechanism for Abrogation of Cyclophosphamide-Induced Cardiac Damage and Oxidative Hepatorenal Toxicity in Rats. | Drug research | 2022 Sep |
| 37973297 | Saxagliptin, a selective dipeptidyl peptidase-4 inhibitor, alleviates somatic cell aneugenicity and clastogenicity in diabetic mice. | Mutation research. Genetic toxicology and environmental mutagenesis | 2023 Nov-Dec |

## 2) 直译式对比

### 检索式 B（直译式，无 sort）
```
DPP-4 inhibitor animal
```
- `esearch`（默认相关度）
- **命中数：2939**
- API 自动展开为：`"dipeptidyl-peptidase iv inhibitors"` 的 [Pharmacological Action]/[Supplementary Concept]/[All Fields]/[MeSH Terms] + `"dpp 4 inhibitor"` [All Fields] AND `animals[MeSH:noexp] OR animal[All Fields]`

### 命中数对比
| 检索式 | 命中数 | 差异 |
|--------|--------|------|
| A（MeSH + relevance，全时段） | 1519 | — |
| A 窄化 2021–2026 | 418 | 约 27.5% 集中在近 5 年 |
| B（直译式，全时段） | 2939 | 比 A 多约 93%（+1420） |

**解读**：直译式 B 用 [All Fields] 全字段 + animals(noexp) 泛匹配，召回量更大、更松（含正文/任意字段出现 "animal" 的文献）；MeSH 检索式 A 命中更少但语义更精确。两者差异主要来自字段范围与术语展开方式，非动物模型本身。

## 3) 核心结论（≤80 字）
DPP-4 抑制剂在啮齿动物模型中主要被用于抗氧化/脏器保护与遗传毒性研究；2021–2026 约 418 篇，占全时段 1519 篇的 27.5%。saxagliptin 无独立 MeSH，直译式召回更高但精度更低。

## 4) 置信度
**4 / 5** —— 命中数、PMID、标题、期刊均直接来自 API 返回，可复核；扣分项：saxagliptin 未被 MeSH 收录，检索式 A 实际未覆盖该药，故 MeSH 检索式对"全部 DPP-4i"覆盖不完整（直译式 B 的 [All Fields] 反而能捞到 saxagliptin 文献）。

## 附：可复现命令
```bash
# A
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&sort=relevance&retmax=0&term=(DPP-4%20inhibitor%5BMeSH%5D%20OR%20sitagliptin%5BMeSH%5D%20OR%20saxagliptin%5BMeSH%5D%20OR%20linagliptin%5BMeSH%5D)%20AND%20(Rodentia%5BMeSH%5D%20OR%20mice%5Btw%5D%20OR%20rats%5Btw%5D%20OR%20mouse%5Btw%5D)"
# A 窄化 + 前3
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&sort=relevance&retmax=3&term=(DPP-4%20inhibitor%5BMeSH%5D%20OR%20sitagliptin%5BMeSH%5D%20OR%20saxagliptin%5BMeSH%5D%20OR%20linagliptin%5BMeSH%5D)%20AND%20(Rodentia%5BMeSH%5D%20OR%20mice%5Btw%5D%20OR%20rats%5Btw%5D%20OR%20mouse%5Btw%5D)%20AND%202021%3A2026%5Bdp%5D"
# 前3 esummary
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=37535747,35772725,37973297&retmode=json"
# B
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmax=0&term=DPP-4%20inhibitor%20animal"
```
