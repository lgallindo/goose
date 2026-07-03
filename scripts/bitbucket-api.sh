#!/bin/bash
# scripts/bitbucket-api.sh
# Bitbucket API wrapper for MCP integration
# Direct API calls to Bitbucket via curl (no Python/MCP overhead)
# Usage: source ~/.bashrc && source scripts/bitbucket-api.sh && bitbucket_list_workspaces

set -e

# Configuration (load from environment)
BITBUCKET_HOST="${BITBUCKET_HOST:-bitbucket.org}"
BITBUCKET_URL="${BITBUCKET_URL:-https://api.bitbucket.org/2.0}"
BITBUCKET_TOKEN="${BITBUCKET_SCOPED_TOKEN}"  # Use BITBUCKET_SCOPED_TOKEN from ~/.bashrc

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_success() { echo -e "${GREEN}[✓]${NC} $*" >&2; }
log_info() { echo -e "${BLUE}[INFO]${NC} $*" >&2; }

# Validate token
if [[ -z "$BITBUCKET_TOKEN" ]]; then
    log_error "BITBUCKET_SCOPED_TOKEN environment variable not set"
    log_info "Load credentials: source ~/.bashrc"
    return 1
fi

# Helper: Make API call (Bitbucket uses Bearer token)
bitbucket_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    
    local url="${BITBUCKET_URL}${endpoint}"
    
    local curl_opts=(
        -s
        -X "$method"
        -H "Authorization: Bearer ${BITBUCKET_TOKEN}"
        -H "Content-Type: application/json"
    )
    
    if [[ -n "$data" ]]; then
        curl_opts+=(-d "$data")
    fi
    
    curl "${curl_opts[@]}" "$url"
}

# Tool: List workspaces (teams)
bitbucket_list_workspaces() {
    log_info "Fetching Bitbucket workspaces"
    
    bitbucket_api_call GET "/workspaces" | jq -r '.values[] | "\(.slug): \(.name)"'
}

# Tool: List repositories in workspace
bitbucket_list_repositories() {
    local workspace="${1}"
    
    if [[ -z "$workspace" ]]; then
        log_error "Usage: bitbucket_list_repositories <workspace>"
        return 1
    fi
    
    log_info "Fetching repositories in workspace: $workspace"
    
    bitbucket_api_call GET "/repositories/${workspace}" | jq -r '.values[] | "\(.slug): \(.name)"'
}

# Tool: Get repository details
bitbucket_get_repository() {
    local workspace="$1"
    local repo_slug="$2"
    
    if [[ -z "$workspace" ]] || [[ -z "$repo_slug" ]]; then
        log_error "Usage: bitbucket_get_repository <workspace> <repo_slug>"
        return 1
    fi
    
    log_info "Fetching repository: $workspace/$repo_slug"
    
    bitbucket_api_call GET "/repositories/${workspace}/${repo_slug}"
}

# Tool: List issues in repository
bitbucket_list_issues() {
    local workspace="$1"
    local repo_slug="$2"
    local state="${3:-new}"  # new, on hold, resolved, duplicate, wontfix, closed, all
    
    if [[ -z "$workspace" ]] || [[ -z "$repo_slug" ]]; then
        log_error "Usage: bitbucket_list_issues <workspace> <repo_slug> [state]"
        return 1
    fi
    
    log_info "Fetching issues (state: $state) in $workspace/$repo_slug"
    
    # Bitbucket uses /issues endpoint
    bitbucket_api_call GET "/repositories/${workspace}/${repo_slug}/issues?state=${state}" | jq -r '.values[] | "\(.id): \(.title) (\(.state))"'
}

# Tool: Get issue details
bitbucket_get_issue() {
    local workspace="$1"
    local repo_slug="$2"
    local issue_id="$3"
    
    if [[ -z "$workspace" ]] || [[ -z "$repo_slug" ]] || [[ -z "$issue_id" ]]; then
        log_error "Usage: bitbucket_get_issue <workspace> <repo_slug> <issue_id>"
        return 1
    fi
    
    log_info "Fetching issue $issue_id in $workspace/$repo_slug"
    
    bitbucket_api_call GET "/repositories/${workspace}/${repo_slug}/issues/${issue_id}"
}

# Tool: Create issue
bitbucket_create_issue() {
    local workspace="$1"
    local repo_slug="$2"
    local title="$3"
    local description="${4:-}"
    
    if [[ -z "$workspace" ]] || [[ -z "$repo_slug" ]] || [[ -z "$title" ]]; then
        log_error "Usage: bitbucket_create_issue <workspace> <repo_slug> <title> [description]"
        return 1
    fi
    
    local data="{\"title\":\"${title}\",\"kind\":\"bug\""
    if [[ -n "$description" ]]; then
        data+=",\"content\":{\"raw\":\"${description}\"}"
    fi
    data+="}"
    
    log_info "Creating issue in $workspace/$repo_slug: $title"
    
    bitbucket_api_call POST "/repositories/${workspace}/${repo_slug}/issues" "$data"
}

