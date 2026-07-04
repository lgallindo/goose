#!/bin/bash
# scripts/gitlab-api.sh
# GitLab API wrapper for MCP integration
# Direct API calls to GitLab via curl (no Python/MCP overhead)
# Usage: source ~/.bashrc && source scripts/gitlab-api.sh && gitlab_list_milestone_issues "sistemas/tjpeia" "5"

set -e

# Configuration (load from environment)
GITLAB_URL="${GITLAB_URL:-https://gitlab.cloud.tjpe.jus.br}"
GITLAB_TOKEN="${GITLAB_PAT}"  # Use GITLAB_PAT from ~/.bashrc

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
if [[ -z "$GITLAB_TOKEN" ]]; then
    log_error "GITLAB_PAT environment variable not set"
    log_info "Load credentials: source ~/.bashrc"
    return 1
fi

# Helper: Make API call
gitlab_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    
    local url="${GITLAB_URL}/api/v4${endpoint}"
    
    local curl_opts=(
        -s
        -X "$method"
        -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}"
        -H "Content-Type: application/json"
    )
    
    if [[ -n "$data" ]]; then
        curl_opts+=(-d "$data")
    fi
    
    curl "${curl_opts[@]}" "$url"
}

# Tool: List milestones in a group
gitlab_list_milestones() {
    local group_slug="${1:-sistemas/tjpeia}"
    local encoded_slug=$(echo -n "$group_slug" | jq -sRr @uri)
    
    log_info "Fetching milestones for group: $group_slug"
    
    gitlab_api_call GET "/groups/${encoded_slug}/milestones" | jq -r '.[] | "\(.id): \(.title) (\(.state))"'
}

# Tool: List issues in a group milestone
gitlab_list_milestone_issues() {
    local group_slug="${1:-sistemas/tjpeia}"
    local milestone_id="${2:-13}"
    local encoded_slug=$(echo -n "$group_slug" | jq -sRr @uri)
    
    log_info "Fetching issues for milestone $milestone_id in group: $group_slug"
    
    gitlab_api_call GET "/groups/${encoded_slug}/milestones/${milestone_id}/issues" | jq -r '.[] | "\(.iid): \(.title) (\(.state))"'
}

# Tool: Get full details of a milestone
gitlab_get_milestone() {
    local group_slug="${1:-sistemas/tjpeia}"
    local milestone_id="${2:-13}"
    local encoded_slug=$(echo -n "$group_slug" | jq -sRr @uri)
    
    log_info "Fetching milestone details: $milestone_id in $group_slug"
    
    gitlab_api_call GET "/groups/${encoded_slug}/milestones/${milestone_id}"
}

# Tool: Get issue details
gitlab_get_issue() {
    local project_id="$1"
    local issue_iid="$2"
    
    if [[ -z "$project_id" ]] || [[ -z "$issue_iid" ]]; then
        log_error "Usage: gitlab_get_issue <project_id> <issue_iid>"
        return 1
    fi
    
    log_info "Fetching issue $issue_iid in project $project_id"
    
    gitlab_api_call GET "/projects/${project_id}/issues/${issue_iid}"
}

# Tool: Update issue
gitlab_update_issue() {
    local project_id="$1"
    local issue_iid="$2"
    
    if [[ -z "$project_id" ]] || [[ -z "$issue_iid" ]]; then
        log_error "Usage: gitlab_update_issue <project_id> <issue_iid> <json_updates>"
        log_info "Example: gitlab_update_issue 123 45 '{\"state\":\"closed\",\"description\":\"Updated\"}'"
        return 1
    fi
    
    # Read updates from stdin if available, otherwise use arg 3
    local updates="${3:-}"
    if [[ -z "$updates" ]]; then
        log_error "Updates JSON required"
        return 1
    fi
    
    log_info "Updating issue $issue_iid in project $project_id"
    
    gitlab_api_call PUT "/projects/${project_id}/issues/${issue_iid}" "$updates"
}

# Tool: Create issue
gitlab_create_issue() {
    local project_id="$1"
    local title="$2"
    local description="${3:-}"
    
    if [[ -z "$project_id" ]] || [[ -z "$title" ]]; then
        log_error "Usage: gitlab_create_issue <project_id> <title> [description]"
        return 1
    fi
    
    local data="{\"title\":\"${title}\""
    if [[ -n "$description" ]]; then
        data+=",\"description\":\"${description}\""
    fi
    data+="}"
    
    log_info "Creating issue in project $project_id: $title"
    
    gitlab_api_call POST "/projects/${project_id}/issues" "$data"
}

