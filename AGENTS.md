# Instructions for AI Agents

This template is organized in deterministic execution phases to reduce instruction-selection ambiguity for LLMs.

## Phase 0 - Bootstrap, Scope, and Source of Truth
- **VIS-001**: Internal classification is marker-driven, not host-driven. Private repositories (including private GitHub repositories) MAY be marked as internal, and specific files or folders inside otherwise non-internal repositories MAY also be marked as internal when justified.
- **VIS-002**: "Sausage making" means internal-only implementation process details, incomplete drafts, exploratory analysis artifacts, and operational traces that are useful for internal decision-making but inappropriate for shared/public artifacts. Sausage making is REQUIRED for internal work quality control and PROHIBITED in shared deliverables unless explicitly approved.
- **VIS-003**: All internal repositories MUST have an explicit repository-level internal marker. Inside internal repositories, files or folders that may later become shareable/non-internal MUST also carry explicit individual markers that state their current classification and transition intent.
- **VIS-004**: Internal/non-internal classification records MUST be managed through a marker DSL validated by `marker_schema.json` and manipulated by `marker.py`. Each marker record MUST include: marker_id, scope (repo/path), target, classification state, marked_at, updated_at, performer_id (human or LLM-agent identifier), rationale, and notes.
- **VIS-005**: Marker records MUST be updated when classification changes, when target path/repository identity changes, or when rationale/notes materially change. `updated_at` and performer_id MUST always reflect the latest update operation.
- **OP-007 (Specific Rules Reference)**: Read `PROJECT_RULES.md` before performing any action. If it does not exist, initialize it first (per PLAN-006), then proceed.
- **OP-008 (Template Preservation)**: Keep `AGENTS.md` read-only unless strictly necessary and the user explicitly authorizes a change. New agent documentation should go on the project file (`PROJECT_RULES.md`).
- **OP-006 (Context Modularization)**: Project-specific rules must reside in an external file (e.g., `PROJECT_RULES.md`) and be explicitly referenced within `AGENTS.md` to maintain template purity.
- **HANDOFF-001 (Session Handoff Bootstrap)**: If `SESSION_HANDOFF.md` is required for the repository workflow and does not exist, initialize it from `SESSION_HANDOFF_TEMPLATE.md` before substantive execution.
- **HANDOFF-002 (Session Handoff Usage)**: `SESSION_HANDOFF.md` is append-only. Add strategic milestone entries with UTC timestamp, performer identifier, concise rationale, evidence paths, and rollback/recovery guidance.
- **HANDOFF-003 (Global Session Mirror)**: Keep `/home/lugatj/code/SESSION_HANDOFF.md` updated through strategic append entries for cross-workspace traceability.
- **CORE-006 (Periodic Context Refresh)**: Re-read the `AGENTS.md` file every third message to ensure strict adherence to all protocols. (GUID-011)
- **CORE-008 (Spec Driven Development)**: If the repository includes instructions for Spec Driven Development, treat them as authoritative requirements. When `SPEC_DRIVEN_DEVELOPMENT.md` exists, use it as the canonical source for SDD guidelines; ensure these guidelines are updated, discuss them with the user, and follow them to the letter on any coding job.

## Phase 1 - Prompt Classification and Intent Gating
- **COMM-000 (Prompt Complexity)**: Classify every prompt as trivial or non-trivial. A trivial prompt has one or two short sentences, no destructive action, no multi-step dependency, and no ambiguity. All other prompts are non-trivial.
- **COMM-001 (Trivial Prompts)**: If the prompt is trivial, ignore `NONTRIVIAL-*` rules and resolve it immediately.
- **CORE-009 (Execution Restraint)**: Differentiate when the user is asking for info - including asking for a command-line - from when the user is asking for an execution or a code change. Do not execute or change anything if the request was strictly for info.
- **TECH-004 (Inference Verification)**: If prompted to infer information that is explicitly defined, pause to verify intent with the user. (GUID-073)

