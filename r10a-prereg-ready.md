# R10-A OSF 预注册就绪版（Prereg-Ready）— DPP4 受试药 db/db 小鼠随机对照试验

> 来源：`r8c_design_v2.md`（终评修订基线），机制假说引用 R8-B 三通路速览（`r7-mechanism.md` 共识内容）。
> 本文档 = **可直接复制到 OSF Pre-registration 模板的字段级成稿** + 需人工提交清单。
> REF 占位纪律沿用：剂量/文献依据一律 `[REF]`，禁止虚构编号，提交前逐条补实。
> **术语修正记录（R10-A）**：动物实验伦理审查全文统一使用 **IACUC（机构动物伦理与管理委员会, Institutional Animal Care and Use Committee）**；原文档中的 "IRB" 占位已全部替换。IRB 仅适用于人类受试者研究，本方案为动物实验，归口 IACUC。

---

## A. 修正摘要（相对 r8c_design_v2.md §3.2）

| # | 修正/补齐项 | 说明 |
|---|---|---|
| 1 | IRB → IACUC 全文替换 | 伦理编号统一为 `IACUC-2026-____`；注明审查机构为 [机构名称] 实验动物伦理委员会（IACUC）|
| 2 | Hypotheses 填实 | 由 R8-B 三通路机制（AMPK/FOXO3a 抗炎抗氧化轴、肠脑轴 α-syn、心肌脂毒性）推导 H1/H2/H3 |
| 3 | Primary endpoint 定义收紧 | 由「HbA1c（0/4/8 周）」改为**第 8 周 HbA1c 较基线（第 0 周）的变化值（ΔHbA1c_W8）** |
| 4 | Secondary endpoints 补齐 | 体重曲线、炎症标志（血清 IL-6、TNF-α、CRP/血清总蛋白比值 [REF 测定方法]）、氧化应激（SOD 活性、MDA）|
| 5 | Inclusion / Exclusion criteria 新增 | 原骨架缺失，本文补齐 |
| 6 | Sample size rationale 引用 R8-C | 直接引用 r8c_design_v2.md §1（d=0.8, α=0.05 two-tailed, power=0.8 → 25/组；含 20% 流失膨胀 → 32/组 × 5 = 160 只）|
| 7 | Analysis plan（SAP）细化 | 主分析模型、缺失处理、多重比较、效应量与 CI、锁定脚本 |
| 8 | 人工提交字段标注 | §B 表格 + 文中 `[MANUAL]` 标记，AI 不代提交 |

---

## B. 需人工登录 OSF 提交 / 人工补实字段清单

> **AI 仅生成草稿，不代提交 OSF。以下字段需 PI 人工登录 osf.io 完成：**

| 字段 | 人工动作 | 责任 |
|---|---|---|
| OSF Project 创建、模板勾选（Pre-registration）| 人工登录创建 | PI |
| `Principal Investigator` 姓名/单位 | `[MANUAL]` PI 填写 | PI |
| `Institution` 名称 | `[MANUAL]` 填写 | PI |
| `Ethics/IACUC` 排号 `IACUC-2026-____` | 待 [机构名称] 实验动物伦理委员会受理后排号，**先提交伦理申请**再回填 | PI + 机构 IACUC 办公室 |
| 阳性药/受试药剂量 `[REF]` 补实 | 定稿文献核对（西格列汀 10–30 mg/kg 依据、受试药 1/3 临床等效折算依据）| PI |
| 动物供应商/遗传背景 `[REF]` 补实 | 采购合同与品系档案 | 实验员 |
| OSF 提交与 LOCK（状态 DRAFT→LOCKED）| 人工提交、锁定时间戳 | PI |
| OSF DOI / Registration Date | 系统生成，提交后回填 | PI |
| 数据仓库组件（OSF Component / 仓库 URL）| 人工上传原始数据与 R 脚本 | 数据管理员 |

---

## C. OSF Pre-registration 字段级成稿（可直接粘贴）

