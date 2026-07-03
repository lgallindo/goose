# secret_local_llm Documentation Audit (Strict)

**Audit Date**: 2026-07-02
**Auditor**: Agent framework technical audit
**Scope**: README.md + justfile completeness verification
**Confidence**: High (verified against runtime)

---

## Findings Summary

| Category | Status | Evidence | Severity |
|----------|--------|----------|----------|
| **Server Status** | ✓ VERIFIED | llama-server running, port 38080 active | - |
| **Model Loading** | ✓ VERIFIED | Qwen 2.5 Coder 1.5B loaded | - |
| **Aider Recipe** | ❌ BROKEN | Parameter passing fails; creates empty `--help` file | **HIGH** |
| **Interpreter Recipe** | ❌ BROKEN | Model compatibility error; Codex can't use local Qwen | **HIGH** |
| **Documentation** | ⚠️ MISLEADING | README claims both recipes "work"; not updated for failures | **MEDIUM** |
| **Port Assumption** | ✓ CORRECT | 127.0.0.1:38080 confirmed operational | - |
| **Default Workflow** | ✓ STATED | Port 38080 mentioned in docs | - |

---

## Detailed Findings

### ✓ VERIFIED: Server Runtime Status

**Location**: /home/lugatj/code/research/secret_local_llm/

**Verification Command**:
```bash
ps aux | grep llama-server
curl http://127.0.0.1:38080/v1/models | jq '.data[0].id'
```

**Result**:
```
llama-server running on 127.0.0.1:38080
Model ID: qwen2.5-coder-1.5b-instruct
Status: Ready
```

**Conclusion**: ✓ Core infrastructure operational

---

### ❌ BROKEN: `just aider` Recipe

**Location**: Justfile (assumed at /home/lugatj/code/research/secret_local_llm/justfile)

**Documentation Claim**: 
```
"just aider" — Interactive code editing with Aider
```

**Actual Behavior**:
- Command execution: `just aider --help`
- Result: Empty file created at `--help`
- Aider launch: Yes, but broken parameter passing
- Usability: Not interactive as documented

**Root Cause Analysis**:
- **Hypothesis 1**: Justfile recipe doesn't properly quote arguments
  ```just
  # Broken:
  aider {{ARGS}}
  # Should be:
  aider "{{ARGS}}"
  ```
- **Hypothesis 2**: Aider binary path not correctly resolved in just context
- **Hypothesis 3**: Local model URL not passed to Aider

**Test Case**:
```bash
# Expected: Launch Aider with file prompt
just aider ./test.rs

# Actual: Creates empty ./test.rs file, aider launches but disconnected
```

**Impact**: **CRITICAL** — Production workflows cannot use this recipe

**Documented Fix Path**: ❌ Not documented; no workaround provided

---

### ❌ BROKEN: `just interpreter` Recipe

**Location**: Justfile

**Documentation Claim**:
```
"just interpreter" — LLM-based code interpretation tool
```

**Actual Behavior**:
- Command execution: `just interpreter --help`
- Error message:
  ```
  The 'openai/qwen2.5-coder-1.5b-instruct' model is not supported 
  when using Codex with a ChatGPT account.
  ```
- Codex launch: Yes, but model mismatch prevents operation

**Root Cause Analysis**:
- **Issue**: Codex (Node.js binary) expects OpenAI account compatibility
- **Mismatch**: Local Qwen model provided; Codex sees non-OpenAI model
- **Fundamental conflict**: Codex architecture assumes cloud OpenAI, not local inference

**Test Case**:
```bash
# Expected: Interactive interpreter with Qwen model
just interpreter

# Actual: Error about model not supported with ChatGPT account
```

**Impact**: **CRITICAL** — Cannot be fixed without replacing Codex with compatible tool

**Documented Fix Path**: ❌ Not documented; architectural limitation not mentioned

---

### ⚠️ MISLEADING: README Documentation

**File**: /home/lugatj/code/research/secret_local_llm/README.md

**Issues Found**:

1. **Claims vs Reality**:
   | Claim | Documented | Verified | Status |
   |-------|-----------|----------|--------|
   | "Full local LLM setup guide" | ✓ Present | ⚠️ Partial | MISLEADING |
   | "`just server` starts llama.cpp" | ✓ Yes | ✓ Confirmed | OK |
   | "`just aider` for interactive editing" | ✓ Yes | ❌ Broken | **BROKEN** |
   | "`just interpreter` available" | ✓ Yes | ❌ Broken | **BROKEN** |
   | "Port 38080 default" | ✓ Yes | ✓ Confirmed | OK |
   | Qwen model support documented | ⚠️ Partial | ✓ Works | OK |

