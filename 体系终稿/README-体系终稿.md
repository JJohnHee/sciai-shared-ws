# SCIAI 蜂王体系 — 最终总结（2026-11-24）

## 一、体系现在能运行吗？——能，全部在自动运行中

| 组件 | 运行状态 | 验证方式 |
|---|---|---|
| SCAI 主脑 hub（OPC 总指挥） | ✅ 运行中 | `ssh oneyear 'curl http://127.0.0.1:8788/api/health'` |
| ClawsGO 官方服务器（204 命令） | ✅ systemd 常驻 | `ssh oneyear 'systemctl status clawsgo-official'` |
| 4 平台采集器 | ✅ 每天 cron 自动 | 任务计划程序：GitHub(09:00)/YouTube(09:30)/Telegram(10:30)/抖音(11:30) |
| legion-sweeper（节点扩容） | ✅ 每小时 cron | `ssh oneyear 'tail /root/legion-sweeper.log'` |
| git-connector（节点通信） | ✅ 每小时 cron | 4 节点（i9/lx-6/lx7/oneyear）cron */5 |
| memory-sync（记忆体系） | ✅ 每小时 cron | 4 节点 ~/fleet/memory/ |
| 22 Fleet Bot | ✅ 部署在 6 节点 | 首跑闭环走通（选题→起草→审稿退回→修改→再审通过） |
| FreeLLMAPI 网关（319 模型） | ✅ 运行中 | `ssh oneyear 'curl http://127.0.0.1:3001/health'` |
| 18900 模型池（23 模型） | ✅ 运行中 | `ssh oneyear 'curl http://127.0.0.1:18900/v1/models'` |
| DeepSeek 网页逆向 | ✅ systemd :18960 | `ssh oneyear 'curl http://127.0.0.1:18960'` |

## 二、结果体系都在哪儿

