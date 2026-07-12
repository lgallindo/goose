import argparse
import json
import os
import re
import sys
from datetime import datetime, timezone


SCHEMA_FIELDS = {
    "marker_id",
    "scope",
    "target",
    "classification",
    "marked_at",
    "updated_at",
    "performer_id",
    "rationale",
    "notes",
}
SCOPE_VALUES = {"repo", "path"}
CLASSIFICATION_VALUES = {"internal", "non-internal", "share-candidate"}


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def default_registry_path() -> str:
    return os.path.join(os.getcwd(), "marker_registry.json")


def load_registry(path: str) -> list:
    if not os.path.exists(path):
        return []
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, list):
        raise ValueError("registry file must contain a JSON array")
    return data


def save_registry(path: str, records: list) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(records, f, indent=2, ensure_ascii=False)
        f.write("\n")


def generate_marker_id(records: list) -> str:
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    seq = len(records) + 1
    return f"MKR-{ts}-{seq:04d}"


def validate_record(record: dict) -> tuple[bool, list]:
    errors = []
    keys = set(record.keys())
    missing = SCHEMA_FIELDS - keys
    extra = keys - SCHEMA_FIELDS
    if missing:
        errors.append(f"missing fields: {sorted(missing)}")
    if extra:
        errors.append(f"unexpected fields: {sorted(extra)}")

    if record.get("scope") not in SCOPE_VALUES:
        errors.append("scope must be one of: repo, path")
    if record.get("classification") not in CLASSIFICATION_VALUES:
        errors.append("classification must be one of: internal, non-internal, share-candidate")

    for field in ["marker_id", "target", "performer_id", "rationale", "notes"]:
        val = record.get(field)
        if not isinstance(val, str) or not val.strip():
            errors.append(f"{field} must be a non-empty string")

    for field in ["marked_at", "updated_at"]:
        val = record.get(field)
        if not isinstance(val, str) or not re.match(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+00:00$", val):
            errors.append(f"{field} must be UTC ISO-8601, e.g. 2026-07-02T19:00:00+00:00")

    return len(errors) == 0, errors


def find_record(records: list, marker_id: str) -> dict | None:
    for r in records:
        if r.get("marker_id") == marker_id:
            return r
    return None


def cmd_mark(args: argparse.Namespace) -> int:
    records = load_registry(args.registry)
    now = utc_now_iso()
    marker_id = args.marker_id or generate_marker_id(records)
    record = {
        "marker_id": marker_id,
        "scope": args.scope,
        "target": args.target,
        "classification": args.classification,
        "marked_at": now,
        "updated_at": now,
        "performer_id": args.performer,
        "rationale": args.rationale,
        "notes": args.notes,
    }
    ok, errors = validate_record(record)
    if not ok:
        print("validation failed:")
        for e in errors:
            print(f"- {e}")
        return 2

    if find_record(records, marker_id):
        print(f"marker_id already exists: {marker_id}")
        return 2

    records.append(record)
    save_registry(args.registry, records)
    print(json.dumps(record, ensure_ascii=False))
    return 0


def cmd_update(args: argparse.Namespace) -> int:
    records = load_registry(args.registry)
    record = find_record(records, args.marker_id)
    if not record:
        print(f"marker_id not found: {args.marker_id}")
        return 2

    if args.scope:
        record["scope"] = args.scope
    if args.target:
        record["target"] = args.target
    if args.classification:
        record["classification"] = args.classification
    if args.rationale:
        record["rationale"] = args.rationale
    if args.notes:
        record["notes"] = args.notes
    if args.performer:
        record["performer_id"] = args.performer

    record["updated_at"] = utc_now_iso()

    ok, errors = validate_record(record)
    if not ok:
        print("validation failed:")
        for e in errors:
            print(f"- {e}")
        return 2

    save_registry(args.registry, records)
    print(json.dumps(record, ensure_ascii=False))
    return 0


def cmd_list(args: argparse.Namespace) -> int:
    records = load_registry(args.registry)
    if args.scope:
        records = [r for r in records if r.get("scope") == args.scope]
    if args.classification:
        records = [r for r in records if r.get("classification") == args.classification]
    print(json.dumps(records, indent=2, ensure_ascii=False))
    return 0


def cmd_validate(args: argparse.Namespace) -> int:
    records = load_registry(args.registry)
    all_ok = True
    for i, record in enumerate(records, start=1):
        ok, errors = validate_record(record)
        if not ok:
            all_ok = False
            print(f"record #{i} marker_id={record.get('marker_id', '<missing>')} invalid")
            for e in errors:
                print(f"- {e}")
    if all_ok:
        print(f"all records valid: {len(records)}")
        return 0
    return 2


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Marker DSL utility for internal/non-internal classification records")
    parser.add_argument("--registry", default=default_registry_path(), help="Path to marker registry JSON file")

    sub = parser.add_subparsers(dest="command", required=True)

    p_mark = sub.add_parser("mark", help="Create a marker record")
    p_mark.add_argument("--marker-id", help="Optional explicit marker ID")
    p_mark.add_argument("--scope", required=True, choices=sorted(SCOPE_VALUES))
    p_mark.add_argument("--target", required=True)
    p_mark.add_argument("--classification", required=True, choices=sorted(CLASSIFICATION_VALUES))
    p_mark.add_argument("--performer", required=True, help="Human or agent identifier")
    p_mark.add_argument("--rationale", required=True)
    p_mark.add_argument("--notes", default="")
    p_mark.set_defaults(func=cmd_mark)

    p_update = sub.add_parser("update", help="Update an existing marker record")
    p_update.add_argument("--marker-id", required=True)
    p_update.add_argument("--scope", choices=sorted(SCOPE_VALUES))
    p_update.add_argument("--target")
    p_update.add_argument("--classification", choices=sorted(CLASSIFICATION_VALUES))
    p_update.add_argument("--performer", help="Human or agent identifier")
    p_update.add_argument("--rationale")
    p_update.add_argument("--notes")
    p_update.set_defaults(func=cmd_update)

    p_list = sub.add_parser("list", help="List marker records")
    p_list.add_argument("--scope", choices=sorted(SCOPE_VALUES))
    p_list.add_argument("--classification", choices=sorted(CLASSIFICATION_VALUES))
    p_list.set_defaults(func=cmd_list)

    p_validate = sub.add_parser("validate", help="Validate all marker records")
    p_validate.set_defaults(func=cmd_validate)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
