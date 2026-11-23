#!/usr/bin/env bash
# 节点心跳脚本：向协调服务注册并周期性上报心跳+系统指标
set -u

COORD="http://100.126.7.54:8788"
INTERVAL="${NODE_HB_INTERVAL:-30}"   # 秒，可通过环境变量覆盖
LOG_TAG="node-heartbeat"

get_ip() {
  local ip
  ip="$(tailscale ip -4 2>/dev/null || true)"
  [ -z "$ip" ] && ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
  echo "$ip"
}

# --- 系统指标采集 ---
collect_stats() {
  local cpu
  cpu="$(awk '{printf "%.1f", $1*100/2}' /proc/loadavg 2>/dev/null || echo 0)"
  local mem
  mem="$(awk '/MemAvailable/{avail=$2} /MemTotal/{total=$2} END{if(total>0) printf "%.1f", (total-avail)*100/total; else print 0}' /proc/meminfo 2>/dev/null || echo 0)"
  local up
  up="$(awk '{printf "%d", $1}' /proc/uptime 2>/dev/null || echo 0)"
  local arch
  arch="$(uname -m)"

  cat <<EOF
{"ip":"$1","cpu":$cpu,"mem":$mem,"uptime":$up,"arch":"$arch","hostname":"$(hostname)"}
EOF
}

register() {
  local ip="$1"
  curl -s -m 10 "$COORD/api/nodes/register" -X POST \
    -H "content-type: application/json" \
    -d "{\"ip\":\"$ip\"}" >/dev/null 2>&1 \
    && echo "[$LOG_TAG] registered $ip" || echo "[$LOG_TAG] register failed for $ip"
}

heartbeat_once() {
  local ip="$1"
  local payload
  payload="$(collect_stats "$ip")"
  curl -s -m 10 "$COORD/api/nodes/$ip/heartbeat" -X POST \
    -H "content-type: application/json" \
    -d "$payload" >/dev/null 2>&1 \
    && echo "[$LOG_TAG] heartbeat ok $ip" \
    || echo "[$LOG_TAG] heartbeat failed for $ip"
}

main() {
  local ip
  ip="$(get_ip)"
  [ -z "$ip" ] && { echo "[$LOG_TAG] no IP found, exiting"; exit 1; }

  register "$ip"

  while true; do
    heartbeat_once "$ip"
    sleep "$INTERVAL"
  done
}

case "${1:-}" in
  --once)
    ip="$(get_ip)"
    register "$ip"
    heartbeat_once "$ip"
    ;;
  *)
    main
    ;;
esac
