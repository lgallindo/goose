# MCP Integration Roadmap - Q3 2026

**Date**: 2026-07-03
**Status**: Phase 1 (Deployment) → Phase 2 (Agents) → Phase 3 (Production)
**Commits**: 66ed27177 (GitHub unblocked + secured), origin/close-up-and-personal

---

## Phase 1: Core MCP Deployment ✅ IN PROGRESS

### Work Front 1a: GitHub MCP Server
- ✅ **COMPLETE**: Local build verified (Go binary at `/home/lugatj/code/foss/github-mcp-server`)
- ✅ **COMPLETE**: VS Code integration documented
- ✅ **COMPLETE**: Token management via `$GITHUB_TOKEN` env var (secure, not in docs)
- ✅ **COMPLETE**: Agent prompt created (`docs/GITHUB_MCP_AGENT_PROMPT.md`)
- 🟡 **NEXT**: Deploy server instance (background process)
  - Command: `cd /home/lugatj/code/foss/github-mcp-server && ./github-mcp-server stdio &`
  - Verify: `pgrep github-mcp-server`

### Work Front 1b: GitLab MCP Integration
- ✅ **RESEARCH COMPLETE**: No official FOSS implementation exists
- ✅ **DOCUMENTED**: Option 2 (Python MCP wrapper) + Option 3 (shell script wrapper)
- 🟡 **NEXT**: Implement + test both options
  - **Option 2**: `tools/gitlab_mcp.py` (Python MCP server using GitLab API)
  - **Option 3**: `scripts/gitlab-api.sh` (Pure shell/curl wrapper)
- 📋 **BLOCKERS**: None (PAT now in `$GITLAB_PAT` env var)
- **Timeline**: This session (immediate)

### Work Front 1c: Bitbucket MCP Integration
- ✅ **MIGRATION COMPLETE**: App passwords → Scoped API Tokens documented
- ✅ **DOCUMENTED**: Option 1 (Python wrapper) + Option 2 (shell script)
- 🟡 **NEXT**: Implement Python MCP wrapper for Bitbucket API
  - Path: `tools/bitbucket_mcp.py`
  - Token: `$BITBUCKET_SCOPED_TOKEN` env var
- **Timeline**: This session (after GitLab)

---

## Phase 2: Agent Integration 📋 PENDING

### Work Front 2a: Agent Onboarding
- 📋 **TODO**: Create agent prompts for each MCP server
  - GitHub prompt: ✅ DONE (`docs/GITHUB_MCP_AGENT_PROMPT.md`)
  - GitLab prompt: 🔲 TODO (`docs/GITLAB_MCP_AGENT_PROMPT.md` after implementation)
  - Bitbucket prompt: 🔲 TODO (`docs/BITBUCKET_MCP_AGENT_PROMPT.md` after implementation)

### Work Front 2b: KV Store Integration
- ✅ **DESIGN COMPLETE**: Session-scoped KV templating (docs/KV_TEMPLATING_PLUMBING.md)
- ✅ **EVOLUTION SPEC**: 7-item roadmap (docs/KV_EVOLUTION_SPEC.md)
- 🟡 **NEXT**: Implement item 1 (timestamps with RFC3339 + timezone)
  - File: `crates/goose/src/utils/timestamp.rs`
  - Tests first (TDD approach per PROJECT_RULES.md)

### Work Front 2c: AGENTS Determinism Refinement
- ✅ **ANALYSIS COMPLETE**: 20 rules audited (docs/AGENTS_DETERMINISM_ANALYSIS.md)
- ✅ **SESSION KV**: Auto-increment message counter, auto-refresh on 3rd msg
- 🟡 **NEXT**: Implement rules in agent runtime
  - Phase 1 classification (fast pattern detection)
  - Phase 2 SDD evaluation (lazy, only for Planning_Step)
  - Rules 010/011/015 enforcement

---

## Phase 3: Alternative Implementations 🔲 PENDING

### Work Front 3a: Alternative 1 - Aider API Wrapper
- 📋 **DUE**: Tomorrow (user request)
- **Goal**: Bridge Aider to local LLM via API wrapper
- **Implementation**: Shell script OR Go binary
- **Path**: `tools/aider-api-wrapper.sh` or `crates/aider-wrapper/`
- **Evidence**: Working test with local llama-server

