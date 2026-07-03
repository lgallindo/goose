# MCP Servers Status Report

**Date**: 2026-07-03
**Status**: Active session assessment
**Reference**: [docs/MCP_GITHUB_SETUP.md](MCP_GITHUB_SETUP.md), [docs/MCP_BITBUCKET_SETUP.md](MCP_BITBUCKET_SETUP.md)

---

## Currently Running MCP Servers

### ✅ Active: llama-server (Local LLM)

**PID**: 5461
**Port**: 127.0.0.1:38080
**Model**: Qwen 2.5 Coder 1.5B GGUF (4-bit quantized)
**Memory**: ~1GB
**Status**: **OPERATIONAL** (verified 2026-07-03 with curl)
**Capabilities**:
- ✓ OpenAI-compatible `/v1/chat/completions` endpoint
- ✓ `/v1/models` endpoint (model enumeration)
- ✓ Streaming support (optional)
- ✓ Code completion (tested)
- ✓ Performance: ~1.25s for 20-token generation

**Uptime**: Since 2026-07-01 (continuous, ~48 hours)

**Usage**:
```bash
curl -s -X POST http://127.0.0.1:38080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen2.5-coder-1.5b-instruct","messages":[{"role":"user","content":"hello"}],"max_tokens":10}'
```

**Integration Point**: Available for local code generation tasks, testing, and AI-assisted development

---

### ✅ Active: playwright-mcp (Web Automation)

**PID**: 19478 (node process)
**Package**: @playwright/mcp
**Status**: **OPERATIONAL**
**Capabilities**:
- ✓ Browser automation (Chromium, Firefox, WebKit)
- ✓ Page navigation and interaction
- ✓ Screenshot/PDF generation
- ✓ Network interception
- ✓ Test scenario recording

**Usage Context**: Can be used to interact with web-based tools, dashboards, or APIs that require browser interaction

**Integration**: Available for UI testing or web-based workflow automation

---

## Available MCP Servers (Not Currently Running)

### GitHub MCP Server

**Status**: ✅ Built locally at `/home/lugatj/code/foss/github-mcp-server`

**Capabilities**:
- List/clone repositories
- Read/write files
- Create/manage pull requests
- Search issues
- User/org management

**Build Command**:
```bash
cd /home/lugatj/code/foss/github-mcp-server
go build -o github-mcp-server cmd/github-mcp-server/main.go
./github-mcp-server stdio
```

**Authorization**: Configured with PAT token (see [docs/MCP_GITHUB_SETUP.md](MCP_GITHUB_SETUP.md))

**Ready to Deploy**: Yes (no Docker required)

---

## GitLab MCP Integration (Priority 0)

### Status: RESEARCH PHASE

**Objective**: Enable MCP access to GitLab instance at `https://gitlab.cloud.tjpe.jus.br`

**Scope**: Manage milestones, issues, and projects via MCP

**Current Findings**:

#### GitLab Official Support
- **Status**: ❌ No official GitLab MCP server exists
- **Reference**: Checked GitLab docs, MCP registry, GitHub/OpenAI MCP servers
- **Implication**: Custom implementation required

