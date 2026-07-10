# Goose Fork: Copyleft Strategy (No Upstream Permission Required)

**Created:** 2026-07-10T20:12:00Z  
**Applies to:** `lgallindo/goose` fork modifications only

---

## Constraint

You asked for:
1. **No permission** from Block/AAIF/upstream contributors
2. **Your additions** as copyleft as possible
3. Failing that, **non-commercial**

---

## What Apache-2.0 Already Allows (No Permission)

Upstream goose is **Apache-2.0**. You may:
- Fork and modify freely
- Create derivative works
- License **your new files** under a stronger copyleft (GPL-3.0-or-later, AGPL-3.0-or-later)
- Keep upstream files under Apache-2.0 with notices preserved

You may **not** (without contributor/AAIF agreement):
- Re-license upstream-authored files to remove Apache obligations
- Strip copyright/patent notices
- Claim the entire combined work is "GPL only" without marking file boundaries

**Precedent in your workspace:** [arclength-continuation-fossil/LICENSE-COPYLEFT.md](/home/lugatj/code/foss/arclength-continuation-fossil/LICENSE-COPYLEFT.md) — same pattern for Continue fork.

---

## Recommended: Dual-License Boundary Model

| Layer | License | Permission needed? |
|---|---|---|
| Unmodified upstream files | Apache-2.0 | No |
| Your new files (docs, scripts, new modules) | **GPL-3.0-or-later** or **AGPL-3.0-or-later** | No |
| Files mixing upstream + your edits | Apache-2.0 for upstream portions; GPL for your additions (SPDX per file) | No |
| Entire repo relicense to single GPL | Yes — impractical | Yes |

### GPL vs AGPL for your goal

| License | Copyleft strength | When to pick |
|---|---|---|
| **GPL-3.0-or-later** | Strong — derivatives must share source on distribution | CLI tools, local VPS binaries you distribute |
| **AGPL-3.0-or-later** | Strongest — triggers on **network use** (SaaS) | If you run `goosed` as a network service others use |

**Recommendation:** **AGPL-3.0-or-later** for new Rust modules (`rust_llm.rs`, `secrets_kv.rs`, websearch) and scripts if VPS-hosted goose-server might be accessed by others. **GPL-3.0-or-later** for docs-only and shell scripts if network trigger is unwanted.

## Implementation Status (2026-07-10)

- [x] `LICENSE-COPYLEFT.md` created
- [x] `NOTICE` created
- [x] SPDX headers on `rust_llm.rs`, `secrets_kv.rs`, `websearch/mod.rs`
- [ ] SPDX pass on all `scripts/*.sh` (Agent 1 task)
- [ ] File-level audit before any public release

---

## Non-Commercial Option (Weaker Recommendation)

| Approach | Permission? | Problems |
|---|---|---|
| Custom NC addendum on your files only | No | Not OSI-approved; incompatible with Apache redistribution norms; scares contributors |
| CC BY-NC 4.0 on docs | No | Docs only; code still Apache/GPL mix |
| Commons Clause / SSPL | No | Not copyleft; legal ambiguity; npm/cargo ecosystem friction |

**Verdict:** NC does **not** satisfy "as close to copyleft as possible." GPL/AGPL on **your new files** is cleaner and needs zero upstream permission.

---

## Implementation Checklist (No Permission Path)

1. Add `LICENSE-COPYLEFT.md` (copy from arclength-continuation-fossil template, adapt for goose)
2. Keep root `LICENSE` as upstream Apache-2.0 text unchanged
3. Add SPDX headers to **new** files:
   ```text
   // SPDX-License-Identifier: AGPL-3.0-or-later
   // Copyright (c) 2026 Lucas Gallindo
   ```
4. For modified upstream files, add at top:
   ```text
   // Modifications Copyright (c) 2026 Lucas Gallindo — AGPL-3.0-or-later
   // Original work Copyright Block/AAIF — Apache-2.0
   ```
5. Generate `NOTICE` aggregating both licenses + dependency licenses
6. **Do not** change `Cargo.toml` workspace `license = "Apache-2.0"` for upstream crates; new crates can declare `license = "AGPL-3.0-or-later"`

---

## Hardness Rating

| Action | Difficulty |
|---|---|
| GPL/AGPL on new files only | **Easy** — 1–2 days (legal doc + SPDX pass on your 58-file delta) |
| GPL on all modified upstream files (boundary model) | **Medium** — file-by-file audit |
| Relicense entire goose monorepo to single copyleft | **Very hard** — requires AAIF + all contributors |
| NC overlay | **Medium legally, high friction practically** — not recommended |

---

## What You Cannot Achieve Without Permission

- Making upstream Block/AAIF code non-commercial
- Removing Apache notice requirements from inherited files
- Single-license "GPL-only goose" distribution of unmodified upstream crates
