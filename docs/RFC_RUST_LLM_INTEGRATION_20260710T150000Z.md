# RFC: Rust LLM Integration (Alternative 3)

**Status**: RFC DRAFT  
**Date**: 2026-07-10T15:00:00Z  
**Branch**: `wt/post-outage-recovery-20260710`  
**Deadline**: 2026-07-31 (roadmap)

## Motivation

Replace shell bridges (`aider-local-bridge.sh`) and external runtimes with a native Rust path to local OpenAI-compatible endpoints (llama.cpp on `127.0.0.1:38080`), reducing deployment surface and aligning with goose's Rust codebase.

## Non-goals (MVP)

- On-device GGUF loading inside goose process  
- Training / fine-tuning  
- Replacing cloud providers for production workloads  

## Design

### Phase A — HTTP provider only (4 weeks)

Extend `RustLlmProvider` (stub in `crates/goose/src/rust_llm.rs`) to wrap existing OpenAI-compatible client:

```rust
pub struct LocalOpenAiProvider {
    base_url: String,  // http://127.0.0.1:38080/v1
    model: String,
    client: reqwest::Client,
}

impl LocalOpenAiProvider {
    pub async fn chat(&self, messages: &[Message]) -> Result<String>;
    pub async fn stream(&self, messages: &[Message]) -> Result<impl Stream<Item = String>>;
}
```

Wire into `Provider` trait alongside existing OpenAI provider; select via `GOOSE_PROVIDER=openai` + `OPENAI_HOST`.

### Phase B — Optional embedded inference (future)

Evaluate only if Phase A insufficient:

| Crate | Pros | Cons |
|-------|------|------|
| `llama-cpp-rs` / `llama-cpp-2` | Direct GGUF, no separate server | Build complexity, GPU drivers |
| `ort` (ONNX) | Portable | Model conversion pipeline |
| `burn` | Pure Rust | Immature for coder models |

**Recommendation**: Stay on HTTP to llama-server for MVP; revisit embedded in Q4 if latency/ops cost justifies.

## Alternatives considered

| Option | Verdict |
|--------|---------|
| Shell bridge (current) | Keep until Phase A ships |
| Aider dependency | Out of scope for goose core |
| LiteLLM proxy | Rejected per project policy |

## Risks

| Risk | Mitigation |
|------|------------|
| Small model tool-calling quality | `GOOSE_TOOLSHIM=true` (validated in harness) |
| Context limits (1.5B / 32k) | Document in provider metadata |
| Duplicate OpenAI client code | Reuse `goose_providers::openai` internals |

## Success criteria

1. `cargo test -p goose rust_llm` — integration test against mock server  
2. `goose run` with env pointed at 38080 — no shell wrapper required  
3. Latency within 10% of direct curl chat completion  

## References

- `docs/AIDER_API_WRAPPER_PLAN.md` (Alternative 1, complete)  
- `scripts/test-local-editor.sh` (6/6 curl harness)  
- `crates/goose/src/rust_llm.rs` (stub)
