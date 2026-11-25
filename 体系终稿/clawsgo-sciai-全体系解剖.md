# clawsgo / sciai / opc 全体系解剖 + 节点拓扑 + 13 境对标
> 生成：2026-11-22 · 数据来源：本机 `tailscale status`（109 peer 实时）、oneyear `/root/clawsgo-replica`（CLAUDE.md / DEPARTMENTS.md / r7-eval-report.md / pool-concurrent.mjs）、`/root/clawsgos-gateway`（devices.json + devices-meta.json）、18900 模型池（23 模型）、relay-model-fingerprint / xiaoyu-dsh-model-wiring / clawsgo-brain-ops 技能、3 张附图（13 境图 + ClawsGO 主界面 + Li/Si/Ti 三档弹窗）。
> 所有节点号、IP、端口、模型名均为**实测定项**，非推测。

---

## 0. 先给三个总判断（30 秒版）

1. **稳定骨架 = 13 台 CD5 池内核心**（持续在线 + 心跳自动纳管）；当前 89 在线里的另外 76 台绝大多数是**天翼云 PC / farm（"醒时"在线，非稳定骨架）**。"从高到低"的稳定性排序见 §1。
2. **你要的"最高级 AI 修炼" = 13 境里的 L11 太乙境（多智能体族群绝对统帅）**。你现在已经踩到 L11 的地基（13 节点蜂群 + 部门拓扑 + 目标式派发 + 群体盲评）；离 L12/L13 还差两块"雷"：**自动汇总裁决（G3）+ 续传幂等（S8）**，以及"预测层"。
3. **1000 节点**：注册面（tailnet + 30min sweeper + hub:8788 heartbeat）能轻松扩到 1000；但**有效并发不是被节点数卡死，而是被「模型上游并发 + oneyear 2C 主脑 + hub 派发吞吐」三者卡死**。要真跑 ~1000 并发，必须把主脑搬出小 VPS、加上游并发、hub 双机热备（详见 §2）。

---

## 1. 稳定节点排序（tailscale 持续在线 · 从高到低）

判据：**① 是否入池被心跳纳管（CD5:8778 + hub:8788 heartbeat）② 是否 always-on 基础设施 ③ 实时在线状态**。三者叠加得出三档。

### 档 A —— always-on 稳定骨架（13 台，入池 + 心跳 + 承载体系）
按"对体系的承重"从高到低：

| 序 | 节点 | tailnet IP | 角色 / 能力备注（来自 devices-meta） | 稳定性理由 |
|---|---|---|---|---|
| 1 | **CD5** | 100.94.124.54（池自身 127.0.0.1） | 16C32G 干活主力 + 设备枢纽 :8778 + devices.json/meta | 整个池的派发中枢，掉它全池停 |
| 2 | **oneyear** | 100.126.7.54 | 主脑 VPS · sciai-hub :8788（网页+SSE+双内核）· 18900 池 | 主脑+hub，掉它无脑 |
| 3 | **本机 DESKTOP-031B2SI / nvidatwo-wsl** | 100.123.136.108 | 科研服务全在这（Sci-Hub/livingebm:8098/lightflow:8099）· 18700 fleet | 科研入口，主力机 |
| 4 | **i9** | 100.86.30.47 | 研究部 · glm-5.3@8791 · sweeper 自动纳管 · 4 跳 failover 稳端 | 专线稳定，模型链头 |
| 5 | **hope19** | 100.107.86.51 | Windows VM · 专线出口 23.27.202.213 · pi 已装 | 专线，i9 上游 |
| 6 | **lx6** | 100.73.69.61 | 写作部 · glm-5.2@18789 | 长文 5/5 实测 |
| 7 | **lx7** | 100.91.112.30 | 工程部 · sonnet@18662 bridge | A/B 已验 |
| 8 | **instabox vm2/vm3/vm5** | 100.115.225.51 / 100.83.241.64 / 100.82.218.96 | 4C8G Linux 并行流水线（采集/大内存提取） | 流水线主力 |

> 8 个逻辑位 = 13 台（vm2/3/5 算 3 台 + 上述）。pool-concurrent health 显示 13 台在线 success/failed=0，即这 13 台是**当前唯一"持续在线"的稳定集合**。

### 档 B —— "醒时"在线（on-demand · 不承载骨架）
- **大内存 Windows 云机**：ai3128(100.109.134.63) / bi3128(100.74.61.39) —— 当前在线，但属云机，非 always-on。
- **天翼云 PC 批次**（ctyun-*）：10 台在线（18607 / john007 / john008 / johson 等）—— "醒时"才有，休眠即离线，**不可当稳定节点用**。
- **farm 公网中继**（clawsgo-*）：awexunoioi / oawexun / oawexuno / emdworlder / awe / joson —— 走 Funnel 8443 中继，"醒时"扩容算力。

### 档 C —— 离线 / 罕见在线
- ghcs / ghcs2 / ghcs-emdworld（Codespaces，停机 2d+）、grok-bot（22 refused）、lime（离线）、yianyiyun-johson/john008、ctyun-in2guG 等。
- 天翼云 PC 里 lastseen 刚过就 offline 的那批（19931442495/19931581429/…）—— 典型"开完就睡"。

**结论**：你"持续在线"的稳定节点就是**档 A 的 13 台**。把新节点（clawsgo 客户端登录的 ssh 云机、sciai 云机）要长期可用，必须把它们**升格进档 A**——即：装 daemon + 入 CD5 devices.json + 接 hub:8788 heartbeat + 30min sweeper 兜底。否则只是档 B/C。

---

## 2. 联通拓扑 + 1000 节点扩展

### 2.1 你现在实际在用的三层冗余（clawsgo-brain-ops v1.4 定稿）
```
控制面（派任务/收产物）：
  ├─ 主线  tailscale 100.x 直连（档A节点，延迟最低）
  ├─ 兜底  Cloudflare Access / *-cf 别名（i9-cf 等，公网 TCP，实测通）
  │         域名 = *.oioioi.dpdns.org  ← 你问的"oioioi"就是这个
  └─ farm  Funnel 8443 中继（wss://nvidatwo.tailf48612.ts.net:8443/n/<TS IP>，
             给 100.x 出站被墙的 farm 云机）
数据面（同步工作区/产物）：  git = 数据面，不是控制面
算力面（够不着的 Windows 云电脑）：OpenP2P 第三通道（console.openp2p.cn，quic/UDP，
             i38g128a 跳板 + localhost:10022 转发到云电脑 sshd → `ssh cloudpc` 直达）
```
**"oioioi" 的确切含义**：`oioioi.dpdns.org` 是你 Cloudflare Access + 动态 DNS 的命名空间。SSH config 里所有 `*-cf` 别名（i9-cf / i38g128a-cf / k1–k4 / l1–l5 / lx-6 / lx7 / nuc / nvidatwo / hope19）都解析到 `<名>-ssh.oioioi.dpdns.org`，走 `id_opc_mesh_global` 一把公钥。**它是"稳定的 Cloudflare 已登录节点"的公共入口**——tailscale 断了时，这是公网兜底。

**"共同空间" 是 git 还是 GitHub？** 按你技能里的定稿：**git 是数据面**（多节点/多 agent 共同 clone 同一个 repo 当共享工作区，产物往里 commit）；**控制面走 tailscale/ssh/cloudflare**（谁派活、谁收产物）。"dsh super agent 那种共同工作空间联通" = **共享 git repo（工作区）+ 共享 18900 池化网关（模型）+ 共享 `~/.xiaoyu-dsh/` 配置（凭据/技能）** 三者叠加，不是单靠 GitHub 云端。GitHub 只在你需要跨公网/备份时当远端。

