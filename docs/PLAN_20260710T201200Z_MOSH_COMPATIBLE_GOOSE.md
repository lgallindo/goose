# Plan: Mosh-Compatible Goose Variant

**Created:** 2026-07-10T20:12:00Z  
**Status:** Draft / planning only  
**Goal:** Reliable goose CLI over `mosh` (mobile shell) with session survival across disconnects

---

## Problem Statement

Mosh differs from SSH+terminal in ways that break typical TUI agents:

| Mosh behavior | Goose impact today |
|---|---|
| Predictive/local echo | Conflicts with raw-mode TUI redraw (Ink in `ui/text`, rustyline in CLI session) |
| No server-side scrollback for full-screen apps | Ink alternate-screen content lost after detach |
| Connection migration (UDP) | Mid-render state desync; cursor position assumptions fail |
| Smaller effective terminal state | Layout overflow bugs (see PROJECT_RULES Ink guidelines) |

Goose today has:
- **Rust CLI** (`goose session`) — rustyline + streaming output
- **Ink TUI** (`ui/text`, `goose-tui`) — full-screen React-in-terminal
- **Headless** (`goose run --recipe`, `--text`) — most mosh-friendly path already

---

## Design: `goose-mosh` Profile

Not a fork — a **runtime profile** + optional thin wrapper.

### Phase 0 — Use what works today (zero code)

```bash
# Non-interactive / recipe mode over mosh (recommended baseline)
mosh user@vps -- goose run --recipe my-task.yaml

# One-shot prompt
mosh user@vps -- goose run --text "summarize logs in /var/log/nginx"

# Resume by session ID after reconnect
mosh user@vps -- goose session --resume 20260710_143022
```

**Acceptance:** Recipe runs complete; scrollback preserved in mosh client.

### Phase 1 — Detection + plain renderer flag

| Item | Change |
|---|---|
| Env detection | If `MOSH_CONNECTION` or `GOOSE_PLAIN=1`, force plain mode |
| CLI flag | `--plain` / `--no-tui` on `session` and `run` |
| Renderer | Line-at-a-time markdown (reuse `session/streaming_buffer.rs` path) |
| Disable | Ink launch, alternate screen, cursor hide |

**Files:** `crates/goose-cli/src/cli.rs`, `crates/goose-cli/src/session/mod.rs`

### Phase 2 — Session persistence for reconnect

| Item | Change |
|---|---|
| Auto-save | Persist session ID + last N messages to `~/.config/goose/sessions/` |
| Resume UX | `goose session --resume last` after mosh reconnect |
| Heartbeat | Optional `goosed` sidecar for long-running delegates while laptop sleeps |

**Files:** `crates/goose/src/session/session_manager.rs`, CLI session builder

### Phase 3 — Subagent/delegate over mosh

| Item | Change |
|---|---|
| Async delegates | Prefer `delegate(..., async: true)` in recipes used on VPS |
| Notification drain | Plain-mode parent prints subagent tool lines as prefixed log (`subagent:ID | tool`) |
| No blocking spinners | Replace indicatif/cliclack spinners with periodic plain-text status lines in plain mode |

**Files:** `summon.rs`, `goose-cli/src/session/output.rs`

### Phase 4 — VPS integration (your stack)

Align with existing local-LLM + agent-sync work:

```bash
# ~/.config/goose/config.yaml profile snippet
# profile: mosh-vps
#   plain: true
#   provider: openai-compatible
#   model: http://127.0.0.1:38080/v1
#   extensions: [developer, summon]
```

Wire to:
- `scripts/agent-bus-publish.sh` — post status on delegate completion
- `docs/AGENT_SYNC_BUS_20260710T034700Z.md` — cross-agent coordination

### Phase 5 — Validation matrix

| Test | Pass criteria |
|---|---|
| `mosh vps -- goose run --recipe smoke.yaml` | Completes, scrollback readable |
| Detach mid-session, reattach, `--resume` | Conversation continues |
| Parallel async delegates | 3 tasks finish ~2s apart not ~6s |
| Local editor via developer extension | No alternate-screen corruption |

---

## Minimal AS-IS → TO-BE (Phase 1)

| AS-IS | TO-BE |
|---|---|
| Session always uses TUI/streaming assumptions | `GOOSE_PLAIN=1` selects line renderer |
| Ink TUI default for some entrypoints | Skip Ink when plain |
| User must know `--text` / `--recipe` | Document mosh profile in fork docs |

---

## Non-Goals (v1)

- Patch mosh itself
- Full desktop Electron over mosh
- GooseTeam-style multi-process peer agents

---

## Estimated Effort

| Phase | Effort | Value |
|---|---|---|
| 0 (docs + recipes) | 1 hour | High — usable now |
| 1 (plain flag) | 2–4 days | High |
| 2 (resume) | 3–5 days | Medium |
| 3 (delegate plain output) | 2–3 days | Medium |
| 4 (VPS profile) | 1 day | High for your use case |
