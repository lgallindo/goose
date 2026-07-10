# Dual-Agent Worktree Setup — Goose Copyleft + Arclength Rebrand

**Created:** 2026-07-10T20:31:00Z

---

## Prerequisites

- Copyleft files committed on goose: `LICENSE-COPYLEFT.md`, `NOTICE`, SPDX headers
- Arclength already has `LICENSE-COPYLEFT.md` (GPL-3.0-or-later)
- Read `AGENT_COORDINATION.md` in each repo before parallel work

---

## Agent 1 — Goose: Copyleft + Upstream Merge Prep

### Create worktree

```bash
cd /home/lugatj/code/foss/goose
git fetch --all

git worktree add \
  /home/lugatj/code/foss/worktrees/goose-copyleft-upstream-$(date -u +%Y%m%dT%H%M%SZ) \
  -b wt/copyleft-upstream-merge \
  close-up-and-personal
```

### Agent 1 mission brief (paste to agent)

```
Repository: /home/lugatj/code/foss/worktrees/goose-copyleft-upstream-*
Branch: wt/copyleft-upstream-merge

Read first:
- LICENSE-COPYLEFT.md, NOTICE, docs/UPSTREAM_MERGE_GUIDE_20260710T203100Z.md
- PROJECT_RULES.md, SESSION_HANDOFF.md (append-only)

Tasks (in order):
1. Commit pending copyleft files if not on branch yet
2. Merge upstream/main — STOP at conflicts, list each conflict file with AS-IS/TO-BE recommendation; do NOT auto-resolve
3. Complete SPDX header pass on all fork-authored scripts in scripts/
4. Implement KV_TEMPLATING_PLUMBING Phase 1 (prompt_manager kv_snapshot) — TDD first
5. Append SESSION_HANDOFF milestone

Constraints:
- No git push -f, no amend, no merge --ff-only
- No git add . — stage files individually
- Destructive ops require user approval
```

### Agent 1 lock zones

- `crates/goose/src/agents/prompt_manager.rs`
- `LICENSE*`, `NOTICE`
- `Cargo.toml` / `Cargo.lock` (coordinate with user on merge)

---

## Agent 2 — Arclength: Full Rebrand + Copyleft Hardening

### Create worktree

```bash
cd /home/lugatj/code/foss/arclength-continuation-fossil
git fetch origin

git worktree add \
  /home/lugatj/code/foss/worktrees/arclength-rebrand-$(date -u +%Y%m%dT%H%M%SZ) \
  -b wt/full-rebrand-gpl \
  main

# Copy node_modules efficiently (from worktree-config.yaml)
# Manual: rsync -a --link-dest=../arclength-continuation-fossil/node_modules \
#   ../arclength-continuation-fossil/node_modules ./node_modules 2>/dev/null || true
```

### Agent 2 mission brief (paste to agent)

```
Repository: /home/lugatj/code/foss/worktrees/arclength-rebrand-*
Branch: wt/full-rebrand-gpl

Read first:
- LICENSE-COPYLEFT.md, README.md, AGENT_COORDINATION.md
- docs/PLAN_20260710T203100Z_MIRROR_GOOSE_FEATURES_ARCLENGTH.md
- docs/PLAN_20260710T203100Z_MOSH_COMPATIBLE_ARCLENGTH.md
- scripts/rebrand.py (use carefully — caused identifier corruption before)

Tasks (in order):
1. Pull origin/main (1 commit behind), resolve any conflicts
2. Rebrand: Continue → ArclengthContinuation (NO hyphens in TS identifiers)
3. SPDX pass on all modified TS/Rust files
4. VS Code extension: update displayName, publisher, icons, package.json scopes
5. CLI: plain-mode / mosh profile (Phase 0 from mosh plan)
6. Commit untracked governance files (marker_registry, scripts/marker.py) if approved
7. Append SESSION_HANDOFF.md

Constraints:
- NEVER use rebrand.py global replace on TypeScript identifiers
- Check AGENT_COORDINATION.md locks before editing core/**/*.ts
- IntelliJ plugin: document-only unless user approves Gradle work
- CI remains disabled (.github/workflows.disabled/)
```

### Agent 2 lock zones

- `extensions/vscode/package.json`, `extensions/vscode/src/**`
- `gui/src/**`, `core/**/*.ts`
- `extensions/intellij/**` (read-only unless user approves)

---

## Coordination Between Agents

| Bus | Path |
|---|---|
| Global handoff | `/home/lugatj/code/SESSION_HANDOFF.md` |
| Goose handoff | `foss/goose/SESSION_HANDOFF.md` |
| Arclength handoff | `foss/arclength-continuation-fossil/SESSION_HANDOFF.md` |
| Agent sync | `/home/lugatj/code/.agent_sync/inbox.jsonl` |

**No shared files** between worktrees except handoff logs — append with distinct entry IDs.

---

## Launch Commands (Two Terminals)

```bash
# Terminal 1 — Goose agent (Cursor / Codex / goose)
cd /home/lugatj/code/foss/worktrees/goose-copyleft-upstream-*
cursor .   # or your agent CLI

# Terminal 2 — Arclength agent
cd /home/lugatj/code/foss/worktrees/arclength-rebrand-*
cursor .
```

---

## Merge Back Policy

1. User reviews each worktree branch
2. User resolves any cross-repo dependency manually (none expected in v1)
3. Merge to `close-up-and-personal` (goose) and `main` (arclength) separately
4. Remove worktrees after merge: `git worktree remove <path>`
