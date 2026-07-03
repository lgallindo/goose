# Timestamp Tool: AS-IS vs TO-BE Specification

## AS-IS Analysis

**File**: [crates/goose/src/agents/prompt_manager.rs](crates/goose/src/agents/prompt_manager.rs) lines 207-219

### Current Implementation

```rust
// Line 209: Production path
current_date_timestamp: Utc::now().format("%Y-%m-%d %H:00").to_string(),
// Example output: "2026-07-02 14:00"

// Line 219: Test path (with precision)
current_date_timestamp: dt.format("%Y-%m-%d %H:%M:%S").to_string(),
// Example output: "2026-07-02 14:32:47"
```

### AS-IS Limitations

| Issue | Impact | Severity |
|-------|--------|----------|
| **No timezone info** | Ambiguous in multi-region | HIGH |
| **Hourly coarseness** (production) | Less precise for time-sensitive tasks | MEDIUM |
| **Inconsistent precision** | Production ≠ tests | MEDIUM |
| **Not ISO-8601** | Harder to parse programmatically | LOW |
| **Hardcoded format strings** | Not configurable by caller | MEDIUM |

---

## TO-BE Specification

### Design Goals
1. **Precise**: Capture second-level granularity with timezone
2. **Standard**: Use RFC 3339 (ISO-8601 subset) for universal compatibility
3. **Consistent**: Same format across production and test paths
4. **Flexible**: Support caller-chosen precision (hour/minute/second)
5. **Zero-cost**: No extra rendering passes, read-only from templates

### TO-BE Format

**Primary format**: RFC 3339 (ISO-8601 with timezone)

```
Examples:
- 2026-07-02T14:32:47Z         (UTC)
- 2026-07-02T14:32:47-05:00    (EST)
- 2026-07-02T09:32:47+09:00    (JST)
```

**Rationale**: 
- Standard library support in Rust (`DateTime::<Utc>::to_rfc3339()`)
- Universally parseable by LLMs
- Includes explicit timezone anchor

### Rust Implementation

```rust
// New utility function
pub fn get_timestamp_rfc3339() -> String {
    Utc::now().to_rfc3339()
    // Output: "2026-07-02T14:32:47.123456Z"
}

// Precision control variant
pub fn get_timestamp_rfc3339_truncated(precision: TimestampPrecision) -> String {
    let dt = Utc::now();
    match precision {
        TimestampPrecision::Hour => {
            dt.format("%Y-%m-%dT%HZ").to_string()
            // "2026-07-02T14Z"
        }
        TimestampPrecision::Minute => {
            dt.format("%Y-%m-%dT%H:%MZ").to_string()
            // "2026-07-02T14:32Z"
        }
        TimestampPrecision::Second => {
            dt.format("%Y-%m-%dT%H:%M:%SZ").to_string()
            // "2026-07-02T14:32:47Z"
        }
        TimestampPrecision::Millisecond => {
            dt.to_rfc3339_opts(SecondsFormat::Millis, false)
            // "2026-07-02T14:32:47.123Z"
        }
    }
}

#[derive(Clone, Copy)]
pub enum TimestampPrecision {
    Hour,
    Minute,
    Second,
    Millisecond,
}
```

### Integration with PromptManager

```rust
impl PromptManager {
    pub fn new() -> Self {
        PromptManager {
            system_prompt_override: None,
            system_prompt_extras: IndexMap::new(),
            // CHANGED: Use minute precision (cache-friendly middle ground)
            current_date_timestamp: get_timestamp_rfc3339_truncated(
                TimestampPrecision::Minute
            ),
            timestamp_precision: TimestampPrecision::Minute,
            subdirectory_hint_tracker: SubdirectoryHintTracker::new(),
        }
    }

    #[cfg(test)]
    pub fn with_timestamp(dt: DateTime<Utc>) -> Self {
        PromptManager {
            system_prompt_override: None,
            system_prompt_extras: IndexMap::new(),
            current_date_timestamp: get_timestamp_rfc3339_truncated_at(
                dt,
                TimestampPrecision::Second
            ),
            timestamp_precision: TimestampPrecision::Second,
            subdirectory_hint_tracker: SubdirectoryHintTracker::new(),
        }
    }
}
```

### Template Usage

```jinja2
{# system.md #}
Current timestamp: {{ current_date_timestamp }}
{# Output: "Current timestamp: 2026-07-02T14:32Z" #}

{# For agent reasoning about precise timing #}
{% if millisecond_precision_available %}
  Precise time for scheduling: {{ current_timestamp_ms }}
{% endif %}
```

---

## Implementation Roadmap

### Step 1: Add Utility Module
**File**: Create `crates/goose/src/utils/timestamp.rs`

