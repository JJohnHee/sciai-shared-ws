#!/usr/bin/env bash
# retry.sh — 对一个命令 FAIL 自动重试 3 次，每次间隔 10s，重试耗尽后标记 stale
# 用法：./retry.sh [--interval N] [--task-id ID] <command...>
#   --interval N  重试间隔秒数（默认 10）
#   --task-id ID  可选，重试耗尽后将 task-queue.md 中该任务状态改为 STALE
# 调度闭环 v1 · i9 研究部（模型 18900 deepseek-flash-fb）· 2026-11-24

set -uo pipefail

MAX_RETRIES=3
INTERVAL=10
TASK_ID=""

while [ $# -gt 0 ]; do
    case "$1" in
        --interval) INTERVAL="$2"; shift 2 ;;
        --task-id)  TASK_ID="$2"; shift 2 ;;
        -h|--help)  grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) break ;;
    esac
done

if [ $# -eq 0 ]; then
    echo "用法: $0 [--interval N] [--task-id ID] <command...>" >&2
    exit 2
fi

QUEUE_FILE="${QUEUE_FILE:-$HOME/clawsos_ws/task-queue.md}"
STALE_LOG="${STALE_LOG:-$HOME/clawsos_ws/retry-stale.log}"

mark_stale() {
    # 1) 追加 stale 日志留档
    echo "$(date -Iseconds) STALE task_id=${TASK_ID:-N/A} cmd=\"$*\" retries=${MAX_RETRIES} interval=${INTERVAL}s" >> "$STALE_LOG"
    # 2) 若给了 --task-id，更新 task-queue.md 中该行状态为 STALE
    if [ -n "$TASK_ID" ] && [ -f "$QUEUE_FILE" ]; then
        sed -i -E "s/^(\|[[:space:]]*${TASK_ID}[[:space:]]*\|[^|]*\|[^|]*\|)[[:space:]]*(PENDING|RUNNING|FAIL|DONE|STALE)[[:space:]]*\|/\1 STALE |/" "$QUEUE_FILE" 2>/dev/null
    fi
    echo "[retry] MARKED STALE (task_id=${TASK_ID:-N/A})，已记录 $STALE_LOG" >&2
}

attempt=1
while true; do
    echo "[retry] attempt=${attempt}/${MAX_RETRIES}: $*"
    rc=0
    "$@" || rc=$?
    if [ "$rc" -eq 0 ]; then
        echo "[retry] SUCCESS on attempt ${attempt}"
        exit 0
    fi
    echo "[retry] FAIL rc=${rc} on attempt ${attempt}" >&2
    if [ "$attempt" -ge "$MAX_RETRIES" ]; then
        echo "[retry] 重试 ${MAX_RETRIES} 次（间隔 ${INTERVAL}s）后仍失败" >&2
        mark_stale "$@"
        exit "$rc"
    fi
    attempt=$((attempt+1))
    sleep "$INTERVAL"
done