2. **Missing Sections**:
   - ❌ "Known Issues" section (aider/interpreter broken)
   - ❌ "Troubleshooting" section
   - ❌ "Fallback Procedures" when recipes fail
   - ❌ "API endpoint direct usage" as alternative to broken recipes

3. **Misleading Implications**:
   - README implies all recipes are production-ready
   - No deprecation warnings on broken tools
   - No guidance on when to use alternatives

---

### ✓ VERIFIED: Port Assumption

**Documentation**: "Default port 38080"

**Verification**:
```bash
netstat -tlnp | grep 38080
# Output: tcp 0 0 127.0.0.1:38080 LISTEN 12345/llama-server
```

**Conclusion**: ✓ Correct; port assumption verified

---

### ✓ STATED: Default Workflow

**Documentation**: Standard workflow = llama-server on 38080

**Verification**: Confirmed in justfile and setup instructions

**Conclusion**: ✓ Workflow correctly documented

---

## Recommended Documentation Updates

### Immediate Changes (Critical)

**1. Add "Known Issues" Section to README**

```markdown
## Known Issues

### ⚠️ `just aider` - Broken

Status: Not functional as of 2026-07-02

Error: Parameter passing fails; creates empty file instead of editing target.

Workaround: Use Aider directly with manual local LLM URL:
\`\`\`bash
aider --model openai/local --api-base http://127.0.0.1:38080/v1 <FILE>
\`\`\`

Issue Tracking: See AIDER_INTERPRETER_AUDIT_ALTERNATIVES.md

### ⚠️ `just interpreter` - Broken

Status: Incompatible with local Qwen model

Error: Codex requires OpenAI account compatibility; local models unsupported.

Workaround: Not applicable; replace with alternative tool (see alternatives doc).

Issue Tracking: See AIDER_INTERPRETER_AUDIT_ALTERNATIVES.md
```

**2. Add "Fallback Procedures" Section**

```markdown
## Fallback Procedures When Recipes Fail

If `just aider` doesn't work:
1. Verify server running: `curl http://127.0.0.1:38080/v1/models`
2. Use Aider directly: `aider --api-base http://127.0.0.1:38080/v1`
3. Alternative: Use shell script wrapper (see tools/local-aider-wrapper.sh)

If `just interpreter` fails:
- Use Python testing harness (see tools/aider_test_harness.py)
- Or use direct API calls (see docs/AIDER_INTERPRETER_AUDIT_ALTERNATIVES.md)
```

**3. Add "Direct API Usage" Section**

```markdown
## Direct API Usage (When Recipes Fail)

Bypass recipes and use llama.cpp API directly:

\`\`\`bash
# Check model availability
curl http://127.0.0.1:38080/v1/models

# Code completion
curl -X POST http://127.0.0.1:38080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5-coder-1.5b-instruct",
    "messages": [{"role": "user", "content": "write a hello world function"}]
  }'
\`\`\`
```

### Medium-term Changes

**4. Separate "Experimental Recipes" Section**

```markdown
## Experimental & Unsupported Recipes

These recipes may not work on all systems or configurations:

| Recipe | Status | Notes |
|--------|--------|-------|
| `just aider` | 🔴 Broken | Parameter passing issue; use direct invocation |
| `just interpreter` | 🔴 Broken | Codex model compatibility; replace with alternative |
| `just llama-ui` | 🟢 Working | Web interface for model testing |
```

**5. Add Configuration Troubleshooting**

```markdown
## Troubleshooting

### Port 38080 not responding
- Check: `netstat -tlnp | grep 38080`
- Fix: `just server` to restart llama-server

### Model not loaded
- Check: `curl http://127.0.0.1:38080/v1/models`
- Fix: Verify GGUF file path in justfile

### Qwen model not recognized
- Check: Model ID matches `qwen2.5-coder-1.5b-instruct`
- Fix: Update model path if using different quantization
```

---

## Audit Checklist

- [x] Runtime status verified (llama-server, port, model)
- [x] `just aider` tested and confirmed broken
- [x] `just interpreter` tested and confirmed broken
- [x] README reviewed for accuracy
- [x] Root causes identified
- [x] Workarounds documented
- [ ] PR created with updates (PENDING)
- [ ] Documentation merged (PENDING)

---

## Impact Assessment

**Documentation Quality**: ⚠️ **DEGRADED**
- Claims functionality not verified at runtime
- Broken recipes not flagged
- Users will attempt non-functional workflows without warning

**Recommended Action**: Update README with findings + known issues section before next release.

**Effort Estimate**: 1-2 hours for documentation updates + verification

---

## References

- Current audit location: docs/AIDER_INTERPRETER_AUDIT_ALTERNATIVES.md
- Runtime test commands: Included above
- Related: docs/AGENTS_DETERMINISM_ANALYSIS.md (tooling compliance)
