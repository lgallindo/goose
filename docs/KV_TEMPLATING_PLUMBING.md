# KV-to-Templating Plumbing Design

## Goal
Enable session-scoped key-value store data to be injected into prompt templates without an extra rendering pass.

## AS-IS Architecture

Current flow:
1. **PromptManager** ([crates/goose/src/agents/prompt_manager.rs](crates/goose/src/agents/prompt_manager.rs)) assembles context
2. **Template variables** injected: `current_date_timestamp`, system hints, extensions
3. **System prompt** ([crates/goose/src/prompts/system.md](crates/goose/src/prompts/system.md)) renders with `{% if ... %}{{ }}{% endif %}`
4. **No KV data** currently exposed to templates

## TO-BE Architecture

**Minimal approach** (no extra rendering session):

```
DeveloperPlatformExtension (KV store)
          ↓
    session_kv_store (RwLock<HashMap>)
          ↓
PromptManager::build_context()  ← NEW: read KV snapshot
          ↓
context["kv_snapshot"] = json!({ "key1": "val1", ... })
          ↓
system.md template: {% for k, v in kv_snapshot.items() %}...{% endfor %}
          ↓
final_prompt
```

## Implementation Plan

### Phase 1: Add KV snapshot to context (MINIMAL CHANGE)

**File**: [crates/goose/src/agents/prompt_manager.rs](crates/goose/src/agents/prompt_manager.rs)

**Changes**:
1. Add reference to `DeveloperPlatformExtension` in `PromptManager::build_context()`
2. At context assembly time, read `session_kv_store` (read lock only, no mutation)
3. Serialize to JSON and add as `"kv_snapshot"` to template context

```rust
// Inside build_context() method, after other context setup:

let mut context = Context::new();
context.insert("current_date_timestamp", &self.manager.current_date_timestamp);

// NEW: Add KV snapshot
if let Some(kv_store) = &self.kv_store_ref {
    let kv_lock = kv_store.read().await;
    let session_data = kv_lock.get(session_id).unwrap_or_default().clone();
    context.insert("kv_snapshot", &json!(session_data));
}

// Continue with other context...
```

### Phase 2: Template usage (NO SCHEMA CHANGE)

**File**: [crates/goose/src/prompts/system.md](crates/goose/src/prompts/system.md)

Example template snippet:
```jinja2
{% if kv_snapshot is defined and kv_snapshot|length > 0 %}
### Available Context from Session KV Store:
{% for key, value in kv_snapshot.items() %}
- `{{ key }}`: {{ value }}
{% endfor %}
{% endif %}
```

### Phase 3: Type safety

Create wrapper struct for KV context:
```rust
#[derive(Serialize)]
struct KVSnapshot {
    data: HashMap<String, String>,
    session_id: String,
    last_updated: DateTime<Utc>,
}
```

**Benefit**: Avoids raw JSON, enables future versioning.

## Trade-offs

| Approach | Pros | Cons | Chosen |
|----------|------|------|--------|
| **Inject KV into template context (chosen)** | Single render pass, minimal code, no schema changes | KV data becomes static per prompt | ✓ |
| Extra rendering pass after KV mutation | KV always fresh | Doubles rendering overhead, complex state mgmt | ✗ |
| Push KV to extension messages | Async-friendly, reactive | Changes message protocol, larger msgs | ✗ |

## Execution Order

1. Add `session_id` and `kv_store_ref` as optional fields to `PromptManager`
2. In `build_context()`, read KV snapshot (read lock only)
3. Add to template context as `"kv_snapshot"`
4. Update system.md to optionally display KV data
5. Test: Set KV value via tool, verify it appears in next prompt context

## Code Footprint

- **Additions**: ~15 lines in prompt_manager.rs (read + serialize)
- **Modifications**: 1 line in system.md (optional template block)
- **No breaking changes**: Existing templates continue working

## Risk Assessment

**Low risk**: 
- Read-only access to KV store (no mutation)
- Optional template block (backward compatible)
- Single render pass unchanged

**Testing strategy**:
1. Unit test: KV snapshot serializes correctly
2. Integration test: KV data flows to template context
3. E2E test: Agent can read its own KV values from prompts

## Future Evolution

Once working, enables:
- KV-aware prompt routing (different prompts for different context)
- Automatic context summarization (compress large KV for token efficiency)
- Multi-turn conversation state in prompts