#### Option 1: Community Implementations
- **Project**: [GitLab MCP Candidates](https://registry.modelcontextprotocol.io/)
- **Current Count**: 0 in official registry (as of 2026-07-03)
- **Viability**: Low (FOSS GitLab MCP is nascent)

#### Option 2: Custom Python MCP Wrapper (FOSS - Recommended)

**Approach**: Build lightweight MCP server using Python MCP SDK + GitLab API

**Setup**: Token is stored in `~/.bashrc` as `$GITLAB_PAT` (do NOT commit credentials)

**Implementation Sketch**:
```python
# tools/gitlab_mcp.py
from mcp.server.fastmcp import FastMCP
import httpx
import os

mcp = FastMCP("gitlab")

GITLAB_URL = "https://gitlab.cloud.tjpe.jus.br"
GITLAB_TOKEN = os.getenv("GITLAB_PAT")  # Personal access token from ~/.bashrc

@mcp.tool()
async def list_milestones(group_slug: str = "sistemas/tjpeia") -> dict:
    """List milestones for group (e.g., sistemas/tjpeia)."""
    url = f"{GITLAB_URL}/api/v4/groups/{group_slug}/milestones"
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            url,
            headers={"PRIVATE-TOKEN": GITLAB_TOKEN}
        )
        return resp.json()

@mcp.tool()
async def list_milestone_issues(group_slug: str, milestone_id: int) -> dict:
    """List issues in a group milestone (e.g., milestone 5 in sistemas/tjpeia)."""
    url = f"{GITLAB_URL}/api/v4/groups/{group_slug}/milestones/{milestone_id}/issues"
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            url,
            headers={"PRIVATE-TOKEN": GITLAB_TOKEN}
        )
        return resp.json()

@mcp.tool()
async def update_issue(project_id: int, issue_iid: int, updates: dict) -> dict:
    """Update issue (title, description, labels, state, etc.)."""
    url = f"{GITLAB_URL}/api/v4/projects/{project_id}/issues/{issue_iid}"
    async with httpx.AsyncClient() as client:
        resp = await client.put(
            url,
            json=updates,
            headers={"PRIVATE-TOKEN": GITLAB_TOKEN}
        )
        return resp.json()

def main():
    mcp.run(transport="stdio")

if __name__ == "__main__":
    main()
```

#### Option 3: Direct API Integration (Shell Wrapper)

**Approach**: Use shell + curl to interact with GitLab API without Python MCP server overhead

**Token**: Stored in `~/.bashrc` as `$GITLAB_PAT` (do NOT commit)

**Implementation**:
```bash
#!/bin/bash
# scripts/gitlab-api.sh

GITLAB_URL="https://gitlab.cloud.tjpe.jus.br"
GITLAB_TOKEN="${GITLAB_PAT}"

# List milestones in a group
gitlab_list_milestones() {
    local group_slug="${1:-sistemas/tjpeia}"
    curl -s -X GET \
        "${GITLAB_URL}/api/v4/groups/${group_slug}/milestones" \
        -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        -H "Content-Type: application/json"
}

# List issues in a milestone
gitlab_list_milestone_issues() {
    local group_slug="${1:-sistemas/tjpeia}"
    local milestone_id="${2:-5}"
    curl -s -X GET \
        "${GITLAB_URL}/api/v4/groups/${group_slug}/milestones/${milestone_id}/issues" \
        -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        -H "Content-Type: application/json"
}

# Update issue
gitlab_update_issue() {
    local project_id="$1"
    local issue_iid="$2"
    local updates="$3"
    
    curl -s -X PUT \
        "${GITLAB_URL}/api/v4/projects/${project_id}/issues/${issue_iid}" \
        -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "${updates}"
}

# Examples
# gitlab_list_milestones "sistemas/tjpeia"
# gitlab_list_milestone_issues "sistemas/tjpeia" "5"
# gitlab_update_issue "123" "45" '{"state":"closed","description":"Done"}'
```

**Usage**:
```bash
source ~/.bashrc  # Load $GITLAB_PAT
source scripts/gitlab-api.sh
gitlab_list_milestone_issues "sistemas/tjpeia" "5" | jq '.[] | {id, title, state}'
```

**Advantages**:
- ✅ No Python runtime required
- ✅ No MCP server overhead
- ✅ Direct integration with shell workflows
- ✅ Can be combined with jq for JSON processing

**Estimated Effort**: 4-6 hours (Python + GitLab API mapping)

#### Option 3: Direct API Integration (Shell Wrapper)

Similar to Bitbucket approach; use curl + shell to call GitLab API directly

**Advantage**: No Python dependency, integrates with existing shell testing harness

#### Option 4: Temporal Integration (Workflow-based)

Use Temporal workflow engine to manage GitLab milestone tracking as background tasks

**Advantage**: Persistent, event-driven
**Disadvantage**: Requires Temporal setup

---

## Recommended Path Forward (Priority Order)

| Priority | Action | Timeline | Owner | Notes |
|----------|--------|----------|-------|-------|
| **0** | Kickstart GitLab MCP wrapper (Option 2) | Week 1 | Agent | Python-based, FOSS-friendly |
| 1 | Verify Permission: Can we connect to `https://gitlab.cloud.tjpe.jus.br`? | Immediate | User | Need GitLab API token + network verification |
| 2 | Create GitLab token (scopes: milestones, issues) | Immediate | User | Setup on GitLab instance |
| 3 | Test GitLab API connectivity | Day 1 | Agent | curl to `/api/v4/version` endpoint |
| 4 | Implement core milestones/issues queries | Day 2-3 | Agent | list_milestones, list_milestone_issues |
| 5 | Add write operations (update issue, create comment) | Day 4-5 | Agent | Full CRUD for workflow |
| 6 | Integrate into VS Code MCP config | Day 5-6 | Agent | Register GitLab MCP server |
| 7 | Test with real milestone (tjpeia milestone 5) | Day 6 | Agent + User | Verify end-to-end flow |

---

## Implementation Checklist

- [ ] Confirm network access to `https://gitlab.cloud.tjpe.jus.br` (may require VPN)
- [ ] Create GitLab API token with scopes: `api` (or narrower: `read_api`, `write_repository`)
- [ ] Set up Python environment for GitLab MCP server
- [ ] Implement core MCP tools (list/read/update)
- [ ] Register in VS Code `.vscode/mcp.json`
- [ ] Test milestone 5 queries
- [ ] Document usage in [docs/MCP_GITLAB_SETUP.md](MCP_GITLAB_SETUP.md)

---

## Connection Details Required

To proceed with GitLab MCP implementation:
1. **URL**: https://gitlab.cloud.tjpe.jus.br ✓
2. **Project Path**: groups/sistemas/tjpeia ✓
3. **Target Milestone**: 5 ✓
4. **API Token**: ⚠️ **NEEDED** (User to provide or create)
5. **Network Access**: ⚠️ **VERIFY** (May need VPN or allowlist)
6. **Permission**: ⚠️ **VERIFY** (Can I authenticate + query milestones?)

---

## References

- GitLab API Docs: https://docs.gitlab.com/ee/api/
- GitLab Milestones API: https://docs.gitlab.com/ee/api/milestones.html
- GitLab Issues API: https://docs.gitlab.com/ee/api/issues.html
- Python MCP SDK: https://github.com/modelcontextprotocol/python-sdk
- Target: https://gitlab.cloud.tjpe.jus.br/groups/sistemas/tjpeia/-/milestones/5#tab-issues

---

## Blocking Questions

1. **Network Access**: Can agent access `https://gitlab.cloud.tjpe.jus.br` from this environment?
2. **Authentication**: What type of GitLab token should be created (scope: read-only vs write)?
3. **Other Agents**: Have other agents made progress on GitLab MCP? (Check session history)
4. **Prioritization**: Is GitLab MCP blocking other work, or can it proceed in parallel?
