# GitLab MCP Server Setup & Deployment

**Status**: ✅ Ready for Agent Integration  
**Branch**: origin/close-up-and-personal  
**Last Updated**: 2026-07-04

---

## Quick Start

```bash
# 1. Load credentials
source ~/.bashrc

# 2. Source the GitLab wrapper
source scripts/gitlab-api.sh

# 3. Test connection
gitlab_test_connection

# 4. List milestones
gitlab_list_milestones "sistemas/tjpeia"

# 5. Get milestone issues
gitlab_list_milestone_issues "sistemas/tjpeia" "13"
```

---

## Authentication

**Token**: `$GITLAB_PAT` (Personal Access Token, stored in ~/.bashrc)  
**Required Scopes**: `api`, `read_api`, `read_user`  
**Instance**: https://gitlab.cloud.tjpe.jus.br  
**⚠️ CRITICAL**: Never commit token to repository; use environment variables only

---

## Available Commands

### Workspace & Milestone Management
```bash
# List all milestones in a group
gitlab_list_milestones "sistemas/tjpeia"

# Get milestone details (dates, progress)
gitlab_get_milestone "sistemas/tjpeia" "13"

# List issues in a milestone
gitlab_list_milestone_issues "sistemas/tjpeia" "13"

# Search issues across group
gitlab_search_issues "sistemas/tjpeia" "state:open"
```

### Issue Tracking
```bash
# List all issues in a group (no milestone filter)
gitlab_list_milestones "sistemas/tjpeia"  # See milestone IDs first

# Get issue details
gitlab_get_issue PROJECT_ID ISSUE_IID

# Create new issue
gitlab_create_issue PROJECT_ID "Issue Title" "Issue Description"

# Update issue (state, description)
gitlab_update_issue PROJECT_ID ISSUE_IID '{"state":"closed"}'
```

### Project Discovery
```bash
# List all projects in group
gitlab_list_projects "sistemas"

# List projects with more details
gitlab_list_projects "sistemas/tjpeia"
```

### Pull/Merge Request Management
```bash
# List merge requests
gitlab_list_merge_requests PROJECT_ID "opened"  # opened, closed, merged, all

# List commits on a branch
gitlab_list_commits PROJECT_ID BRANCH
```

### User & Team Info
```bash
# Get current user
gitlab_get_user

# Get specific user
gitlab_get_user "username"
```

---

## Real-World Examples

### Tracking Prescrição Module Sprint

```bash
# List all active sprints
gitlab_list_milestones "sistemas/tjpeia"

# See what's in SPRINT 22/06 to 09/07 (milestone 13)
gitlab_list_milestone_issues "sistemas/tjpeia" "13"

# Update issue status when complete
gitlab_update_issue 155 30 '{"state":"closed","labels":["feature:complete"]}'
```

### Finding Related Work

```bash
# Search for open bugs
gitlab_search_issues "sistemas/tjpeia" "state:open AND labels:bug"

# Find PR-ready features
gitlab_search_issues "sistemas/tjpeia" "state:opened AND labels:ready-for-review"
```

---

## Integration with goose Agents

### For Agent Prompts

Include this snippet in agent briefings:

```
You have access to GitLab API via the wrapper at scripts/gitlab-api.sh.
Load it with: source ~/.bashrc && source scripts/gitlab-api.sh

Available functions:
- gitlab_list_milestone_issues(group, milestone_id)  → List issues
- gitlab_create_issue(project_id, title, description)  → Create ticket
- gitlab_update_issue(project_id, issue_iid, json_updates)  → Update status
- gitlab_list_merge_requests(project_id, state)  → Find open PRs
- gitlab_search_issues(group, query)  → Search issues
```

### For Agentic Workflows

Use in shell scripts:

```bash
#!/bin/bash
source ~/.bashrc
source scripts/gitlab-api.sh

# Get active milestone
ACTIVE_MILESTONE=$(gitlab_list_milestones "sistemas/tjpeia" | grep "active" | awk '{print $1}' | head -1)

# List issues
echo "Issues in milestone $ACTIVE_MILESTONE:"
gitlab_list_milestone_issues "sistemas/tjpeia" "$ACTIVE_MILESTONE"

# Create summary
ISSUE_COUNT=$(gitlab_list_milestone_issues "sistemas/tjpeia" "$ACTIVE_MILESTONE" | wc -l)
echo "Total issues: $ISSUE_COUNT"
```

---

## Troubleshooting

### Authentication Errors (401)

```bash
# Verify token is loaded
echo $GITLAB_PAT

# Test endpoint directly
curl -s -X GET "https://gitlab.cloud.tjpe.jus.br/api/v4/user" \
  -H "PRIVATE-TOKEN: ${GITLAB_PAT}" | jq .

# If 401: Check token scopes at
# https://gitlab.cloud.tjpe.jus.br/profile/personal_access_tokens
```

### 404 Errors on Group Endpoints

GitLab requires URL-encoding for group paths containing slashes:
- ✅ CORRECT: `gitlab_list_milestone_issues "sistemas/tjpeia" "13"`
- ❌ INCORRECT (manual): `/groups/sistemas/tjpeia/milestones` (needs encoding)

The wrapper handles encoding automatically with `jq @uri`.

### Rate Limiting

GitLab API rate limits: 600 requests per 10 minutes  
If hitting limits:
- Use pagination: `gitlab_api_call GET "/endpoint?per_page=50&page=2"`
- Cache results between calls
- Add delays between bulk operations

---

## Next Steps

1. **Agent Integration**: Include `scripts/gitlab-api.sh` sourcing in agent prompts
2. **Workflow Automation**: Build agentic shell scripts using the wrapper functions
3. **Phase 2**: Implement timestamp-based KV store for secret templating (scheduled week 2)
4. **Monitoring**: Set up alerts for milestone completions using `gitlab_update_issue` callbacks

---

## Reference: Function Signatures

| Function | Parameters | Returns | Example |
|----------|-----------|---------|---------|
| `gitlab_test_connection` | None | Exit code 0/1 | `gitlab_test_connection` |
| `gitlab_list_milestones` | `group_slug` | List of milestone ID:Title:State | `gitlab_list_milestones "sistemas"` |
| `gitlab_list_milestone_issues` | `group_slug`, `milestone_id` | List of Issue:Title:State | `gitlab_list_milestone_issues "sistemas/tjpeia" "13"` |
| `gitlab_get_milestone` | `group_slug`, `milestone_id` | Full JSON milestone object | `gitlab_get_milestone "sistemas/tjpeia" "13"` |
| `gitlab_create_issue` | `project_id`, `title`, `[description]` | JSON issue object | `gitlab_create_issue 155 "Bug" "Details"` |
| `gitlab_update_issue` | `project_id`, `issue_iid`, `json_updates` | Updated JSON object | `gitlab_update_issue 155 30 '{"state":"closed"}'` |
| `gitlab_search_issues` | `group_slug`, `query` | Filtered issue list | `gitlab_search_issues "sistemas/tjpeia" "state:open"` |
| `gitlab_list_projects` | `group_slug` | Project list | `gitlab_list_projects "sistemas"` |
| `gitlab_list_merge_requests` | `project_id`, `[state]` | MR list | `gitlab_list_merge_requests 155 "opened"` |

---

## Security Notes

- ✅ Credentials in `~/.bashrc` only (never committed)
- ✅ Token scopes follow principle of least privilege (api, read_api, read_user)
- ✅ No hardcoded URLs in scripts (uses `$GITLAB_URL` env var)
- ✅ All API calls use HTTPS with token in header (not URL)
- ⚠️ Ensure token rotation every 90 days
