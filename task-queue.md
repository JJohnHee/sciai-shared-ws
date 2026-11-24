# task-queue.md — 调度队列（i9 研究部 / lx7 / 100.91.112.30）

> 由 heartbeat.sh 每 60s 从 hub:8788 /api/tasks 自动同步（上行心跳 + 下行任务 = 调度闭环 v1）。
> 任务执行/重试走 retry.sh；LLM 任务由 18900 模型池执行（model: deepseek-flash-fb）。
> 同步时间（UTC）: 2026-11-24T14:35:02Z

| ID | 任务 | 节点 | 状态 |
|---|---|---|---|
| HUB-0f821851 | 在当前目录创建 opc-test.md，内容为：OPC-TURN-OK。完成后回复 DONE。 | lx7(100.91.112.30) | PENDING |
| HUB-e52aa25e | 用 epic-breakdown-advisor 技能，把「实现多节点并行跑科研任务」这个大 Epic 拆成纵切小故事。要求：先 INVEST 检查、按九种拆法至少给出 4 个按交付顺序的故事（含价值/验收/依赖/预估），写到 /root/ | lx7(100.91.112.30) | PENDING |
| HUB-dee806f7 | 用 Bash 执行: echo OK-CLAUDE > /root/sciai_ws/tooluse-claude-1795408860424.txt。完成后只回复 DONE。 | lx7(100.91.112.30) | PENDING |
| HUB-0052969f | 执行 hostname 命令，只回复输出内容，不要解释。 | lx7(100.91.112.30) | PENDING |
| HUB-8672d5df | 用 Bash 或 Write 工具在 /root/sciai_ws 下创建 tooluse-claude-1795408575901.txt，内容 OK-CLAUDE。完成后回复 DONE。 | lx7(100.91.112.30) | PENDING |
| HUB-8307d99c | 只回复两个字：可用 | lx7(100.91.112.30) | PENDING |
| HUB-c3530953 | 只回复数字：PubMed 检索 Aspirin[MeSH] 的全部年份命中数？实调 eutils 确认。 | lx7(100.91.112.30) | PENDING |
| HUB-42aff292 | 以下是同一文件在两边的版本，请给出合并后的完整文件内容（只输出文件内容，不要解释）：

【master 侧】
VERSION-A


【分支侧】
VERSION-B | lx7(100.91.112.30) | PENDING |
| HUB-cb795fec | 任务：检索 DPP-4 抑制剂在动物模型中的文献。要求：按 scios-research 技能的 PubMed 检索纪律，用 MeSH 严格式（动物侧必须 "Disease Models, Animal"[MeSH Terms]），sort | lx7(100.91.112.30) | PENDING |
| HUB-355b3a20 | 请在当前目录创建 README.md，写入一行：# Demo Project
然后是：项目托管闭环测试 OK。完成后回复 DONE。 | lx7(100.91.112.30) | PENDING |
| HUB-24eacf92 | ??????? README.md,???:???????? OK????? DONE? | lx7(100.91.112.30) | PENDING |
| HUB-bdd64f53 | 任务：检索 DPP-4 抑制剂在动物模型中的文献。要求：用 MeSH 严格式检索（自己判断合适主题词），sort=relevance。必须实际调用 PubMed E-utilities 拿真实数字。报告：全部年份命中数、2021-2026  | lx7(100.91.112.30) | PENDING |