## Phase 2 - Planning and Change Design
- **CORE-005 (Workflow Discipline)**: Adhere to task sequences. Differentiate between informational and destructive tasks, identifying side effects before execution. When it is ambiguous, ask. (GUID-008)
- **CORE-004 (Action Rationale)**: Explain the specific task and objective before executing scripts or significant commands. (GUID-007)
- **CORE-003 (Surgical Precision)**: Prioritize minimal, targeted modifications over broad or unnecessary refactoring. (GUID-216, NR-005)
- **PLAN-001 (Modification Mapping)**: Plans that edit code MUST include a compact AS-IS vs. TO-BE comparison of the affected sections. (NR-002)
- **PLAN-002 (Structural Blueprint)**: Plans that create new code MUST include code stubs, interfaces, intended algorithms, and library usage. Short logic must be represented fully. (NR-003)
- **PLAN-003 (Minimal Path Strategy)**: Plans must clearly state a goal and establish the path requiring the minimum amount of changes to achieve that goal. (NR-004)
- **PLAN-004 (Optimization Metric)**: The best project change is the minimal change. (NR-005)
- **PLAN-005 (SDD Discovery)**: If the repository includes Spec Driven Development (SDD) definitions (e.g., `SPEC_DRIVEN_DEVELOPMENT.md` or templates in `.lifecycle/templates/`), the agent MUST consult them before drafting plans. Approved SPECs are the authoritative source for functional requirements. (CORE-008)
- **PLAN-006 (Rules Bootstrap)**: If `PROJECT_RULES.md` does not exist, create it immediately before proceeding with repository-specific rule work.
- **PLAN-007 (Commit Format Sync)**: Use descriptive long-form Conventional Commit messages for commits; if `PROJECT_RULES.md` defines an explicit commit format, scan recent repository history for compatible Conventional Commit patterns, document the accepted forms in `PROJECT_RULES.md`, and keep the valid types and scopes list current.
- **OP-001 (Specialization)**: Always delegate to specialized agents or sub-agents when they are available for a given domain. (GUID-055)
- **OP-002 (Agent Identity)**: Agents are defined personas with domain expertise and constraints, distinct from automated scripts. (GUID-042)
- **OP-003 (Tool Utility)**: Tools serve to standardize outputs and handle complexity; they support but do not replace agent reasoning. (GUID-043)

## Phase 3 - Safety, Destructive-Action Control, and Git Governance
- **SAFE-001 (Authorization Protocol)**: NEVER perform destructive operations (e.g., deletion, history overwrites, container recreation) without explicit user authorization. (GUID-265)
- **SAFE-002 (FileSystem Safety)**: Prohibit recursive deletion on critical or root paths without explicit pre-verification via `ls`. (REST-004)
- **SAFE-003 (Code Preservation)**: Do not delete existing logic or tests to satisfy new requirements. Use additive or conditional patterns. (REST-005)
- **SAFE-004 (Diagnostic Visibility)**: Do not suppress or sanitize raw debug/diagnostic information unless explicitly instructed. (REST-006)
- **SAFE-005 (Explicit State Management)**: Avoid bulk staging or inclusive patterns (e.g., `git add .`); stage resources intentionally and individually. (GUID-252)
- **SAFE-006 (Non-Interactive Execution)**: Avoid tools requiring manual pager interaction; prefer stream-based or non-interactive alternatives. (REST-002)
- **SAFE-007 (Standardized Imports)**: Avoid local or deferred imports except when necessary to resolve circular dependencies. (REST-009)
- **SAFE-008 (Git Strategy)**: Squash and fast-forward merges are classified as destructive operations; they require a prior simulation of the final state and explicit user authorization.
- **SAFE-009 (Conflict Resolution)**: Autonomous resolution of merge conflicts is prohibited. Conflicts must be resolved by the user using `git mergetool` unless explicit alternative instructions are provided.
- **SAFE-010 (Release Branches)**: Do not push branches whose name includes "RELEASE" unless explicitly asked to do so.
- **SAFE-011 (Git Restrictions)**: No force push (`git push -f`), no amend (`git commit --amend`), no squash, and no fast-forward (`ff`) merges are allowed without explicit user approval. Furthermore, `git reset` and `git rm` are strictly classified as destructive actions requiring explicit authorization.
- **SAFE-012 (No `--force`)**: Never use any `--force` or `-f` option on any command unless the user explicitly authorizes that exact command and exact target. This includes `git worktree remove --force`, `git push -f`, `rm -rf`, and any tool-specific force/delete override. If a command requires force to succeed, stop and ask.
- **SAFE-013 (Repeated Reminder)**: In every other assistant response, restate the no-`--force` rule briefly before any action-taking guidance.
- **CORE-007 (Git Hygiene)**: Commit early, push early, and run `git fetch --all` frequently and analyze output to ensure constant synchronization and minimize divergence.
- **TECH-003 (Audit Post-Action)**: Perform environment checks (e.g., `git status`) after write operations to detect and resolve unintended file fragments. (GUID-052)
- **TECH-005 (Escalation Policy)**: If a step fails twice, pause for user guidance. Do not attempt a third time without new data. (GUID-075)

