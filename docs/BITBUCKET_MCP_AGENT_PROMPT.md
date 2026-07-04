# Bitbucket MCP Server Setup & Deployment

**Status**: ⚠️ Ready for Integration (Token Activation Pending)  
**Branch**: origin/close-up-and-personal  
**Last Updated**: 2026-07-04

---

## Quick Start

```bash
# 1. Load credentials
source ~/.bashrc

# 2. Source the Bitbucket wrapper
source scripts/bitbucket-api.sh

# 3. Test connection
bitbucket_test_connection

# 4. List workspaces
bitbucket_list_workspaces

# 5. List repositories in workspace
bitbucket_list_repositories "YOUR_WORKSPACE"
```

---

## Authentication

**Token**: `$BITBUCKET_SCOPED_TOKEN` (OAuth token, stored in ~/.bashrc)  
**Required Scopes**: 
- **Read**: `read:workspace`, `read:repository`, `read:issue`, `read:pullrequest`, `read:me`, `read:account`
- **Write**: `write:repository`, `write:issue`, `write:pullrequest`
- **Admin**: `admin:repository`, `admin:workspace`

**Instance**: https://api.bitbucket.org/2.0  
**Auth Method**: Bearer token (in Authorization header)  
**⚠️ CRITICAL**: Never commit token to repository; use environment variables only

### Token Activation

If authentication fails with "Token is invalid, expired, or not supported":
1. **Wait 60 seconds** - Bitbucket may not have yet propagated the token
2. **Verify in Bitbucket UI** - https://bitbucket.org/account/settings/personal-tokens/
3. **Regenerate if needed** - https://id.atlassian.com/manage-profile/security/api-tokens

---

## Available Commands

### Workspace & Repository Management
```bash
# List all workspaces
bitbucket_list_workspaces

# List repositories in workspace
bitbucket_list_repositories "workspace-slug"

# Get repository details
bitbucket_get_repository "workspace-slug" "repo-slug"
```

### Issue Tracking
```bash
# List issues in repository (state: new, on hold, resolved, duplicate, wontfix, closed)
bitbucket_list_issues "workspace-slug" "repo-slug" "new"

# Get issue details
bitbucket_get_issue "workspace-slug" "repo-slug" ISSUE_ID

# Create new issue
bitbucket_create_issue "workspace-slug" "repo-slug" "Issue Title" "Description"

# Update issue status
bitbucket_update_issue "workspace-slug" "repo-slug" ISSUE_ID '{"state":"resolved"}'
```

### Pull Request Management
```bash
# List pull requests (state: OPEN, MERGED, DECLINED, SUPERSEDED)
bitbucket_list_pull_requests "workspace-slug" "repo-slug" "OPEN"

# List commits on branch
bitbucket_list_commits "workspace-slug" "repo-slug" "main"
```

### Team & Project Info
```bash
# List teams in workspace
bitbucket_list_teams "workspace-slug"

# Get current user
bitbucket_get_user
```

---

## Real-World Examples

### Listing Issues in a Repository

```bash
# List all new issues in a repo
bitbucket_list_issues "my-workspace" "my-repo" "new"

# Find a specific issue
bitbucket_get_issue "my-workspace" "my-repo" "123"

# Resolve an issue (mark as resolved)
bitbucket_update_issue "my-workspace" "my-repo" 123 '{"state":"resolved"}'
```

### Managing Pull Requests

```bash
# See all open PRs
bitbucket_list_pull_requests "my-workspace" "my-repo" "OPEN"

# Check recent commits
bitbucket_list_commits "my-workspace" "my-repo" "develop"
```

### Creating Issues from Agentic Workflows

```bash
# Create bug ticket
bitbucket_create_issue "my-workspace" "my-repo" "API Error on /users endpoint" \
  "Status 500 returned when fetching user list. Stack trace: ..."
```

---

## Integration with goose Agents

### For Agent Prompts

Include this snippet in agent briefings:

```
You have access to Bitbucket API via the wrapper at scripts/bitbucket-api.sh.
Load it with: source ~/.bashrc && source scripts/bitbucket-api.sh

Available functions:
- bitbucket_list_workspaces()  → List teams/workspaces
- bitbucket_list_repositories(workspace)  → Find repos
- bitbucket_list_issues(workspace, repo, state)  → List issues
- bitbucket_create_issue(workspace, repo, title, description)  → Create ticket
- bitbucket_update_issue(workspace, repo, issue_id, json_updates)  → Update status
- bitbucket_list_pull_requests(workspace, repo, state)  → Find open PRs

Note: Requires BITBUCKET_SCOPED_TOKEN in ~/.bashrc (populated via source ~/.bashrc)
```

### For Agentic Workflows

Use in shell scripts:

```bash
#!/bin/bash
source ~/.bashrc
source scripts/bitbucket-api.sh

# Get list of workspaces
WORKSPACES=$(bitbucket_list_workspaces | awk '{print $1}')

# For each workspace, find open issues
for WS in $WORKSPACES; do
    REPOS=$(bitbucket_list_repositories "$WS" | awk '{print $1}')
    for REPO in $REPOS; do
        echo "=== Open issues in $WS/$REPO ==="
        bitbucket_list_issues "$WS" "$REPO" "new" | head -5
    done
done
```

---

## Troubleshooting

### Authentication Errors (401)

```bash
# Verify token is loaded
echo ${#BITBUCKET_SCOPED_TOKEN} | grep -q "0" && echo "❌ Token not loaded" || echo "✓ Token loaded"

# Test endpoint directly
curl -s -X GET "https://api.bitbucket.org/2.0/user" \
  -H "Authorization: Bearer ${BITBUCKET_SCOPED_TOKEN}" | jq .

# If 401 with new token: Wait 60 seconds (propagation delay)
# If 401 persistent: Verify token scopes at
# https://bitbucket.org/account/settings/personal-tokens/
```

### 401 "Token not supported for this endpoint"

This typically means:
1. **Token not yet activated** (wait 1-2 minutes after generation)
2. **Token already expired** (Atlassian tokens can have short lifespans)
3. **Insufficient scopes** - Ensure token has: `read:workspace`, `read:repository`, `read:issue`, `read:me`

**Solution**: Regenerate token at https://id.atlassian.com/manage-profile/security/api-tokens with all required scopes checked.

### Rate Limiting

Bitbucket Cloud rate limits: 60 requests per minute per IP  
If hitting limits:
- Cache results between calls
- Add 1-second delays between bulk operations: `sleep 1`
- Use pagination: `curl "https://api.bitbucket.org/2.0/repositories/ws?pagelen=50&page=2"`

---

## Next Steps

1. **Token Verification**: Once token is active (test with `bitbucket_test_connection`), proceed to step 2
2. **Agent Integration**: Include `scripts/bitbucket-api.sh` sourcing in agent prompts
3. **Workflow Automation**: Build agentic shell scripts using wrapper functions
4. **Phase 2 Integration**: Combine with GitLab wrapper for multi-provider issue tracking

---

## Reference: Function Signatures

| Function | Parameters | Returns | Example |
|----------|-----------|---------|---------|
| `bitbucket_test_connection` | None | Exit code 0/1 | `bitbucket_test_connection` |
| `bitbucket_list_workspaces` | None | List of workspace:name pairs | `bitbucket_list_workspaces` |
| `bitbucket_list_repositories` | `workspace` | List of repo:name pairs | `bitbucket_list_repositories "my-ws"` |
| `bitbucket_get_repository` | `workspace`, `repo_slug` | Full JSON repo object | `bitbucket_get_repository "my-ws" "my-repo"` |
| `bitbucket_list_issues` | `workspace`, `repo`, `[state]` | Issue list (state: new, resolved) | `bitbucket_list_issues "my-ws" "my-repo" "new"` |
| `bitbucket_get_issue` | `workspace`, `repo`, `issue_id` | JSON issue object | `bitbucket_get_issue "my-ws" "my-repo" 123` |
| `bitbucket_create_issue` | `workspace`, `repo`, `title`, `[desc]` | JSON issue object | `bitbucket_create_issue "my-ws" "my-repo" "Bug" "Details"` |
| `bitbucket_update_issue` | `workspace`, `repo`, `id`, `json_updates` | Updated JSON | `bitbucket_update_issue "my-ws" "my-repo" 123 '{"state":"resolved"}'` |
| `bitbucket_list_pull_requests` | `workspace`, `repo`, `[state]` | PR list | `bitbucket_list_pull_requests "my-ws" "my-repo" "OPEN"` |
| `bitbucket_list_teams` | `workspace` | Team list | `bitbucket_list_teams "my-ws"` |
| `bitbucket_list_commits` | `workspace`, `repo`, `[branch]` | Recent commits | `bitbucket_list_commits "my-ws" "my-repo" "main"` |

---

## Security Notes

- ✅ Credentials in `~/.bashrc` only (never committed)
- ✅ Token scopes follow principle of least privilege (read + write, no delete by default)
- ✅ No hardcoded URLs in scripts (uses `$BITBUCKET_URL` env var)
- ✅ All API calls use HTTPS with token in Authorization header
- ⚠️ Ensure token rotation every 90 days (Atlassian recommended)
- ⚠️ Monitor token usage for unusual patterns (possible compromise)

---

## API Reference

- **Base URL**: https://api.bitbucket.org/2.0
- **Authentication**: Bearer token in `Authorization` header
- **Pagination**: Default 30 items; use `?pagelen=50&page=2` for more
- **Rate Limit**: 60 requests/minute per IP (check `X-RateLimit-*` headers)
- **Docs**: https://developer.atlassian.com/cloud/bitbucket/rest/intro/

