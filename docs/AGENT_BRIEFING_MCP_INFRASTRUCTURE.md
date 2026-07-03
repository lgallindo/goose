# Agent Briefing: MCP Infrastructure & Credential Management

**Version**: 2026-07-03
**Audience**: All agents working on goose project
**Required Reading**: Before starting any MCP-related task

---

## TL;DR

We've secured MCP integration for GitHub, GitLab, and Bitbucket. All credentials are stored in `~/.bashrc` as environment variables (never hardcoded in docs). Three MCP servers are being deployed:

1. **GitHub MCP** ✅ Ready to deploy
2. **GitLab MCP** 🟡 Needs Option 2 & 3 implementation
3. **Bitbucket MCP** 🟡 Needs Python wrapper implementation

---

## Critical: Credential Storage Policy

### ⚠️ NEVER DO THIS

```bash
# ❌ WRONG - Hardcoded in script
export GITLAB_TOKEN="glft-XXXXXXXXXXXXXXXXXX"

# ❌ WRONG - In markdown docs
Tutorial: `curl -H "Authorization: token ghp_XXXXXXXXXXXXXXXXXXXX" ...`

# ❌ WRONG - In code files
const GITHUB_PAT = "ghp_XXXXXXXXXXXXXXXXXXXX";
```

### ✅ DO THIS

```bash
# ✅ RIGHT - In ~/.bashrc (git-ignored)
echo 'export GITLAB_PAT="glft-U1a8JH61..."' >> ~/.bashrc
source ~/.bashrc

# ✅ RIGHT - In docs, reference env vars only
curl -H "Authorization: token ${GITHUB_TOKEN}" ...

# ✅ RIGHT - In code, read from environment
const token = process.env.GITHUB_TOKEN;
```

---

## MCP Servers Available

### 1. GitHub MCP Server

**Status**: ✅ Built, ready to deploy
**Binary**: `/home/lugatj/code/foss/github-mcp-server/github-mcp-server`
**Deployment**:
```bash
export GITHUB_TOKEN="$(grep GITHUB_TOKEN ~/.bashrc | cut -d'"' -f2)"
cd /home/lugatj/code/foss/github-mcp-server
./github-mcp-server stdio &
```

**Documentation**: [docs/GITHUB_MCP_AGENT_PROMPT.md](GITHUB_MCP_AGENT_PROMPT.md)

**Tools Available**:
- `list_repositories` - List user/org repos
- `get_repository` - Get repo details
- `search_issues` - Find issues/PRs
- `create_pull_request` - Open new PR
- `read_file` - Get file content
- `write_file` - Create/update files

**Token**: Stored as `$GITHUB_TOKEN` in `~/.bashrc`

---

### 2. GitLab MCP Server

**Status**: 🟡 Two implementations needed (Option 2 & 3)

