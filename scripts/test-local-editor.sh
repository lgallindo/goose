#!/bin/bash
# Test harness for local LLM editor integration
# Purpose: Verify local Qwen model is accessible and functioning via OpenAI-compatible API
# No dependencies: uses curl only (POSIX shell + curl, no Python/Docker)

set -e

# Configuration
LOCAL_LLM_URL="${LOCAL_LLM_URL:-http://127.0.0.1:38080/v1}"
TIMEOUT="${TIMEOUT:-5}"
VERBOSE="${VERBOSE:-0}"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper: Print test header
test_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Test: $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Helper: Print test result
test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        ((TESTS_FAILED++))
    fi
}

# Helper: Print verbose output
verbose() {
    if [ "$VERBOSE" -eq 1 ]; then
        echo "[DEBUG] $1"
    fi
}

# ============================================================================
# Test 1: Server connectivity
# ============================================================================
test_header "Server Connectivity"

verbose "Attempting to connect to $LOCAL_LLM_URL"
RESPONSE=$(curl -s --max-time "$TIMEOUT" -o /dev/null -w "%{http_code}" "$LOCAL_LLM_URL/models" 2>/dev/null || echo "000")

if [ "$RESPONSE" -eq 200 ]; then
    test_result 0 "Server responding on $LOCAL_LLM_URL (HTTP $RESPONSE)"
else
    test_result 1 "Server not responding (HTTP $RESPONSE). Is llama-server running on $LOCAL_LLM_URL?"
    echo -e "${YELLOW}Tip: Start with: llama-server -m <model.gguf> --listen 127.0.0.1:38080${NC}"
fi

# ============================================================================
# Test 2: Model availability
# ============================================================================
test_header "Model Availability"

MODEL_RESPONSE=$(curl -s --max-time "$TIMEOUT" "$LOCAL_LLM_URL/models" 2>/dev/null || echo '{}')
verbose "Model response: $MODEL_RESPONSE"

# Extract first model ID
MODEL_ID=$(echo "$MODEL_RESPONSE" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -n "$MODEL_ID" ]; then
    test_result 0 "Model found: $MODEL_ID"
else
    test_result 1 "No models available. Response was: $MODEL_RESPONSE"
fi

# ============================================================================
# Test 3: Chat completion endpoint
# ============================================================================
test_header "Chat Completion Endpoint"

# Use first available model or default
TARGET_MODEL="${MODEL_ID:-qwen2.5-coder-1.5b-instruct}"
verbose "Targeting model: $TARGET_MODEL"

PAYLOAD=$(cat <<EOF
{
  "model": "$TARGET_MODEL",
  "messages": [
    {"role": "user", "content": "Return only the word: hello"}
  ],
  "max_tokens": 10,
  "temperature": 0.1
}
EOF
)

