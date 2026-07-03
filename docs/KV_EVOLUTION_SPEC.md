# KV System Evolution Specification (Items 1-5, 7)

**Status**: Design phase | **Scope**: Session-scoped key-value store enhancements
**Deferred**: Item 6 (TOON payload envelope) - see separate analysis request below

## Item 1: Temporal Tracking

**Requirement**: Track creation, update, and access timestamps per key.

**Schema**:
```rust
struct KVEntry {
    key: String,
    value: String,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
    last_read_at: Option<DateTime<Utc>>,
}
```

**Implications**:
- Storage: Upgrade from `HashMap<String, String>` to `HashMap<String, KVEntry>`
- Queries: Enable "changed in last N minutes" filtering
- Use case: Detect stale context, conversation activity tracking

**Implementation effort**: Low (90 LOC in developer/mod.rs)

---

## Item 2: Reason Fields (Mutation Tracking)

**Requirement**: Attach optional reason/annotation to create/read/update operations.

**Schema**:
```rust
struct KVEntry {
    key: String,
    value: String,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
    last_read_at: Option<DateTime<Utc>>,
    
    // NEW
    created_reason: Option<String>,     // "initialized by agent", "set via tool"
    updated_reason: Option<String>,     // "cache invalidation", "user correction"
    read_reason: Option<String>,        // "template injection", "validation check"
}
```

**Implications**:
- Tool interface: Add optional `reason` parameter to `kv_set`, `kv_update`
- Auditing: Trace why values changed
- Debugging: Understand state transitions

**Implementation effort**: Low (120 LOC + tool parameter changes)

---

## Item 3: Version History (Per-Key Rollback)

**Requirement**: Maintain version chain per key for inspection and rollback.

**Schema**:
```rust
struct KVVersion {
    value: String,
    timestamp: DateTime<Utc>,
    reason: Option<String>,
}

struct KVEntry {
    key: String,
    current_value: String,
    versions: VecDeque<KVVersion>,    // circular buffer, max 10 versions
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
}
```

**Implications**:
- Storage: More memory per key (bounded by version count)
- Tools: Add `kv_history(key)`, `kv_rollback(key, version_num)`
- Use case: Undo incorrect agent decisions, audit trail

**Implementation effort**: Medium (180 LOC, circular buffer logic)

---

## Item 4: Namespaces with Per-Namespace Versioning

**Requirement**: Organize keys into logical groups; version entire namespaces atomically.

**Schema**:
```rust
struct Namespace {
    name: String,
    entries: HashMap<String, KVEntry>,
    version: u64,                      // bumped on any entry change
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
}

struct KVStore {
    namespaces: HashMap<String, Namespace>,
    // global version?
}
```

**Implications**:
- Tool interface: `kv_set(namespace, key, value)` instead of flat keys
- Transactions: Version bump on write ensures atomicity observation
- Use case: Separate "tool_context" from "user_preferences" from "session_state"

**Implementation effort**: Medium-High (250 LOC, namespace isolation logic)

---

## Item 5: Tags and Metadata Map

**Requirement**: Attach arbitrary tags and metadata to entries for filtering.

**Schema**:
```rust
struct KVEntry {
    key: String,
    value: String,
    tags: HashSet<String>,            // "sensitive", "ephemeral", "computed"
    metadata: HashMap<String, String>, // "type": "url", "expires_at": "2026-07-10T..."
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
}
```

**Implications**:
- Tools: Add `kv_tag(key, tag)`, `kv_query_by_tag(tag)` 
- Security: Mark sensitive data (e.g., "credentials", "pii")
- Lifecycle: Set expiration via metadata, cleanup on access
- Use case: Filter "all URLs for download", "all expired cache entries"

**Implementation effort**: Medium (200 LOC, tag filtering logic)

---

## Item 7: Append-Only Event Log (Audit & Replay)

**Requirement**: Maintain immutable log of all KV operations for audit and replay.