| 产物 | 位置 |
|---|---|
| **全体系解剖文档**（498+ 行） | `workspace/clawsgo-sciai-全体系解剖.md` |
| **终极架构蓝图** | `workspace/终极架构蓝图-三脑军团-20261124.md` |
| **蜂王全体系评估**（opus 5.5 产出） | `workspace/全体系评估-蜂王-20261124.md` |
| **OPC 全体系进度总览** | `workspace/OPC全体系进度总览-20261124.md` |
| **Gumroad 上架指南**（复制粘贴版） | `workspace/GUMROAD-上架指南-复制粘贴.md` |
| **GitHub 采集报告** | `F:\对标\github\` |
| **YouTube 采集报告** | `F:\对标\youtube\` |
| **Telegram 采集报告** | `F:\对标\telegram\` |
| **抖音热榜报告** | `F:\对标\douyin\` |
| **GrokBot 对标体系**（16 份文档） | `F:\对标\` |
| **Git 联通层产物** | `oneyear:/root/sciai-shared-ws/` |
| **GitHub 共享仓** | github.com/JJohnHee/sciai-shared-ws |
| **Google Drive 镜像** | SCIAI/任务日志/ + SCIAI/评估/ |
| **Skill A/B/C 产品** | github.com/JJohnHee/ui-deai + brand-iso + batch-social |
| **Bot 军团注册**（138 个） | `oneyear:/root/clawsgo-replica/bots/bots.json` |
| **节点注册**（77 台） | `oneyear:/root/clawsgos-gateway/devices.json` |
| **记忆体系**（4 节点） | 各节点 `~/fleet/memory/` + `~/fleet/shared-memory/` |
| **客户端桥（preload.js）** | `workspace/sciai-workbench/preload.js` |

## 三、构建进度总表

| 指标 | 当前 | 目标 | 完成度 |
|---|---|---|---|
| 节点数 | 77 台注册 / 34 台活跃 | 200 台 | 38.5%（差额需开天翼云新机） |
| Agent/bot | 138 个 | 1000 个 | 13.8% |
| 采集平台 | 4 个运行 | 8+ 个 | 50%（X/小红书/闲鱼/Trendar 被封锁） |
| 变现收入 | $0 | 首月 ~$870 | 0%（待 Gumroad 上架） |
| 体系搭建 | 核心闭环全通 | 完整 | ~85% |

## 四、l1 对整个体系的梳理

### l1 竞调部产出的架构分析

**17 框架库竞调分析**（`internet-gathering-design.md`）：
- 采集层（GitHub API/X RSS/小红书浏览器/YouTube yt-dlp/抖音 API/闲鱼浏览器/Telegram RSS）
- 处理管道（采集→去重→分类→富化→存储→检索）
- 集成层（蜂王 GOAL/DONE 协议+心跳+日报+研究部联动+赚钱部信号评分）

**赚钱部首单研究**（`money-ops-research-v1.md`）：
- 机会：Agent Skill 付费包（unslop 21k★ + anatomy 29k★ = 验证需求，付费位空缺）
- 对标：Bannerbear $49-$299/月($80-90K MRR) / Plausible $1M+ ARR / PhotoAI $100K+/月
- MVP：3 个 Skill 包 × $29 → Gumroad 上架 → 第2月托管 API $19-49/月
- 止损：4 周内 <5 付费用户或 <$150 GMV → 转向

**外网信息检索项目主脑**（l1 专属 bot）：
- 13-竞品雷达-P0（7 个重点博主）
- 14-竞品雷达-P1（8 个同赛道博主）
- 15-趋势新词（GitHub trending + 热词 + 新工具）
- 20-账号健康（各渠道限流/异常/封禁监控）

### 20 对标博主清单

| 层 | 博主 | 定位 |
|---|---|---|
| P0 ★ | @zifeng1125 子枫 | SEO 冷启动 AI 工具站出海 |
| P0 ★ | @littlebena Ben | 前字节 PM，All in AI 出海 |
| P0 ★ | @swg209 小苏 | 程序员副业 → Next.js 建站变现 |
| P0 ★ | @BaixiongBuilds 白熊 | Claude Code + ChatGPT 开发 |
| P0 | @HarryAIDev Harry | OpsDev 工程师独立全栈 |
| P0 | @Eryx_Zhu Eryx | 一人公司 OPC 实操 |
| P0 | @ZhenXing1993 | 公开记录起号/选题/变现 |
| P1 ★ | @loki_yan_seo Loki | SEO/GEO/AI 可见度（对标 BeatGEO） |
| P2 | @alexmashrabov Alex | Higgsfield 视频 GenAI ARR |

## 五、GrokBot 22 员工模式解析

### 核心方法论
1. **单一入口**：只跟一个「总管」Bot 对话，它派活收执
2. **按岗位分工**：每个 Bot 有名字、职责、持久记忆
3. **6 条工作线**：社媒/SEO-AEO/外链/竞品监控/视频/趋势
4. **写稿审稿分离**：不同 Bot 负责起草和事实核对
5. **人类决策点只有 4 个**：内容方向/发布批准/付费调用/不可逆操作

### Fleet/ 落盘契约（i9 已建）
```
i9:~/fleet/
├── SHARED.md           # 9 条共用规则 + 22 Bot 名册
├── review-sheet.md     # 审核→批准→发布→回收
├── routines.md         # 定时任务清单
├── SETUP.md           # 手动步骤
└── bots/               # 22 个岗位 Bot
    00-总管  01-选题  02-SEO巡检  03-06-起草×4
    07-审稿  08-事实核对  09-11-发布×3  12-外链
    13-14-竞品雷达×2  15-趋势  16-视频脚本
    17-数据回收  18-日报  19-周复盘  20-账号健康  21-应急
