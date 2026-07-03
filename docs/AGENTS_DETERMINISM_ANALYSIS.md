# AGENTS Deterministic Analysis & Tooling Plan

**Created**: 2026-07-02
**Status**: Analysis complete; tooling proposals pending subagent review
**Relates to**: [AGENTS.md](AGENTS.md) phases 0-5

---

## Deterministic Analysis Results (AGT-DET-001 to AGT-DET-020)

| ID | Rule | Phase | Determinism Assessment | Risk Level | Tooling Status |
|----|----|------|--------------------------|------------|-----------------|
| AGT-DET-001 | VIS-001 (marker-driven classification) | 0 | Deterministic if marker_schema.json stable | LOW | ✓ Requires marker.py |
| AGT-DET-002 | VIS-002 (sausage-making boundaries) | 0 | Policy-dependent (requires human judgment) | MEDIUM | ⚠️ No automation possible |
| AGT-DET-003 | VIS-003 (internal marker requirements) | 0 | Deterministic (file check + marker validation) | LOW | ✓ lint-markers.py needed |
| AGT-DET-004 | VIS-004 (marker DSL + performer_id) | 0 | Deterministic if schema enforced | LOW | ✓ marker_schema.json validation |
| AGT-DET-005 | VIS-005 (marker updated_at tracking) | 0 | Deterministic (timestamp-based) | LOW | ✓ Built-in via marker.py |
| AGT-DET-006 | OP-007 (read PROJECT_RULES.md first) | 0 | **SEMI-DET**: Requires file existence check | MEDIUM | 🟡 Pre-execution gate needed |
| AGT-DET-007 | OP-008 (keep AGENTS.md read-only) | 0 | **Deterministic**: Enforced by tool whitelist | HIGH | ✓ Restrict file_edit on AGENTS.md |
| AGT-DET-008 | PLAN-006 (bootstrap PROJECT_RULES.md) | 2 | **SEMI-DET**: Conditional on file absence | MEDIUM | 🟡 Bootstrap gate needed |
| AGT-DET-009 | CORE-006 (re-read AGENTS every 3rd message) | 0 | **NOT DETERMINISTIC**: Message counter required | HIGH | ❌ **PENDING TOOLING** |
| AGT-DET-010 | PLAN-005 (SDD discovery before planning) | 2 | **SEMI-DET**: Requires file search | MEDIUM | 🟡 File detection gate (check for SDD paths) |
| AGT-DET-011 | COMM-000 (classify trivial vs non-trivial) | 1 | **NOT DETERMINISTIC**: Requires semantic judgment | HIGH | ❌ **PENDING SUBAGENT ANALYSIS** |
| AGT-DET-012 | TECH-001 (use explicit double quotes in shell) | 4 | Deterministic (syntax rule) | LOW | ✓ Lint shell commands |
| AGT-DET-013 | SAFE-005 (avoid `git add .`, stage intentionally) | 3 | **SEMI-DET**: Requires intent verification | MEDIUM | 🟡 Git command audit before execution |
| AGT-DET-014 | SAFE-011 (no force push/amend without auth) | 3 | Deterministic (command pattern matching) | HIGH | ✓ Deny-list: `git push -f`, `git commit --amend` |
| AGT-DET-015 | SAFE-012 (never `--force` without explicit auth) | 3 | Deterministic (flag matching) | CRITICAL | ✓ Deny-list: any command with `--force` or `-f` |
| AGT-DET-016 | NONTRIVIAL-000 (break non-trivial into atoms) | 5 | Deterministic (structure, not content) | LOW | ✓ Template-driven, no tooling needed |
| AGT-DET-017 | NONTRIVIAL-001 (dependency graph) | 5 | Deterministic (graph structure rules) | LOW | ✓ Template-driven (Graphviz DOT) |
| AGT-DET-018 | NONTRIVIAL-002 (leaf intents) | 5 | **SEMI-DET**: Requires semantic analysis | MEDIUM | 🟡 Adversarial analysis (no full automation) |
| AGT-DET-019 | TRLR-006 (message ID % 3 rule) | 5 | Deterministic (arithmetic) | LOW | ✓ Auto-increment message counter |
| AGT-DET-020 | CORE-007 (git hygiene: fetch --all frequently) | 3 | **SEMI-DET**: "Frequently" is policy-dependent | LOW | 🟡 Recommend after destructive ops |

---

## Unresolved High-Priority Items

### ❌ AGT-DET-009: Periodic Refresh (AGENTS Re-read Every 3rd Message)

**Rule**: CORE-006 — "Re-read `AGENTS.md` every third message to ensure strict adherence"

**Challenge**: Requires persistent message counter across sessions.

**Proposed Tooling**:
1. **Session store counter**: Track in `/memories/session/message_counter.md`
   ```
   message_count: 47
   last_agt_det_009_check: 45 (refreshed 2 messages ago)
   ```
2. **Pre-execution gate**: Before main response, check:
   ```python
   if message_count % 3 == 0:
       re_read_AGENTS_md()
       update_session_memory()
   ```
3. **Implementation**: Add to memory management tool or as pre-response hook

---

### ❌ AGT-DET-010: SDD Discovery (Lazy Evaluation - Planning Phase Only)

**Rule**: PLAN-005 — "Consult SDD definitions before drafting plans"

**Refinement**: Only evaluate this when resolving an **Atomic Prompt Item of type `Planning_Step`** during NONTRIVIAL-003 (execution order).

**Proposed Gating**:
```
if current_item.type == "Planning_Step":
    check_for_sdd_files()  # Only here, not at prompt start
    if sdd_exists:
        read_and_process_sdd()
        proceed_with_planning()
    else:
        proceed_without_sdd()
else:
    skip_sdd_check()  # Not a planning item
```

