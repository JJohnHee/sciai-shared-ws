#!/usr/bin/env bash
# retry.sh — 调度闭环 v1 任务执行与重试（i9 研究部 / lx7）
# 用法:
#   retry.sh <HUB-xxxxxxxx | T-V1-xxx>          # 从 task-queue.md 取任务执行
#   retry.sh --model "提示词"                    # 直接调用 18900 deepseek-flash-fb
#   retry.sh -- "shell 命令"                     # 直接执行 shell 命令
# 规则: FAIL 后自动重试 3 次，每次间隔 10s；重试耗尽（超时仍 FAIL）则标记 STALE。
set -u

WS="$HOME/clawsos_ws"
QUEUE="$WS/task-queue.md"
STATUS_FILE="$WS/.queue-status"
LOG="$WS/retry.log"
MAX_RETRY=3
RETRY_GAP=10
MODEL_URL="http://100.126.7.54:18900/v1/chat/completions"   # 18900 模型池
MODEL="deepseek-flash-fb"
TASK_TIMEOUT=120

log() { echo "[$(date '+%F %T')] $*" >> "$LOG"; echo "$*"; }
mkdir -p "$WS/results"; touch "$STATUS_FILE"

set_status() {  # set_status <ID> <STATUS>  —— 记录覆盖状态并改写队列行
  local id="$1" st="$2"
  if grep -q "^$id " "$STATUS_FILE" 2>/dev/null; then
    sed -i "s|^$id .*|$id $st|" "$STATUS_FILE"
  else
    echo "$id $st" >> "$STATUS_FILE"
  fi
  sed -i -E "s/^\| $id \|([^|]*)\|([^|]*)\|[^|]*\|/| $id |\1|\2| $st |/" "$QUEUE" 2>/dev/null
  log "[$id] 状态 -> $st"
}

run_once() {  # run_once <mode> <payload> <out_file> ; 返回0=成功
  local mode="$1" payload="$2" out="$3"
  if [ "$mode" = "shell" ]; then
    if timeout "$TASK_TIMEOUT" bash -c "$payload" >"$out" 2>&1; then return 0; fi
  else
    local body; body=$(python3 -c 'import json,sys;print(json.dumps({"model":sys.argv[1],"messages":[{"role":"user","content":sys.argv[2]}],"max_tokens":4096,"timeout":int(sys.argv[3])}))' "$MODEL" "$payload" "$TASK_TIMEOUT")
    curl -s --max-time "$TASK_TIMEOUT" "$MODEL_URL" -H 'content-type: application/json' -d "$body" >"$out" 2>/dev/null
    python3 - "$out" <<'PY'
import json,sys
try:
    d=json.load(open(sys.argv[1]))
    txt=(d.get("choices") or [{}])[0].get("message",{}).get("content","")
    open(sys.argv[1]+".txt","w").write(txt)
    sys.exit(0 if txt.strip() else 1)
except Exception:
    sys.exit(1)
PY
  fi
  return 1
}

# ---------- 解析参数 ----------
MODE=""; TASK_ID=""; PAYLOAD=""
case "${1:-}" in
  --model) MODE="model"; PAYLOAD="$2";;
  --)      MODE="shell"; PAYLOAD="$*"; PAYLOAD="${PAYLOAD#-- }";;
  "")      echo "用法: retry.sh <HUB-xxxxxxxx|T-V1-xxx> | --model \"提示词\" | -- \"shell命令\""; exit 2;;
  *)       TASK_ID="$1"
           PAYLOAD=$(grep -E "^\| $TASK_ID \|" "$QUEUE" 2>/dev/null | head -1 | awk -F'|' '{gsub(/^ +| +$/,"",$3); print $3}')
           if [ -z "$PAYLOAD" ]; then echo "错误: 队列中找不到任务 $TASK_ID"; exit 2; fi
           MODE="model"   # hub 任务为自然语言任务，默认走 18900 deepseek-flash-fb
           ;;
esac
[ -z "$TASK_ID" ] && TASK_ID="ADHOC-$(date +%s)"

OUT="$WS/results/$TASK_ID.out"
set_status "$TASK_ID" "RUNNING" 2>/dev/null

# ---------- 执行 + 自动重试 ----------
attempt=0
while true; do
  attempt=$((attempt+1))
  log "[$TASK_ID] 第 $attempt 次执行 (mode=$MODE) ..."
  if run_once "$MODE" "$PAYLOAD" "$OUT"; then
    set_status "$TASK_ID" "DONE"
    log "[$TASK_ID] 成功，结果: $OUT"
    exit 0
  fi
  if [ "$attempt" -gt "$MAX_RETRY" ]; then
    set_status "$TASK_ID" "STALE"
    log "[$TASK_ID] 重试 ${MAX_RETRY} 次仍 FAIL（超时），标记 STALE"
    exit 1
  fi
  log "[$TASK_ID] FAIL，${RETRY_GAP}s 后自动重试 ($attempt/$MAX_RETRY)"
  sleep "$RETRY_GAP"
done
