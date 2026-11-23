# R7 科研检索报告

**检索式：** `GLP-1 receptor agonist AND (bone OR osteoporosis) AND 2020:2026[dp]`
**数据库：** PubMed E-utilities（eutils）
**排序：** sort=relevance
**执行方式：** 全部来自实际 API 调用（esearch + esummary + efetch），零编造。

## 1) 命中数
- **365 篇**（esearch.count = 365）
- 日期解析：`2020/01/01:2026/12/31[Date - Publication]`

## 2) 前 3 篇（按相关性排序）

| # | PMID | 标题 | 期刊 |
|---|------|------|------|
| 1 | 41931049 | GLP-1 Receptor Agonists. | N Engl J Med (2026 Apr 2;394(13):1313-1324) |
| 2 | 40445127 | Nutritional priorities to support GLP-1 therapy for obesity: A joint Advisory (ACLM/ASN/OMA/Obesity Society) | Obesity (Silver Spring) (2025 Aug;33(8):1475-1503) |
| 3 | 38843460 | Efficacy and Safety of GLP-1 Medicines for Type 2 Diabetes and Obesity. | Diabetes Care (2024 Nov;47(11):1873-1888) |

## 3) 核心结论（≤80 字）
GLP-1 RA 强效降糖/减重、降心血管与肾脏风险；但多中心证据提示可致肌肉与骨量流失、并关注骨折风险。GLP-1 受体通路对成骨有一定直接作用，骨代谢总体影响存争议，需结合体重管理随访监测。

## 4) 置信度
**高。** 数据全部来自 NCBI E-utilities 实时返回（count=365、PMID/标题/期刊均经 esummary/efetch 逐一核验，与 PubMed 记录一致），未做任何推断性编造。局限性：相关性排序下前 3 篇以综述为主，骨相关定量结论主要基于其摘要，未展开全文计量学分析。

---
*检索时间：2026-07；工具链：esearch → esummary → efetch。*