**Implementation**: Add conditional to NONTRIVIAL-003 execution loop (not global bootstrap)

---

### ❌ AGT-DET-011: Trivial vs Non-Trivial Classification (Fast Path + Subagent)

**Rule**: COMM-000 — "Classify every prompt as trivial or non-trivial"

**Refinement**: Two-phase classification:

**Phase 1: Fast Pattern Detection** (no subagent needed)
```
dangerous_strings = [
    "--force", "-f", "reset", "restore", "checkout",
    "git merge", "rewrite", "delete", "rm -rf"
]
dangerous_patterns = [
    r"after\s+\w+\s+completes",
    r"then\s+",
    r"multiple\s+",
    r"batch\s+"
]

if any(s in prompt for s in dangerous_strings):
    return "NON_TRIVIAL"  # Skip subagent
if any(re.search(p, prompt) for p in dangerous_patterns):
    return "NON_TRIVIAL"  # Skip subagent
```

**Phase 2: Semantic Subagent** (only if Phase 1 inconclusive)
- If Phase 1 returns non-trivial: **Skip subagent** (optimization)
- If Phase 1 unclear: Invoke subagent for 3-way breakdown
- Otherwise: Default to trivial (safe assumption for read-only queries)

**Result**: ~80-90% of requests skip subagent; only edge cases use it

---

### ❌ AGT-DET-015: Force/Amend Restrictions (ENFORCEMENT)

**Rule**: SAFE-012/SAFE-011 — "Never use `--force` or `-f` without explicit user authorization"

**Challenge**: Current enforcement is procedural (agent reads rule, self-enforces).

**Proposed Tooling**:
1. **Command deny-list** (exact pattern matcwith Command Aliases

**Rule**: SAFE-012/SAFE-011 — "Never use `--force` or `-f` without explicit user authorization"

**Refinement**: Command aliases + exact match in user message

**Command Registry**:
```rust
let risky_commands = vec![
    ("git push -f", "git push --force"),              // aliases for same command
    ("git commit --amend", "git commit -amend"),
    ("rm -rf", "rm -r -f"),                           // variations
    ("git reset --hard", "git reset -hard"),
    ("--force", "-f"),                                // flags alone
];

pub fn check_authorization(user_message: &str, command: &str) -> bool {
    for (cmd, alias) in &risky_commands {
        if command.contains(cmd) || command.contains(alias) {
            // Exact match check: user must explicitly write the exact command
            return user_message.contains(&command) || user_message.contains(alias);
        }
    }
    true  // Not risky, proceed
}
```

**Authorization Examples**:
```
User: "I authorize: git push -f origin feature"
Agent: ✓ Allowed (exact match in message)

User: "Please force push"
Agent: ✗ Blocked (no exact command match)

User: "I authorize this exact command: git commit --amend HEAD~1"
Agent: ✓ Allowed (explicit command in message)
```

---

## Session KV Store Integration for Deterministic Tooling

**Goal**: Persist message counter and auto-include context for AGT-DET-009

**Implementation**:

1. **Initialize on session start**:
```rust
session_kv_store.set("message_counter", "0")
```

2. **Increment on each message** (before response generation):
```rust
let counter_str = session_kv_store.get("message_counter");
let counter: u32 = counter_str.parse().unwrap_or(0);
session_kv_store.set("message_counter", &(counter + 1).to_string());
```

3. **Auto-include in prompt context** (every message):
```rust
context.insert("message_counter", &session_kv_store.get("message_counter"));
let counter: u32 = session_kv_store.get("message_counter").parse().unwrap_or(0);
if counter % 3 == 0 {
    context.insert("refresh_agents_md", true);
}
```

4. **Enable rule checking**:
```
if context["message_counter"] % 3 == 0:
    re_read_AGENTS_md()
    validate_against_rules()
```

**Benefits**: ✓ Automatic AGT-DET-009 compliance | ✓ No user intervention | ✓ Persistent state

---

## Tooling Implementation Priority
| **CRITICAL** | AGT-DET-014 (git command audit) | Low | Git safety | Agent framework |
| **HIGH** | AGT-DET-009 (periodic refresh) | Medium | AGENTS compliance | Memory system |
| **HIGH** | AGT-DET-011 (trivial classification) | High | Request routing | Subagent system |
| **MEDIUM** | AGT-DET-010 (SDD discovery) | Low | Planning compliance | Workspace analyzer |
| **LOW** | AGT-DET-006/008 (file gates) | Low | Consistency | Workspace analyzer |

---

## Remediation Workflow

**Immediate Actions** (before next request):
1. ✓ Document this analysis (DONE)
2. 🟡 Implement AGT-DET-015 force-flag deny-list (PENDING)
3. 🟡 Implement AGT-DET-014 git-command audit (PENDING)

**Next Cycle**:
4. Invoke subagent for AGT-DET-011 (trivial/non-trivial breakdown)
5. Implement AGT-DET-009 (message counter in session memory)
6. Add AGT-DET-010 gate (SDD file detection)

---

## Verification Checklist

- [ ] AGT-DET-009: Message counter initialized and incremented
- [ ] AGT-DET-010: SDD file detection functional before planning tasks
- [ ] AGT-DET-011: Subagent analysis complete; classification heuristics applied
- [ ] AGT-DET-014: Git commands blocked/audited (no `git add .` without explicit intent)
- [ ] AGT-DET-015: Force-flag blocker active; authorization flow working

---

## References

- [AGENTS.md](AGENTS.md) - Full rules
- [AGENTS.template.md](AGENTS.template.md) - Authoritative source
- [PROJECT_RULES.md](PROJECT_RULES.md) - Project-specific overrides
- Session memory: Will track unresolved items for reminder at next message
