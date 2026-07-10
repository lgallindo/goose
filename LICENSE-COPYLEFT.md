# Goose Fork Copyleft Notice

New modifications made for the `lgallindo/goose` fork are licensed under the **GNU Affero General Public License, version 3.0 or any later version (AGPL-3.0-or-later)**, unless a file or directory explicitly states a different license.

The inherited upstream goose codebase remains available under its original **Apache License 2.0** terms, preserved in [LICENSE](LICENSE). Apache-2.0 is compatible with AGPL-3.0 for combined distribution, but upstream copyright and patent notices must be preserved.

Until a file-level SPDX audit is complete, treat this repository as a **mixed-license derivative work**:

| Layer | License |
|---|---|
| Unmodified upstream files | Apache-2.0 (Block, Inc. / AAIF) |
| Fork modifications (see [NOTICE](NOTICE)) | AGPL-3.0-or-later (Lucas Gallindo) |
| Third-party dependencies | Respective licenses (see `Cargo.lock`, `deny.toml`) |

## Files Currently Under AGPL-3.0-or-later (Fork Authorship)

- `crates/goose/src/rust_llm.rs`
- `crates/goose/src/secrets_kv.rs`
- `crates/goose-mcp/src/websearch/mod.rs`
- `scripts/agent-bus-publish.sh`, `scripts/agent-bus-wait.sh`
- `scripts/aider-local-bridge.sh`, `scripts/test-local-editor.sh`
- `scripts/github-api.sh`, `scripts/gitlab-api.sh`, `scripts/bitbucket-api.sh`
- `scripts/start-mcp-servers.sh`
- `docs/*` authored in this fork (2026-07-03 onward), except upstream-derived content

Modified upstream files (e.g. `developer/mod.rs`, prompts) contain Apache-2.0 base plus AGPL-3.0-or-later modifications — preserve both notices.

Do not publish release artifacts until the license audit and notice inventory are complete.