**Option 2: Python MCP Wrapper** (recommended)
- Path: `tools/gitlab_mcp.py` (needs implementation)
- Runtime: `python tools/gitlab_mcp.py`
- Token: `$GITLAB_PAT` from `~/.bashrc`
- Docs: [docs/MCP_SERVERS_STATUS.md#option-2](MCP_SERVERS_STATUS.md#option-2-custom-python-mcp-wrapper-foss---recommended)

**Option 3: Shell/Curl Wrapper** (lightweight)
- Path: `scripts/gitlab-api.sh` (needs implementation)
- Runtime: `source ~/.bashrc && source scripts/gitlab-api.sh`
- Token: `$GITLAB_PAT` from `~/.bashrc`
- Docs: [docs/MCP_SERVERS_STATUS.md#option-3](MCP_SERVERS_STATUS.md#option-3-direct-api-integration-shell-wrapper)

**Tools** (both options):
- `list_milestones` - Get milestones in group (e.g., sistemas/tjpeia)
- `list_milestone_issues` - Issues in milestone (e.g., milestone 5)
- `update_issue` - Modify issue state/title/labels

**Target**: https://gitlab.cloud.tjpe.jus.br/groups/sistemas/tjpeia/-/milestones/5

**Token**: Stored as `$GITLAB_PAT` in `~/.bashrc`

---

### 3. Bitbucket MCP Server

**Status**: 🟡 Python MCP wrapper needed (Option 1)

**Implementation**: `tools/bitbucket_mcp.py` (needs implementation)

**Runtime**:
```bash
export BITBUCKET_WORKSPACE="hustles"
export BITBUCKET_API_TOKEN="$BITBUCKET_SCOPED_TOKEN"
python tools/bitbucket_mcp.py
```

**Tools** (to implement):
- `list_repositories` - List Bitbucket repos
- `list_pull_requests` - Get open PRs
- `create_pull_request` - Create new PR
- `update_issue` - Modify issue state

**Token**: Stored as `$BITBUCKET_SCOPED_TOKEN` in `~/.bashrc`

**Critical Note**: App passwords deprecated July 28, 2026 → Migration to Scoped API Tokens required immediately.

---

## Credentials: Current Status

### Environment Variables (in ~/.bashrc)

```bash
export GITHUB_TOKEN="ghp_XXXXXXXXXXXXXXXXXXXX"         # Personal access token
export GITLAB_PAT="glft-XXXXXXXXXXXXXXXXXX"            # GitLab personal token  
export BITBUCKET_SCOPED_TOKEN="ATATT3xXXXXXXXXXXXXXX" # Bitbucket scoped token
```

**Note**: Replace `XXXX...` with actual tokens from `~/.bashrc`. Never commit real tokens.

### How to Load

```bash
# In current shell session
source ~/.bashrc

# Verify (will display actual tokens from ~/.bashrc)
echo $GITHUB_TOKEN
echo $GITLAB_PAT
echo $BITBUCKET_SCOPED_TOKEN
```

### Token Regeneration

**⚠️ REMINDER**: GitHub PAT must be regenerated within 5 messages (user request at 2026-07-03T08:50Z).

New token should have minimal scopes:
- GitHub: `repo`, `gist`, `user`
- GitLab: `api`, `read_user`, `read_repository`
- Bitbucket: Create with scopes: `repository:read`, `pullrequest:read`, `issue:read`

---

## Documentation Files (Reference)

| File | Purpose | Status |
|------|---------|--------|
| [GITHUB_MCP_AGENT_PROMPT.md](GITHUB_MCP_AGENT_PROMPT.md) | GitHub server deployment + usage | ✅ Ready |
| [MCP_GITHUB_SETUP.md](MCP_GITHUB_SETUP.md) | GitHub MCP setup (local build, no Docker) | ✅ Complete |
| [MCP_BITBUCKET_SETUP.md](MCP_BITBUCKET_SETUP.md) | Bitbucket API token migration | ✅ Complete |
| [MCP_SERVERS_STATUS.md](MCP_SERVERS_STATUS.md) | Active servers + GitLab roadmap | ✅ Complete |
| [ROADMAP_2026Q3_MCP_INTEGRATION.md](ROADMAP_2026Q3_MCP_INTEGRATION.md) | Full roadmap + work fronts | ✅ Ready |
| GITLAB_MCP_AGENT_PROMPT.md | GitLab server prompt (to create) | 🔲 TODO |
| BITBUCKET_MCP_AGENT_PROMPT.md | Bitbucket server prompt (to create) | 🔲 TODO |

---

## Next Steps for Agents

### Immediate (Today)

1. **Deploy GitHub MCP**:
   ```bash
   source ~/.bashrc
   cd /home/lugatj/code/foss/github-mcp-server
   ./github-mcp-server stdio &
   ```

2. **Implement GitLab Option 2** (Python MCP wrapper):
   - Read: [docs/MCP_SERVERS_STATUS.md#option-2](MCP_SERVERS_STATUS.md#option-2-custom-python-mcp-wrapper-foss---recommended)
   - Create: `tools/gitlab_mcp.py` with functions:
     - `list_milestones(group_slug)`
     - `list_milestone_issues(group_slug, milestone_id)`
     - `update_issue(project_id, issue_iid, updates)`
   - Test: `python tools/gitlab_mcp.py` → verify connects to GitLab

3. **Implement GitLab Option 3** (Shell wrapper):
   - Read: [docs/MCP_SERVERS_STATUS.md#option-3](MCP_SERVERS_STATUS.md#option-3-direct-api-integration-shell-wrapper)
   - Create: `scripts/gitlab-api.sh` with shell functions
   - Test: `source ~/.bashrc && source scripts/gitlab-api.sh && gitlab_list_milestone_issues sistemas/tjpeia 5`

4. **Implement Bitbucket Option 1** (Python MCP wrapper):
   - Read: [docs/MCP_BITBUCKET_SETUP.md#option-1](MCP_BITBUCKET_SETUP.md#option-1-bitbucket-rest-api-wrapper-with-scoped-tokens-recommended)
   - Create: `tools/bitbucket_mcp.py` with functions
   - Test: `python tools/bitbucket_mcp.py`

### Later (Week 1)

1. Create `docs/GITLAB_MCP_AGENT_PROMPT.md` (deployment + usage)
2. Create `docs/BITBUCKET_MCP_AGENT_PROMPT.md` (deployment + usage)
3. Deploy servers as background processes + verify connectivity

---

## Key Git Commits (Reference)

- **66ed27177**: Secured env vars + GitLab Option 3 + GitHub agent prompt
- **b571422a3**: Original MCP docs (has old test PAT, now unblocked)
- **d32406c4c**: Security fix attempt

**Branch**: `origin/close-up-and-personal` (personal fork, NOT aaif-goose upstream)

---

## Troubleshooting

### Token not found
```bash
# Check ~/.bashrc has the export
grep GITHUB_TOKEN ~/.bashrc

# Reload
source ~/.bashrc

# Verify
echo $GITHUB_TOKEN
```

### GitHub MCP won't start
```bash
# Check if binary exists
ls -la /home/lugatj/code/foss/github-mcp-server/github-mcp-server

# If missing, rebuild
cd /home/lugatj/code/foss/github-mcp-server
go build -o github-mcp-server cmd/github-mcp-server/main.go
```

### GitLab API returns 401
```bash
# Verify token is valid
curl -H "PRIVATE-TOKEN: ${GITLAB_PAT}" \
  https://gitlab.cloud.tjpe.jus.br/api/v4/user

# Should return your GitLab user info
```

---

## Questions?

Refer to:
1. [ROADMAP_2026Q3_MCP_INTEGRATION.md](ROADMAP_2026Q3_MCP_INTEGRATION.md) - Project roadmap
2. [GITHUB_MCP_AGENT_PROMPT.md](GITHUB_MCP_AGENT_PROMPT.md) - GitHub-specific setup
3. [MCP_SERVERS_STATUS.md](MCP_SERVERS_STATUS.md) - Status + GitLab/Bitbucket options
4. User request context in `SESSION_HANDOFF.md`

**Last Updated**: 2026-07-03T08:50Z
**Reminder**: New GitHub PAT within 5 messages