```
──────────────────────────────────────────────
OSF PRE-REGISTRATION — R10-A / R8-C DPP4 db/db STUDY
──────────────────────────────────────────────
[Project Title] R8-C：DPP4 受试药（DPP4i）对 db/db 小鼠 HbA1c 影响的随机对照剂量-效应试验
[Principal Investigator] ________ [MANUAL: PI 填写]
[Institution] [机构名称] [MANUAL]
[Ethics] [机构名称] 实验动物伦理委员会（IACUC，机构动物伦理与管理委员会）
         Protocol: IACUC-2026-____（占位，伦理受理后回填；动物实验归口 IACUC，非 IRB）
[OSF DOI] （提交后生成） [MANUAL]
[Registration Date] 2026-MM-DD [MANUAL]
[Status] DRAFT → LOCKED（锁定后一切偏离记入 deviation log）
──────────────────────────────────────────────
```

### C.1 Hypotheses（基于 R8-B 三通路机制）

- **H1（主要）**：受试药低/高剂量组较 db/db 溶媒对照组，第 8 周 ΔHbA1c_W8（相对基线下降幅度）显著更大（剂量-效应，趋势检验 P<0.05）。
- **H2（机制-通路1，抗炎/抗氧化轴）**：DPP4 抑制延长 GLP-1 半衰期 → AMPK 磷酸化 → FOXO3a 核转位上调 SOD1/CAT，故受试药组炎症标志（IL-6、TNF-α）较 db/db 对照下降、SOD 活性升高；该通路效应为支持性（supportive）表述——啮齿类 GLP-1 底物组成与人存在差异，不外推至临床（R8-B 未核实项声明第 5 条）。
- **H3（机制-通路2/3，探索性）**：肠脑轴（α-syn 聚集减轻）与心肌脂毒性（心脂沉积/凋亡降低）通路于 4–8 周时程内的结构改善证据强度**未核实**（R8-B 未核实项 2、3），本预注册将其列为**探索性终点，不作主要推断**；若数据不足以检验，在结果中如实报告欠检。
- **H0**：各组 ΔHbA1c_W8 无差异（受试药无作用）。

### C.2 Design & Groups

5 组随机对照（雄性 db/db，6–8 周龄，适应 1 周后按周龄+体重分层随机）：

| 组 | 处理 |
|---|---|
| G1 | db/db + 溶媒（阴性对照）|
| G2 | db/db + 西格列汀 10–30 mg/kg/d p.o.（阳性对照）[REF 剂量依据待补实] |
| G3 | db/db + 受试药低剂量（≈1/3 临床等效剂量按体表面积折算，km 小鼠 K=3 / 人 K=37）[REF] |
| G4 | db/db + 受试药高剂量 [REF] |
| G5 | db/m 同窝对照 + 溶媒（遗传背景对照）|

给药：灌胃 qd，容量 ≤10 mL/kg；周期 4–8 周；每周体重/摄食量/随机血糖。

### C.3 Primary Endpoint（唯一主要终点）

- **ΔHbA1c_W8**：第 8 周 HbA1c（LC-MS/MS 或 HPLC [REF 方法]）相对第 0 周基线的变化值（百分点）。
- 时间序列 0/4/8 周数据用于**描述性轨迹与重复测量探索**，不进入主要假设检验。

### C.4 Secondary Endpoints

1. **体重**：基线及各周体重、体重变化率（每周曲线）。
2. **炎症标志**：血清 IL-6、TNF-α、CRP（或血清总蛋白比值替代）；组织 SOD 活性与 MDA（通路 1 支持性证据）[REF 检测方法与试剂]。
3. 随机血糖 / OGTT、血清胰岛素、血脂谱（TG/HDL/LDL）、摄食量（继承 r8c §0 次要终点集）。
4. 探索性（通路 2/3，非推断性）：心肌/肠组织脂染与 α-syn 免疫定位（如经费允许，另行伦理增补）。

### C.5 Inclusion / Exclusion Criteria（动物水平）

**纳入（Inclusion）**
- 品系：C57BL/KsJ 背景 db/db 与同窝 db/m（遗传背景档案 [REF]）；雄性，6–8 周龄；
- 到达后适应饲养 1 周，空腹血糖 4–30 mmol/L 区间；
- 无感染、无外伤、体重符合品系预期区间。

**排除（Exclusion）**
- 到达时点：适应期死亡、空腹血糖 <4 或 >30 mmol/L、非雄性/周龄不符；
- 随机化前发现品系档案不符（如杂合误判）即整笼剔除并记录。

**剔除/终止（Termination / Dropout 规则）**
- 人道终点（预定义）：随机血糖 >30 mmol/L 或 7 日体重骤降 >20% → 安乐并记录原因与时间点；
- 操作失败（灌胃误入气管、采血失败 2 次）→ 剔除该时点数据，动物保留入组直至人道终点；
- 预设 20% 流失，分析集 = 完整数据 + 已记录剔除原因（ITTT，intent-to-treat 动物水平）。

