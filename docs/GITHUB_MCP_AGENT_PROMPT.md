# GitHub MCP Server - Deployment & Agent Instructions

## Quick Start for All Agents

### Prerequisites
- GitHub PAT token (personal access token with `repo`, `gist`, `user` scopes)
- Bash shell
- `go` installed (or use pre-built binary)

### Deploy GitHub MCP Server

```bash
# 1. Navigate to server repo
cd /home/lugatj/code/foss/github-mcp-server

# 2. Build (if not already built)
go build -o github-mcp-server cmd/github-mcp-server/main.go

# 3. Set token in environment
export GITHUB_TOKEN="your-github-pat-token-here"

# 4. Start server (stdio transport for MCP clients)
./github-mcp-server stdio &

# 5. Verify it's running
ps aux | grep github-mcp-server
```

### VS Code Integration (Recommended)

Add to `.vscode/settings.json` or `.vscode/mcp.json`:

```json
{
  "mcp": {
    "servers": {
      "github": {
        "command": "/home/lugatj/code/foss/github-mcp-server/github-mcp-server",
        "args": ["stdio"],
        "env": {
          "GITHUB_TOKEN": "${env:GITHUB_TOKEN}"
        },
        "disabled": false
      }
    }
  }
}
```

**Then in terminal**:
```bash
export GITHUB_TOKEN="your-pat-here"
# OR add to ~/.bashrc:
# export GITHUB_TOKEN="your-pat-here"
```

---

## Agent Usage

### When to Use GitHub MCP

Use the GitHub MCP server when you need to:
- ✅ List/search repositories
- ✅ Read/write files in repos
- ✅ Create/update pull requests
- ✅ Search issues and discussions
- ✅ Manage collaborators
- ✅ Clone repos locally

### Example: Interacting with the Server

```bash
# Connect to GitHub MCP server
mcp-client call github list_repositories --limit 10

# Get specific repo details
mcp-client call github get_repository --owner lgallindo --repo goose

# Create a pull request
mcp-client call github create_pull_request \
  --owner lgallindo \
  --repo goose \
  --title "Feature: Add MCP integration" \
  --head "feature/mcp-integration" \
  --base main
```

### Token Management

**CRITICAL**: Never hardcode tokens in documentation or scripts.

**Secure Storage**:
```bash
# Store in ~/.bashrc (git-ignored)
echo 'export GITHUB_TOKEN="your-pat-here"' >> ~/.bashrc
source ~/.bashrc

# Load before using server
export GITHUB_TOKEN="$(grep GITHUB_TOKEN ~/.bashrc | cut -d'"' -f2)"
./github-mcp-server stdio
```

**For CI/CD**: Use GitHub Secrets or environment variables injected at runtime.

---

## Troubleshooting

### Server won't start
```bash
# Check if port is in use
lsof -i :8000  # or check actual port

# Check for syntax errors
./github-mcp-server --help

# Enable debug mode
GITHUB_MCP_DEBUG=1 ./github-mcp-server stdio
```

### Token authentication fails
```bash
# Verify token is set
echo $GITHUB_TOKEN

# Test token directly
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user

# Should return your GitHub user info
```

### Connection refused
```bash
# Ensure server is running
pgrep github-mcp-server

# Check stdio connection
nc -zv 127.0.0.1 8000  # if using TCP (non-stdio)
```

---

## Capabilities Reference

| Tool | Purpose | Example |
|------|---------|---------|
| `list_repositories` | List user/org repos | `--owner lgallindo --limit 50` |
| `get_repository` | Get repo details | `--owner lgallindo --repo goose` |
| `search_issues` | Find issues/PRs | `--query "label:bug is:open"` |
| `create_pull_request` | Open new PR | `--title "Fix" --head feature --base main` |
| `read_file` | Get file content | `--path src/main.rs` |
| `write_file` | Create/update file | `--path docs/NEW.md --content "..."` |

---

## Integration with goose Project

### Current Status
- ✅ Server built and ready at `/home/lugatj/code/foss/github-mcp-server`
- ✅ No Docker required (native Go binary)
- ✅ Token stored in `~/.bashrc` as `$GITHUB_TOKEN` (not in docs)

### Next Steps
1. Deploy server: `cd /home/lugatj/code/foss/github-mcp-server && ./github-mcp-server stdio &`
2. All agents can now call GitHub tools via MCP
3. Reference this prompt when onboarding new agents

---

**Last Updated**: 2026-07-03
**Token Security**: Environment variable injection (no hardcoded credentials)