# Tool: List projects
gitlab_list_projects() {
    local group_slug="${1:-sistemas}"
    local encoded_slug=$(echo -n "$group_slug" | jq -sRr @uri)
    
    log_info "Fetching projects in group: $group_slug"
    
    gitlab_api_call GET "/groups/${encoded_slug}/projects" | jq -r '.[] | "\(.id): \(.name_with_namespace)"'
}

# Tool: Search issues across group
gitlab_search_issues() {
    local group_slug="${1:-sistemas/tjpeia}"
    local query="${2:-}"
    local encoded_slug=$(echo -n "$group_slug" | jq -sRr @uri)
    
    if [[ -z "$query" ]]; then
        log_error "Usage: gitlab_search_issues <group_slug> <query>"
        log_info "Example: gitlab_search_issues sistemas/tjpeia 'bug AND state:open'"
        return 1
    fi
    
    log_info "Searching issues in group $group_slug with query: $query"
    
    gitlab_api_call GET "/groups/${encoded_slug}/issues?search=${query}" | jq -r '.[] | "\(.iid): \(.title) (\(.state))"'
}

# Tool: List merge requests
gitlab_list_merge_requests() {
    local project_id="$1"
    local state="${2:-opened}"  # opened, closed, merged, all
    
    if [[ -z "$project_id" ]]; then
        log_error "Usage: gitlab_list_merge_requests <project_id> [state]"
        return 1
    fi
    
    log_info "Fetching merge requests (state: $state) for project $project_id"
    
    gitlab_api_call GET "/projects/${project_id}/merge_requests?state=${state}" | jq -r '.[] | "\(.iid): \(.title) (\(.state))"'
}

# Tool: Get user info
gitlab_get_user() {
    local username="${1:-}"
    
    if [[ -n "$username" ]]; then
        log_info "Fetching GitLab user: $username"
        gitlab_api_call GET "/users?username=${username}"
    else
        log_info "Fetching current user info"
        gitlab_api_call GET "/user"
    fi
}

# Tool: Test connection
gitlab_test_connection() {
    log_info "Testing GitLab connection to: $GITLAB_URL"
    
    local response=$(gitlab_api_call GET "/version")
    
    if echo "$response" | jq empty 2>/dev/null; then
        local version=$(echo "$response" | jq -r '.version')
        log_success "Connected to GitLab version: $version"
        return 0
    else
        log_error "Connection failed"
        echo "$response" >&2
        return 1
    fi
}

# Display available functions
gitlab_help() {
    cat <<EOF
${BLUE}GitLab API Wrapper for goose MCP Integration${NC}

${GREEN}Available Functions:${NC}

  gitlab_test_connection
    Test connection to GitLab instance

  gitlab_list_milestones [group_slug]
    List milestones in a group
    Default group: sistemas/tjpeia
    Example: gitlab_list_milestones "sistemas/tjpeia"

  gitlab_list_milestone_issues [group_slug] [milestone_id]
    List issues in a group milestone
    Default: sistemas/tjpeia milestone 5
    Example: gitlab_list_milestone_issues "sistemas/tjpeia" "5"

  gitlab_get_milestone [group_slug] [milestone_id]
    Get full milestone details

  gitlab_list_projects [group_slug]
    List projects in a group

  gitlab_get_issue <project_id> <issue_iid>
    Get issue details

  gitlab_create_issue <project_id> <title> [description]
    Create new issue

  gitlab_update_issue <project_id> <issue_iid> <json_updates>
    Update issue
    Example: gitlab_update_issue 123 45 '{"state":"closed"}'

  gitlab_list_merge_requests <project_id> [state]
    List merge requests (state: opened, closed, merged, all)

  gitlab_search_issues [group_slug] <query>
    Search issues in group

  gitlab_get_user [username]
    Get current user or specific user info

  gitlab_help
    Display this help message

${YELLOW}Setup:${NC}
  1. Load credentials: source ~/.bashrc
  2. Source this script: source scripts/gitlab-api.sh
  3. Call functions: gitlab_list_milestone_issues

${YELLOW}Environment Variables:${NC}
  GITLAB_URL       GitLab instance URL (default: https://gitlab.cloud.tjpe.jus.br)
  GITLAB_PAT       Personal access token (required, loaded from ~/.bashrc)

EOF
}

log_success "GitLab API wrapper loaded"
log_info "Run 'gitlab_help' for available commands"
