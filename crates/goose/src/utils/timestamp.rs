use chrono::{DateTime, SecondsFormat, Utc};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
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

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::TimeZone;

    #[test]
    fn test_rfc3339_second_precision() {
        let dt = Utc.with_ymd_and_hms(2026, 7, 10, 14, 32, 47).unwrap();
        assert_eq!(
            rfc3339_at_precision(dt, TimestampPrecision::Second),
            "2026-07-10T14:32:47Z"
        );
    }

    #[test]
    fn test_rfc3339_minute_precision() {
        let dt = Utc.with_ymd_and_hms(2026, 7, 10, 14, 32, 47).unwrap();
        assert_eq!(
            rfc3339_at_precision(dt, TimestampPrecision::Minute),
            "2026-07-10T14:32Z"
        );
    }

    #[test]
    fn test_now_rfc3339_parses_as_utc() {
        let ts = now_rfc3339(TimestampPrecision::Second);
        let parsed: DateTime<Utc> = ts.parse().expect("valid RFC3339");
        assert_eq!(parsed.timezone(), Utc);
    }
}
