#!/bin/bash
# scripts/github-api.sh
# GitHub API wrapper for MCP integration
# Direct API calls to GitHub via curl (no Python/MCP overhead)
# Usage: source ~/.bashrc && source scripts/github-api.sh && github_list_repos "lgallindo"

set -e

# Configuration (load from environment)
GITHUB_HOST="${GITHUB_HOST:-github.com}"
GITHUB_URL="${GITHUB_URL:-https://api.github.com}"
GITHUB_TOKEN="${GITHUB_TOKEN}"  # Use GITHUB_TOKEN from ~/.bashrc

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
if [[ -z "$GITHUB_TOKEN" ]]; then
    log_error "GITHUB_TOKEN environment variable not set"
    log_info "Load credentials: source ~/.bashrc"
    return 1
fi

# Helper: Make API call (GitHub uses Bearer token or Basic auth)
github_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    
    local url="${GITHUB_URL}${endpoint}"
    
    local curl_opts=(
        -s
        -X "$method"
        -H "Authorization: Bearer ${GITHUB_TOKEN}"
        -H "Accept: application/vnd.github+json"
        -H "X-GitHub-Api-Version: 2022-11-28"
    )
    
    if [[ -n "$data" ]]; then
        curl_opts+=(-H "Content-Type: application/json" -d "$data")
    fi
    
    curl "${curl_opts[@]}" "$url"
}

# Tool: Get authenticated user
github_get_user() {
    log_info "Fetching current user info"
    
    github_api_call GET "/user"
}

# Tool: List repositories
github_list_repos() {
    local owner="${1}"
    local filter="${2:-}"  # owner, public, private, all
    
    if [[ -z "$owner" ]]; then
        log_info "Fetching current user repositories"
        github_api_call GET "/user/repos?per_page=100" | jq -r '.[] | "\(.name): \(.description // "N/A") [\(.visibility)]"'
    else
        log_info "Fetching repositories for user/org: $owner"
        github_api_call GET "/users/${owner}/repos?per_page=100" | jq -r '.[] | "\(.name): \(.description // "N/A")"'
    fi
}

# Tool: Get repository details
github_get_repo() {
    local owner="$1"
    local repo="$2"
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]]; then
        log_error "Usage: github_get_repo <owner> <repo>"
        return 1
    fi
    
    log_info "Fetching repository: $owner/$repo"
    
    github_api_call GET "/repos/${owner}/${repo}"
}

# Tool: List issues
github_list_issues() {
    local owner="$1"
    local repo="$2"
    local state="${3:-open}"  # open, closed, all
    local labels="${4:-}"
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]]; then
        log_error "Usage: github_list_issues <owner> <repo> [state] [labels]"
        return 1
    fi
    
    log_info "Fetching issues (state: $state) in $owner/$repo"
    
    local endpoint="/repos/${owner}/${repo}/issues?state=${state}&per_page=100"
    if [[ -n "$labels" ]]; then
        endpoint+="&labels=${labels}"
    fi
    
    github_api_call GET "$endpoint" | jq -r '.[] | "\(.number): \(.title) [\(.state)]"'
}

# Tool: Get issue details
github_get_issue() {
    local owner="$1"
    local repo="$2"
    local issue_num="$3"
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]] || [[ -z "$issue_num" ]]; then
        log_error "Usage: github_get_issue <owner> <repo> <issue_num>"
        return 1
    fi
    
    log_info "Fetching issue #$issue_num in $owner/$repo"
    
    github_api_call GET "/repos/${owner}/${repo}/issues/${issue_num}"
}

# Tool: Create issue
github_create_issue() {
    local owner="$1"
    local repo="$2"
    local title="$3"
    local body="${4:-}"
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]] || [[ -z "$title" ]]; then
        log_error "Usage: github_create_issue <owner> <repo> <title> [body]"
        return 1
    fi
    
    local data="{\"title\":\"${title}\""
    if [[ -n "$body" ]]; then
        # Escape newlines and quotes for JSON
        body=$(echo "$body" | jq -Rs .)
        data+=",\"body\":${body}"
    fi
    data+="}"
    
    log_info "Creating issue in $owner/$repo: $title"
    
    github_api_call POST "/repos/${owner}/${repo}/issues" "$data"
}