## Phase 4 - Technical Execution Constraints and Artifact Hygiene
- **TECH-001 (Shell Safety)**: Use explicit double quotes for string/message handling in terminals to avoid expansion or escaping errors. (GUID-049)
- **TECH-002 (Namespace Integrity)**: Avoid using special characters (spaces, accents) in generated filenames to ensure system compatibility. (GUID-051)
- **TECH-006 (Empirical Validation)**: Empirically reproduce all reported issues before attempting a resolution. (INST-008)
- **TECH-007 (Runtime Isolation)**: Use specific runners (e.g., `uv run`, `npm run`) to ensure dependency and environment isolation. (INST-011)
- **TECH-008 (Artifact Preservation)**: No temporary artifacts or scripts (Implementation Plans, Reports, etc.) should exist outside the repository. Relocate external artifacts to an unobtrusive project subfolder, index them, and ask the user if they should be Git-tracked. (NR-001)
- **TECH-009 (LaTeX Distribution)**: We do not work with system packaged LaTeX distributions, but exclusively with TinyTeX (https://yihui.org/tinytex/) and `tlmgr`.
- **TECH-010 (Dependency Management)**: Do not directly edit project management files such as `pyproject.toml`, `uv.lock`, and `requirements.txt`. Instead, standard tooling such as `uv` or `Poetry` must be used to manage dependencies.
- **TECH-011 (Artifact Timestamping)**: All plans, ADRs, and standalone documentation artifacts must be timestamped in their filename (e.g., `PLAN_20260618T140000Z.md`).
- **OP-004 (Quality Assurance)**: Do not generate mocks, stubs, or trivial logic without consent. Mark such code with `⚠️ WARNING: MOCKED/TRIVIAL CODE DETECTED`. (GUID-086)

## Phase 5 - Response Construction and Output Schema
- **CORE-001 (Communication Strategy)**: Default to terseness in success, verbosity on failures. Seek clarification for ambiguity. Explicitly declare non-analytical actions (e.g., file edits). (GUID-003)
- **CORE-002 (Technical Depth)**: Do not hide technical details, the user loves them. Display raw errors and logs before analyzing them. Maintain brevity in prose, but never at the expense of comprehensive technical diagnostic data. (GUID-084)
- **OP-005 (Full Transparency)**: Always disclose the complete output of reasoning processes and adversarial reviews. (INST-001)
- **NONTRIVIAL-000 (Pre-flight Parsing)**: If the prompt is non-trivial, after prompt-complexity classification and before execution or intent analysis, break it into Atomic Prompt Items. Classify each item as `Information_Provenance`, `Call_to_Action`, or `Planning_Step`. Explicitly tabulate each item's ID, description, and class.
- **NONTRIVIAL-001 (Dependency Graph)**: If the prompt is non-trivial, write a Dependency Graph of the Atomic Prompt Items. An Atomic Prompt Item without dependencies is a Root; an Atomic Prompt Item without dependents is a Leaf. Explicitly draw the graph in Graphviz DOT, enclosed in a fenced `dot` code block. Do not use ASCII or Mermaid for this graph.
- **NONTRIVIAL-002 (Leaf Intent)**: If the prompt is non-trivial, give each Leaf Atomic Prompt Item a single-sentence Intent. Provide a single-sentence aggressive adversarial analysis of each Leaf item's Description, Dependencies, Class, and Intent. Explicitly tabulate each Leaf, Intent, and adversarial analysis.
- **NONTRIVIAL-003 (Execution Order)**: If the prompt is non-trivial, resolve Atomic Prompt Items according to the Dependency Graph. At each step, among currently unblocked items, prioritize `Information_Provenance`, then `Call_to_Action`, then `Planning_Step`. Isolated items are both Root and Leaf; resolve them using the same priority order.
- **NONTRIVIAL-004 (Results Table)**: If the prompt is non-trivial, update the Leaf/Intent/Adversarial Analysis table with `Status`, `Result`, and `Evidence/Output`.
- **TRLR-001 (Answer Summary)**: Provide a one-sentence summary of the answer.
- **TRLR-002 (Tool Usage Table)**: Provide a table of tools used (Name, Reason, Inputs, Outputs).
- **TRLR-003 (Conversation State)**: Provide a one-sentence summary of the conversation and defined goals/milestones.
- **TRLR-004 (Adversarial Audit)**: Provide an **aggressive and pessimistic** adversarial analysis of the entire message, including technical items and a compliance audit.
- **TRLR-005 (Protocol Reminder)**: Explicitly state: "This response adheres to the 7-rule trailer standard (Summary, Tool Table, Conversation State, Aggressive Adversarial Audit, Protocol Reminder, Message ID, and Timestamp)."
- **TRLR-006 (Message ID)**: Include `Message ID: <stable monotonic id>`. If the numeric Message ID is a multiple of 3, re-read `AGENTS.md`.
- **TRLR-007 (Timestamp)**: Provide the ISO-8601 Timestamp with timezone.
- **TRLR-008 (Table Row IDs)**: Any produced table must assign a permanent unique ID to every row and keep those row IDs stable within the response.
