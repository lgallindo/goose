# RFC: Secrets KV Store MVP

**Status**: RFC DRAFT  
**Date**: 2026-07-10T15:00:00Z  
**Supersedes**: Planning-only phase in `docs/SECRETS_KV_STORE_SPECIFICATION.md`  
**Branch**: `wt/post-outage-recovery-20260710`

## Summary

Implement encrypted at-rest secret storage with template substitution at tool-invocation time only (`%$SECRET_NAME$%`), exposed via slash commands and a `SecretsKvStore` Rust module.

## Scope (MVP)

| In | Out |
|----|-----|
| AES-256-GCM + Argon2id key derivation | HSM, external vaults |
| `save` / `get` / `list` / `delete` | Versioning, RBAC |
| Per-user global store (SQLite) | Per-session isolation (Phase 2) |
| Redaction in tool output | Audit log UI |

## API sketch

```rust
// crates/goose/src/secrets_kv.rs (extend existing stub)
pub struct SecretsKvStore { /* encrypted sqlite */ }

impl SecretsKvStore {
    pub fn unlock(master_password: &str) -> Result<Self>;
    pub fn put(&self, name: &str, value: &str) -> Result<()>;
    pub fn get_template(&self, name: &str) -> Option<String>; // returns %$NAME$%
    pub fn resolve_at_invocation(&self, template: &str) -> Result<String>;
}
```

## Slash commands (CLI)

- `/secret add <name>` — prompt for value  
- `/secret list` — names only, never values  
- `/secret remove <name>`

## Dependencies (via `cargo add`, not manual edit)

- `rusqlite`, `aes-gcm`, `argon2`, `zeroize`, `keyring` (optional OS keyring for master key)

## Test plan (TDD)

1. `test_put_get_roundtrip` — encrypted blob in sqlite, plaintext never on disk  
2. `test_template_substitution_only_at_invoke` — agent log contains `%$TOKEN$%`, not value  
3. `test_redaction_in_tool_output` — output scrubbed before display  

## Timeline

| Week | Deliverable |
|------|-------------|
| 1 | RFC approval + schema + failing tests |
| 2–3 | Encryption layer + sqlite |
| 4 | Slash commands + integration |

## Open decisions (need operator)

1. Master key: password-only vs OS keyring default?  
2. Audit retention: 90 days recommended  

## References

- `docs/SECRETS_KV_STORE_SPECIFICATION.md` (full design)  
- `crates/goose/src/secrets_kv.rs` (current in-memory stub, commit `0881bf402`)
