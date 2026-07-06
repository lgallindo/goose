#!/bin/bash
# scripts/start-mcp-servers.sh
# Deploy all MCP servers (GitHub, GitLab, Bitbucket)
# Usage: source ~/.bashrc && ./scripts/start-mcp-servers.sh [github|gitlab|bitbucket|all]

set -e

GITHUB_MCP_BIN="/home/lugatj/code/foss/github-mcp-server/github-mcp-server"
GOOSE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${GOOSE_ROOT}/.mcp-logs"
PID_DIR="${GOOSE_ROOT}/.mcp-pids"

# Create directories
mkdir -p "$LOG_DIR" "$PID_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $*" >&2; }
log_success() { echo -e "${GREEN}[✓]${NC} $*" >&2; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Start GitHub MCP Server
start_github_mcp() {
    log_info "Starting GitHub MCP Server..."
    
    # Verify binary exists
    if [[ ! -f "$GITHUB_MCP_BIN" ]]; then
        log_error "GitHub MCP binary not found at: $GITHUB_MCP_BIN"
        log_info "Building from source..."
        cd /home/lugatj/code/foss/github-mcp-server
        go build -o github-mcp-server cmd/github-mcp-server/main.go
        cd - > /dev/null
    fi
    
    # Check if already running
    if [[ -f "$PID_DIR/github-mcp.pid" ]]; then
        local old_pid=$(cat "$PID_DIR/github-mcp.pid")
        if kill -0 "$old_pid" 2>/dev/null; then
            log_warn "GitHub MCP already running (PID: $old_pid)"
            return 0
        fi
    fi
    
    # Verify token available
    if [[ -z "$GITHUB_TOKEN" ]]; then
        log_error "GITHUB_TOKEN environment variable not set"
        log_info "Load credentials: source ~/.bashrc"
        return 1
    fi
    
    # Start server
    nohup "$GITHUB_MCP_BIN" stdio > "$LOG_DIR/github-mcp.log" 2>&1 &
    local pid=$!
    echo "$pid" > "$PID_DIR/github-mcp.pid"
    
    sleep 1
    
    if kill -0 "$pid" 2>/dev/null; then
        log_success "GitHub MCP started (PID: $pid)"
        return 0
    else
        log_error "GitHub MCP failed to start"
        cat "$LOG_DIR/github-mcp.log" >&2
        return 1
    fi
}

# Start GitLab Python MCP (Option 2)
start_gitlab_python_mcp() {
    log_info "Starting GitLab Python MCP Server (Option 2)..."
    
    local gitlab_mcp="$GOOSE_ROOT/tools/gitlab_mcp.py"
    
    if [[ ! -f "$gitlab_mcp" ]]; then
        log_error "GitLab MCP Python script not found: $gitlab_mcp"
        log_info "Need to implement tools/gitlab_mcp.py first"
        return 1
    fi
    
    if [[ -z "$GITLAB_PAT" ]]; then
        log_error "GITLAB_PAT environment variable not set"
        log_info "Load credentials: source ~/.bashrc"
        return 1
    fi
    
    nohup python3 "$gitlab_mcp" > "$LOG_DIR/gitlab-mcp-python.log" 2>&1 &
    local pid=$!
    echo "$pid" > "$PID_DIR/gitlab-mcp-python.pid"
    
    sleep 1
    
    if kill -0 "$pid" 2>/dev/null; then
        log_success "GitLab Python MCP started (PID: $pid)"
        return 0
    else
        log_error "GitLab Python MCP failed to start"
        cat "$LOG_DIR/gitlab-mcp-python.log" >&2
        return 1
    fi
}

# Start Bitbucket Python MCP
start_bitbucket_python_mcp() {
    log_info "Starting Bitbucket Python MCP Server..."
    
    local bitbucket_mcp="$GOOSE_ROOT/tools/bitbucket_mcp.py"
    
    if [[ ! -f "$bitbucket_mcp" ]]; then
        log_error "Bitbucket MCP Python script not found: $bitbucket_mcp"
        log_info "Need to implement tools/bitbucket_mcp.py first"
        return 1
    fi
    
    if [[ -z "$BITBUCKET_SCOPED_TOKEN" ]]; then
        log_error "BITBUCKET_SCOPED_TOKEN environment variable not set"
        log_info "Load credentials: source ~/.bashrc"
        return 1
    fi
    
    nohup python3 "$bitbucket_mcp" > "$LOG_DIR/bitbucket-mcp.log" 2>&1 &
    local pid=$!
    echo "$pid" > "$PID_DIR/bitbucket-mcp.pid"
    
    sleep 1
    
    if kill -0 "$pid" 2>/dev/null; then
        log_success "Bitbucket Python MCP started (PID: $pid)"
        return 0
    else
        log_error "Bitbucket Python MCP failed to start"
        cat "$LOG_DIR/bitbucket-mcp.log" >&2
        return 1
    fi
}

# Status check
status_all() {
    log_info "MCP Servers Status:"
    echo ""
    
    for server in github gitlab-python bitbucket; do
        local pid_file="$PID_DIR/${server}-mcp.pid"
        if [[ -f "$pid_file" ]]; then
            local pid=$(cat "$pid_file")
            if kill -0 "$pid" 2>/dev/null; then
                log_success "$server MCP: Running (PID: $pid)"
            else
                log_error "$server MCP: Dead (stale PID: $pid)"
            fi
        else
            log_warn "$server MCP: Not started"
        fi
    done
    
    echo ""
    log_info "Logs available at: $LOG_DIR/"
}

# Stop servers
stop_all() {
    log_info "Stopping all MCP servers..."
    
    for pid_file in "$PID_DIR"/*.pid; do
        if [[ -f "$pid_file" ]]; then
            local pid=$(cat "$pid_file")
            if kill -0 "$pid" 2>/dev/null; then
                kill "$pid"
                log_success "Stopped PID: $pid"
            fi
        fi
    done
    
    rm -f "$PID_DIR"/*.pid
}

# Main
main() {
    local target="${1:-all}"
    
    case "$target" in
        github)
            start_github_mcp
            ;;
        gitlab)
            start_gitlab_python_mcp
            ;;
        bitbucket)
            start_bitbucket_python_mcp
            ;;
        all)
            start_github_mcp || log_warn "GitHub MCP startup had issues"
            start_gitlab_python_mcp || log_warn "GitLab MCP startup had issues"
            start_bitbucket_python_mcp || log_warn "Bitbucket MCP startup had issues"
            sleep 1
            status_all
            ;;
        status)
            status_all
            ;;
        stop)
            stop_all
            ;;
        *)
            log_error "Unknown target: $target"
            echo "Usage: $0 [github|gitlab|bitbucket|all|status|stop]"
            return 1
            ;;
    esac
}

main "$@"