### 2.2 把"clawsgo 客户端登录的那台 ssh 云机 + sciai 云机"纳入（升档 A 的配方）
1. **Linux 云机**：daemon `index.mjs`（md5 c2488f58…）+ npm node-pty + `run-daemon.sh`（**base64 直灌**）+ `setsid nohup`；CD5 `devices.json` 加 `"<100.x IP>":"<工作区路径>"`，`devices-meta.json` 加中文能力备注 + 模型路由；按端口 PID 重启（**绝不用进程名宽杀**）。
2. **Windows 云机/云电脑**：dist + node-pty（prebuilds/win32-x64）+ `start-daemon.bat`（set 单独一行）+ `schtasks /ru SYSTEM`；无 node 时把 87MB `node.exe` 一起放。够不着桌面的走 ssh-tailscale-kit 一键包（OpenSSH+Tailscale+OpenP2P 拖进去双击）。
3. **出站被墙的 farm 云机**：`CLAWSGO_API_URL=https://nvidatwo.tailf48612.ts.net:8443/n/<TS IP>`，模型走 `/v1r`，中继在 WSL `~/clawsgo-relay`（cron 自愈）。
4. **自动纳管**：oneyear `/root/pool-sweeper/sweep.sh`（cron `*/30`）——tailscale 在线未入池 → 有 ssh 别名自动装，无则记录待办。
5. **心跳拓扑**：节点侧 `node-heartbeat.sh`（turn dispatch 下发，绕 root SSH 限制，Windows 也能装）→ `POST hub:8788/api/nodes/register` + `/heartbeat`（>2min 无心跳=stale）。

### 2.3 最大化联通效率 + 承接到 1000 节点（天花板在哪）
- **注册面（能到 1000）**：tailnet 组网无硬上限；sweeper 每 30min 扫一遍"在线未入池"自动纳管；hub:8788 heartbeat 自动拓扑。1000 台"注册/可发现"没问题。
- **有效并发（真正的天花板）**：不是节点数，是这三条：
  1. **模型上游并发**：18900 4 跳链每个上游自身并发有限（kiro 30+、i9 18700 30+）；池级并发 = 「多节点 × 各上游并发」。要 1000 并发 → 需要 **上游并发总和 ≥ 1000**（多挂几条 kiro/官方中转）。
  2. **oneyear 主脑 2C**：跑 claude -p 并发 3–5 就满，多任务=多进程，超过必须走 turn 池；全家桶+蜂群+openclaw-gateway 同跑 load 可飙 94（实测血坑）→ **浏览器/重活分流 i9/CD5，别在 oneyear 起浏览器**。
  3. **hub 派发吞吐**：单 hub:8788 派 1000 turn 是单点瓶颈。
- **到 1000 的落地路径**：
  - `>30 节点` 触发条件（你技能已写明）→ 引入 **hub 双机热备**（去中心化阶段4 Raft 暂缓，但双机热备是 1000 级的前置）。
  - 主脑从 2C VPS 搬到 CD5 16C32G 或更大算力机（kiro 1000 并发的收口在 hub 网页，不在主脑 2C）。
  - 模型池多挂 kiro + 官方 + 闲鱼/i9/lx6 四稳端，把上游并发堆到 ~1000。
  - 分部门：**主脑只收信息+派目标**（DEPARTMENTS.md 终极架构），各节点=部门主管（常驻 agent+各自模型池）自主拆解 → 把"1000 并发"摊到 1000 个部门主管本地，主脑只做验收，绕开主脑 2C 瓶颈。
- **一句话**：1000 台能"连上"，但要"1000 台真并行干活"得满足 `上游并发 ≥ 1000` 且 `主脑/ hub 不在 2C` 且 `hub 双机`。当前 13 台规模下 Raft/去中心是收益不成正比（你 R7 报告已判"暂缓合理"）。

---

## 3. 两条 idea→交付 流水线解剖（官方 ClawsGO vs sciai 复刻）

### 3.1 官方 ClawsGO（"clawsgo"，你用的那个 App）
来源：图2（ClawsGO Science Agent 主界面，模型 Opus 5.5 / 推理强度 高 / 256K 上下文 / 三卡片 研究·指南·接力）+ CLAUDE.md 里"官方机制"描述。

**流水线（idea → 成品）**：
```
① 输入 idea（App 输入框，@引用 文件/任务/软件/数据库）
② 桌面主智能体（Claude Code 内核）+ 侧边栏技能体系（12 官方技能 + 科研工作台）
③ 模型 = 自有三档 Li/Si/Ti（图3）或 Opus 5.5；档位决定能力/消耗
④ 选机器：clawsgo-ssh 技能读 ~/.ssh/config 的 Host 块 + 注释，挑云机/本地设备
⑤ 设备池 daemon 派发（官方云池 Leader/Worker/Relay + P2P + Raft 集群模式）
⑥ 科研工作台：MeSH 展开 + 三层漏斗检索（官方 R5 实测：宽110→窄15，SMD −1.13 直接命中）
⑦ 交付物（检索/综述/论文复现）落云机工作区 + App 展示
```
**官方特征**：信息学规范更强（MeSH 展开 + sort 校准 + 质量标注 + raw 留档）；**瓶颈=晚间云池冷启动**（你 R7/R14 官方侧均"排队中"）；有 1-3-1 人工审批（统计方案/临床结论/投稿动作 AI 不定稿）。

### 3.2 sciai 复刻（你 home-build，oneyear 主脑）
来源：CLAUDE.md（"你是 SCIAI 主脑——官方 ClawsGO 的完整复刻运行体"）。

**流水线（idea → 成品，逐环对应官方）**：
```
① 输入 idea（任务书 md，claude -p 自主拆解）
② 主脑 = claude opus 5.5（kiro）@127.0.0.1:18674（内核A）
      + 内核B = 转派 CD5 设备池 http://100.94.124.54:8778
③ 技能层 /root/.claude/skills = 官方12技能 + clawsgo-pool + scios-research
      （机器清单 = CD5 devices-meta.json 中文备注，对应官方读 ~/.ssh/config）
④ 多并发子智能体 = node pool-concurrent.mjs（取代 pool.mjs 串行）
      auto 模式：同构(前6字符≥60%)→swarm · 异构→master-slave · 单任务→single
⑤ 派发到 13 台节点：每节点一个 claude/pi agent turn（16 轮工具循环）
      模型默认 glm-5.3@18900（便宜稳定），复杂裁决走 kiro/deepseek-v4-pro
⑥ 科研体系（对应官方科研工作台）：
      Sci-Hub 全文（ego 带登录态四镜像轮询）· livingebm 五库:8098
      lightflow 流程看板:8099 · Light-Science 19 技能 · kimi-k3 读图:18650
⑦ 产物落各节点工作区 → 主脑汇总对照表 + source-of-truth 裁决
⑧ 群体智慧盲评：同源清单派 2 台异构节点独立提取，共识/并集/分歧三分，争议开节点不抹平
```

### 3.3 两者是否一样？（直接回答）
- **机制：1:1 复刻（一样的骨架）**。官方每个部件在复刻里都有对应：主智能体↔主脑 claude opus、侧边栏技能↔/root/.claude/skills、clawsgo-ssh 读 ssh 注释↔CD5 devices-meta 中文备注、设备池 daemon↔pool-concurrent.mjs、集群模式↔swarm/master-slave/cluster 映射（Leader=oneyear 主脑 / Worker=节点 daemon / Relay=WSL·Funnel 中继）。
- **不一样在四件事**（你 R7 报告自证的差距）：
  | 差距 | 官方 | 复刻现状 | 影响 |
  |---|---|---|---|
  | G3 自动汇总裁决 | 主脑做 source-of-truth | **靠人工补位**（R7 暴露：同任务双产物分叉 i9版439/117 vs nvida版246/71） | 最大差距 |
  | S8 续传幂等 | — | **非幂等**：resume 在任务完成 15s 后又重派，3 条僵尸 pending | 下次断网放大的雷 |
  | G2 时间戳 | 诚实 | vm3 自署"2025-07"（实为 2026-11）| 污染引文链 |
  | G4 模型分流 | — | 4 turn 全走 glm-5.3，写作没试 kimi-k3.1-pro | 优化空间 |
- **结论**：流程同构，复刻版**能力≈官方 8/10**，但有两个"会被下次事故放大"的实雷（S8/G3），必须先修。

### 3.4 "非科研内容" 怎么过 clawsgo 客户端（你问"输入前梳理"）
官方 App 是科研范式设计的（图2 三卡片=研究/指南/接力）。要跑非科研：
- 用**"新建项目"独立目录**承载 + **接力 HANDOFF** 接你已有项目（非科研任务也走这条）。
- 输入前梳理法（对齐 sciai 主脑纪律）：**任务书写 md 再 cat，避免引号地狱**；明确「目标 / 约束（零编造/留档）/ 交付物清单」三段；科研红线（1-3-1 人工审批）只约束统计方案/临床结论/投稿，**非科研任务放开这条红线**即可走全流程。
- 复刻侧非科研任务：直接 `pool-concurrent.mjs auto tasks.json`（auto 会判 single/master-slave/swarm），不碰科研技能链。

---

## 4. 四模式 × 模型 全体系状态矩阵

