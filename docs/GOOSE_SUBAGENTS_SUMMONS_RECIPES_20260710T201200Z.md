# Goose: Recipes, Summon, and Subagents

**Created:** 2026-07-10T20:12:00Z  
**Scope:** ELI5 → technical deep dive → code review pointers  
**Upstream:** AAIF goose (Apache-2.0)

---

## 1. ELI5 — The Kitchen Analogy

Imagine goose is a **head chef** in a kitchen.

| Concept | Kitchen analogy |
|---|---|
| **Recipe** | A written menu card: "Make tomato soup. Use these ingredients (extensions). Ask the customer how spicy (parameters)." Anyone can photocopy and share the card. |
| **Summon** | The chef's **sous-chef station**. Two jobs: (1) pull a reference book off the shelf and read it aloud (`load`), or (2) send a helper to another counter to cook one dish (`delegate`). |
| **Subagent** | A **helper cook** with one assignment, their own tools, and a turn limit. They report back when done. They cannot hire more helpers. |

**Flow:** You give goose a Recipe → goose follows it. Mid-recipe, goose may use Summon to `load` a skill or `delegate` work to subagents (possibly in parallel). Each subagent runs as an isolated session with a tighter system prompt.

---

## 2. Middle Ground — When to Use What

| Need | Use |
|---|---|
| Repeatable one-shot task ("plan a trip", "run security scan") | **Recipe** via `goose run --recipe foo.yaml` |
| Teach goose a workflow once, reuse in chat | **Skill** in `.agents/skills/` + Summon `load` |
| Offload a subtask without bloating main context | Summon **`delegate`** → **subagent** |
| Multi-step pipeline with predefined child steps | Recipe with **`sub_recipes`** |
| Parallel research / build tasks | Summon **`delegate(..., async: true)`** × N in one message |
| Human chat session with ad-hoc delegation | Interactive **`goose session`** + enabled Summon extension |

**Key distinction:** Recipes define *what to run*. Summon is the *runtime tool* that loads knowledge or spawns subagents. Subagents are the *execution mechanism* for delegated work.

---

## 3. Recipes — Technical Reference

### 3.1 Data model

```rust
// crates/goose/src/recipe/mod.rs
pub struct Recipe {
    pub version: String,
    pub title: String,
    pub description: String,
    pub instructions: Option<String>,  // system-level guidance
    pub prompt: Option<String>,        // user kickoff message
    pub extensions: Option<Vec<ExtensionConfig>>,
    pub settings: Option<Settings>,
    pub parameters: Option<Vec<RecipeParameter>>,
    pub response: Option<Response>,    // optional JSON schema output
    pub sub_recipes: Option<Vec<SubRecipe>>,
    pub retry: Option<RetryConfig>,
}

pub struct SubRecipe {
    pub name: String,
    pub path: String,
    pub values: Option<HashMap<String, String>>,
    pub sequential_when_repeated: bool,
}
```

At least one of `instructions` or `prompt` must be set. Templates use `{{ parameter }}` and Jinja-style `{% if %}` blocks.

### 3.2 Execution paths

```bash
goose run --recipe trip.yaml --params destination=Europe --params duration=14
goose run --recipe goose-self-test.yaml
goose run --explain --recipe my-recipe.yaml   # inspect without running
```

Recipes can pin extensions (MCP servers, builtins), provider settings, and activities (UI pills). Sub-recipes resolve paths relative to the parent recipe file (`manifest.rs` → `resolve_recipe_sub_recipe_paths`).

### 3.3 Code review notes

- **Strengths:** Single-file shareability; extension sandboxing; parameter validation; sub-recipe composition.
- **Risks:** Recipe YAML is executable policy — treat untrusted recipes like code (desktop shows "Trust and Execute" dialog).
- **Fork note:** Your `goose-self-test.yaml` is an integration harness exercising Summon delegate sync vs async parallelism.

---

## 4. Summon — Technical Reference

### 4.1 Platform extension

Built-in platform extension name: `summon` (`crates/goose/src/agents/platform_extensions/summon.rs`).

**Tools (conceptual):**

| Tool | Purpose |
|---|---|
| `load` | Inject skill/recipe/agent/subrecipe content into parent context (no subagent) |
| `delegate` | Spawn subagent with instructions, optional source recipe, extensions, provider override |
| Background task APIs | Track async delegates (`BackgroundTask`, `CompletedTask`) |

