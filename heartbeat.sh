#!/usr/bin/env bash
# heartbeat.sh — 每 60s 上报 CPU/内存到 hub:8788 /api/nodes/<IP>/heartbeat
# 调度闭环 v1 · i9 研究部（模型 18900 deepseek-flash-fb）· 2026-11-24
# 依赖：curl, tailscale/hostname；token 走 x-scai-token，从 ~/.scai-token 读取（权限 600）

set -uo pipefail

HUB_HOST="${HUB_HOST:-100.126.7.54}"
HUB_PORT="${HUB_PORT:-8788}"
INTERVAL="${INTERVAL:-60}"
NODE_NAME="${NODE_NAME:-$(hostname)}"
TOKEN="${SCAI_TOKEN:-$(cat ~/.scai-token 2>/dev/null || true)}"

# 获取本机 IP（优先 tailscale IP，与 hub 注册约定一致）
NODE_IP=$(tailscale ip -4 2>/dev/null | head -1)
[ -z "$NODE_IP" ] && NODE_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
[ -z "$NODE_IP" ] && NODE_IP=$(hostname -I 2>/dev/null | awk '{print $1}')

URL="http://${HUB_HOST}:${HUB_PORT}/api/nodes/${NODE_IP}/heartbeat"

register() {
    curl -s --max-time 8 -X POST "http://${HUB_HOST}:${HUB_PORT}/api/nodes/register" \
        -H "Content-Type: application/json" \
        -H "x-scai-token: ${TOKEN}" \
        -d "{\"ip\":\"${NODE_IP}\",\"hostname\":\"${NODE_NAME}\",\"arch\":\"$(uname -s)\",\"workspace\":\"$HOME/clawsos_ws\"}" >/dev/null 2>&1
}

register  # hub 要求先注册才能心跳

echo "[heartbeat] ${NODE_NAME} (${NODE_IP}) -> ${URL} every ${INTERVAL}s"

BEAT=0
while true; do
    BEAT=$((BEAT+1))
    # 每 10 次心跳重新注册，hub 重启后可自动恢复
    [ $((BEAT % 10)) -eq 0 ] && register
    TS=$(date -Iseconds)
    # CPU 使用率：两次采样 idle 差值
    idle1=$(awk '/^cpu /{print $5}' /proc/stat)
    total1=$(awk '/^cpu /{s=$2+$3+$4+$5+$6+$7+$8}END{print s}' /proc/stat)
    sleep 1
    idle2=$(awk '/^cpu /{print $5}' /proc/stat)
    total2=$(awk '/^cpu /{s=$2+$3+$4+$5+$6+$7+$8}END{print s}' /proc/stat)
    CPU_IDLE=$(awk -v i1="$idle1" -v i2="$idle2" -v t1="$total1" -v t2="$total2" \
        'BEGIN{ d=t2-t1; if (d>0) printf "%.1f", 100*(i2-i1)/d; else printf "0.0" }')
    CPU_USAGE=$(awk -v x="$CPU_IDLE" 'BEGIN{printf "%.1f", 100-x}')

    MEM_TOTAL_KB=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    MEM_AVAIL_KB=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
    MEM_USED_PCT=$(awk -v t="$MEM_TOTAL_KB" -v a="$MEM_AVAIL_KB" \
        'BEGIN{ if (t>0) printf "%.1f", 100*(t-a)/t; else printf "0.0" }')

    LOAD1=$(awk '{print $1}' /proc/loadavg)

    PAYLOAD=$(cat <<EOF
{"node":"${NODE_NAME}","ip":"${NODE_IP}","ts":"${TS}","cpu_pct":${CPU_USAGE},"mem_pct":${MEM_USED_PCT},"load1":${LOAD1}}
EOF
)

    HTTP_CODE=$(curl -s -o /tmp/hb_resp.json -w '%{http_code}' \
        -X POST "$URL" \
        -H "Content-Type: application/json" \
        -H "x-scai-token: ${TOKEN}" \
        -d "$PAYLOAD" 2>/dev/null)

    if [ "$HTTP_CODE" = "200" ]; then
        echo "[heartbeat] ${TS} OK cpu=${CPU_USAGE}% mem=${MEM_USED_PCT}% load=${LOAD1}"
    else
        echo "[heartbeat] ${TS} FAIL http=${HTTP_CODE} url=${URL}" >&2
    fi

    sleep "$INTERVAL"
done