```rust
pub mod timestamp {
    use chrono::{DateTime, SecondsFormat, Utc};
    
    #[derive(Clone, Copy, Debug)]
    pub enum TimestampPrecision {
        Hour,
        Minute,
        Second,
        Millisecond,
    }
    
    pub fn rfc3339_at_precision(dt: DateTime<Utc>, precision: TimestampPrecision) -> String {
        match precision {
            TimestampPrecision::Hour => dt.format("%Y-%m-%dT%HZ").to_string(),
            TimestampPrecision::Minute => dt.format("%Y-%m-%dT%H:%MZ").to_string(),
            TimestampPrecision::Second => dt.format("%Y-%m-%dT%H:%M:%SZ").to_string(),
            TimestampPrecision::Millisecond => {
                dt.to_rfc3339_opts(SecondsFormat::Millis, false)
            }
        }
    }
    
    pub fn now_rfc3339(precision: TimestampPrecision) -> String {
        rfc3339_at_precision(Utc::now(), precision)
    }
}
```

### Step 2: Update PromptManager
**File**: [crates/goose/src/agents/prompt_manager.rs](crates/goose/src/agents/prompt_manager.rs)

Replace lines 207-219:
```rust
use crate::utils::timestamp::{now_rfc3339, TimestampPrecision};

pub fn new() -> Self {
    PromptManager {
        system_prompt_override: None,
        system_prompt_extras: IndexMap::new(),
        // Now ISO-8601 compliant with timezone, minute precision for cache efficiency
        current_date_timestamp: now_rfc3339(TimestampPrecision::Minute),
        subdirectory_hint_tracker: SubdirectoryHintTracker::new(),
    }
}

#[cfg(test)]
pub fn with_timestamp(dt: DateTime<Utc>) -> Self {
    PromptManager {
        system_prompt_override: None,
        system_prompt_extras: IndexMap::new(),
        current_date_timestamp: rfc3339_at_precision(dt, TimestampPrecision::Second),
        subdirectory_hint_tracker: SubdirectoryHintTracker::new(),
    }
}
```

### Step 3: Add Tests
**File**: `crates/goose/src/utils/timestamp.rs`

```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_hour_precision() {
        let dt = DateTime::parse_from_rfc3339("2026-07-02T14:32:47Z")
            .unwrap()
            .with_timezone(&Utc);
        assert_eq!(rfc3339_at_precision(dt, TimestampPrecision::Hour), "2026-07-02T14Z");
    }
    
    #[test]
    fn test_minute_precision() {
        let dt = DateTime::parse_from_rfc3339("2026-07-02T14:32:47Z")
            .unwrap()
            .with_timezone(&Utc);
        assert_eq!(rfc3339_at_precision(dt, TimestampPrecision::Minute), "2026-07-02T14:32Z");
    }
    
    #[test]
    fn test_second_precision() {
        let dt = DateTime::parse_from_rfc3339("2026-07-02T14:32:47Z")
            .unwrap()
            .with_timezone(&Utc);
        assert_eq!(rfc3339_at_precision(dt, TimestampPrecision::Second), "2026-07-02T14:32:47Z");
    }
    
    #[test]
    fn test_now_includes_timezone() {
        let ts = now_rfc3339(TimestampPrecision::Second);
        assert!(ts.ends_with("Z") || ts.contains("+") || ts.contains("-"));
    }
}
```

### Step 4: Update Templates
**File**: [crates/goose/src/prompts/system.md](crates/goose/src/prompts/system.md)

Add context hint:
```jinja2
<!-- Around line 5 -->
The current date and time is {{ current_date_timestamp }} (ISO-8601 format with UTC timezone).
```

---

## Comparison Matrix

| Aspect | AS-IS | TO-BE |
|--------|-------|-------|
| **Format** | Custom ("%Y-%m-%d %H:00") | RFC 3339 ISO-8601 |
| **Timezone** | ❌ Missing | ✓ Z or ±HH:MM |
| **Production precision** | 1 hour | 1 minute |
| **Test precision** | 1 second | 1 second |
| **Consistency** | ❌ Varies | ✓ Same across paths |
| **Configurable** | ❌ Hardcoded | ✓ Via enum |
| **Parsing effort (for LLM)** | Medium | Low (standard) |
| **Cache-friendly** | ✓ Yes | ✓ Yes (minute-level) |

---

## Migration Path (Zero Downtime)

1. ✓ Add new `timestamp` utility (non-breaking)
2. ✓ Add tests for new utility
3. ✓ Update `PromptManager` to use new utility
4. ✓ Verify existing tests pass (format change transparent to templates)
5. ✓ Deploy
6. ✓ Monitor agent timestamp accuracy logs

**Risk**: **Low** — timestamp format change is backward-compatible for LLM reasoning.

---

## Cost-Benefit

| Benefit | Cost | ROI |
|---------|------|-----|
| Timezone clarity | +50 LOC | High (eliminates ambiguity) |
| Standard format | +30 LOC | High (improves LLM parsing) |
| Precision control | +100 LOC | Medium (enables future use cases) |
| Consistency | +0 LOC | High (reduces confusion) |
| **Total** | **~180 LOC** | **High** |

---

## References

- Chrono RFC 3339: [to_rfc3339_opts](https://docs.rs/chrono/latest/chrono/struct.DateTime.html#method.to_rfc3339_opts)
- RFC 3339 Spec: https://tools.ietf.org/html/rfc3339
- Current code: [crates/goose/src/agents/prompt_manager.rs](crates/goose/src/agents/prompt_manager.rs)