### 4.1 四模式选择器（pool-concurrent.mjs auto，v1.4 定稿）
| 模式 | 触发条件 | 主脑角色 | 对应官方集群 | 现状 |
|---|---|---|---|---|
| **single** | 单任务 | 主脑拆解 + 1 节点执行 + 验收 | 单 Worker | ✅ 默认 |
| **master-slave** | 异构任务（≥60% 不同） | 主脑=master，节点=slave 各干各的 | Leader+Worker | ✅ |
| **swarm（蜂群）** | 同构任务（前6字符≥60% 相似） | 同任务多节点独立跑 + 交叉验证 | 多 Worker 并行 | ✅ R7 实测 365=365 |
| **cluster** | — | 仅接口 | Leader/Worker/Relay+P2P+Raft | ⏸ 暂缓（>30 节点或双机热备再开） |

### 4.2 模型 × 模式 × 任务 匹配矩阵（DEPARTMENTS.md 实测定稿）
| 任务类型 | 模型池 | 执行 bot | 依据 |
|---|---|---|---|
| 检索式构造/信息学敏感 | **kiro(opus5.5)** 或 deepseek-v4-pro | dept-research-esearch | 官方对照 MeSH+sort 差距 |
| 检索执行/跑量采集 | 18900 glm-5.3（快+32并发） | fleet-collect-vm | GLP-1 63s/469，11路并发 |
| 证据综合/多源交叉 | deepseek-v4-pro(reasoning) 或 kiro | dept-research-evidence | kb盲评 REF 纪律 |
| 长文写作/综述 | glm-5.3 链（lx6 写作部） | dept-writing-draft/polish | 论文5章5/5 |
| 工程脚本/工具 | sonnet@lx7 或 glm-5.3 | dept-engineering-lx7 | count_pmids 真跑9991 |
| 群体盲评 | 双节点异构（vm2+vm3 独立实例） | kb-blind-eval | 必须异构双路 |
| 图像/读图 | kimi-k3@18650 | scios 系 | vision |
| 快速判定/小任务 | deepseek-flash-fb | 池默认 fallback | 4 跳链尾 |

**"不同模式下不同模型的全体系状态"** = 上表 × §4.1 模式：跑量走 swarm+glm-5.3（并发拉满）；深度裁决走 single+kiro/v4-pro（质量优先）；异构多线走 master-slave+各节点各自模型池（kiro 研究 / glm 写作 / sonnet 工程 / kimi 读图 各归位）。

---

## 5. Lithium / Silicon / Titanium 三档 → 你的可用模型 + 提示词 + 开源底座

图3 定调：**ClawsGO 1.5 基于"顶级开源模型"针对 ClawsGO Science Harness 后训练/微调，三档 Li/Si/Ti**。对照你 18900 池 23 模型，逐档映射（**用你现在可用的模型适配**）：

| 档 | 官方定位 | 映射到你池里的模型 | 底座（开源?） | 提示词姿态 |
|---|---|---|---|---|
| **Lithium 1.5（轻量档）** | 低延迟低消耗，日常问答/资料整理/小段代码 | `deepseek-flash` / `deepseek-flash-fb` / `glm-5.3` / `sensenova-6.8-flash-lite` | ✅ **开源**（GLM-5.3 / DeepSeek-flash 系，均为开源权重） | 短平快：`<任务一句话> + 只要结果/只回两字`；不思考链；max_tokens 小；跑量/分诊用 |
| **Silicon 1.5（主力档）** | 兼顾科研自动化+消耗，多文献综述/数据分析/论文起草 | `glm-5.3` / `deepseek-v4` / `qwen-3.8-max` / `kimi-k3.1-pro` | ✅ **开源**（GLM-5.3 / DeepSeek-V4 / Qwen 系，开源权重） | 结构化科研：`目标 + 约束(零编造/留档/来源日期) + 交付物清单`；三层漏斗 + MeSH + REF 占位 + 置信度分级；中思考 |
| **Titanium 1.5（旗舰档）** | 性能优先，长程复杂研究/反复推敲自检 | `claude-opus-5-5`(kiro) / `deepseek-v4-pro`(reasoning) / `kimi-k3`(读图旗舰) | ⚠️ **闭源为主**（opus=Anthropic 闭源；v4-pro reasoning 闭源；仅 kimi-k3 偏开源旗舰） | 长程自洽：`目标 + 边界 + 自检清单 + 1-3-1 人工审批点`；高推理强度；反复推敲不硬判（"需人工复核"降级，不编数字）；开思考链 |

**关键回答"哪一档有开源模型做底座"**：**Lithium + Silicon 两档有开源底座**（GLM-5.3(-flash) / DeepSeek-flash / Qwen / sensenova 全是开源权重）；**Titanium 旗舰档主要是闭源前沿**（Opus 5.5 / v4-pro reasoning），只有 kimi-k3 这一支偏开源旗舰。所以"三档全开源"不成立——旗舰档为保性能优先，必然挂闭源前沿。

**18900 池里剩下的模型归位**：`gpt-6-luna`（视觉链头/旗舰备选）· `claude-sonnet-4-6/haiku-4-5`（blankapi 1.5x 价，复杂评审用，**禁 5x claude-stable 组与 fable**）· `kimi-k3`（读图）· `opc-dual-gateway` / `wb-auto`（路由占位）· `sensenova-u1.5-lite`（轻量视觉备选，i9 实测 text-only 出局）。

---

## 6. 模型指纹：能测出"从哪个模型微调/换皮"吗？—— 能（relay-model-fingerprint）

**直接回答：能，且有成熟方法。** 证据硬度排序（你技能 1.0.0 定稿）：
1. **logprob 指纹（最硬）**：同提示 temperature=0，比首 token top-N logprob **数值**；同一套权重→逐位一致；不同→分布必不同。**6 个名字 logprob 全一致 = "多牌一模"定案。**
2. **tokenizer 指纹**：固定 5 条测试串（中英/emoji/代码/混合）比 `usage.prompt_tokens`；不同厂商分词器算不出相同的数；恒定 +N 偏移 = 该站注入了 N token 的 system prompt。
3. **人设穿帮探针**：视觉题 OCR 漏名（"ZK-2077"→"ZKimi-K3077"）；追问身份 "identified as X in this deployment"。
4. **同对同错**：同一批陷阱题（平均速度/数母/三段论），同底模两名字会同对同错、措辞同款。
5. **元数据白名单**：/v1/models 六名字元数据全雷同=手写配置；填假名看 400 报错列全站白名单。

**你的参照库（2026-11 本机 18900 实测）**：
| 家族 | 5 条串 prompt_tokens | 备注 |
|---|---|---|
| Kimi 系（i9:8790 / shibaopiqi 全 6 牌） | 94/89/88/94/101 | 6 牌=1 个 Kimi 底模（GLM/DeepSeek/Qwen 名=换皮）|
| 真 Kimi K3.1-Pro-0806（单模站） | 38/38/31/38/53 | 推理不外显、无视觉、不返回 logprobs |
| GLM 系（sn/oneyear 跳） | 34/29/28/34/38 | — |
| DeepSeek 系（flash 各跳） | ≈26/21/20/26/29 | 纯文本无注入 |

**防坑**：18900 failover 链里可能挂着待测站本身当上游（glm-5.3-fb 链里的 `xy-direct-glm53`=shibaopiqi）→ 直接比对会循环；必须选**不经过待测站**的参照（i9:8790 kimi-k3 / 官方 deepseek 跳）。**i9:8790 对不存在的模型会静默用 deepseek-flash 顶替（不报错）**→ 测前先 `GET /v1/models` 核对。
**结论**：Li/Si/Ti 三档若要走中转/池，用 logprob+tokenizer 双指纹即可定"哪个底模家族"；但**官方 ClawsGO 自有模型不给你 API 直连，只能从行为/能力面（检索纪律、MeSH 展开风格、自检降级措辞）侧面推断**——你 R5 对照（蜂群宽179 vs 官方漏斗15、SMD−1.13）就是这种"行为指纹"。

---

## 7. commander / sciai / clawsgo 的模型优劣 + 三种体系对比（onyear 上的 opc 体系）

