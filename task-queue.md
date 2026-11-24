# task-queue.md — i9 研究部 待执行任务队列
> 调度闭环 v1 · 2026-11-24 · 模型 18900 deepseek-flash-fb
> 节点：i9（opc，LAN 192.168.0.102 / tailscale 100.86.30.47）· hub=100.126.7.54:8788（token 已落盘 ~/.scai-token，权限 600）

| ID | 任务 | 节点 | 状态 |
|----|------|------|------|
| 1 | 编写 heartbeat.sh（每 60s 上报 CPU/内存到 hub:8788 /api/nodes/<IP>/heartbeat，带 x-scai-token） | i9 | DONE |
| 2 | 建立 task-queue.md 任务队列（格式 \| ID \| 任务 \| 节点 \| 状态 \|） | i9 | DONE |
| 3 | 编写 retry.sh（FAIL 自动重试 3 次，每次间隔 10s，超时后标记 stale） | i9 | DONE |
| 4 | 启动 heartbeat.sh 并验证 hub 返回 200 | i9 | DONE |
| 5 | 验证 retry.sh 重试链路（FAIL 路径 + stale 标记） | i9 | DONE |

## 状态约定
- PENDING：待执行
- RUNNING：执行中
- DONE：完成
- FAIL：失败
- STALE：重试 3 次仍失败（10s 间隔），由 retry.sh 自动标记，留待主脑重新调度
