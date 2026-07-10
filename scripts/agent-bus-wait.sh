#!/usr/bin/env bash
# Block until runtime_status.json reports healthy=true (or timeout).
# Usage: scripts/agent-bus-wait.sh [timeout_seconds]

set -euo pipefail

BUS_DIR="${AGENT_SYNC_DIR:-/home/lugatj/code/.agent_sync}"
STATUS_FILE="${BUS_DIR}/runtime_status.json"
TIMEOUT="${1:-120}"
INTERVAL=2
ELAPSED=0

echo "agent-bus-wait: polling ${STATUS_FILE} (timeout ${TIMEOUT}s)..."

while [ "${ELAPSED}" -lt "${TIMEOUT}" ]; do
    if [ -f "${STATUS_FILE}" ]; then
        if grep -q '"healthy": true' "${STATUS_FILE}" 2>/dev/null; then
            echo "agent-bus-wait: ready"
            cat "${STATUS_FILE}"
            exit 0
        fi
    fi
    sleep "${INTERVAL}"
    ELAPSED=$((ELAPSED + INTERVAL))
done

echo "agent-bus-wait: timeout after ${TIMEOUT}s" >&2
if [ -f "${STATUS_FILE}" ]; then
    cat "${STATUS_FILE}" >&2
fi
exit 1