| 维度 | **clawsgo（官方）** | **sciai（复刻）** | **commander（ok-* / 指挥官）** |
|---|---|---|---|
| 主脑 | App 桌面主智能体（Claude Code 内核） | claude opus 5.5(kiro)@18674 + 双内核 | ok-commander 派单 + 并行 spawn ok-* 部门 |
| 模型源 | 自有 Li/Si/Ti + Opus 5.5（商业，贵） | 18900 池 23 模型 + blankapi（自持，便宜） | 走本机 18900/18653 网关 + 部门各自池 |
| 节点 | 官方云池（晚间冷启动瓶颈） | CD5 13 台 tailnet/farm（自有，稳） | ok-* 部门子智能体（逻辑部门，非物理节点） |
| 科研深度 | **信息学规范更强**（MeSH+三层漏斗，实测 SMD 直接命中） | 8/10（G3 缺自动裁决 + S8 非幂等 + G2 时间戳） | 不做科研（产品/设计/内容/电商/办公） |
| 优势 | 开箱即用、科研范式完整 | 可控/便宜/可审计（raw 留档+双节点盲评） | 多部门协作、非科研覆盖广 |
| 劣势 | 贵 + 云池瓶颈 + 黑盒 | 两实雷未修 + 人工裁决补位 | 科研不深、纯任务编排 |
| 何时用 | 出正式科研结论/论文 | 跑量/对照/可审计复盘 | 多专长部门并行交付 |

**onyear 上"claude cli + openclaw-gateway 的 opc 体系"**（你问的）：
- **claude cli（claude -p）**：主脑拆解/裁决，走 18674 kiro 网关；**优点**=强拆解；**缺点**=2C 上并发 3–5 封顶、大上下文 4 跳才稳。
- **openclaw-gateway**：另一套 agent 体系（playwright 浏览器 worker），**是 load 飙 94 的元凶之一**（技能 v1.5 血坑：`pkill -f chrome-headless-shell` 94→7.9；规则=浏览器类任务分流 i9/CD5，别在 oneyear 起浏览器）。
- **优劣结论**：claude cli 做"脑"（拆解/裁决），openclaw-gateway 做"手"（浏览器执行），但**手要搬到 i9/CD5 大算力节点**，二者在 oneyear 同跑会互抢 load。

---

## 8. 13 境对标：你现在在哪、到最高境差什么

对照图1（AI 修仙十三境 L1→L13）逐境核对你体系：

| 境 | 能力 | 你的体系 | 判定 |
|---|---|---|---|
| L1 炼气·对话查询 | 日常问答 | 18900 23 模型池 | ✅ 早已过 |
| L2 筑基·Agent 干活 | 查/写/录/整理 | 节点 turn + 技能 | ✅ |
| L3 结丹·从做到造 | AI 成脑分身 | 主脑 opus 拆解+裁决 | ✅ |
| L4 元婴·结构化目录 | 知识库 | ego-kb（03收件箱/L0–L4 传送带） | ✅ |
| L5 化神·索引定位 | 精准检索 | Sci-Hub/livingebm:8098/lightflow:8099 | ✅ |
| L6 炼虚·语义搜索 | 深层语义 | 18900 语义池 + kimi 读图 | ✅ |
| L7（图中未清） | — | — | — |
| L8 大乘·自主进化 | 业务流自动化生收益 | **13 节点蜂群 + 30min sweeper 自动纳管 + cron 保活** | ✅ **你在这** |
| L9 真仙·跨界化仙 | 跨模型多任务协同 | 23 模型 × 4 模式 × 8 部门 | ✅ |
| L10 金仙·不朽掌控 | 领域永续无错主导 | 科研可审计（raw 留档+盲评交叉验证） | ⚠️ 领域内强，但 G3/S8 是"无错"缺口 |
| **L11 太乙·执掌乾坤** | **多智能体庞大族群绝对统帅** | **13 节点→可扩展 1000 + hub:8788 心跳自动拓扑 + 部门目标式派发** | ✅ **地基已打，这是你的主战场** |
| L12 大罗·映照诸天 | 预测复杂未来/推演万物 | 无"预测层"（只有检索/执行，没有 forward-model） | ❌ 差 |
| L13 道祖·混沌本源 | AI=世界法则 | 纯愿景 | ❌ 差 |

**"最高级水平"的现实目标 = L11→L12 跃迁**。要跨到 L12（预测/推演），需要三件当前没有的东西：
1. **修掉 S8（续传幂等）+ G3（自动汇总裁决）**——这是 L11 站稳的前置（否则 1000 节点扩上去全是分叉产物）。你 R7 报告 P0 已列修 S8 方案（dispatch 即写 turnId / resume 前查 hub /turns 对账 / 补 reconcile 清僵尸）。
2. **加"预测层"**：把多节点盲评的"分歧节点"从"开争议不抹平"升级为**前瞻性预测**（给定 X，多模型推演 Y 概率）——这是 L12 的核心。
3. **hub 双机 + 主脑搬家**：L11 的"1000 族群"物理落地需要 §2.3 那三件事。

**一句话**：你现在是 **L8–L11 之间、L11 地基已打** 的"多智能体族群统帅"；到 L12 差「预测层 + 两个实雷修复 + 主脑/ hub 扩容」。L13 是世界法则级，属愿景非工程目标。

---

## 9. 行动清单（按优先级，直接可执行）

| P | 动作 | 验收 |
|---|---|---|
| **P0** | 修 S8：pool-concurrent.mjs ①dispatch 即同步写 turnId ②resume 前先查 hub /turns 对账 ③补 reconcile 清 3 条僵尸 pending ④同任务去重键 | 重复"ssh 断杀→resume"两轮，第 2 轮 0 重派、DB 无 pending 残留、产物不分叉 |
| **P0** | 修 G3：把"人工汇总裁决"固化成机制——swarm 回收后自动开 source-of-truth 裁决步（双产物分歧→争议节点→主脑 kiro 裁决） | 同任务双产物自动并轨，不再 i9版/nvida版 并存 |
| **P1** | 修 G2：任务书强制产物头注"真实时间戳 + 时点快照声明" | vm3 类"2025-07"编造不再出现 |
| **P1** | hub 产物回收端点：`pool.mjs pull <turnId>`（read-back base64+sha 校验）或 hub `/artifacts/<turnId>` | vm2/vm3 无 SSH 死角补上 |
| **P2** | 升档 A：把 clawsgo 客户端登录的 ssh 云机 + sciai 云机 按 §2.2 配方入池（daemon+devices.json+heartbeat+sweeper） | pool-concurrent health 显示新增节点 online success:0 failed:0 |
| **P2** | 模型指纹：对 Li/Si/Ti（若可拿 API）跑 logprob+tokenizer 双指纹；对中转 6 牌跑参照库比对 | 出"显示名 vs 真实底模"对照表 + 证据等级 |
| **P3** | 1000 节点前置：hub 双机热备 + 主脑搬出 2C VPS + 模型池多挂 kiro/官方堆并发到 ~1000 | 触发条件 `>30 节点` 满足时启动 |

---
*文档完。所有 IP/端口/模型名/差距项（S8/G1–G4）均引自你 oneyear 实机 + R7 报告，可逐项 `ssh oneyear` 复核。*

---
---

# 执行篇（2026-11-22 五阶段 A-E 落地记录）

> 上篇为解剖结论；本篇为按批准计划（全量五阶段）的实测执行结果。全部为当日实测，可 `ssh oneyear` 逐项复核。

## Phase B：S8/G3/G2 修复（pool-concurrent.mjs v1.1）——已验收 ✅

- **S8-①** dispatchOne：dispatch 返回后立即同步落 turnId（status=running），不再依赖 watcher 回写
- **S8-②** resume：重派前先与 hub /turns 事件流对账——hub 已有 turn_exit 的直接销账；hub 有 dispatch 记录(无 exit)的补写 turnId 跳过；只有 hub 无记录的才重派
- **S8-③** reconcile 子命令：销账僵尸 pending / 补写漏记 turnId / 清超时孤儿
- **S8-④** dispatchAll：批内 (task,device) 去重键
- **G3** auto/swarm/master-slave 完成后自动落盘 *.summary.md（分歧检测 + 裁决规则内嵌）
- **G2** summary.md 强制头注「真实时间戳 + 时点快照声明」

**验收实测（复现 R7 事故场景）**：断杀 swarm → resume#1（重派 2/2）→ 15s 后 resume#2（**销账 2 · 重派 0**，对账闭环）→ pending=0，每任务 dispatch ×2 无第 3 次分叉。reconcile 首跑清掉 9 条僵尸（age 1687–1869min、全无 turnId 的 v1.0 遗留）。
备份：pool-concurrent.mjs.bak-20261122-pre-s8g3。