### Work Front 3b: Alternative 3 - Rust LLM Integration
- 📋 **TIMELINE**: End of month (2026-07-31)
- **Reminder**: Within 5 messages (user request)
- **Goal**: Direct Rust integration (no Aider dependency)
- **Design**: RFC for new crate (goose-local-editor OR similar)
- **Scope**: Streaming, validation, error handling

### Work Front 3c: secret_local_llm Documentation Fix
- ✅ **AUDIT COMPLETE**: docs/SECRET_LOCAL_LLM_AUDIT.md
- 📋 **TODO**: Apply fixes to `/documentation/docs/secret_local_llm.md`
  - Add "Known Issues" section
  - Add "Fallback Procedures" section
  - Add "Direct API Usage" examples (using curl harness)

---

## Explicit Work Fronts (Priority Order)

| Front | Owner | Status | Timeline | Blocker |
|-------|-------|--------|----------|---------|
| **1a** (GitHub Server) | Deploy | 🟡 Ready | Today | None |
| **1b** (GitLab Options 2+3) | Implement | 🟡 Ready | Today | None |
| **1c** (Bitbucket Wrapper) | Implement | 📋 Next | Today (after 1b) | None |
| **2a** (Agent Onboarding) | Docs | 📋 Pending | After 1a-1c | Server deployment |
| **2b** (Timestamp RFC3339) | Code | 📋 Pending | Week 1 | Project_rules.md TDD |
| **2c** (AGENTS Runtime) | Code | 📋 Pending | Week 1 | Analysis complete ✅ |
| **3a** (Aider Wrapper) | Implement | 📋 URGENT | Tomorrow | None |
| **3b** (Rust Integration) | Design | 📋 Pending | Week 4 | RFC approval |
| **3c** (secret_local_llm) | Docs | 📋 Pending | Week 1 | None |

---

## Credential Management (Secure)

**Storage**: `~/.bashrc` (git-ignored)

```bash
export GITHUB_TOKEN="ghp_..."               # Regenerate in 5 messages ⚠️
export GITLAB_PAT="glft-U1a8JH61..."       # Already set
export BITBUCKET_SCOPED_TOKEN="ATATT3x..."  # Already set
```

**Reference in Docs**: Use `$ENV_VAR_NAME` only, never hardcode values.

**CI/CD**: Inject via GitHub Secrets or environment variables at runtime.

---

## Dependency Graph

```
GitHub MCP (1a) ─┐
                  ├─→ Agent Onboarding (2a) ──→ All agents can call GitHub tools
GitLab Options (1b) ┤
                    └─→ GitLab Agent Prompt (Future)
Bitbucket (1c) ────→ Bitbucket Agent Prompt (Future)

KV Timestamp (2b) ──→ Prompt System Update
AGENTS Runtime (2c) → Agent Determinism Enforcement
                      
Alternative 1 (3a) ─→ Tomorrow deliverable
Alternative 3 (3b) ─→ RFC + Design (Week 1), Implementation (Week 4)
```

---

## Git Branch Strategy

- **Branch**: `origin/close-up-and-personal` (personal, NOT aaif-goose upstream)
- **Commits This Session**: 
  - b571422a3: Attribution + MCP docs (had PAT, now unblocked)
  - d32406c4c: Security fix attempt
  - 66ed27177: Secured env vars + GitLab Option 3 + GitHub agent prompt
- **Next Commits**: Implementations (GitLab/Bitbucket wrappers, Aider alt, timestamp tool)

---

## Success Criteria

### Phase 1 (Deployment)
- ✅ GitHub server running as background process
- ✅ GitLab Options 2 & 3 tested and verified
- ✅ Bitbucket wrapper functional
- ✅ Zero hardcoded credentials in repo

### Phase 2 (Agents)
- ✅ All agents can list/manipulate repos via MCP
- ✅ KV timestamp system producing RFC3339 output
- ✅ AGENTS determinism rules enforced in runtime
- ✅ Alternative 1 (Aider wrapper) delivered

### Phase 3 (Production)
- ✅ secret_local_llm docs updated with fallback procedures
- ✅ Alternative 3 RFC approved and implemented
- ✅ All MCP servers in production use

---

**Last Updated**: 2026-07-03T08:50Z
**Next Review**: After Alternative 1 completion (tomorrow)
**Reminder**: Regenerate GitHub PAT within 5 messages