**Schema**:
```rust
#[derive(Clone, Serialize)]
enum KVEvent {
    Created { key: String, value: String, reason: Option<String> },
    Updated { key: String, old_value: String, new_value: String, reason: Option<String> },
    Deleted { key: String, reason: Option<String> },
    Read { key: String, timestamp: DateTime<Utc> },
    Tagged { key: String, tag: String },
}

struct KVAuditLog {
    events: Vec<(DateTime<Utc>, KVEvent)>,
    session_id: String,
    max_events: usize,  // circular buffer safety
}
```

**Implications**:
- Storage: Unbounded growth (mitigate with rotation per session)
- Tools: `kv_audit_log(session_id, filter_by_time|key|event_type)`
- Replay: Reconstruct full state at any point in time
- Use case: Debug agent decisions, compliance auditing, troubleshooting

**Implementation effort**: Low-Medium (160 LOC, log rotation logic)

---

## Item 6: TOON Payload Envelope (DEFERRED)

**Status**: PENDING external subagent analysis
**Reason**: Requires detailed use case and implementation trade-offs

**Placeholder specification**:
- Envelope format for wrapping KV values with semantic metadata
- Enables type-aware serialization (not just strings)
- Potential for structured reasoning over KV state

**Scheduled for**: Separate analysis session (date TBD)

---

## Sequencing Strategy

| Phase | Items | Effort | Priority |
|-------|-------|--------|----------|
| 1 (Foundational) | 1, 2 | Low | **CRITICAL** - foundation for auditing |
| 2 (Querying) | 3, 4, 5 | Medium | **HIGH** - enables advanced workflows |
| 3 (Durability) | 7 | Low-Medium | **MEDIUM** - compliance/debugging |
| 4 (Semantic) | 6 | ??? | **TBD** - pending analysis |

## Rollout Plan

1. **Batch 1** (Week 1): Items 1-2 (timestamps + reasons)
   - PR: Update `KVEntry` struct, tool signatures
   - Tests: Temporal queries, reason tracking
   - Integration: Update prompt context snapshot

2. **Batch 2** (Week 2): Item 3 (version history)
   - PR: Circular buffer for versions
   - Tools: `kv_history()`, `kv_rollback()`
   - Tests: Version chain integrity

3. **Batch 3** (Week 3): Items 4-5 (namespaces, tags)
   - PR: Namespace isolation, tag filtering
   - Tools: `kv_query_by_tag()`, namespace-scoped operations
   - Tests: Cross-namespace queries, tag lifecycle

4. **Batch 4** (Week 4): Item 7 (audit log)
   - PR: Event log structure, rotation policy
   - Tools: `kv_audit_log()`, time-range queries
   - Tests: Log completeness, replay validation

5. **Item 6 TBD**: Post-analysis subagent report

---

## Storage Impact Estimate

**Current**: `HashMap<String, String>` ≈ 100 keys × 200 bytes/entry = ~20 KB/session
**After Phase 1**: +timestamps ~50 bytes → ~35 KB
**After Phase 2**: +version history (10 versions × 200B) → ~250 KB worst-case
**After Phase 3**: +metadata/tags → ~300 KB
**After Phase 4**: +audit log (1000 events × 100B) → ~400 KB

**Acceptable?** Yes, per-session RAM only, cleared on session end.

---

## Testing Strategy

- **Unit tests**: Each item (serialization, filtering, version chain)
- **Integration tests**: Items combined (e.g., versioned + tagged entries)
- **E2E tests**: Full workflow (set → tag → query → audit → replay)
- **Bench**: Verify no regression in latency for common operations

---

## References

- Current implementation: [crates/goose/src/agents/platform_extensions/developer/mod.rs](crates/goose/src/agents/platform_extensions/developer/mod.rs) lines 36-163
- Related: [KV_TEMPLATING_PLUMBING.md](KV_TEMPLATING_PLUMBING.md) (enables KV data in prompts)