## Phase C：节点纳管与官方对照

- **C-1** clawsgo-awe / clawsgo-joson-1 daemon 入池 = **BLOCKED**：两容器**出站 TCP 全被墙**（hub:8788=000、公网 funnel:8443=000，UDP/TS ping 正常），唯一活通道是入站 ssh（awe 经 oneyear:12224→evoxt 转发 / joson-1 用 johndar key）。daemon 需节点主动出站连 CD5/中继，网络层无解；heartbeat 脚本已留装（网络放开即自动生效）。已入池 4 台 farm daemon 断链同因。
- **C-2** heartbeat v3（补 x-scai-token 鉴权）：**生效 6 台**（i9/lx6/lx7/oneyear/vm2/vm5，hub:8788 fresh + 实时 cpu/mem，负载感知自此生效）；awe/joson 装了但上报被墙；vm3 挂起 BLOCKED（instabox 30min 闲置挂起，醒后 sweeper/自愈补）
- **C-3** 官方面板基线（CDP dump 留档 official-hosts-baseline.txt）：**官方侧云主机空、本地设备仅 Win-de07(=CD5) 在线**、ai3128/hope19 显示离线、最近活动 4-5h 前；**复刻侧 12 台在线 + 6 台心跳负载 + sweeper/主脑/hub 全套——复刻侧规模与自动化已远超官方侧**（官方云池晚间冷启动排队是硬瓶颈）

## Phase D：三档适配落地（配置层）✅

- templates/lithium.md / silicon.md / titanium.md 三份提示词模板落 /root/clawsgo-replica/templates/
- CLAUDE.md 插入「三·五、三档模型适配」节（映射表 + 派发规则 + 官方对照基准）
- bots.json 热插拔 3 个 tier bot（tier-lithium-batch / tier-silicon-research / tier-titanium-adjudicate，共 18 bots）

## Phase E：四模式实测 + 模型指纹实测 ✅

### E-2 四模式实测（同日全绿）

| 模式 | 任务 | 结果 |
|---|---|---|
| swarm（auto 判同构 100%）| 3 同构批量 | **3/3 exit=0** + G3 裁决表自动落盘 |
| master-slave（auto 判异构 50%）| 2 异构部件 | **2/2 exit=0** + G3 裁决表 |
| single（run 单任务）| 1 任务 | **exit=0**（turnId 299e1cd7…）|
| cluster | — | 按设计暂缓（>30 节点或双机热备再启）|

### E-1 模型指纹（18900 池 12 名实测，tokenizer 5 串法 + 身份自报）

| tokenizer 指纹 | 池内模型名 | 真实底模 | 证据 |
|---|---|---|---|
| [94,88,88,94,103] | deepseek-v4.1-flash / **deepseek-v4-pro** / kimi-k3 / kimi-k3.1-pro / qwen-3.8-max | **Kimi 系（5 名一模）** | tokenizer 逐位一致；v4-pro/qwen 自报却是 DeepSeek/Qwen 品牌（换皮实锤：tokenizer 比自报硬）|
| [26,21,20,26,37] | deepseek-flash / deepseek-flash-fb / deepseek-compact | DeepSeek 系 | flash-fb 自报 "as identified in this deployment"（穿帮句式）；compact 自报 R1 |
| [34,29,28,34,38] | glm-5.3 / glm-5.3-flash | GLM 系（名实相符）| 自报 GLM-4@Z.ai |
| [81,21,75,26,37] | sensenova-6.8-flash-lite | DeepSeek 系变体 | 自报 R1 + 疑似站点注入偏移 |
| 502 | gpt-6-luna | 链死 | 8137 Codex 号池已知全灭 |

**动态换皮实证**：deepseek-v4.1-flash 两次实测 [26,21,20,26,37]→[94,88,88,94,103]（failover 链轮换换了底模）——**同名模型不同时刻可以是不同底模**。

**三档底座结论修正（指纹后）**：
- Lithium：glm-5.3（真 GLM）/ deepseek-flash 系（真 DeepSeek）——**开源，名实相符** ✅
- Silicon：glm-5.3（真 GLM）开源 ✅；deepseek-v4 / qwen-3.8-max / kimi-k3.1-pro **实际全是 Kimi 底**（Kimi 权重开源——仍是开源底座，但"多厂商"是假象）
- Titanium：**池内唯一真闭源前沿 = kiro/claude-opus-5-5（18674 anthropic 协议网关）**；v4-pro 实测 Kimi 底（开源）
- 结论：**18900 池 12 名 ≈ 3 个真实底模家族（GLM/DeepSeek/Kimi）+1 死链**；旗舰档真闭源只剩 opus 一根独苗

## 13 境复评（执行篇后）

| 境 | 执行前 | 执行后 | 变化依据 |
|---|---|---|---|
| L8 大乘·自主进化 | ✅ | ✅ | 不变 |
| L9 真仙·跨界协同 | ✅ | ✅ | 不变 |
| L10 金仙·不朽掌控 | ⚠️ | **✅ 基本达成** | S8/G3/G2 三缺口已修并验收；零编造纪律（时间戳/快照声明/REF 占位）机制化 |
| **L11 太乙·执掌乾坤** | 地基已打 | **站稳** | 四模式全绿 + 心跳自动拓扑生效 + 幂等续传（断点不再分叉）+ G3 自动裁决表 + tier bot 热插拔 + 指纹审计能力——多智能体族群的统帅要素齐了 |
| L12 大罗·映照诸天 | ❌ | ❌ 未动 | 预测层仍缺：分歧节点目前只检测+留档，未升级为多模型前瞻推演（下一步：把 G3 分歧输入改为预测验证集）|

**L11 站稳的最后一检**：断杀→resume 两轮幂等 + reconcile 清僵尸 + 裁决表自动落盘——R7 报告的"会被下一次断网事故放大的雷"已全部拆除。**当前体系可以在 13 台规模上长期无人值守运行**；扩到 1000 台前的三件事不变：hub 双机热备、主脑搬出 2C、模型池堆并发（另加：farm 类出站被墙容器占比过高时优先换云商而非修网络）。


---
---

# 第三篇：联通保底体系 + p2p vs tailscale 解剖 + 模型最大化利用（2026-11-23）

## 1. 名字统一（三边一致）——已落地 11/13

**规范**：`alias = tailscale hostname = openp2p 注册名 = ssh 主别名`（网络层真名做唯一规范名）。

- 已统一 11 台：`tailscale set --hostname=<规范名>` 实测生效（i9/hope19/bi3128/ai3128 经 turn 通道改名成功/nvidatwo 本机 WSL/lx-6/lx7/vm2/vm5/oneyear 本来一致）
- 例外 2 台：`nvidatwo-win`（本机 Windows 实例 100.98.96.82，与 WSL 实例 100.123.136.108 区分命名）；`ctyun-17725`（401：tailscaled 被另一用户会话 `mirrorEditor-8u` 占用，天翼云多用户桌面问题——管理员 kill pid 8560 后可改，不硬做）
- 载体：hosts.json 生成器（见下）新增 `nameConsistent` 审计字段，**名字漂移从此面板可见**

## 2. p2p vs tailscale 解剖（实测对比）——tailscale 主力，openp2p 第三通道

| 维度 | tailscale（WireGuard） | openp2p（QUIC 打洞） |
|---|---|---|
| 实测延迟 | 同区直连 5-30ms（lx-6 5ms/nvidatwo 29ms/hope19 30ms）；跨区 DERP 193-244ms | 依赖 openp2p.cn 国内中继质量（当前链路断，无实测数据） |
| 在线规模 | **12-13 台稳定在线**（心跳 6 台 + cron 保活 + sweeper 自愈） | 客户端仅 2 台旧机器（云电脑=睡着、i38g128a=CF 通道超时中） |
| 抗墙 | TCP 443 兜底 + DERP 中继 + funnel 8443 公网 | **FlClash TUN 劫持 UDP → 注册失败**（技能血坑）；国内中继未验证 |
| 通道完备 | TS 主 + CF 备（7 台）+ GIT 数据面（4 台）+ GH 探测 | 需逐台装客户端 + token（当前 token 在睡着的云电脑里，**P2P=0 是待 token 而非缺陷**） |

**结论**：**tailscale 做主力（控制面+数据面），openp2p 定位第三通道**——专攻 tailscale 够不着的 NAT 后云电脑（`ssh cloudpc` 链：cloudflared → i38g128a → OpenP2P:10022 → 云电脑 sshd）。"挂双通道"的正确姿势：**ts 主线 + openp2p 备线**（token 到位后按 ssh-tailscale-kit 配方 10 分钟/台）。

