# Goal Report: PubMed E-Search — SGLT2 Inhibitor × Cardiovascular Outcome

## RESULT
- **Query**: `SGLT2 inhibitor cardiovascular outcome`（db=pubmed, sort=relevance）
- **命中数（count）**: **4097**
- **前 3 PMID（按 relevance）**:
  1. **38456601** — *SGLT2 inhibitors: from glucose-lowering to cardiovascular benefits.* (Cardiovasc Res, 2024 Apr 30)
  2. **39210781** — *Cardiovascular, Kidney, and Safety Outcomes With GLP-1 Receptor Agonists Alone and in Combination with SGLT2i* (Circulation, 2024 Nov 26)
  3. **32665641** — *SGLT2 inhibitors: mechanisms of cardiovascular benefit beyond glycaemic control.* (Nat Rev Cardiol, 2020 Dec)

## CHANGED
- 创建 `goal-report.md`（本报告）
- 未修改工作区其他文件

## TESTED
- `esearch.fcgi` 调用返回 200 JSON：`count=4097`，`idlist` 前 3 = 38456601, 39210781, 32665641
- `esummary.fcgi` 交叉验证 3 个 PMID 存在且标题与主题匹配（见 EVIDENCE）

## EVIDENCE
```
GET https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi
    ?db=pubmed&term=SGLT2+inhibitor+cardiovascular+outcome
    &sort=relevance&retmax=3&retmode=json
→ {"esearchresult":{"count":"4097","idlist":["38456601","39210781","32665641"]}}

esummary(id=38456601,39210781,32665641) 输出：
38456601 | 2024 Apr 30 | Cardiovasc Res | SGLT2 inhibitors: from glucose-lowering to cardiovascular benefits.
39210781 | 2024 Nov 26 | Circulation | Cardiovascular, Kidney, and Safety Outcomes With GLP-1 Receptor Agonists Alone and in Combination Wi…
32665641 | 2020 Dec | Nat Rev Cardiol | SGLT2 inhibitors: mechanisms of cardiovascular benefit beyond glycaemic control.
```
注：esearch 自动将 "SGLT2 inhibitor" 扩展为 MeSH 词 "sodium glucose transporter 2 inhibitors"（见 querytranslation）。

## BLOCK
- 无

## ASK
- 如需扩展：可加时间限定（datetype/date）、限制人类研究或 RCT（`randomized controlled trial[pt]`），或拉取完整 4097 条列表（retmax 分页）。需要哪种请指示。
