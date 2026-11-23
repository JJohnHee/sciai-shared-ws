#!/usr/bin/env bash
# node_heartbeat.sh - 向 SCIAI Hub (100.126.7.54:8788) 注册并周期性上报心跳
# 用法:
#   ./node_heartbeat.sh start   # 后台启动 (nohup, 日志写入日志目录)
#   ./node_heartbeat.sh stop    # 停止后台心跳
#   ./node_heartbeat.sh status  # 查看运行状态
#   ./node_heartbeat.sh run     # 前台运行 (调试)
#   ./node_heartbeat.sh once    # 立即执行一次注册/心跳

set -u

HUB="${HUB:-http://100.126.7.54:8788}"
INTERVAL="${INTERVAL:-30}"
BASE="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$BASE/.node_heartbeat"
LOG="$LOG_DIR/heartbeat.log"
PIDFILE="$LOG_DIR/heartbeat.pid"
mkdir -p "$LOG_DIR"

# 取本机对外 IP: 优先 tailscale, 否则取第一个本地 IP
local_ip() {
  local ip
  ip="$(tailscale ip -4 2>/dev/null || hostname -I 2>/dev/null | awk '{print $1}')"
  echo "${ip:-unknown}"
}

# 简单读取系统指标 (尽力而为, 读不到就填 0)
cpu_pct() {
  if [ -r /proc/stat ]; then
    read -r _ u n s i io irq sirq _ < /proc/stat
    sleep 0.3
    read -r _ u2 n2 s2 i2 io2 irq2 sirq2 _ < /proc/stat
    local idle1=$((i + io + irq + sirq))
    local idle2=$((i2 + io2 + irq2 + sirq2))
    local tot1=$((u + n + s + idle1))
    local tot2=$((u2 + n2 + s2 + idle2))
    local d=$((tot2 - tot1))
    if [ "$d" -gt 0 ]; then
      echo "$(( (100 * (d - (idle2 - idle1))) / d ))"
    else
      echo 0
    fi
  else
    echo 0
  fi
}

mem_pct() {
  if [ -r /proc/meminfo ]; then
    awk '/^MemTotal/{t=$2} /^MemAvailable/{a=$2} END{ if (t>0) printf "%d", (t-a)*100/t; else print 0 }' /proc/meminfo
  else
    echo 0
  fi
}

uptime_s() {
  if [ -r /proc/uptime ]; then
    awk '{print int($1)}' /proc/uptime
  else
    echo 0
  fi
}

send_heartbeat() {
  local ip hostname arch ws cpu mem up ts
  ip="$(local_ip)"
  hostname="$(hostname 2>/dev/null || uname -n)"
  arch="$(uname -m)"
  ws="$PWD"
  cpu="$(cpu_pct)"
  mem="$(mem_pct)"
  up="$(uptime_s)"
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  local payload
  payload="$(cat <<EOF
{"ip":"${ip}","hostname":"${hostname}","arch":"${arch}","workspace":"${ws}","cpu":${cpu},"mem":${mem},"uptime":${up},"time":"${ts}"}
EOF
)"

  local out http
  out="$(curl -s -m 10 "${HUB}/api/nodes/register" -X POST \
        -H "content-type: application/json" -d "${payload}")"
  http="${out:+$?}"
  echo "[$ts] heartbeat -> ${HUB} ip=${ip} cpu=${cpu}% mem=${mem}% up=${up}s resp=${out:-NO_RESPONSE}"
}

is_running() {
  [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

case "${1:-run}" in
  start)
    if is_running; then
      echo "already running (pid $(cat "$PIDFILE"))"
      exit 0
    fi
    nohup "$0" _loop >> "$LOG" 2>&1 &
    echo $! > "$PIDFILE"
    sleep 1
    if is_running; then
      echo "started pid $(cat "$PIDFILE")  log=$LOG  interval=${INTERVAL}s"
    else
      echo "failed to start; see $LOG"
      exit 1
    fi
    ;;
  stop)
    if is_running; then
      kill "$(cat "$PIDFILE")" 2>/dev/null
      rm -f "$PIDFILE"
      echo "stopped"
    else
      echo "not running"
    fi
    ;;
  status)
    if is_running; then
      echo "running (pid $(cat "$PIDFILE"))  log=$LOG"
      echo "--- last 5 log lines ---"
      tail -n 5 "$LOG" 2>/dev/null
    else
      echo "not running"
    fi
    ;;
  once)
    send_heartbeat
    ;;
  _loop)
    while :; do
      send_heartbeat
      sleep "$INTERVAL"
    done
    ;;
  run|*)
    echo "foreground mode (Ctrl-C to stop)"
    "$0" _loop
    ;;
esac