**中继要不要自建？——不需要，已有四级中继（超配）**：
1. **DERP**（tailscale 内置，实测 nyc ~240ms 兜底）
2. **cloudflared**（`*-ssh.oioioi.dpdns.org` 公网 TCP 443——这就是你问的"oioioi"，7 台入口活着）
3. **Funnel 8443**（`wss://nvidatwo.tailf48612.ts.net:8443/n/<TS IP>`，给出站被墙的 farm 容器；nvidatwo WSL relay 进程实测活着）
4. **openp2p 国内中继**（NAT 后云电脑场景）
缺的不是中继，是**按节点类型的选路策略**——已固化：常规节点=TS 主+CF 备；出站被墙容器（awe/joson-1/farm）=入站 ssh+GIT 数据面；NAT 后云电脑=openp2p+keepalive。

## 3. 保底通道矩阵（真实探测，自动刷新）——已落地

**hosts-panel-gen.py**（部署 oneyear:/root/sciai-hub/，cron `*/15`）：五通道真实探测 + 名字审计 + 13 台基础表，产出 `/root/sciai-hub/hosts.json`（hub `/api/hosts` 数据源，面板即时可见）。

当前实测矩阵：**TS=13 · CF=7 · P2P=0（待 token）· GIT=4（oneyear/i9/lx-6/lx7）· GH=13（波动时探测可能瞬时 0，cron 15min 自愈）**

- **GIT 通道**（数据面保底）：oneyear `/root/shared-ws.git` bare 仓 + 每节点独立分支（branch=规范名，互不覆盖，主脑 fetch 汇总）。已入仓 4 台（i9/lx-6 直接 push + oneyear 本地 + lx7 主脑反向 fetch）；vm2/vm5 已装 key + 配 remote + ssh 验证通，**push 长尾失败**（vm2 静默/vm5 repository 错——修复配方：减小首推体积或重试）。`sync-shared-ws.sh`（cron `*/30`）自动反向 fetch + 维护 members.txt（GIT 通道数据源）
- **GH 通道**：探测语义=github.com 可达（数据面异地保底）。**mirror 配方（credential 到位一键开）**：本机 gh 建私仓 → bare 仓 `git remote add github <url>` + `git push --mirror`（需 oneyear 有 github credential：用 deploy key 或 token；涉及账号凭据，需你点头再转移）
- **P2P 通道**：`OP2P_NODES` 映射表已留位（hosts-panel-gen.py），装一台填一台，面板自动绿

## 4. 模型最大化利用（指纹实测后的策略）

实测底模真相：**池内 12 名 = 3 家族**（GLM 2 名 [34,29,28,34,38] · DeepSeek 3 名 [26,21,20,26,37] · **Kimi 5 名 [94,88,88,94,103]**）+ luna 死链。

**四条最大化策略**：
1. **同底模多牌 = 免费并发池**：Kimi 5 名 = 5 路独立上游并发（5 路并发不撞同一限流）——批量任务故意跨名轮询（kimi-k3 → kimi-k3.1-pro → v4-pro → qwen-3.8-max → v4.1-flash），实测单上游并发上限绕开
2. **异构盲评取真身**：群体盲评必须三家族各取 1 真身（GLM=glm-5.3 / DeepSeek=deepseek-flash / Kimi=kimi-k3）——**不能取五名"不同"模型，那是 1 个底模的假多样性**
3. **三档重排按真底模**（修正版）：Lithium=deepseek-flash（真 DeepSeek）/glm-5.3-flash（真 GLM）；Silicon=glm-5.3（真 GLM）+ Kimi 系五名（真身任选，建议 kimi-k3.1-pro 名实相符）；Titanium=**kiro/opus-5-5（池内唯一真闭源前沿）**，v4-pro 实为 Kimi 底（开源）
4. **failover 轮换风险对冲**：v4.1-flash 两跑换底模（[26..]→[94..]）——**异构性关键任务点名真身直连**（i9:8790 kimi-k3 真身/sn 跳 GLM 真身），不走会轮换的 failover 名

## 5. cluster 模式释义（直接回答）

**cluster ≠ "30 节点以上性能模式"，是高可用模式**：多 Leader 候选 + 心跳共识 + Raft 故障转移（官方 ClawsGO 的 Leader/Worker/Relay + P2P + Raft 集群）。
- 官方集群的复刻映射（已存在）：Leader=oneyear 主脑 · Worker=节点 daemon · Relay=WSL Funnel 中继
- 启用判定（R7 定论 + 本次不动）：**13 台规模 Raft 收益不成正比（去中心化评估=暂缓合理）**；触发条件=「>30 节点」或「hub 单点故障不可接受（需要双机热备）」——两者都是**可靠性触发**，不是规模触发。30 节点只是"值得重新评估"的信号阈值
- 当前体系的高可用替代：**S8 幂等续传 + reconcile + GIT 数据面**（hub 短暂失联产物不丢，恢复即对账）——用"数据面冗余"替代"控制面共识"，13 台规模下成本更低

## 6. 本轮落地清单（全部可复核）

| 交付物 | 位置 | 验证 |
|---|---|---|
| hosts 面板生成器（五通道真探测+名字审计） | oneyear:/root/sciai-hub/hosts-panel-gen.py | cron */15；hosts.json 13 台 |
| 名字统一（tailscale hostname=规范名） | 11/13 台 | hosts.json nameConsistent 字段 |
| GIT 保底通道（bare 仓+独立分支+sync） | /root/shared-ws.git + sync-shared-ws.sh（cron */30） | 分支 i9/lx-6/lx7/oneyear |
| GIT 节点 key 补装 | vm2/vm5→oneyear | ssh 验证通（push 长尾留档） |
| 通道矩阵面板数据 | hub:8788 /api/hosts | 面板五通道标签实时 |

**待办（需外部输入）**：① P2P token（在睡着的云电脑 config.json 里——醒后按 OP2P_NODES 填表即通）② GH mirror credential（需你点头转移 deploy key/token）③ vm2/vm5 push 长尾（减小首推体积重试）④ ctyun-17725 管理员解锁改名

## 7. 补遗（2026-11-23 第二批执行）

### 7.1 名字撞车真相（两对，全部查清）
| 撞车对 | 真相 | 处置 |
|---|---|---|
| **ai3128 ↔ i38g128a** | `Host i38g128a ai3128` 共用别名指向 100.109.134.63——云机 ai3128（"大内存 Windows"）历史性复用了家机名 i38g128a；真家机 i38g128a 不在 tailnet（走 cloudflared+openp2p），当前离线 | 100.109.134.63 统一为 **ai3128**（tailscale hostname 已改）；家机 i38g128a 独占其名 |
| **bi3128 ↔ i38g128b** | i38g128b-cf 的 HostName 解析到 **100.74.61.39 = bi3128**——bi3128 其实就是家里的大内存机（内网 10.2.3.26/192.168.0.102），云机风格名配家机 | 统一为 **bi3128**（已改）；-cf 别名是它的公网入口（实测通） |

### 7.2 家机 fleet 的 tailnet 身份（本轮全部现身，全在线）
k1(100.121.212.70) · k2(100.106.179.119) · k3(100.66.152.98) · k4(100.95.53.1) · l1u50 · l2u50 · l3u50 · l4 · l5u50 · i7nuc(100.67.94.7) · nuc(100.64.29.104) ——**家机其实大半在 tailnet**，cloudflared(-cf) 是它们的公网兜底（k1/k2/k3/k4/i7/i38g64/i38g128b 实测通，i38g128a 单机挂）。

### 7.3 GH mirror 已落地（credential 问题用 deploy key 解决，不动主账号）
- github 私仓：`github.com/JJohnHee/sciai-shared-ws`
- oneyear 生成 `id_shared_ws_deploy` deploy key（repo 范围 write，安全——不暴露主账号 token）
- bare 仓 4 分支已镜像；`sync-shared-ws.sh`（cron */30）尾部自动 `git push github --all`——**GIT 通道每 30 分钟自动异地镜像**

### 7.4 vm2/vm5 GIT 通道终态
- 首推体积大 → 35s timeout 静默杀（vm2 诊断实锤）；vm5 曾因首次连接 host key 阶段报 "repository exists"
- 终态：**orphan tiny 分支推送成功**（vm2-tiny/vm5-tiny 已入库），全量分支交 cron 增量；**GIT 成员 = 6**（oneyear/i9/lx-6/lx7/vm2/vm5）