### C.6 Sample Size Rationale（引用 R8-C §1 power calc）

> 依据 `r8c_design_v2.md` §1.1–1.6：

- 参数：主要终点 ΔHbA1c_W8 预期 Cohen's d = 0.8（大效应），α = 0.05 two-tailed，power = 0.80；
- 两样本 t 近似公式 n = 2(z₀.₉₇₅ + z₀.₈₀)²/d² = 24.53 → **25/组**（保证任意 Tukey 两两比较检验力；5 组 ANOVA f≈0.4 视角一致）；
- 含 20% 流失膨胀：**32/组 × 5 组 = 160 只**（最终推荐）；
- 若经费/伦理受限退回 25/组（125 只），须在结果中声明「剔除后可能欠检」；
- 3R 权衡已记录于 IACUC 3R 声明（减量：重复测量 + 功效最小化；替代：db/m 同窝对照；精细：灌胃限量 + 预设人道终点）。
- R 核验脚本见 r8c_design_v2.md §1.5（pwr.t.test / pwr.anova.test / 膨胀计算），随 OSF 公开。

### C.7 Statistical Analysis Plan (SAP)

1. **描述**：mean ± SEM；ΔHbA1c_W8 各组箱线图 + 效应量。
2. **主分析**（预先锁定，不得事后变更）：
   - 主要终点：单因素 ANOVA（5 组）→ 组间比较 Tukey HSD；受试药低/高剂量剂量-效应趋势用线性趋势检验。
   - 若方差齐性/正态性不满足（Levene/Shapiro-Wilk）→ Kruskal-Wallis + Dunn 事后。
3. **时间序列**（体重、血糖、HbA1c 0/4/8）：重复测量 ANOVA；球形不满足用 Greenhouse-Geisser 校正。
4. **多重性**：次要终点采用 Holm-Bonferroni 族内控制 FWER；探索性终点仅描述性，不推断。
5. **效应量与 CI**：主分析报告 Cohen's d（Hedges' g 校正）与 95% CI（ARRIVE 5.2）。
6. **缺失处理**：ITT 动物水平；剔除记录入数据表；敏感性分析 = 完整病例集对比。
7. **显著性**：α = 0.05 two-tailed。
8. **随机化与盲法**：适应后按周龄 + 体重分层区组随机（区组=5，种子与随机表存 OSF）；灌胃操作者与 HbA1c/炎症标志检测人员设盲，盲法破盲规则预先定义。
9. **锁定**：分析 R 脚本与数据表模板于 LOCK 前提交 OSF；LOCK 后任何偏离记入 deviation log 并说明理由。

### C.8 Reporting & Data Sharing

- 按 ARRIVE 2.0 报告全部组（含阴性结果）；
- 原始数据、随机表、R 分析脚本、数据字典随 OSF 组件公开；
- 局限性（预声明）：雄性单一；HbA1c 为间接终点；剂量 [REF] 待补实；通路 2/3 支持性非外推性；若实际剔除 >20% 则欠检风险。

### C.9 Version & Deviation Log

- v1.0 初稿（R10-A 修订：IACUC 术语、假设三通路化、主终点改 ΔHbA1c_W8、新增纳排标准）；
- 偏离记录表：`deviation_id / 日期 / 内容 / 理由 / 影响评估`，LOCK 后逐条登记。

---

## D. 提交前检查清单（PI 人工执行）

- [ ] 伦理申请已提交 [机构名称] 实验动物伦理委员会（IACUC），获受理号 → 回填 `IACUC-2026-____`
- [ ] 所有 `[REF]` 占位（西格列汀剂量、受试药折算、供应商、检测方法）逐条补实，无虚构编号
- [ ] 随机表与区组种子生成并存 OSF
- [ ] 登录 osf.io → 创建 Pre-registration 项目 → 粘贴 §C 成稿 → DRAFT 审阅 → **LOCK**
- [ ] OSF DOI / Registration Date 回填本文件
- [ ] 数据组件（原始数据表、R 脚本）上传并设公开

> **声明：AI（GLM-5.3，智谱 AI）仅生成草稿与占位；OSF 提交、锁定、伦理排号回填均须 PI 人工完成，AI 不代提交。**