verbose "Sending chat completion request..."
CHAT_RESPONSE=$(curl -s --max-time 15 \
  -X POST "$LOCAL_LLM_URL/chat/completions" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" 2>/dev/null || echo '{"error":"timeout"}')

verbose "Response: $CHAT_RESPONSE"

# Check for error
if echo "$CHAT_RESPONSE" | grep -q '"error"'; then
    ERROR_MSG=$(echo "$CHAT_RESPONSE" | grep -o '"error":"[^"]*' | cut -d'"' -f4)
    test_result 1 "Chat endpoint error: $ERROR_MSG"
elif echo "$CHAT_RESPONSE" | grep -q '"choices"'; then
    # Extract response content
    CONTENT=$(echo "$CHAT_RESPONSE" | grep -o '"content":"[^"]*' | head -1 | cut -d'"' -f4)
    test_result 0 "Chat completion successful"
    echo "  Generated: \"$CONTENT\""
else
    test_result 1 "Unexpected response format: $CHAT_RESPONSE"
fi

# ============================================================================
# Test 4: Code completion (practical use case)
# ============================================================================
test_header "Code Completion (Practical)"

CODE_PAYLOAD=$(cat <<EOF
{
  "model": "$TARGET_MODEL",
  "messages": [
    {"role": "user", "content": "Complete this Rust function: fn add(a: i32, b: i32) -> i32 {"}
  ],
  "max_tokens": 50,
  "temperature": 0.1
}
EOF
)

verbose "Sending code completion request..."
CODE_RESPONSE=$(curl -s --max-time 15 \
  -X POST "$LOCAL_LLM_URL/chat/completions" \
  -H "Content-Type: application/json" \
  -d "$CODE_PAYLOAD" 2>/dev/null || echo '{}')

verbose "Response: $CODE_RESPONSE"

if echo "$CODE_RESPONSE" | grep -q '"choices"'; then
    CODE_OUTPUT=$(echo "$CODE_RESPONSE" | grep -o '"content":"[^"]*' | head -1 | cut -d'"' -f4)
    # Check if response contains valid code pattern
    if echo "$CODE_OUTPUT" | grep -q 'a.*b'; then
        test_result 0 "Code completion working"
        echo "  Generated: \"$CODE_OUTPUT\""
    else
        test_result 1 "Code completion did not return expected pattern"
        echo "  Generated: \"$CODE_OUTPUT\""
    fi
else
    test_result 1 "Code completion failed"
fi

# ============================================================================
# Test 5: Streaming endpoint (optional but useful)
# ============================================================================
test_header "Streaming Endpoint (Optional)"

verbose "Testing stream endpoint..."
STREAM_RESPONSE=$(curl -s --max-time 5 \
  -X POST "$LOCAL_LLM_URL/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"$TARGET_MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"stream\":true,\"max_tokens\":5}" \
  2>/dev/null | head -1)

if echo "$STREAM_RESPONSE" | grep -q '"delta"'; then
    test_result 0 "Streaming endpoint available"
else
    test_result 1 "Streaming not available (non-critical)"
fi

# ============================================================================
# Test 6: Performance baseline
# ============================================================================
test_header "Performance Baseline"

START=$(date +%s%N)
PERF_RESPONSE=$(curl -s --max-time 30 \
  -X POST "$LOCAL_LLM_URL/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"$TARGET_MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"write: fn main() {\"}],\"max_tokens\":20,\"temperature\":0}" \
  2>/dev/null || echo '{}')
END=$(date +%s%N)

ELAPSED=$(( (END - START) / 1000000 ))  # Convert to milliseconds
ELAPSED_SEC=$(echo "scale=2; $ELAPSED / 1000" | bc)

if echo "$PERF_RESPONSE" | grep -q '"choices"'; then
    if [ "$ELAPSED" -lt 30000 ]; then
        test_result 0 "Performance acceptable: ${ELAPSED_SEC}ms"
    else
        test_result 1 "Performance slow: ${ELAPSED_SEC}ms (threshold: 30s)"
    fi
else
    test_result 1 "Performance test failed"
fi

# ============================================================================
# Summary Report
# ============================================================================
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    TEST SUMMARY REPORT                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
TOTAL=$((TESTS_PASSED + TESTS_FAILED))
PASS_RATE=$((TESTS_PASSED * 100 / TOTAL))
echo "  Pass rate: $PASS_RATE% ($TESTS_PASSED/$TOTAL)"

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo -e "\n${GREEN}✓ All tests passed!${NC}"
    echo "  Local LLM editor integration is operational."
else
    echo -e "\n${YELLOW}⚠ Some tests failed.${NC}"
    echo "  Please verify:"
    echo "  1. llama-server is running"
    echo "  2. Port 38080 is accessible"
    echo "  3. Model file is loaded correctly"
fi

echo ""
echo "Configuration:"
echo "  Server URL: $LOCAL_LLM_URL"
echo "  Model: $TARGET_MODEL"
echo "  Timeout: ${TIMEOUT}s"
echo ""

# Exit with appropriate code
[ "$TESTS_FAILED" -eq 0 ] && exit 0 || exit 1
