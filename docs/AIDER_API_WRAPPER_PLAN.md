# 1. Goal
Bridge Aider to a local `llama.cpp` instance running at `127.0.0.1:38080` to enable local AI coding assistance within the `goose` development workflow.

# 2. Context
The implementation must leverage the existing infrastructure, specifically taking inspiration from `scripts/test-local-editor.sh`, which currently provides a harness for testing local editor integrations.

# 3. Options
- **(A) Shell wrapper**:
  - *Pros*: Quick to implement, language-agnostic, easily triggered by existing `goose` scripts.
  - *Cons*: Limited error handling, harder to maintain as logic grows, not native to the Rust/Go codebase structure.
- **(B) Go binary**:
  - *Pros*: Robust, better type safety, easier to manage dependencies and network requests, integrates better if other parts of the system are in Go.
  - *Cons*: Introduces another language into a predominantly Rust project, higher initial development effort.

# 4. Recommended
**Option (A) Shell wrapper**. Given the project is primarily Rust-based, adding a Go binary introduces unnecessary complexity. A shell wrapper allows for a rapid, low-friction proof of concept that adheres to the established tooling patterns in the `scripts/` directory.

# 5. Implementation steps
1. Initialize the shell wrapper script `scripts/aider-local-bridge.sh`.
2. Configure the bridge to forward requests to `127.0.0.1:38080`.
3. Implement basic response parsing to translate `llama.cpp` formats to Aider-compatible formats.
4. Integrate the bridge with `scripts/test-local-editor.sh` for verification.
5. Create a `Task` in `TODO` to track the refinement of the wrapper into a more permanent Rust-native implementation.

# 6. Success criteria
- Aider successfully connects to the wrapper.
- The wrapper correctly forwards requests to `llama.cpp` @ `127.0.0.1:38080`.
- The wrapper returns a valid Aider-compatible response.
- `scripts/test-local-editor.sh` passes with the new bridge configuration.
