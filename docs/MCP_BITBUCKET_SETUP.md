# Using MCP to Access Bitbucket (FOSS Solutions)

## ⚠️ CRITICAL: App Passwords Deprecated

**Effective**: June 9, 2026 (brownout) → July 28, 2026 (removal)

See: [Bitbucket Deprecation Notice](https://community.atlassian.com/forums/Bitbucket-articles/Deprecation-notice-Bitbucket-Cloud-app-password-brownout/ba-p/3237429)

All integrations must migrate to **Scoped API Tokens** immediately.

## Challenge: Limited FOSS MCP Support for Bitbucket

Bitbucket does not have an official MCP server. However, several options exist:

### Option 1: Bitbucket REST API Wrapper with Scoped Tokens (Recommended)

**Use Case**: Bridge gap until official Bitbucket MCP exists

**Setup Steps**:

1. **Create Scoped API Token** (replacing deprecated app passwords):
   - Go to: https://bitbucket.org/account/settings/tokens/
   - Click "Create token"
   - Scopes needed:
     - `repository:read` - Read repository data
     - `pullrequest:read` - Read pull requests
     - `issue:read` - Read issues (if needed)
   - Copy token (save securely)

2. **Create Python MCP Wrapper**:

```python
# tools/bitbucket_mcp.py (if Python allowed; otherwise skip to Option 2)

from mcp.server.fastmcp import FastMCP
import httpx
import os

mcp = FastMCP("bitbucket")

BITBUCKET_API = "https://api.bitbucket.org/2.0"
WORKSPACE = os.getenv("BITBUCKET_WORKSPACE", "your-workspace")
API_TOKEN = os.getenv("BITBUCKET_API_TOKEN")

@mcp.tool()
async def get_repository(repo_slug: str) -> str:
    """Get Bitbucket repository details."""
    url = f"{BITBUCKET_API}/repositories/{WORKSPACE}/{repo_slug}"
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            url,
            auth=("token", API_TOKEN),
            headers={"Accept": "application/json"}
        )
        return resp.json()

@mcp.tool()
async def list_pull_requests(repo_slug: str) -> str:
    """List pull requests in repository."""
    url = f"{BITBUCKET_API}/repositories/{WORKSPACE}/{repo_slug}/pullrequests?state=OPEN"
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            url,
            auth=("token", API_TOKEN),
            headers={"Accept": "application/json"}
        )
        return resp.json()

def main():
    mcp.run(transport="stdio")

if __name__ == "__main__":
    main()
```

### Option 2: Shell Script Wrapper (No Python - Recommended)

### Option 2: Shell Script Wrapper (No Python - Recommended)

Use curl + shell to interact with Bitbucket API directly:

```bash
#!/bin/bash
# scripts/bitbucket-api.sh

BITBUCKET_WORKSPACE="${BITBUCKET_WORKSPACE:-your-workspace}"
BITBUCKET_API_TOKEN="${BITBUCKET_API_TOKEN}"

# List repositories
bitbucket_list_repos() {
    curl -s "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE" \
      -H "Authorization: Bearer $BITBUCKET_API_TOKEN" | jq '.values[].links.html.href'
}

# Get pull requests
bitbucket_list_prs() {
    local repo="$1"
    curl -s "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$repo/pullrequests?state=OPEN" \
      -H "Authorization: Bearer $BITBUCKET_API_TOKEN" | jq '.values[] | {id, title, source, destination}'
}

# Read file from repo
bitbucket_read_file() {
    local repo="$1"
    local file_path="$2"
    local branch="${3:-main}"
    curl -s "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$repo/src/$branch/$file_path" \
      -H "Authorization: Bearer $BITBUCKET_API_TOKEN"
}

# Test connection
test_connection() {
    curl -s "https://api.bitbucket.org/2.0/user" \
      -H "Authorization: Bearer $BITBUCKET_API_TOKEN" | jq '.display_name'
}

# Usage examples
case "${1:-}" in
    list-repos)
        bitbucket_list_repos
        ;;
    list-prs)
        bitbucket_list_prs "${2:?Repo slug required}"
        ;;
    read-file)
        bitbucket_read_file "${2:?Repo required}" "${3:?File path required}" "${4:-main}"
        ;;
    test)
        test_connection
        ;;
    *)
        echo "Usage: $0 {list-repos|list-prs REPO|read-file REPO FILE|test}"
        ;;
esac
```

**Setup**:
```bash
export BITBUCKET_WORKSPACE="your-workspace"
export BITBUCKET_API_TOKEN="your-scoped-api-token"

# Test
./scripts/bitbucket-api.sh test
# Output: Your Name

# List repos
./scripts/bitbucket-api.sh list-repos

# List PRs
./scripts/bitbucket-api.sh list-prs repo-slug
```

**VS Code Integration** (shell wrapper):
```json
{
  "servers": {
    "bitbucket": {
      "command": "/home/lugatj/code/foss/goose/scripts/bitbucket-api.sh",
      "args": ["${input:action}"],
      "env": {
        "BITBUCKET_WORKSPACE": "${input:workspace}",
        "BITBUCKET_API_TOKEN": "${env:BITBUCKET_API_TOKEN}"
      }
    }
  }
}
```

### Option 3: Git-based MCP Server (Indirect Access)

Use official [MCP Git Server](https://github.com/modelcontextprotocol/servers/tree/main/src/git) to clone and inspect Bitbucket repos locally:

```json
{
  "servers": {
    "git": {
      "command": "npx",
      "args": [
        "-y", 
        "@modelcontextprotocol/server-git",
        "--repository", 
        "path/to/local/bitbucket/repo"
      ]
    }
  }
}
```

**Workflow**:
1. Clone Bitbucket repo locally
2. Use Git MCP server for analysis/inspection
3. Limited to read-only git operations

### Option 3: Generic HTTP MCP Server + Bitbucket API

Some community MCP servers support generic HTTP calls:
- [MCP HTTP Server](https://github.com/modelcontextprotocol/servers-archived/tree/main/src/http) (archived but usable)

Configure with Bitbucket API endpoints directly.

## Recommended Approach for Goose

**Best Path**: Option 1 (Custom Python MCP wrapper)
- **Pros**: Full API access, most control, FOSS
- **Cons**: Requires custom development, authentication management

**Quick Alternative**: Option 2 (Git MCP Server)
- **Pros**: Ready-to-use, no custom code
- **Cons**: Git operations only, less powerful

## Bitbucket App Password Setup

1. Navigate to: https://bitbucket.org/account/settings/app-passwords/
2. Create new app password
3. Required scopes for PR/repo access:
   - `repo:read` - Read repository data
   - `pullrequest:read` - Read pull requests
   - `issue:read` - Read issues (if needed)
4. Store securely (e.g., environment variable)

## Testing Connection

```bash
# Test Bitbucket API access
curl -u "username:app_password" \
  https://api.bitbucket.org/2.0/repositories/your_workspace/repo_slug
```

## References

- [Bitbucket API Documentation](https://developer.atlassian.com/cloud/bitbucket/rest/intro/)
- [App Passwords Guide](https://bitbucket.org/account/settings/app-passwords/)
- [Python MCP SDK](https://github.com/modelcontextprotocol/python-sdk)
- [MCP Servers Directory](https://registry.modelcontextprotocol.io/)
