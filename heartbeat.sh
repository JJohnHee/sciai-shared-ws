#!/usr/bin/env bash
# heartbeat.sh — 调度闭环 v1 节点心跳（i9 研究部 / lx7 / 100.91.112.30）
# 每 60s 向 hub:8788 /api/nodes/<IP>/heartbeat 上报 CPU/内存/uptime（带 x-scai-token）
# 每个周期顺带从 hub /api/tasks 同步待执行任务到 ~/clawsos_ws/task-queue.md（闭环下行）
set -u

HUB="http://hub:8788"                              # hub -> 100.126.7.54 (/etc/hosts)
TOKEN="620937dabbf57e921110380f7c1b4bde"
AUTH="x-scai-token: $TOKEN"
INTERVAL=60
WS="$HOME/clawsos_ws"
QUEUE="$WS/task-queue.md"
STATUS_FILE="$WS/.queue-status"                    # 格式: <ID> <STATUS>，由 retry.sh 维护，同步时保留
NODE_IP=$(tailscale ip -4 2>/dev/null | head -1)
[ -z "$NODE_IP" ] && NODE_IP=$(hostname -I | awk '{print $1}')
NODE_NAME=$(hostname)
LOG="$WS/heartbeat.log"

mkdir -p "$WS/results"
touch "$STATUS_FILE"

log() { echo "[$(date '+%F %T')] $*" >> "$LOG"; }

register() {
  curl -s --max-time 8 -X POST "$HUB/api/nodes/register" \
    -H "content-type: application/json" -H "$AUTH" \
    -d "{\"ip\":\"$NODE_IP\",\"hostname\":\"$NODE_NAME\",\"arch\":\"$(uname -s)\",\"workspace\":\"$WS\"}" \
    >/dev/null 2>&1
}

# ---- 从 hub 拉取任务事件，刷新 task-queue.md（不编造：仅使用 hub 真实数据）----
sync_queue() {
  local tasks_file; tasks_file=$(mktemp)
  curl -s --max-time 10 -H "$AUTH" "$HUB/api/tasks" -o "$tasks_file" 2>/dev/null
  python3 - "$tasks_file" "$QUEUE" "$STATUS_FILE" "$NODE_IP" "$NODE_NAME" <<'PYEOF'
import json, sys, datetime, re
tasks_file, queue, status_file, ip, name = sys.argv[1:6]
try:
    events = json.load(open(tasks_file))
except Exception:
    sys.exit(0)  # hub 不可达/解析失败时保留现有队列，不破坏
try:
    overrides = dict(l.split(None,1) for l in open(status_file) if l.strip())
except Exception:
    overrides = {}
seen, rows = set(), []
for e in reversed(events):                      # 新任务在前
    if e.get("type") != "task_new": continue
    tid8 = e["id"][:8]; txt = e.get("task","").strip().replace("|","\\|")
    key = txt[:60]
    if key in seen: continue                    # 按内容去重（hub 有重发任务）
    seen.add(key)
    rid = "HUB-" + tid8
    rows.append("| %s | %s | %s(%s) | %s |" % (rid, txt[:120], name, ip, overrides.get(rid,"PENDING")))
    if len(rows) >= 12: break
hdr = """# task-queue.md — 调度队列（i9 研究部 / {name} / {ip}）

> 由 heartbeat.sh 每 60s 从 hub:8788 /api/tasks 自动同步（上行心跳 + 下行任务 = 调度闭环 v1）。
> 任务执行/重试走 retry.sh；LLM 任务由 18900 模型池执行（model: deepseek-flash-fb）。
> 同步时间（UTC）: {ts}

| ID | 任务 | 节点 | 状态 |
|---|---|---|---|
""".format(name=name, ip=ip, ts=datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"))
open(queue,"w").write(hdr + "\n".join(rows) + "\n")
PYEOF
  rm -f "$tasks_file"
}

# ---- 主循环 ----
register
BEAT=0
while true; do
  BEAT=$((BEAT+1))
  [ $((BEAT % 10)) -eq 0 ] && register          # 每10拍重注册，hub 重启可自愈

  # CPU：/proc/stat 两次采样；MEM：used(MB)
  read -r _ u1 n1 s1 i1 w1 q1 sq1 _ < <(sed -n '2p' /proc/stat)
  T1=$((u1+n1+s1+i1+w1+q1+sq1)); I1=$((i1+w1))
  sleep 1
  read -r _ u2 n2 s2 i2 w2 q2 sq2 _ < <(sed -n '2p' /proc/stat)
  T2=$((u2+n2+s2+i2+w2+q2+sq2)); I2=$((i2+w2))
  DT=$((T2-T1)); DI=$((I2-I1))
  if [ "$DT" -gt 0 ]; then CPU=$(awk -v dt="$DT" -v di="$DI" 'BEGIN{printf "%.1f",100*(dt-di)/dt}')
  else CPU=0; fi
  MT=$(awk '/MemTotal/{print $2}' /proc/meminfo)
  MA=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
  MEM=$(( (MT-MA)/1024 ))
  UP=$(cut -d. -f1 /proc/uptime)

  RESP=$(curl -s --max-time 8 -X POST "$HUB/api/nodes/$NODE_IP/heartbeat" \
    -H "content-type: application/json" -H "$AUTH" \
    -d "{\"cpu\":$CPU,\"mem\":$MEM,\"uptime\":$UP}")
  log "beat#$BEAT cpu=${CPU}% mem=${MEM}MB uptime=${UP}s resp=${RESP:-<timeout>}"

  sync_queue
  sleep $((INTERVAL-1))
done
