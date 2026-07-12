# Conversation Chronicle & Artifact Index

**Created:** 2026-07-12T15:36:00Z  
**Scope:** Cursor agent sessions 2026-07-10 → 2026-07-12 (goose fork, GooseTeam, Arclength, workspace bootstrap)  
**Performer:** cursor-agent + operator (lugatj)

---

## Session arc (minutiae)

### 2026-07-10 — Bootstrap & analysis

1. Operator asked to read `~/code/AGENTS.md`, implement rulings, analyze `foss/goose` vs `foss/GooseTeam`.
2. **AGENTS bootstrap:** Synced `research/standardization_analysis/AGENTS.md` from template; expanded `~/code/PROJECT_RULES.md`; appended global `SESSION_HANDOFF.md`.
3. **GooseTeam verdict:** Largely superseded by native subagents/summon; keep only for peer multi-agent MCP experiments.
4. **Licensing:** Goose is Apache-2.0; fork additions can use AGPL boundary model without upstream permission (mirrors Arclength `LICENSE-COPYLEFT.md` pattern).

### 2026-07-10 — Deep dive docs

5. Produced subagents/summon/recipes guide, mosh plan (goose), copyleft strategy, upstream merge guide, dual-agent worktree setup, KV integration revision, websearch requirements, unified testing report.
6. **Measured tests:** goose `--lib` 1395 tests; Arclength CLI vitest 1691 pass / 2 fail; core 67 Jest files.
7. **TECH-012:** Prefer bun/pnpm over npm (workspace + project rules).

### 2026-07-10 evening — Operator merge work

8. Operator committed `152ac6c0a` (`remote stash`) — copyleft docs, SPDX on 3 Rust files.
9. Created worktree `goose-upstream-merge-20260710T211932Z`, merged `upstream/main`.
10. Conflicts in `AGENTS.md`, `Cargo.lock`, `system-prompt.ts` — resolved via `git mergetool`; merge commit `69ca0a4f5`.
11. **Upstream highlights absorbed:** v1.42.0, `goose-local-inference` crate, provider-types split, desktop `goosed` removal → `gooseServe`, Python SDK wheels workflow.

### 2026-07-10 — G-02 recovery worktree

12. Worktree `goose-20260710T023600Z-post-outage-recovery` on `wt/post-outage-recovery-20260710`.
13. Commit `75395ca29`: RFC3339 `utils/timestamp.rs`, marker DSL, RFC drafts, websearch test fix.

### 2026-07-12 — Integration execution (this session)

14. Committed home dirt: `44a1158ae` (Justfile + SESSION_HANDOFF).
15. Merged `wt/post-outage-recovery-20260710` → `close-up-and-personal` (clean).
16. Merged `wt/upstream-merge-20260710` → `close-up-and-personal` → `aca929307` (clean auto-merge).
17. **Websearch refactor:** Removed `duckduckgo-search-cli` subprocess; primary tool `search_web`; env `GOOSE_SEARXNG_URL`.
18. **Arclength websearch:** `embeddedWebSearch.ts` (DDG API + optional SearXNG); proxy opt-in via `ARCLENGTH_WEBSEARCH_PROXY=1`.
19. SPDX headers on fork shell scripts.

---

## Git state after integration

| Branch / worktree | HEAD | Notes |
|---|---|---|
| `close-up-and-personal` (home) | `aca929307` + pending websearch commit | Ahead of bitbucket ~122 |
| `wt/post-outage-recovery-20260710` | merged into home | |
| `wt/upstream-merge-20260710` | merged into home | Worktree can be removed |
| Arclength `main` | local changes pending commit | embedded websearch |

---

## Produced files index

### Workspace (`~/code/`)

| File | Purpose |
|---|---|
| `PROJECT_RULES.md` | TECH-012 bun/pnpm, VIS rules, workspace layout |
| `SESSION_HANDOFF.md` | Global append-only mirror |
| `foss/UNIFIED_TESTING_REPORT_20260710T203100Z.md` | Cross-project testing |

### Goose fork (`foss/goose/`)

| File | Purpose |
|---|---|
| `LICENSE-COPYLEFT.md` | AGPL fork modifications notice |
| `NOTICE` | Mixed-license attribution |
| `docs/GOOSE_SUBAGENTS_SUMMONS_RECIPES_20260710T201200Z.md` | ELI5 → deep dive |
| `docs/PLAN_20260710T201200Z_MOSH_COMPATIBLE_GOOSE.md` | Mosh CLI plan |
| `docs/LICENSE_STRATEGY_COPYLEFT_20260710T201200Z.md` | Relicensing without permission |
| `docs/UPSTREAM_MERGE_GUIDE_20260710T203100Z.md` | Merge procedure |
| `docs/AGENT_WORKTREE_SETUP_20260710T203100Z.md` | Dual-agent worktrees |
| `docs/KV_STORE_INTEGRATION_REVISION_20260710T203100Z.md` | KV × templating |
| `docs/WEBSEARCH_REQUIREMENTS_20260710T203100Z.md` | Websearch spec + negative scope |
| `docs/RFC_SECRETS_KV_MVP_20260710T150000Z.md` | Secrets KV RFC (G-02) |
| `docs/RFC_RUST_LLM_INTEGRATION_20260710T150000Z.md` | Rust LLM RFC (G-02) |
| `docs/CARGO_LOCK_AUDIT_20260712T153600Z.md` | Post-upstream lock notes |
| `docs/CONVERSATION_INDEX_20260712T153600Z.md` | This file |
| `crates/goose/src/utils/timestamp.rs` | RFC3339 module |
| `crates/goose-mcp/src/websearch/mod.rs` | Embedded websearch MCP |
| `scripts/marker.py` | Marker DSL tooling |
| `marker_registry.json`, `marker_schema.json` | Classification records |

### Arclength (`foss/arclength-continuation-fossil/`)

| File | Purpose |
|---|---|
| `docs/PLAN_20260710T203100Z_MOSH_COMPATIBLE_ARCLENGTH.md` | Mosh plan |
| `docs/PLAN_20260710T203100Z_MIRROR_GOOSE_FEATURES_ARCLENGTH.md` | Feature parity plan |
| `core/context/providers/embeddedWebSearch.ts` | No-key web search |
| `core/context/providers/embeddedWebSearch.vitest.ts` | Unit test |

---

## Still open (post this session)

- KV templating Phase 1 (`prompt_manager.rs`)
- Mosh `--plain` CLI flag
- `~/code/foss/harness/` unified smoke runner
- Arclength: commit/push governance files, full rebrand worktree
- Fix 2 failing Arclength CLI vitest tests
- Remove merge worktrees after push verification
