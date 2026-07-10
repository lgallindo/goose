# Upstream Merge Guide — aaif-goose/goose → lgallindo/goose

**Created:** 2026-07-10T20:31:00Z  
**Your branch:** `close-up-and-personal` @ `bd84cddc0`  
**Upstream main:** `upstream/main` @ `9cec9f2f4` (81 commits ahead of your merge-base)

---

## Pre-flight Checklist

```bash
cd /home/lugatj/code/foss/goose
source bin/activate-hermit   # if building after merge

# 1. Clean working tree (stash or commit first)
git status

# 2. Fetch all remotes
git fetch --all

# 3. Inspect divergence
git log --oneline HEAD..upstream/main | head -20    # what upstream added
git log --oneline upstream/main..HEAD | head -20    # your fork-only commits (35)
git diff --stat upstream/main...HEAD                  # your delta summary
```

**Current uncommitted work (commit or stash before merge):**
- `docs/*_20260710*.md`, `LICENSE-COPYLEFT.md`, `NOTICE`, SPDX headers
- `SESSION_HANDOFF.md` modifications
- `AGENTS.md` delete/untracked (investigate symlink state)

---

## Recommended Merge Procedure (You Resolve Conflicts)

### Option A — Merge upstream into your branch (preserves history)

```bash
git checkout close-up-and-personal
git merge upstream/main
# Conflicts appear → resolve manually → git add → git commit
```

### Option B — Rebase onto upstream (linear history, harder)

Not recommended until conflicts are understood. Rebase rewrites your 35 commits.

### Option C — Merge in a dedicated worktree (safest)

```bash
git worktree add \
  /home/lugatj/code/foss/worktrees/goose-upstream-merge-$(date -u +%Y%m%dT%H%M%SZ) \
  -b wt/upstream-merge-20260710 \
  close-up-and-personal

cd /home/lugatj/code/foss/worktrees/goose-upstream-merge-*
git merge upstream/main
# resolve conflicts here; main checkout stays untouched
```

---

## High-Probability Conflict Zones

| Row | Path | Why | Resolution guidance |
|---|---|---|---|
| C-01 | `Cargo.toml`, `Cargo.lock` | Upstream bumped to 1.42.0; you added websearch deps | Take upstream versions; re-add `websearch` dep manually |
| C-02 | `crates/goose/src/agents/platform_extensions/developer/mod.rs` | You added ~200 lines KV store | **Keep yours**; merge upstream changes around it |
| C-03 | `crates/goose/src/prompts/*.md` | Attribution strings added | Keep attribution lines; merge upstream prompt changes |
| C-04 | `ui/pnpm-lock.yaml`, `ui/pnpm-workspace.yaml` | Both sides touched | Prefer upstream lock; re-run `pnpm install` if workspace changed |
| C-05 | `crates/goose/Cargo.toml` | Feature flags / deps diverged | Merge feature-by-feature |
| C-06 | `AGENTS.md` | Symlink vs file state messy | Restore symlink or keep fork copy; don't lose PROJECT_RULES ref |
| C-07 | `SESSION_HANDOFF.md` | Append-only sausage-making | **Keep yours** entirely |
| C-08 | `PROJECT_RULES.md` | Fork-only | **Keep yours** |
| C-09 | `docs/` | Fork added many files upstream doesn't have | No conflict (additions) unless upstream renamed same paths |
| C-10 | ACP/desktop changes (81 upstream commits) | Large upstream delta | Accept upstream for files you didn't touch |

---

## Upstream Changes You Want (81 commits)

Notable upstream since your merge-base:
- Version bump **1.42.0**
- GPT-5.6 family, Qwen3.6-27B (OVH), model inventory updates
- ACP fixes (session mode, delete apps, shell PATH)
- Desktop settings relabel, MCP app guest limit
- README relocation announcement removed
- Anthropic thinking block dedupe fix

**Opinion:** Take upstream wholesale for crates you didn't modify (`goose-cli`, `goose-server`, `ui/desktop` unless conflicted). Your value is in `developer/mod.rs`, MCP scripts, docs, KV/secrets/websearch stubs.

---

## Post-Merge Validation

```bash
source bin/activate-hermit
cargo fmt --all
cargo build -p goose -p goose-cli -p goose-mcp
cargo test -p goose --lib
cargo test -p goose-mcp --lib
cargo clippy --all-targets -- -D warnings   # expect some pre-existing warnings

# Fork-specific harness
./scripts/test-local-editor.sh              # needs llama-server on :38080
goose run --recipe goose-self-test.yaml     # long; optional
```

---

## Worktree Merge After Success

```bash
# If merged in worktree wt/upstream-merge-*:
cd /home/lugatj/code/foss/goose
git merge wt/upstream-merge-20260710   # or cherry-pick merge commit
git push origin close-up-and-personal
git push bitbucket close-up-and-personal
```

---

## What NOT to Do (Per AGENTS.md SAFE-*)

- No `git merge --ff-only` without explicit approval
- No `git push -f`
- No `git commit --amend` on pushed commits
- No autonomous conflict resolution by agent — **you** resolve, agent advises

---

## Rollback

```bash
git merge --abort                    # during conflict
git reset --merge                    # only if merge not committed (needs your explicit OK for reset)
git reflog                           # find pre-merge HEAD
```
