# PubMed E-utilities 检索：GLP-1 动物实验

## 检索信息

- **检索日期**：2026-02-27（以实际执行日期为准）
- **数据库**：PubMed
- **检索接口**：NCBI E-utilities（`esearch.fcgi`）
- **结果类型**：命中文献数（`rettype=count`）

## 检索式与命中数

| 编号 | 检索式 | 命中数 |
|------|--------|--------|
| 1 | `GLP-1 AND animal`（全字段） | **12,484** |
| 2 | `GLP-1[Title/Abstract] AND Animals[MeSH Terms]` | **19,012** |

## 检索 URL

1. https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=GLP-1+AND+animal&rettype=count
2. https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=GLP-1[Title/Abstract]+AND+Animals[MeSH+Terms]&rettype=count

## 说明

- 检索式 1 为宽泛的自由词检索，结果偏少但可能漏检（未限定字段且 "animal" 单数形式覆盖不全）。
- 检索式 2 使用主题词 `Animals[MeSH Terms]` 限定动物实验相关文献，命中数更多、更全面，推荐采用。
- 若需更精确的动物实验文献，可进一步结合其他主题词（如 `Models, Animal`）或 RCT/临床研究排除策略进行筛选。