# Tool: Update issue
github_update_issue() {
    local owner="$1"
    local repo="$2"
    local issue_num="$3"
    local state="${4:-}"  # open, closed
    local labels="${5:-}"
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]] || [[ -z "$issue_num" ]]; then
        log_error "Usage: github_update_issue <owner> <repo> <issue_num> [state] [labels]"
        return 1
    fi
    
    local data="{"
    if [[ -n "$state" ]]; then
        data+="\"state\":\"${state}\""
    fi
    if [[ -n "$labels" ]]; then
        if [[ -n "$state" ]]; then
            data+=","
        fi
        # Convert space-separated labels to JSON array
        local label_json=$(echo "$labels" | jq -Rs 'split(" ") | map(select(length > 0))')
        data+="\"labels\":${label_json}"
    fi
    data+="}"
    
    if [[ "$data" == "{}" ]]; then
        log_error "No updates provided"
        return 1
    fi
    
    log_info "Updating issue #$issue_num in $owner/$repo"
    
    github_api_call PATCH "/repos/${owner}/${repo}/issues/${issue_num}" "$data"
}

# Tool: Add comment to issue
github_add_comment() {
    local owner="$1"
    local repo="$2"
    local issue_num="$3"
    local body="$4"
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]] || [[ -z "$issue_num" ]] || [[ -z "$body" ]]; then
        log_error "Usage: github_add_comment <owner> <repo> <issue_num> <body>"
        return 1
    fi
    
    # Escape body for JSON
    body=$(echo "$body" | jq -Rs .)
    
    local data="{\"body\":${body}}"
    
    log_info "Adding comment to issue #$issue_num in $owner/$repo"
    
    github_api_call POST "/repos/${owner}/${repo}/issues/${issue_num}/comments" "$data"
}

# Tool: List pull requests
github_list_pull_requests() {
    local owner="$1"
    local repo="$2"
    local state="${3:-open}"  # open, closed, all
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]]; then
        log_error "Usage: github_list_pull_requests <owner> <repo> [state]"
        return 1
    fi
    
    log_info "Fetching pull requests (state: $state) in $owner/$repo"
    
    github_api_call GET "/repos/${owner}/${repo}/pulls?state=${state}&per_page=100" | jq -r '.[] | "\(.number): \(.title) [\(.state)]"'
}

# Tool: Get pull request details
github_get_pull_request() {
    local owner="$1"
    local repo="$2"
    local pr_num="$3"
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]] || [[ -z "$pr_num" ]]; then
        log_error "Usage: github_get_pull_request <owner> <repo> <pr_num>"
        return 1
    fi
    
    log_info "Fetching PR #$pr_num in $owner/$repo"
    
    github_api_call GET "/repos/${owner}/${repo}/pulls/${pr_num}"
}

# Tool: List commits
github_list_commits() {
    local owner="$1"
    local repo="$2"
    local ref="${3:-main}"  # branch, tag, or commit SHA
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]]; then
        log_error "Usage: github_list_commits <owner> <repo> [ref]"
        return 1
    fi
    
    log_info "Fetching recent commits on $ref in $owner/$repo"
    
    github_api_call GET "/repos/${owner}/${repo}/commits?sha=${ref}&per_page=20" | jq -r '.[] | "\(.sha[0:8]): \(.commit.message | split("\n")[0])"'
}

# Tool: List releases
github_list_releases() {
    local owner="$1"
    local repo="$2"
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]]; then
        log_error "Usage: github_list_releases <owner> <repo>"
        return 1
    fi
    
    log_info "Fetching releases in $owner/$repo"
    
    github_api_call GET "/repos/${owner}/${repo}/releases?per_page=50" | jq -r '.[] | "\(.tag_name): \(.name // "N/A") [draft: \(.draft), prerelease: \(.prerelease)]"'
}

# Tool: List workflows
github_list_workflows() {
    local owner="$1"
    local repo="$2"
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]]; then
        log_error "Usage: github_list_workflows <owner> <repo>"
        return 1
    fi
    
    log_info "Fetching workflows in $owner/$repo"
    
    github_api_call GET "/repos/${owner}/${repo}/actions/workflows?per_page=50" | jq -r '.workflows[] | "\(.name) (\(.state))"'
}

# Tool: Get latest workflow runs
github_list_workflow_runs() {
    local owner="$1"
    local repo="$2"
    local workflow_id="${3:-}"
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]]; then
        log_error "Usage: github_list_workflow_runs <owner> <repo> [workflow_id]"
        return 1
    fi
    
    local endpoint="/repos/${owner}/${repo}/actions/runs?per_page=20"
    if [[ -n "$workflow_id" ]]; then
        endpoint="/repos/${owner}/${repo}/actions/workflows/${workflow_id}/runs?per_page=20"
    fi
    
    log_info "Fetching workflow runs in $owner/$repo"
    
    github_api_call GET "$endpoint" | jq -r '.workflow_runs[] | "\(.id): \(.name) - \(.conclusion // "in_progress")"'
}