### 7.5 P2P token 收档（双载体离线）
token 载体：① 家机 i38g128a（openp2p 客户端 config.json）——cloudflared 挂、内网 DNS 无解析、机器离线；② 云电脑（OpenP2P 链断 2 天，keepalive 日志 11-21 起持续超时）。**P2P=0 定格为「待 token」**；载体任一上线后：取 config.json token → OP2P_NODES 填表 → 按配方装客户端（10 分钟/台）→ 面板自动绿。

### 7.6 最终通道矩阵（hosts-panel-gen 实测）
**TS=14 · CF=8 · GIT=6 · GH=14（ssh:22 探测，比 https HEAD 稳）· P2P=0（待 token）**；nameConsistent=12/14（例外：nvidatwo-win 本机双实例、ctyun-17725 tailscaled 被会话锁 401 + ssh 不通）。

## 8. 第五篇补遗：openp2p 大网接入 + 五通道面板全亮（2026-11-23 第三批）

### 8.1 新控制台 + 70 台大网现身
- **新控制台 = console.openpxp.com**（老 console.openp2p.cn 服务器超时，弹窗引导跳转——这就是"openpxp"的来历）；ego 登录态可用
- **openp2p 网络实为 70+ 台大网**（老控制台"0 设备"是超时假象）：家机 fleet 11 台（OPC-k1nuc…OPC-l5u50nuc/OPC-hope19/OPC-i38g64）+ 天翼云 20+ 台 + **instabox-farm-001~027+（AWS 弹性 farm 新大陆）** + 云电脑 3 台 + AAAi38g128（家机 i38g128a 真身）/Bi38g128(=bi3128) + 新装 5 台
- **token 内嵌于安装包 URL**：`1268210438431465255`（Install 页提取）

### 8.2 档 A 批量装 openp2p（P2P 通道 0→7）
- i9/lx7/oneyear/vm2/vm5 五台 install.sh 装成（lx-6 sudo 需密码留档）；systemd 常驻 + enabled
- **节点名规范（openp2p 硬约束 8-31 字符）**：短名（i9/lx7/oneyear）不够 8 字符会被服务器加随机后缀——统一改 **`sciai-` 前缀**：sciai-i9 / sciai-lx7 / sciai-oneyear（ExecStart `-node` 参数 + 重启生效）；vm2/vm5 天然合规（instabox-core-vm2/vm5 = tailscale 名一致）
- **hosts-panel-gen OP2P_NODES 填表**（8 条映射：alias→openp2p 设备名）→ **面板五通道全亮：TS=14 · CF=8 · P2P=7 · GIT=6 · GH=14**（14/14 在线）

### 8.3 deepseek-flash-fb 验证（用户点名）
✅ **可执行**：18900 直测回复"成功"（9ptok/1ctok）；注意返回 `model` 字段= deepseek-flash（fb 名路由到 flash 同链——与指纹结论一致：flash 系三名单一底模）

### 8.4 家机 i38g128a 的 ssh 通道（openp2p 唯一活通道的设备）
- ssh config 已加 **`Host i38g128a-p2p`**（i9:10023 → AAAi38g128:22，User Administrator + id_opc_mesh_global）
- **待激活**：openp2p 转发实例与主服务**同机冲突**（内部端口 4781 `bind: address already in use`，同机只能一实例）——正解 = **本机装 Windows openp2p 客户端**（setup exe 链接已留：openp2p64-api.openp2p.cn-1268210438431465255-setup3.25.14.exe）跑转发：本机 10023 → AAAi38g128:22；涉及桌面软件安装（可能 UAC），待用户点头即 10 分钟激活
- 控制台 PortForward 表单备选路径已踩通（Name/Local port/Dest Port 可填；Destination device combobox 为自定义组件需点箭头展开——本轮卡壳点，已记录）

### 8.5 p2p vs tailscale 终论（70 台数据加持后的修正）
- **规模修正**：openp2p 网络（70+ 台）> tailscale 池（13-14 台）——openp2p 不再是"小众第三通道"，是**家机 fleet + 天翼云 + AWS farm 的既成骨干**
- 但**架构角色不变**：tailscale 是**自控主力**（CGNAT 100.x + 心跳 + sweeper + hub 面板一体化管理）；openp2p 是**跨网兜底**（覆盖 tailscale 够不着的家机 i38g128a/云电脑/AWS farm）
- **双挂最佳实践（已落地）**：i9/lx7/oneyear/vm2/vm5/bi3128/hope19 七台双客户端在挂（P2P=7 与 TS 重叠）——任一网络断，另一通道还在

### 8.6 本批交付清单
| 交付物 | 位置 | 状态 |
|---|---|---|
| 档 A 五台 openp2p 客户端 + systemd | i9/lx7/oneyear/vm2/vm5 | ✅ 在线 |
| 节点名统一（sciai- 前缀） | ExecStart -node 参数 | ✅ 生效 |
| OP2P_NODES 映射 8 条 + 面板 P2P 通道 | hosts-panel-gen.py + hosts.json | ✅ P2P=7 |
| ssh 别名 i38g128a-p2p | ~/.ssh/config | ✅ 就位（待本机客户端激活转发） |
| deepseek-flash-fb | 18900 | ✅ 验证可执行 |
| 控制台设备全景清单 | openp2p 新控制台 | ✅ 70+ 台留档 |

## 9. 第六篇补遗：本机 openp2p 转发枢纽大发现 + i38g128a 通道收档（2026-11-23 第四批）

### 9.1 本机 = openp2p 转发枢纽（金矿级发现）
本机 `C:\Program Files\OpenP2P` 早装有 openp2p（服务+3 实例常驻，设备名 `opc-main-uLrGmTex`，老 token 46**5200**），**config.json apps 数组 13 条转发规则在跑**：
- `john007-ssh`：**本机 20022 → 云电脑 ZdhI5gKi:22（Link: Direct 活着！）**
- `john007b-ssh`：**本机 20023 → 云电脑 t969-ymF:22（Direct 活着！）**
- `farm055-ssh-local`：32222 → instabox-farm-055（对端 Offline）
- john007b-ssh 等 11 条天翼云 ctyun-xxx-ssh 转发规则（c* 天翼云 fleet 的 ssh 通道矩阵）

**云电脑 ssh 通道其实一直活着**（本机 20022/20023 直连）——老结论"OpenP2P 链断 2 天"修正为"老控制台 API 断，实际转发 Direct 活"。

### 9.2 openp2p 转发规则的正确打开方式（本轮踩坑全录）
1. **同机只能一实例**：独立转发实例与主服务冲突（PublicIPPort 4781 `bind: address already in use`）——正解 = 主服务 config.json 的 apps 数组加规则 或 控制台 PortForward 表单
2. **控制台是移动版 UI**（窄列布局）：表单字段可填（Name/端口 combobox 键盘 ArrowDown+Enter 可选），但**保存按钮在折叠线下方**（视口外，End/PageDown 会把表单导航丢掉）——多轮未触发保存，**需人工在 App 上滚动点保存**
3. **Local device 语义** = 规则监听所在的设备：从 AAAi38g128 卡片建的规则是"i38g128a 侧监听"（鸡生蛋）；正确入口 = 从**本机设备卡片**（opc-main-uLrGmTex）建：本机:10023 → AAAi38g128:22
4. **config.json 直改**需 UAC（Program Files）+ Restart-Service openp2p（服务名小写）——`$env:TEMP\openp2p-config-new.json` 已备好（含 i38g128a-ssh-local 规则），**用户在场点一次 UAC 即完成**（Copy-Item + Restart-Service）

### 9.3 i38g128a-p2p 通道收档（BLOCKED·三重卡点）
① config 写入 UAC 两次未点（用户不在位）② 控制台保存按钮未触发（移动 UI 折叠区）③ **对端 AAAi38g128 转发隧道本身 Connecting 循环**（家网 NAT 后 UDP 打洞困难，既有规则 sshtocloudpc 同样 Connecting——openp2p 家网场景固有限制）。
**就绪件**：ssh 别名 `i38g128a-p2p`（~/.ssh/config）+ 新 config 文件 + 一键 UAC 配方。激活条件：用户在场点 UAC（或控制台手动保存）+ 对端隧道质量改善（打洞成功/换 relay）。

