# Bug: Test-class parser still rejects `?`/`!`/`=`-suffixed test method names

**Status:** Open
**Severity:** Low (rare names; failure is loud — 422, never data loss)
**Triage:** Actionable — extend the regex and round-trip handling; no product decisions needed.
**Found:** 2026-10-18, verification of the bug 010 fix (noted as out of scope there)

## Summary

The bug 010 fix widened `METHOD_DEFINITION` in `app/models/minitest_test_class.rb` to `test_[a-zA-Z0-9_]+`, but a trailing `?`, `!`, or `=` (valid in Ruby identifiers, e.g. `def test_even?`) is still not matched, so saving such a class 422s with the "unparseable" error.

## Where

| File | Problem |
|------|---------|
| `app/models/minitest_test_class.rb` | `METHOD_DEFINITION` regex lacks optional `[?!=]` suffix |

## Impact

Rare but valid test names can't be saved; confusing error. Loud failure, no data loss.

## What done looks like

- `def test_even?` (and `!`/`=` forms) round-trips through `parse_code` / `update_from_code`.
- Model test in `test/models/minitest_test_class_test.rb` covers a `?`-suffixed name round-trip.
- Unparseable input still 422s.

## Suggested direction

`/\A\s*def\s+(test_[a-zA-Z0-9_]+[?!=]?)\b/` (or append `(?:[?!=])?` to the existing regex); confirm the capture used for `position`/naming strips or keeps the suffix consistently on both parse and render sides.
