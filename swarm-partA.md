# 科研蜂群 Part A — PubMed 检索：DPP-4 inhibitors liver protection

- **检索式**：`DPP-4 inhibitors liver protection`
- **接口**：esearch（`sort=relevance`）→ esummary，全部来自 PubMed E-utilities 实际 API
- **检索日期**：2026-11-22
- **结果**：命中 94 篇，取相关度排序前 3 篇
- **原始留档**：`swarmA_esearch.json`（esearch）、`swarmA_esummary.json`（esummary）
- **数据置信度**：5（官方接口逐项核验，PMID/标题/期刊/年份直接来自 esummary 返回）

## 前 3 篇（按 sort=relevance）

| # | PMID | 标题 | 期刊 | 年份 |
|---|------|------|------|------|
| 1 | 39283612 | GLP-1 Receptor Agonists and Risk for Cirrhosis and Related Complications in Patients With Metabolic Dysfunction-Associated Steatotic Liver Disease. | JAMA internal medicine | 2024 |
| 2 | 30729549 | Reply. | Hepatology (Baltimore, Md.) | 2019 |
| 3 | 31496048 | Dipeptidyl peptidase-4 inhibitors and aerobic exercise synergistically protect against liver injury in ovariectomized rats. | Physiological reports | 2019 |

## 相关性标注（三层漏斗·人工筛选）

- **PMID 39283612**（置信度 3/5，直接命中度中）：主题聚焦 GLP-1 RA 对 MASH 相关肝硬化风险，非 DPP-4i 直接肝保护证据；MeSH 展开中 "DPP-4 inhibitors" 与肝病文献联用所致命中。文献类型：临床研究。
- **PMID 30729549**（置信度 2/5，间接）：通讯回复（Reply），无原始数据；命中源于期刊关键词。文献类型：Letter/Reply。
- **PMID 31496048**（置信度 5/5，直接命中）：DPP-4 抑制剂与有氧运动协同保护去卵巢大鼠肝损伤，与检索式核心语义完全一致。文献类型：动物实验研究。

**结论**：前 3 篇中真正直接相关 DPP-4 抑制剂肝保护者为 PMID 31496048（动物模型）；39283612 偏 GLP-1 领域，30729549 为通讯回复，需进一步窄检索（标题/摘要限定联用词）筛选直接命中者。
