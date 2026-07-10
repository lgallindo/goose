# KV Store Integration Revision — Session KV × Secrets KV × Templating

**Created:** 2026-07-10T20:31:00Z  
**Purpose:** Consolidate all KV work and propose templating integration revision

---

## 1. Inventory — What Exists

### 1.1 Session KV (IMPLEMENTED — RAM, per-session)

**Location:** `crates/goose/src/agents/platform_extensions/developer/mod.rs`

| Tool | Status |
|---|---|
| `kv_set` | Implemented |
| `kv_get` | Implemented |
| `kv_delete` | Implemented |
| `kv_list` | Implemented |

**Storage:** `HashMap<String, HashMap<String, String>>` — session_id → flat key/value. Volatile; cleared on session end.

**Documented integrations:**
- `docs/KV_TEMPLATING_PLUMBING.md` — inject `kv_snapshot` into PromptManager
- `docs/AGENTS_DETERMINISM_ANALYSIS.md` — `message_counter` auto-increment pattern
- `docs/ROADMAP_2026Q3_MCP_INTEGRATION.md` — Phase 2b complete (design)

### 1.2 Secrets KV (STUB — global, planned encrypted)

**Location:** `crates/goose/src/secrets_kv.rs` (TDD stub)

**Spec:** `docs/SECRETS_KV_STORE_SPECIFICATION.md` (984 lines)

| Feature | Status |
|---|---|
| Encrypted at rest (AES-256-GCM) | Planned |
| Template syntax `%$NAME$%` | Planned |
| Slash commands `/secret add` | Planned |
| Substitution at tool-call time only | Planned — **not during agent reasoning** |
| SQLite/RocksDB backend | Planned |

**RFC:** `docs/RFC_SECRETS_KV_MVP_20260710T150000Z.md` (worktree)

### 1.3 KV Evolution (DESIGNED — not implemented)

**Location:** `docs/KV_EVOLUTION_SPEC.md`

| Item | Description | Status |
|---|---|---|
| 1 | Temporal tracking (created/updated/read timestamps) | Spec only |
| 2 | Reason fields on mutations | Spec only |
| 3 | Per-key version history + rollback | Spec only |
| 4 | Namespaces with versioning | Spec only |
| 5 | Tags and metadata | Spec only |
| 6 | TOON payload envelope | **Deferred** |
| 7 | Append-only audit log | Spec only |

---

## 2. Templating Engine — Current State

| Engine | Location | Syntax | KV aware? |
|---|---|---|---|
| System prompts | `prompts/*.md` | Jinja2 (`{% if %}`, `{{ var }}`) | No |
| Recipes | `recipe/*.yaml` | Jinja2 + `{{ params }}` | No |
| Secrets (planned) | spec | `%$SECRET_NAME$%` | Separate pass |
| Subagent prompts | `subagent_system.md` | Jinja2 | No |

**PromptManager:** `crates/goose/src/agents/prompt_manager.rs` — builds context with `current_date_timestamp`, hints, extensions. **No KV snapshot yet.**

---

## 3. Integration Problem (Your Revision Point)

Three KV-like systems with **three template syntaxes** risk confusion:

| Store | Syntax | Lifetime | Sensitivity |
|---|---|---|---|
| Session KV | `{{ kv_snapshot.key }}` (proposed) | Session | Non-secret context |
| Secrets KV | `%$SECRET$%` | Persistent | Credentials |
| Recipe params | `{{ param }}` | Recipe run | User input |

### Recommended unified model

```
Template render pipeline (single pass, ordered):

1. Recipe parameters     → {{ param }}
2. Session KV snapshot   → {{ kv.key }}     (non-secret, volatile)
3. Secrets (deferred)    → %$SECRET$%      (substituted ONLY at tool boundary)
4. System/static context → {{ current_date_timestamp }}
```

**Critical rule (from secrets spec):** Never inject decrypted secrets into PromptManager context or Jinja templates visible to the model during reasoning. Secrets substitute only in tool argument strings immediately before MCP/shell invocation.

---

## 4. Revised Integration Plan

### Phase A — Session KV → Jinja (from KV_TEMPLATING_PLUMBING.md)

```rust
// prompt_manager.rs — add optional kv_store_ref
context.insert("kv", &json!(session_kv_map));  // not "kv_snapshot" — shorter in templates
```

```jinja2
{# system.md #}
{% if kv is defined and kv|length > 0 %}
### Session context
{% for key, value in kv.items() %}
- {{ key }}: {{ value }}
{% endfor %}
{% endif %}
```

**Trigger refresh:** Re-render system prompt when KV mutates OR on each turn (choose each turn for simplicity v1).

### Phase B — Bridge Session KV ↔ Secrets KV

| Use case | Store |
|---|---|
| Agent working memory (`message_counter`, `last_file`) | Session KV |
| GitHub PAT, API keys | Secrets KV |
| Never put secrets in Session KV | Enforce in `kv_set` validator |

### Phase C — Recipe template access to Session KV

Allow recipes to reference session state:

```yaml
prompt: |
  Current counter: {{ kv.message_counter | default('0') }}
```

Requires PromptManager to merge KV into recipe render context (same snapshot).

### Phase D — Evolution items 1–2 before 3–7

Implement timestamps + reasons on Session KV first (low effort, enables debugging templating issues).

---

## 5. Open Questions for You

| ID | Question | Options |
|---|---|---|
| Q-01 | Re-render prompt every turn vs on KV change? | Every turn (simple) / event-driven (efficient) |
| Q-02 | Namespace flat keys now or wait for Item 4? | Flat keys with `prefix:` convention |
| Q-03 | Merge `%$SECRET$%` into Jinja or keep separate pass? | **Keep separate** (security) |
| Q-04 | Expose KV to subagent prompts? | Yes, read-only snapshot |

---

## 6. Testing Requirements

| Test | Type |
|---|---|
| `kv_set` → next prompt contains value | Integration |
| Secret in `%$X$%` not in agent log | Security |
| Recipe `{{ kv.foo }}` resolves | Integration |
| KV evolution version rollback | Unit (Phase D) |

---

## 7. Document Cross-References

- [KV_TEMPLATING_PLUMBING.md](KV_TEMPLATING_PLUMBING.md)
- [KV_EVOLUTION_SPEC.md](KV_EVOLUTION_SPEC.md)
- [SECRETS_KV_STORE_SPECIFICATION.md](SECRETS_KV_STORE_SPECIFICATION.md)
- [TIMESTAMP_RFC3339_SPEC.md](TIMESTAMP_RFC3339_SPEC.md)
- [AGENTS_DETERMINISM_ANALYSIS.md](AGENTS_DETERMINISM_ANALYSIS.md)
