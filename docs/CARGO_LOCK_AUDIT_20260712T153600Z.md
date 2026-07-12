# Cargo.lock Audit — Post upstream/main Merge

**Created:** 2026-07-12T15:36:00Z  
**Branch:** `close-up-and-personal` @ post `aca929307`

---

## Fork-specific dependencies to verify

| Crate | Package | Action |
|---|---|---|
| `goose-mcp` | `websearch` 0.1.1 | Keep — embedded DDG |
| `goose-mcp` | `searxng-client` 0.1.0 | Keep — optional local SearXNG |
| `goose-mcp` | ~~`duckduckgo-search-cli`~~ | **Removed** 2026-07-12 |

---

## Upstream structural changes affecting lockfile

- New crates: `goose-local-inference`, `goose-download-manager`, `goose-provider-types`
- Removed: `goose-server` as standalone crate (desktop uses embedded serve)
- Provider JSON defs moved under `goose-providers/src/declarative/definitions/`

---

## Validation commands

```bash
cd /home/lugatj/code/foss/goose
source bin/activate-hermit
cargo build -p goose-mcp -p goose -p goose-cli
cargo test -p goose-mcp --lib
cargo deny check licenses   # if cargo-deny installed
```

---

## Result (2026-07-12)

- `cargo build -p goose-mcp` — **PASS** (v1.42.0)
- `cargo test -p goose-mcp --lib websearch` — **2/2 PASS**
- Full workspace build — operator should run before release

---

## Operator notes

- After any manual `Cargo.toml` edit, run `cargo build` to refresh lockfile consistently.
- Do not hand-merge `Cargo.lock` conflict regions — prefer regenerate via build after resolving `Cargo.toml`.