### 4.2 Delegate parameters

```rust
pub struct DelegateParams {
    pub instructions: Option<String>,
    pub source: Option<String>,           // recipe/skill path or name
    pub parameters: Option<HashMap<String, serde_json::Value>>,
    pub extensions: Option<Vec<String>>,
    pub provider: Option<String>,
    pub model: Option<String>,
    pub temperature: Option<f32>,
    pub max_turns: Option<usize>,
    pub context: Option<String>,
    pub working_dir: Option<String>,
    pub r#async: bool,                     // parallel when true + batched
}
```

**Parallelism rule** (from `goose-self-test.yaml`):
- Sync delegates in one message → **sequential**
- Async delegates (`async: true`) in one message → **parallel**

### 4.3 Source discovery

Summon scans configured directories for:
- Skills (`.agents/skills/**/SKILL.md`)
- Recipes (yaml/json)
- Agent definitions (YAML frontmatter + body)
- Subrecipes

`load()` with no args lists discoverable sources.

### 4.4 Code review notes

- **Strengths:** Clean separation of knowledge injection vs execution; async task tracking; recipe templating reuse.
- **Risks:** `summon.rs` is ~2,900 lines — high complexity; delegate failures may be opaque to parent without reading notification buffer.
- **Deprecation:** Pre-v1.25 "Skills MCP" replaced by Summon platform extension.

---

## 5. Subagents — Technical Reference

### 5.1 Lifecycle

```
Parent agent calls summon.delegate(...)
        │
        ▼
run_subagent_task(SubagentRunParams)     // subagent_handler.rs
        │
        ├─ Agent::with_config(config)
        ├─ SessionType::SubAgent (no recursive spawn)
        ├─ apply_recipe_components (optional JSON schema)
        ├─ override_system_prompt(subagent_system.md)
        └─ agent.reply(...) → stream until max_turns or completion
        │
        ▼
Return text summary to parent (return_last_only configurable)
```

### 5.2 System prompt constraints

From `crates/goose/src/prompts/subagent_system.md`:

- Bounded turns (`{{max_turns}}`)
- Task instructions injected from recipe
- Tool list summarized (efficiency rules)
- **Cannot spawn additional subagents** (security boundary)
- Markdown responses; final message should be summary when requested

### 5.3 Session isolation

- Separate session ID per subagent
- Optional extension subset via `TaskConfig.extensions`
- Provider/model can differ from parent (`task_config.provider`)
- Tool calls forwarded to parent UI via `subagent_tool_request` notifications

### 5.4 Code review notes

- **Strengths:** Clear security boundary (no recursive subagents); template-driven prompts; cancellation token support.
- **Risks:** Failed extension attach is debug-log only (silent degradation); `return_last_only` may drop useful tool traces.
- **Not GooseTeam:** Subagents are hierarchical (parent/child), not peer agents with shared MCP message bus.

---

## 6. How the Three Fit Together

```text
┌─────────────────────────────────────────────────────────┐
│  Recipe (YAML) — static definition                      │
│  • prompt / instructions / extensions / sub_recipes     │
└───────────────────────────┬─────────────────────────────┘
                            │ goose run OR parent session
                            ▼
┌─────────────────────────────────────────────────────────┐
│  Main Agent Session                                     │
│  • Summon extension enabled                             │
└───────────────┬─────────────────────┬───────────────────┘
                │ load(skill)         │ delegate(task)
                ▼                     ▼
         Context injection     Subagent session(s)
         (no new process)      (isolated Agent + reply loop)
```

---

## 7. Quick Reference Commands

```bash
# Recipe one-shot
goose run --recipe my-task.yaml --params key=value

# Interactive session with Summon
goose configure   # enable summon extension
goose session

# Self-test harness (includes delegation tests)
goose run --recipe goose-self-test.yaml
```

---

## 8. Further Reading (upstream docs)

- `documentation/docs/tutorials/recipes-tutorial.md`
- `documentation/docs/mcp/summon-mcp.md`
- `documentation/docs/tutorials/subagents.md`
- `documentation/docs/tutorials/subrecipes-in-parallel.md`
