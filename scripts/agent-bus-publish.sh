#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (c) 2026 Lucas Gallindo
# Publish local LLM runtime status for cross-repo agent coordination.
# Writer: secret_local_llm agent (or operator after `just server`).
# Reader: goose agent via scripts/agent-bus-wait.sh

set -euo pipefail

BUS_DIR="${AGENT_SYNC_DIR:-/home/lugatj/code/.agent_sync}"
PORT="${SECRET_LOCAL_LLM_PORT:-38080}"
HOST="http://127.0.0.1:${PORT}"
STATUS_FILE="${BUS_DIR}/runtime_status.json"
LOCK_FILE="${BUS_DIR}/runtime_status.lock"
PERFORMER="${AGENT_PERFORMER_ID:-goose-agent}"

mkdir -p "${BUS_DIR}"

probe_models() {
    curl -fsS --max-time 5 "${HOST}/v1/models" 2>/dev/null || echo ""
}

write_status() {
    local healthy="$1"
    local models_payload="$2"
    local model_id="unknown"
    if [ -n "${models_payload}" ]; then
        model_id=$(echo "${models_payload}" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4 || true)
        if [ -z "${model_id}" ]; then
            model_id=$(echo "${models_payload}" | grep -o '"model":"[^"]*' | head -1 | cut -d'"' -f4 || true)
        fi
    fi
    local ts
    ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    cat >"${STATUS_FILE}.tmp" <<EOF
{
  "healthy": ${healthy},
  "host": "${HOST}",
  "port": ${PORT},
  "model_id": "${model_id:-unknown}",
  "checked_at": "${ts}",
  "performer_id": "${PERFORMER}",
  "repo": "secret_local_llm"
}
EOF
    mv "${STATUS_FILE}.tmp" "${STATUS_FILE}"
}

(
    flock -x 200
    MODELS=$(probe_models)
    if [ -n "${MODELS}" ]; then
        write_status "true" "${MODELS}"
        echo "agent-bus: healthy=true port=${PORT} model=$(grep -o '"model_id": "[^"]*' "${STATUS_FILE}" | cut -d'"' -f4)"
        exit 0
    fi
    write_status "false" ""
    echo "agent-bus: healthy=false port=${PORT} (llama-server not responding)" >&2
    exit 1
) 200>"${LOCK_FILE}"