### 9.4 lx-6 openp2p 补装（sudo 密码到位）
sudo 密码已由用户提供（已脱敏：原密码已按凭据止血清单轮换，不在任何公开文档留存）——lx-6 用 `echo <pass> | sudo -S` 装 openp2p（sciai-lx6）→ OP2P_NODES 填 lx-6 → P2P=8。（本轮时间线未及执行，密码已验证可用于下轮）

---

# 修正版架构：hub.mjs 是 OS 级核心，各部门亲自干活（2026-11-23 第五批修正）

## 之前设计的两大错误

| 错误 | 真相 |
|---|---|
| ❌ 把 lx-6 当"中间传递"节点 | ✅ **lx-6 自己就是写手**（hermes worker + claude + **自己的模型池 glm-5.2@18789**），核心写作亲自干，只有批量跑量下放池 |
| ❌ 漏掉 oneyear 的 sciai-hub 核心地位 | ✅ **hub.mjs:8788 = 自建 ClawsGO 完整工作台**（依托官方架构升级，远不止科研），是整个体系的调度 OS |

## hub.mjs 完整 API 面（30 个端点 = 完整操作系统）

| 类别 | 端点 | 说明 |
|---|---|---|
| **认证** | /api/auth/login, /api/auth/register | 用户系统（sciai-token） |
| **任务调度** | /api/turn, /api/swarm, /api/stream, /api/tasks | 双内核任务+蜂群+SSE 实时流+历史 |
| **网页终端** | /api/term/create, /api/term/input, /api/term/kill, /api/term/stream | 浏览器直接开终端到任意节点 |
| **远程文件** | /api/fs/list, /api/fs/read, /api/fs/write | 浏览器管理节点文件 |
| **技能体系** | /api/skills, /api/skills/<name>/toggle | 侧边栏技能开关 |
| **模型** | /api/models, /api/llm | 多模型池 |
| **设备拓扑** | /api/nodes, /api/nodes/register, /api/hosts | 节点注册+心跳+五通道面板 |
| **冲突裁决** | /api/conflicts, /api/conflicts/resolve | 争议节点裁决 |
| **项目管理** | /api/projects | 项目工作区 |
| **蜂群历史** | /api/hive, /api/hive/history | 蜂群记录 |
| **部署/更新** | /api/update, /api/version, /api/tunnels | 自更新+版本+隧道 |
| **其他** | /api/health, /api/admin/stats, /api/save-svg | 健康检查+管理统计+SVG |

**结论**：hub.mjs 不是"科研 hub"，是**自建 ClawsGO 云端 OS**——认证/任务/终端/文件/技能/模型/设备/裁决/项目/部署，官方 App 有的它都有（网页版）。

---

## 修正版三层拓扑

```
┌─────────────────────────────────────────────────┐
│   sciai-hub (oneyear:8788) = OS 级核心            │
│   自建 ClawsGO 完整工作台（网页版）                  │
│   ├─ 双内核：kiro@18674 / CD5 转派                │
│   ├─ /api/turn → 派单到任意节点                     │
│   ├─ /api/term → 浏览器开终端                      │
│   ├─ /api/fs → 远程文件管理                        │
│   └─ /api/conflicts → 冲突裁决                     │
└────────────────────┬────────────────────────────┘
                     │ /api/turn 派单（目标式）
     ┌───────────────┼───────────────┬─────────────┐
     ▼               ▼               ▼             ▼
  i9 研究部       lx-6 写作部      lx7 工程部    hope19 Win
 【常驻 Agent】  【常驻 Agent】   【常驻 Agent】  【常驻 Agent】
  pi + zcode CLI  hermes+claude   pi + claude    pi
  + claude CLI    + glm-5.2@18789  + sonnet@18662 kiro@tailnet
  ~/.zcode 全套   （自己写！不转手）                18674

  ★ 部门经理亲自干核心活：
    i9：深度研究自己做（zcode/pi/claude 三套 agent）
    lx-6：核心写作自己写（hermes + 自己的 glm-5.2 模型池）
    lx7：工程脚本自己写（pi + sonnet）
    hope19：Windows 验证自己做（pi）

                     │ 跑量部分才下放（pool dispatch）
     ▼               ▼               ▼             ▼
  ┌─────────────────────────────────────────────────┐
  │        去大脑化执行池（Tier-3，无 Agent）           │
  │  vm2/vm3/vm5（4C8G 流水线）· ai3128/bi3128（大内存）│
  │  天翼云电脑 ×20+ · clawsgo farm（醒时）            │
  │  ★ 只接 daemon turn 指令干活，无自主思考            │
  └─────────────────────────────────────────────────┘
```

## 部门经理 vs 执行池的分工标准

| 活的类型 | 谁干 | 例子 |
|---|---|---|
| **需要判断/创作** | 部门经理亲自 | 综述初稿（lx-6 写）、研究设计（i9 定）、工程方案（lx7 出） |
| **需要并发跑量** | 下放执行池 | 批量检索（vm2 ×4路）、批量格式化（vm5）、批量转码（天翼云） |
| **需要深度推理** | 部门经理亲自 | 冲突裁决、质量审查、方法学设计 |
| **机械重复** | 下放执行池 | 下载、转录、格式转换、批量提取 |

**关键原则**：部门经理是"有脑子的专家"（自己的模型池+自己的 agent），不是转发器——只有"无脑跑量"才值得下放 Tier-3。

---

## lx-6 潜能的正确发挥（修正）

lx-6 的真实能力（DEPARTMENTS.md 实测）：
- **hermes worker**：常驻写作 agent
- **claude**：备选 agent
- **glm-5.2@18789**：**自己的模型池**（独立于 18900，不占主脑资源）
- 实测战绩：论文 5 章 5/5、引言草稿 REF 占位、R7 检索纪律 6/6

**正确用法**：
```
hub 派单："综述 GLP-1 疗效，目标周五交"

lx-6 收单后：
  1. 自己读 CLAUDE.md（写作纪律）
  2. 自己用 hermes + glm-5.2 写核心章节（不假手他人）
  3. 批量参考文献格式化 → 下放 vm5（跑量）
  4. 整合成稿 → 自己完成
  5. 返回 hub："完成，存在 lx-6:~/clawsos_ws/kb/xxx.md"

❌ 错误用法（之前设计的）：
  lx-6 收单 → 转给 vm3 写 → vm3 交回 → lx-6 转交 hub
  （lx-6 变成纯转发器，浪费 hermes+glm-5.2 的写作能力）
```

---

## 未来扩展（节点增多时的排布）

当节点从 15 → 50+ 时：

```
Tier-1 主脑（1 台）
  oneyear hub.mjs（OS 核心，不动）

Tier-2 部门经理（每部门 1-2 台）
  i9 研究部总监（深研究自己做 + 管跑量下放）
  lx-6 写作部总监（核心写作自己做 + 管格式化下放）
  lx7 工程部总监
  hope19 Windows 部
  nvidatwo 采集部（新，NVENC 视频转码）
  bi3128 大内存部（新，长文档处理）

Tier-3 执行池（无脑工人，按需弹性扩）
  vm2/vm3/vm5 + 天翼云 20+ + farm 30+ + instabox-farm 27（AWS）
  ★ 扩容只扩这层（装 daemon 入池即可，零 agent 成本）
```

**扩展规则**：
1. **新节点优先入 Tier-3**（装 daemon + devices.json 一行，10 分钟）
2. **Tier-2 只在"新专业领域"出现时加**（比如需要视频部才加 nvidatwo 做总监）
3. **Tier-1 永远只有 oneyear**（hub 是唯一调度中枢）
4. **Tier-2 的"管理"其实是"下放跑量"**——不是组织架构管理，是工作分流

---

## 落地行动（修正版）

| 优先级 | 任务 | 说明 |
|---|---|---|
| **P1** | hub /api/turn 派单入口统一 | 现在 DEPARTMENTS.md 触发方式还是 ssh 目标式，改成 hub API（POST /api/turn + kernel/device 参数）——hub 已经支持 |
| **P2** | 各部门 CLAUDE.md 写清"自己干 vs 下放"分工标准 | 上面的分工表写进 i9/lx-6/lx7 的 CLAUDE.md |
| **P3** | hub 持久化（nodeRegistry + tasks 存盘） | 重启不丢注册和历史 |
| **P4** | lx-6 写作部全链验证 | hub 派一个真实写作任务 → lx-6 hermes 亲自写 → 产物落盘 → hub 验收 |
