# Embedded Web Search — Requirements, Plans, Negative Scope

**Created:** 2026-07-10T20:31:00Z  
**Status:** TDD stubs implemented; production design incomplete

---

## 1. Original Requirement (SESSION_HANDOFF 2026-07-04)

> Embedded native Rust web search library for Goose (**no MCP server, no external API keys**).

---

## 2. Positive Requirements

| ID | Requirement | Priority |
|---|---|---|
| WS-01 | Search from within goose without Tavily/Exa/Perplexity API keys | CRITICAL |
| WS-02 | Pure Rust implementation path (embedded in goose-mcp or goose crate) | HIGH |
| WS-03 | FOSS dependencies only; MIT/Apache-2.0 preferred (GPL-compatible) | HIGH |
| WS-04 | DuckDuckGo as default provider (no API key) | HIGH |
| WS-05 | Optional local SearXNG at `http://localhost:8080` | MEDIUM |
| WS-06 | Unified `uber_search` aggregating multiple backends | MEDIUM |
| WS-07 | Graceful degradation when a backend fails | HIGH |
| WS-08 | Return title + URL (minimum); snippet optional | HIGH |
| WS-09 | Limit results (default 3) for token budget | HIGH |
| WS-10 | TDD: tool registration tests before implementation | DONE |

---

## 3. Negative Scope (Explicitly Out of Scope)

| ID | Excluded | Reason |
|---|---|---|
| NS-01 | **SearXNG engine embedding** | `searxng-client` is API wrapper only; cannot embed Python/Flask engine |
| NS-02 | **Tavily / Exa / commercial search APIs** as default | Requires API keys; upstream has separate MCP extensions for these |
| NS-03 | **JavaScript rendering / headless browser** | Heavy deps; out of embedded Rust scope |
| NS-04 | **Caching layer / Redis** | v1 complexity; session-level cache deferred |
| NS-05 | **Search result persistence to disk** | Privacy; not required for MVP |
| NS-06 | **Rate limit bypass / scraping evasion** | Legal/ToS risk |
| NS-07 | **Replacing upstream computer-controller web_search** | Parallel capability; different use case |
| NS-08 | **MCP server as separate process** for embedded search | Contradicts "embedded" goal (current stub is builtin MCP module — acceptable interim) |

---

## 3. Candidates Evaluated (2026-07-04 Research)

| Crate | License | Verdict |
|---|---|---|
| `websearch` 0.1.1 | MIT | **Selected** — DDG provider |
| `duckduckgo-search-cli` / `duckduckgo_search` | MIT/Apache | Fallback path |
| `searxng-client` | FOSS | Optional; requires running SearXNG instance |
| SearXNG engine itself | AGPL | **Disqualified** for embedding |

---

## 4. Current Implementation (Coded)

**File:** `crates/goose-mcp/src/websearch/mod.rs` (AGPL-3.0-or-later)

| Tool | Implementation status |
|---|---|
| `search_websearch_crate` | Calls `websearch::web_search` + DDG provider |
| `search_duckduckgo_cli_crate` | Spawns `cargo run --bin duckduckgo-search-cli` (**fragile**) |
| `search_searxng_client_crate` | HTTP to localhost:8080 |
| `uber_search` | `futures::join!` over all three |

**Tests:** `test_websearch_tools_exist` — registration only, no network.

**Deps added:** `websearch = "0.1.1"` in `goose-mcp/Cargo.toml`

---

## 5. Known Issues / Gaps

| Issue | Severity |
|---|---|
| DDG CLI fallback spawns cargo subprocess — wrong for production | HIGH |
| No network integration tests ( flaky / ToS ) | MEDIUM |
| `uber_search` debug-prints Content — ugly output | LOW |
| Not wired as default builtin extension in config | MEDIUM |
| Upstream 1.42.0 may conflict on goose-mcp/Cargo.toml merge | HIGH |

---

## 6. Recommended Next Steps

1. **Remove** cargo subprocess fallback; use `reqwest` minimal DDG lite API or `websearch` crate only
2. Add feature flag `embedded-websearch` default off until stable
3. Integration test with `wiremock` HTTP mock (no live DDG)
4. Wire into `config.yaml` builtin extensions list
5. Document in PROJECT_RULES: when to use embedded vs Tavily MCP

---

## 7. Arclength Port Notes

Port as TypeScript core tool — not Rust MCP. Same negative scope applies. See mirror plan M-05.