# Tool: Search repositories
github_search_repos() {
    local query="$1"
    
    if [[ -z "$query" ]]; then
        log_error "Usage: github_search_repos <query>"
        log_info "Example: github_search_repos 'language:rust topic:mcp'"
        return 1
    fi
    
    log_info "Searching repositories: $query"
    
    # URL encode the query
    local encoded_query=$(echo "$query" | jq -sRr @uri)
    
    github_api_call GET "/search/repositories?q=${encoded_query}&per_page=50" | jq -r '.items[] | "\(.full_name): \(.description // "N/A")"'
}

# Tool: Get repository tree (files)
github_list_files() {
    local owner="$1"
    local repo="$2"
    local path="${3:-}"
    local ref="${4:-main}"
    
    if [[ -z "$owner" ]] || [[ -z "$repo" ]]; then
        log_error "Usage: github_list_files <owner> <repo> [path] [ref]"
        return 1
    fi
    
    log_info "Fetching files in $owner/$repo/$path (ref: $ref)"
    
    github_api_call GET "/repos/${owner}/${repo}/contents/${path}?ref=${ref}" | jq -r '.[] | "\(.type): \(.name)"'
}

# Tool: Test connection
github_test_connection() {
    log_info "Testing GitHub connection"
    
    local response=$(github_api_call GET "/user")
    
    if echo "$response" | jq empty 2>/dev/null; then
        local username=$(echo "$response" | jq -r '.login')
        log_success "Connected to GitHub as: $username"
        return 0
    else
        log_error "Connection failed"
        echo "$response" >&2
        return 1
    fi
}

# Display available functions
github_help() {
    cat <<EOF
${BLUE}GitHub API Wrapper for goose MCP Integration${NC}

${GREEN}Available Functions:${NC}

  github_test_connection
    Test connection to GitHub

  github_get_user
    Get current authenticated user info

  github_list_repos [owner]
    List repositories (default: current user)
    Example: github_list_repos lgallindo

  github_get_repo <owner> <repo>
    Get repository details

  github_list_issues <owner> <repo> [state] [labels]
    List issues (state: open, closed, all)
    Example: github_list_issues lgallindo goose open "bug,help wanted"

  github_get_issue <owner> <repo> <issue_num>
    Get issue details

  github_create_issue <owner> <repo> <title> [body]
    Create new issue

  github_update_issue <owner> <repo> <issue_num> [state] [labels]
    Update issue state or labels
    Example: github_update_issue lgallindo goose 1 closed "bug,verified"

  github_add_comment <owner> <repo> <issue_num> <body>
    Add comment to issue

  github_list_pull_requests <owner> <repo> [state]
    List pull requests (state: open, closed, all)

  github_get_pull_request <owner> <repo> <pr_num>
    Get pull request details

  github_list_commits <owner> <repo> [ref]
    List recent commits (default ref: main)

  github_list_releases <owner> <repo>
    List releases

  github_list_workflows <owner> <repo>
    List GitHub Actions workflows

  github_list_workflow_runs <owner> <repo> [workflow_id]
    List recent workflow runs

  github_search_repos <query>
    Search public repositories
    Example: github_search_repos "language:rust topic:mcp"

  github_list_files <owner> <repo> [path] [ref]
    List files in repository (default ref: main)

  github_help
    Display this help message

${YELLOW}Setup:${NC}
  1. Load credentials: source ~/.bashrc
  2. Source this script: source scripts/github-api.sh
  3. Call functions: github_list_repos lgallindo

${YELLOW}Environment Variables:${NC}
  GITHUB_URL      GitHub API base URL (default: https://api.github.com)
  GITHUB_TOKEN    Personal access token (required, loaded from ~/.bashrc)
  GITHUB_HOST     GitHub hostname (default: github.com)

${YELLOW}Token Scopes Required:${NC}
  repo            Full control of private repositories
  gist            Create gists
  user            Read user profile data
  (minimum for read-only operations: public_repo, user)

EOF
}

log_success "GitHub API wrapper loaded"
log_info "Run 'github_help' for available commands"
