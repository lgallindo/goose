# Using MCP to Access GitHub (FOSS Solutions)

## Overview
This guide covers FOSS options for connecting to GitHub via Model Context Protocol (MCP).

### Recommended Solution: Official GitHub MCP Server (Go-based, FOSS)

**Repository**: [github/github-mcp-server](https://github.com/github/github-mcp-server)
**License**: MIT
**Language**: Go (also TypeScript available)
**Status**: Actively maintained by GitHub

### Installation Options

#### Option 1: Build from Source (Recommended - No Docker)

Already cloned at: `/home/lugatj/code/foss/github-mcp-server`

```bash
cd /home/lugatj/code/foss/github-mcp-server
go build -o github-mcp-server cmd/github-mcp-server/main.go

# Verify build
./github-mcp-server version  # or check if binary exists
ls -lh github-mcp-server
```

**Run with token**:
```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="<YOUR_GITHUB_PAT>"
/home/lugatj/code/foss/github-mcp-server/github-mcp-server stdio
```

#### Option 2: Docker (Alternative, if needed)

```bash
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" \
  ghcr.io/github/github-mcp-server
```

#### Option 3: VS Code Integration (Recommended)

Edit `.vscode/mcp.json`:

```json
{
  "servers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${input:github_pat}"
      }
    }
  }
}
```

### Available Toolsets

Default toolsets (no configuration needed):
- `context` - current user and repository context
- `repos` - repository management and browsing
- `issues` - issue management
- `pull_requests` - PR operations
- `users` - user information

Common toolsets to add:
- `actions` - GitHub Actions workflows
- `code_security` - security scanning results
- `dependabot` - dependency management
- `discussions` - GitHub Discussions

### VS Code Integration (Complete Setup)

Edit `.vscode/mcp.json` (create if doesn't exist):

```json
{
  "servers": {
    "github": {
      "command": "/home/lugatj/code/foss/github-mcp-server/github-mcp-server",
      "args": ["stdio"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_PAT}"
      }
    }
  }
}
```

Set token via environment:
```bash
export GITHUB_PAT="<YOUR_GITHUB_PAT>"
code .
```

**Or with direct token** (dev only - use env var in production):
```json
{
  "servers": {
    "github": {
      "command": "/home/lugatj/code/foss/github-mcp-server/github-mcp-server",
      "args": ["stdio"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_PAT}"
      }
    }
  }<YOUR_GITHUB_PAT>
}
```

Then in shell:
```bash
export GITHUB_PAT="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"
code .  # VS Code inherits env var
```

**VS Code Chat Usage**:
1. Open VS Code Chat panel (Ctrl+Shift+I or Cmd+Shift+I)
2. Type: `@github` to activate GitHub context
3. Use natural language:
   - "List my repositories"
   - "Show issues in goose repo"
   - "Create a pull request for feature X"
   - "Read file docs/README.md from goose repo"

### Alternative: Claude Desktop Integration

### Token Permissions (Minimum Required)

For read-only access:
- `public_repo` - read public repositories
- `repo` - full repository access (if using private repos)
- `read:user` - user profile information

### Verification

Test the connection:

```bash
# Using docker
docker run -i --rm \
  -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" \
  ghcr.io/github/github-mcp-server \
  tool-search "list" --max-results 5
```

## References

- [Official Documentation](https://github.com/github/github-mcp-server)
- [MCP Installation Guides](https://github.com/github/github-mcp-server/tree/main/docs/installation-guides)
- [GitHub Personal Access Token Docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
