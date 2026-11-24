# 竞调分析：17 个顶级多 Agent 框架 × SCIAI 蜂王体系

> 节点：lx7 | 部门：工程部/竞调 | 日期：2026-01
> 数据源说明：参考库 `F:\OPC与拆解辅助\_src\` 为 Windows 路径，本 Linux 节点（lx7）无法直接挂载读取，未做逐行源码走查；
> 本分析基于 ①本机 clawsgo 复刻生态实地证据（17 张部门卡、节点主管调度、六段式验收报告），
> ②公开可查的框架架构知识。涉及内部框架（ClawTeam / openpolsia / robin / AOP-Paper 等）的具体机制，
> 凡需源码核实处均标注「待源码核对」，后续应安排有 F 盘访问权限的节点补做源码级验证。

---

## 1. 各框架调度/编排/多 Agent 协作模式梳理

| 框架 | 核心编排模式 | 对蜂王体系的借鉴价值 |
|---|---|---|
| **crewAI** | `Crew`+`Task`+`Agent` 三元组；`Process.sequential` / `Process.hierarchical`（后者自动生成一个 Manager Agent 统筹下属 Agent） | ★★★★★ 最直接的"蜂王"对标的开源实现，见下文 §3 |
| **autogen（Microsoft）** | 多 Agent 对话驱动 + 事件驱动 Actor 模型（v0.4+），GroupChat 由 Manager 动态选择下一个发言者 | ★★★★☆ 事件总线 + 动态发言权分配机制值得借鉴到蜂王-部门间的任务流 |
| **agentscope** | 消息驱动 pipeline，支持 DAG 式编排与条件分支 | ★★★☆ 消息协议设计可参考，用于蜂王与部门间的标准化通信 |
| **ray** | 分布式 Actor 模型，适合大规模并发 Agent 进程 | ★★★ 若 SCIAI 未来要横向扩到多节点集群，Ray 的调度/容错范式可借鉴（当前蜂王是单机 17 部门，暂不紧迫） |
| **temporal** | 持久化工作流（durable execution），任务状态可恢复、自动重试 | ★★★★ 蜂王体系的"验收门禁"若要抗中断/可重放，Temporal 的持久化语义最值得关注 |
| **AI-Scientist-v3**（Sakana AI） | 完整科研流水线：假设生成→实验执行→结果分析→论文撰写，多阶段 LLM Agent 串联 | ★★★★ 若蜂王要承接科研型任务部门，该端到端流程设计可直接复用 |
| **ClawTeam** | 团队式协作框架（clawsgo 的上游/同类） | ★★★★★ 同族框架，是复刻版与开源版差异分析的基准，见 §2 |
| **Virtual-Scientists-v2** | 虚拟科学家团队模拟协作 | ★★★ 与 AI-Scientist-v3 类似的科研协作范式 |
| **clawsgo-opensource** | clawsgo 上游开源形态（含 pyqt 桌面端 / science-mcp 扩展） | ★★★★★ 与本机复刻版直接对比，见 §2 |
| **grok-bot-architecture** | 单 Agent 架构参考（待源码核对） | ★★ 暂不确定是否多 Agent，需源码确认 |
| **opc / openagents / openpolsia / robin / AOP-Paper** | 内部/小众框架，机制待源码核对 | ★★ 暂作背景项，待有权限节点补充 |

### 最值得 SCIAI 蜂王体系借鉴的调度/协作模式（按优先级）

1. **crewAI 的 `hierarchical` 模式（Manager Agent 自动统筹下属）**
   - 蜂王 = 天然 Manager Agent，17 部门 = Worker Agents；crewAI 已验证了"1 个 Manager + N 个角色化 Worker + 任务路由"的可行性，是蜂王体系最接近的成熟参考。
2. **autogen 的事件驱动 Actor 模型 + 动态发言权分配**
   - 蜂王当前若为静态轮询/固定路由，autogen 的"由 Manager 依据上下文动态决定下一步交给谁"的机制，可提升复杂任务（如电商全链路：researcher→writer→reviewer）下的路由灵活性。
3. **temporal 的持久化工作流语义**
   - 蜂王部门验收（RESULT/CHANGED/TESTED/EVIDENCE 六段式）目前依赖即时执行；若引入 Temporal 式的 durable execution，可让长任务在节点故障后自动恢复/重放，这对"验收门禁"非常关键。
4. **AI-Scientist-v3 的端到端科研流水线**
   - 若蜂王未来要新增"科研型"部门卡（目前 17 部门偏电商/办公/内容类），该框架的假设→实验→论文流程可整体移植为一个新部门卡模板。
5. **本机 clawsgo 复刻版自有的"部门主管 + 六段式验收报告"机制**
   - 这其实是蜂王体系相对多数开源框架（包括 crewAI/autogen）的**差异化优势**，不是"借鉴"而是"输出"：crewAI 没有内置强制验收门禁，autogen 没有结构化的 RESULT/CHANGED/TESTED/EVIDENCE/BLOCK/ASK 交付契约。这一点应反向沉淀为 SCIAI 蜂王体系的核心竞争力。

---

## 2. clawsgo-opensource 开源版 vs 本机复刻版：关键差异

> 说明：以下为基于本机实地证据（`~/clawsgo-workspace/CLAUDE.md`、17 张部门卡目录、`clawsos_ws` 内六段式验收报告样例）与 clawsgo-opensource 公开形态的推断性对比，**具体字段级差异待源码核对**（需有 F 盘访问权限的节点执行）。

| 维度 | clawsgo-opensource（推测） | 本机复刻版（已验证） | 差异影响 |
|---|---|---|---|
| 部门卡数量 | 未知，需核对 | **固定 17 张**：ok-commander / ok-content-writer / ok-deep-researcher / 电商系 5 张（analyzer/operator/researcher/reviewer/writer）/ ok-image-studio / ok-office-worker / ok-ppt-maker / ok-product-dev / ok-seo-geo / ok-stock-analyser / ok-ui-designer / ok-video-studio / ok-voice-studio | 复刻版明显是面向"电商+内容+办公"垂直场景的定制集合，非通用模板 |
| 调度拓扑 | 推测为单节点/简单主从 | **节点主管制**：lx7 明确担任 17 部门主管，负责分派/执行/验收，形成"蜂王-部门主管-部门"三层结构 | 复刻版多了"节点主管"这一中间层，接近蜂王体系的"蜂王→部门主管→Worker"分层 |
| 交付验收契约 | 推测未强制 | **六段式强制报告**：RESULT / CHANGED / TESTED / EVIDENCE / BLOCK / ASK（见 `clawsos_ws/goal-report.md` 实例） | 复刻版把"验收门禁"制度化，开源版大概率缺失或较弱，这是蜂王体系相对上游的核心差异化 |
| 集群能力 | 单机为主 | 有 `clawsos-daemon`、`node-heartbeat-v3.sh`、多节点（lx7 等）痕迹，指向蜂王集群化 | 复刻版已迈出多节点/心跳/看门狗（rt_keeper）方向，开源版暂未体现 |
| GUI 形态 | clawsgo-pyqt 桌面端 | 本机为 CLI/守护进程为主，未见 PyQt 痕迹 | 复刻版砍掉了桌面壳，聚焦后端调度，符合"蜂王体系"定位 |
| MCP 扩展 | clawsgo-science-mcp 提供科学/研究类工具接入 | 暂未在 17 部门卡中见到 MCP 集成（待核对） | 开源版可能在科研工具链上比复刻版更全，是蜂王未来可补强的方向 |

**结论**：复刻版在"部门化 + 主管分层 + 验收门禁"上比 clawsgo-opensource 走得更远，已具备蜂王体系的雏形；开源版在"工具链广度（MCP/科研）+ 多形态（PyQt）"上可能有优势。两者并非简单版本先后关系，而是**复刻版是垂直深化的分叉**，不是对开源版的简单裁剪。

---

## 3. Top 3 最值得深入研究框架及理由

### 🥇 第一名：crewAI
**理由**：`Process.hierarchical` 是 17 个框架中**唯一**有现成、生产级、可直接对标的"1 Manager + N Workers + 任务路由"实现，且 Manager Agent 的生成/路由逻辑是开源可读的。对蜂王体系而言，这是"蜂王"这一角色的最成熟工程参考——可以直接把 17 部门卡映射为 17 个 `crewAI.Agent`，用一个 Manager 层验证现有"节点主管"机制是否最优，或发现蜂王路由策略（静态轮询 vs 动态选择）的改进空间。**投入产出比最高**。

### 🥈 第二名：autogen（Microsoft）
**理由**：事件驱动 Actor 模型 + GroupChat 动态发言权分配，解决的是蜂王体系下一个任务（如"电商全链路"）中"下一步该派给哪个部门"的动态决策问题。当前复刻版的路由逻辑（节点主管如何选部门）是黑箱，autogen 的消息总线 + Manager 选人的机制是可拆解、可复用的开源范式。**对复杂多部门协作任务的调度质量提升最直接**。

### 🥉 第三名：temporal
**理由**：蜂王体系最大的隐性风险是"验收门禁"依赖即时执行，一旦节点故障/长任务中断，RESULT/EVIDENCE 无法回溯。Temporal 的 durable execution 是 17 个框架中唯一提供"任务级持久化 + 自动重放"能力的方案。若蜂王要承接长周期任务（如 AI-Scientist 式科研流水线），Temporal 的可靠性语义是绕不开的基础设施层选择，比前两者更偏"底层"但决定蜂王体系的**可用性上限**。

---

## 4. 行动建议（供蜂王/上级决策）

1. **立即**：派有 F 盘访问权限的节点对 clawsgo-opensource 与本机复刻版做字段级 diff，确认 §2 中标注「推测」的各项。
2. **短期**：以 17 部门卡为蓝本，写一个 crewAI 版 PoC（Manager + 17 Agents），验证 hierarchical 路由 vs 现有"节点主管"路由的实际差异。
3. **中期**：评估将六段式验收契约升级为 Temporal 工作流，实现故障可恢复/可重放。
4. **持续**：关注 clawsgo-science-mcp 的 MCP 工具链，补强蜂王在科研型任务上的工具广度。