# Tool: Update issue
bitbucket_update_issue() {
    local workspace="$1"
    local repo_slug="$2"
    local issue_id="$3"
    
    if [[ -z "$workspace" ]] || [[ -z "$repo_slug" ]] || [[ -z "$issue_id" ]]; then
        log_error "Usage: bitbucket_update_issue <workspace> <repo_slug> <issue_id> <json_updates>"
        log_info "Example: bitbucket_update_issue myspace myrepo 1 '{\"state\":\"resolved\"}'"
        return 1
    fi
    
    local updates="${4:-}"
    if [[ -z "$updates" ]]; then
        log_error "Updates JSON required"
        return 1
    fi
    
    log_info "Updating issue $issue_id in $workspace/$repo_slug"
    
    bitbucket_api_call PUT "/repositories/${workspace}/${repo_slug}/issues/${issue_id}" "$updates"
}

# Tool: List pull requests
bitbucket_list_pull_requests() {
    local workspace="$1"
    local repo_slug="$2"
    local state="${3:-OPEN}"  # OPEN, MERGED, DECLINED, SUPERSEDED
    
    if [[ -z "$workspace" ]] || [[ -z "$repo_slug" ]]; then
        log_error "Usage: bitbucket_list_pull_requests <workspace> <repo_slug> [state]"
        return 1
    fi
    
    log_info "Fetching pull requests (state: $state) in $workspace/$repo_slug"
    
    bitbucket_api_call GET "/repositories/${workspace}/${repo_slug}/pullrequests?state=${state}" | jq -r '.values[] | "\(.id): \(.title) (\(.state))"'
}

# Tool: Get user info
bitbucket_get_user() {
    log_info "Fetching current user info"
    
    bitbucket_api_call GET "/user"
}

# Tool: List teams/groups
bitbucket_list_teams() {
    local workspace="${1}"
    
    if [[ -z "$workspace" ]]; then
        log_error "Usage: bitbucket_list_teams <workspace>"
        return 1
    fi
    
    log_info "Fetching teams in workspace: $workspace"
    
    bitbucket_api_call GET "/workspaces/${workspace}/teams" | jq -r '.values[] | "\(.username): \(.display_name)"'
}

# Tool: List commits in repository
bitbucket_list_commits() {
    local workspace="$1"
    local repo_slug="$2"
    local branch="${3:-master}"
    
    if [[ -z "$workspace" ]] || [[ -z "$repo_slug" ]]; then
        log_error "Usage: bitbucket_list_commits <workspace> <repo_slug> [branch]"
        return 1
    fi
    
    log_info "Fetching recent commits on $branch in $workspace/$repo_slug"
    
    bitbucket_api_call GET "/repositories/${workspace}/${repo_slug}/commits/${branch}" | jq -r '.values[] | "\(.hash[0:8]): \(.message)"' | head -10
}

# Tool: Test connection
bitbucket_test_connection() {
    log_info "Testing Bitbucket connection"
    
    local response=$(bitbucket_api_call GET "/user")
    
    if echo "$response" | jq empty 2>/dev/null; then
        local username=$(echo "$response" | jq -r '.username')
        log_success "Connected to Bitbucket as: $username"
        return 0
    else
        log_error "Connection failed"
        echo "$response" >&2
        return 1
    fi
}

# Display available functions
bitbucket_help() {
    cat <<EOF
${BLUE}Bitbucket API Wrapper for goose MCP Integration${NC}

${GREEN}Available Functions:${NC}

  bitbucket_test_connection
    Test connection to Bitbucket

  bitbucket_list_workspaces
    List all workspaces/teams

  bitbucket_list_repositories <workspace>
    List repositories in a workspace

  bitbucket_get_repository <workspace> <repo_slug>
    Get repository details

  bitbucket_list_issues <workspace> <repo_slug> [state]
    List issues (state: new, on hold, resolved, duplicate, wontfix, closed)
    Default state: new

  bitbucket_get_issue <workspace> <repo_slug> <issue_id>
    Get issue details

  bitbucket_create_issue <workspace> <repo_slug> <title> [description]
    Create new issue

  bitbucket_update_issue <workspace> <repo_slug> <issue_id> <json_updates>
    Update issue
    Example: bitbucket_update_issue myws myrepo 1 '{"state":"resolved"}'

  bitbucket_list_pull_requests <workspace> <repo_slug> [state]
    List pull requests (state: OPEN, MERGED, DECLINED, SUPERSEDED)
    Default state: OPEN

  bitbucket_list_commits <workspace> <repo_slug> [branch]
    List recent commits (default branch: master)

  bitbucket_list_teams <workspace>
    List teams in workspace

  bitbucket_get_user
    Get current user info

  bitbucket_help
    Display this help message

${YELLOW}Setup:${NC}
  1. Load credentials: source ~/.bashrc
  2. Source this script: source scripts/bitbucket-api.sh
  3. Call functions: bitbucket_list_workspaces

${YELLOW}Environment Variables:${NC}
  BITBUCKET_URL              Bitbucket API base URL (default: https://api.bitbucket.org/2.0)
  BITBUCKET_SCOPED_TOKEN    OAuth token (required, loaded from ~/.bashrc)

EOF
}

log_success "Bitbucket API wrapper loaded"
log_info "Run 'bitbucket_help' for available commands"