```

## 六、F:\OPC与拆解辅助 解析

### 17 框架源码（已全部解压到 _src/）
| 类别 | 框架 | 价值 |
|---|---|---|
| **科研自动化** | AI-Scientist-v3 / Virtual-Scientists-v2 | AI 自主科研 |
| **多 Agent 编排** | autogen / crewAI / agentscope / openagents | 并行协作 |
| **分布式计算** | ray / temporal / robin | 任务调度 |
| **ClawsGO 官方** | clawsgo-opensource / clawsgo-pyqt / clawsgo-science-mcp | **完整复刻版（211 命令+219 E2E）** |
| **Bot 架构** | ClawTeam / grok-bot-architecture | 团队架构参考 |
| **其他** | AOP-Paper / opc / openpolsia | 方法论 |

### clawsgo-opensource 官方对比（金矿发现）
| 对比 | 官方 | 我们 |
|---|---|---|
| 总命令 | 204 | 30（hub） |
| admin | 64 | 0 |
| chat | 30 | 5 |
| hosts | 19 | 4 |
| skills | 10 | 12 ✅ |
| E2E 测试 | 219 | 0 |
| **实际部署** | ✅ 已部署 | oneyear:5180/5181 |

### 204 命令分布
```
auth(3) session(4) chat(30) files(9) memory(6) projects(7)
hosts(19) skills(10) teams(16) billing(13) support(7)
usage(2) admin(64) other(14)
```

## 七、SCAI 主脑提示词体系（三层）

### 层 1：运行手册 CLAUDE.md（人设+能力+纪律）
`oneyear:/root/clawsgo-replica/CLAUDE.md` = OPC 总指挥人设

### 层 2：技能层 SKILL.md（12 个，对应官方侧边栏）
scios-research / clawsgo-figure / clawsgo-ssh / docx / pdf / pptx / xlsx / prd / ralph / agent-browser / epic-breakdown-advisor / skill-creator

### 层 3：任务书三档模板
| 档 | 模型 | 适用 |
|---|---|---|
| Lithium 轻量 | deepseek-flash / glm-5.3 | 跑量采集 |
| Silicon 主力 | glm-5.3 / deepseek-v4 / kimi-k3.1-pro | 检索/综述/分析 |
| Titanium 旗舰 | claude-opus-5-5 (kiro@18674) | 长程/裁决/自检 |

## 八、模型池实测指纹

### 23 模型 = 3 真实底模（tokenizer 5 串法实测）
| 底模 | 池内名字 |
|---|---|
| **GLM 系** [34,29,28,34,38] | glm-5.3 / glm-5.3-flash |
| **DeepSeek 系** [26,21,20,26,37] | deepseek-flash / flash-fb / compact |
| **Kimi 系** [94,88,88,94,103] | v4.1-flash / v4-pro / k3 / k3.1-pro / qwen-3.8-max（五名一模） |

### 动态换皮
deepseek-v4.1-flash 两次跑不同底模（[26..]→[94..]）= **同名模型不同时刻可以是不同底模**

## 九、三脑架构

| 脑 | 节点 | 职责 |
|---|---|---|
| **脑1：ICR AI** | 独立 | 待接入 |
| **脑2：SCAI 蜂王** | oneyear:8788 | OPC 总指挥（只做 idea+指挥+验收+裁决） |
| **脑3：ZCode 黑五类** | 本机 | 全网检索+模型评估+外部系统交互 |

### 指挥层级
```
SCAI 最高主脑（不干活）
  ├── 项目主脑层
  │   CD5=ClawsGO 科研 / L5=写书出版 / l1=外网信息检索
  │   i9=dregg bot+备用脑 / lx-6=写作 / lx7=工程 / nvidatwo=视频
  └── 打工仔层（天翼云×20+ / vm2/3/5 / farm×27）
```

## 十、外部双评审结论（2026-11-25，Computer Use 直控两大桌面 AI）

| 评审人 | 综合判断 | 报告位置 |
|---|---|---|
| **Grok Bot Desktop** | "分层蜂群原型形态合理，但 6 节点闭环 ≠ 77 节点生产可用" | 本目录 `grokbot-desktop-evaluation.md` + Drive `SCIAI/评估/grokbot-desktop/` |
| **Gemini Desktop（Neon）** | **综合 6.8/10**，六维：架构7.5 / 联通7.0 / 路由6.5 / 调度7.5 / 对比7.0 / 风险盲区5.5 | 本目录 `gemini-desktop-evaluation.md` + Drive `SCIAI/评估/gemini/` |

**双评审收敛的 5 大共识（先修再扩容）**：
1. hub.mjs:8788 单点故障 → 引入消息队列/WAL 账本 + 主备热切
2. Git 只做归档，不当高频状态总线
3. 319 模型池漏斗剪枝到 Top 10–15 + 脱敏网关
4. 扩容前梯度压测（6→20→50→77）+ 注入故障验证 Failover
5. 补财务刹车（Token 预算/Max-Hop/DLQ）+ 执行层沙箱隔离

## 十一、待完成（需要用户操作）

| 操作 | 时间 | 效果 |
|---|---|---|
| Gumroad 上架 3 个 ZIP | 10 分钟 | 变现闭环 |
| 天翼云开新云电脑 | 每台 5 分钟 | 节点 77→200 |

---

*生成：SCAI 蜂王体系 · 2026-11-24 · 本文档是全体系的最终总结*
