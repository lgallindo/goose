#!/usr/bin/env bash
set -euo pipefail

# Configuration
API_URL="http://127.0.0.1:38080"
TIMEOUT=5

# Logging
log_debug() { echo "[DEBUG] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

# Connection check
aider_connect() {
    log_debug "Testing connection to $API_URL..."
    if curl -s -f -o /dev/null --connect-timeout "$TIMEOUT" "$API_URL/health"; then
        log_debug "Connected successfully."
        return 0
    else
        log_error "Failed to connect to $API_URL"
        return 1
    fi
}

# Fetch models
aider_get_models() {
    log_debug "Fetching models..."
    curl -s -f --connect-timeout "$TIMEOUT" "$API_URL/v1/models" | jq -r '.data[].id'
}

# Chat
aider_chat() {
    local prompt="$1"
    log_debug "Sending chat request..."
    response=$(curl -s -f -X POST --connect-timeout "$TIMEOUT" "$API_URL/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d "{\"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}]}") || {
        log_error "Chat request failed."
        return 1
    }
    echo "$response" | jq -r '.choices[0].message.content'
}

# Complete
aider_complete() {
    local prompt="$1"
    log_debug "Sending completion request..."
    response=$(curl -s -f -X POST --connect-timeout "$TIMEOUT" "$API_URL/v1/completions" \
        -H "Content-Type: application/json" \
        -d "{\"prompt\": \"$prompt\"}") || {
        log_error "Completion request failed."
        return 1
    }
    echo "$response" | jq -r '.choices[0].text'
}
