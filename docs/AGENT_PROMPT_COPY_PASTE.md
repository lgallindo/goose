# Copy-Paste Agent Prompt

Use this prompt when briefing other agents on MCP infrastructure:

---

## PROMPT FOR OTHER AGENTS

> **NOTE**: You are working on the goose project. Before starting MCP-related tasks, read this briefing.
> 
> **Status**: MCP infrastructure is being deployed for GitHub, GitLab, and Bitbucket. We've secured credential management via environment variables (all tokens stored in `~/.bashrc`, never in code/docs).
> 
> **Critical Rules**:
> 1. ❌ NEVER hardcode credentials in docs, scripts, or code
> 2. ✅ ALWAYS reference `$GITHUB_TOKEN`, `$GITLAB_PAT`, `$BITBUCKET_SCOPED_TOKEN` from `~/.bashrc`
> 3. ✅ ALWAYS load credentials before running MCP servers: `source ~/.bashrc`
> 
> **Three MCP Servers Available**:
> 
> ### 1. GitHub MCP ✅ Ready Now
> - **Deployment**: `cd /home/lugatj/code/foss/github-mcp-server && ./github-mcp-server stdio &`
> - **Token**: `$GITHUB_TOKEN` (from `~/.bashrc`)
> - **Documentation**: [docs/GITHUB_MCP_AGENT_PROMPT.md](https://github.com/lgallindo/goose/blob/close-up-and-personal/docs/GITHUB_MCP_AGENT_PROMPT.md)
> - **Tools**: list_repositories, get_repository, search_issues, create_pull_request, read_file, write_file
> 
> ### 2. GitLab MCP 🟡 Implementation In Progress
> - **Options**: 
>   - Option 2: Python MCP wrapper → `tools/gitlab_mcp.py` (recommended)
>   - Option 3: Shell/curl wrapper → `scripts/gitlab-api.sh` (lightweight)
> - **Token**: `$GITLAB_PAT` (from `~/.bashrc`)
> - **Target**: https://gitlab.cloud.tjpe.jus.br/groups/sistemas/tjpeia/-/milestones/5
> - **Documentation**: [docs/MCP_SERVERS_STATUS.md](https://github.com/lgallindo/goose/blob/close-up-and-personal/docs/MCP_SERVERS_STATUS.md#option-2-custom-python-mcp-wrapper-foss---recommended)
> - **Tools**: list_milestones, list_milestone_issues, update_issue
> 
> ### 3. Bitbucket MCP 🟡 Implementation In Progress
> - **Option**: Python MCP wrapper → `tools/bitbucket_mcp.py` (Scoped API Tokens required, app passwords deprecated July 28)
> - **Token**: `$BITBUCKET_SCOPED_TOKEN` (from `~/.bashrc`)
> - **Documentation**: [docs/MCP_BITBUCKET_SETUP.md](https://github.com/lgallindo/goose/blob/close-up-and-personal/docs/MCP_BITBUCKET_SETUP.md)
> - **Tools**: list_repositories, list_pull_requests, update_issue
> 
> **Credentials** (already in `~/.bashrc`, load with `source ~/.bashrc`):
> - `$GITHUB_TOKEN` - GitHub PAT
> - `$GITLAB_PAT` - GitLab personal token
> - `$BITBUCKET_SCOPED_TOKEN` - Bitbucket scoped token
> 
> **Next Steps** (Priority Order):
> 1. Deploy GitHub MCP server (standalone binary, no Docker)
> 2. Implement GitLab Options 2 & 3 (Python wrapper + shell wrapper)
> 3. Implement Bitbucket Python wrapper
> 4. Create agent briefing prompts for each MCP server
> 5. Test connectivity and document deployment playbooks
> 
> **Reference Documentation**:
> - Full briefing: [docs/AGENT_BRIEFING_MCP_INFRASTRUCTURE.md](AGENT_BRIEFING_MCP_INFRASTRUCTURE.md)
> - Project roadmap: [docs/ROADMAP_2026Q3_MCP_INTEGRATION.md](ROADMAP_2026Q3_MCP_INTEGRATION.md)
> - Commit history: Branch `origin/close-up-and-personal` (personal fork, NOT aaif-goose upstream)
> 
> **Critical**: Do NOT push to upstream (aaif-goose). All work is on personal fork `lgallindo/goose`.

---

## HOW TO USE THIS PROMPT

1. Copy the text between the "---" markers
2. Paste into chat with another agent
3. Agent receives full briefing + links to documentation
4. Agent can immediately start implementing assigned task

---

## VARIANT: Short Version (for quick briefing)

> You're working on goose project's MCP infrastructure. Quick context:
> - GitHub MCP: Ready to deploy (binary at `/home/lugatj/code/foss/github-mcp-server`)
> - GitLab MCP: Need Python + shell wrappers (use `$GITLAB_PAT` from ~/.bashrc)
> - Bitbucket MCP: Need Python wrapper (use `$BITBUCKET_SCOPED_TOKEN` from ~/.bashrc)
> - All credentials in `~/.bashrc`, never hardcode in docs/code
> - Full briefing: [docs/AGENT_BRIEFING_MCP_INFRASTRUCTURE.md](AGENT_BRIEFING_MCP_INFRASTRUCTURE.md)
> - Don't push to aaif-goose upstream; use personal fork `origin/close-up-and-personal`

---

## VARIANT: For Specific MCP Server

### For GitHub MCP Agent:
> Deploy GitHub MCP server to enable all agents to access GitHub via MCP tools. Server is pre-built at `/home/lugatj/code/foss/github-mcp-server/github-mcp-server`. Use `$GITHUB_TOKEN` from ~/.bashrc (load with `source ~/.bashrc`). Documentation: [docs/GITHUB_MCP_AGENT_PROMPT.md](GITHUB_MCP_AGENT_PROMPT.md). Tools available: list_repositories, get_repository, search_issues, create_pull_request, read_file, write_file.

### For GitLab MCP Agent:
> Implement GitLab MCP wrapper with two options: Option 2 (Python MCP server using gitlab_mcp.py) - recommended, or Option 3 (shell/curl wrapper using gitlab-api.sh) - lightweight. Both use `$GITLAB_PAT` from ~/.bashrc. Target: https://gitlab.cloud.tjpe.jus.br/groups/sistemas/tjpeia/-/milestones/5. Details: [docs/MCP_SERVERS_STATUS.md](MCP_SERVERS_STATUS.md).

### For Bitbucket MCP Agent:
> Implement Bitbucket MCP wrapper using Python (bitbucket_mcp.py). Use `$BITBUCKET_SCOPED_TOKEN` from ~/.bashrc. Important: App passwords deprecated July 28, 2026 - use Scoped API Tokens only. Details: [docs/MCP_BITBUCKET_SETUP.md](MCP_BITBUCKET_SETUP.md).

---

## METADATA

- **Created**: 2026-07-03T08:55Z
- **Status**: Ready to use
- **Branch**: origin/close-up-and-personal
- **Last Updated**: Session handoff + roadmap commit (66ed27177)
