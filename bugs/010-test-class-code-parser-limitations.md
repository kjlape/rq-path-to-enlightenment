# Bug: Test-class code parser rejects valid test names and loses method ordering on save

**Status:** Open
**Severity:** Low (usability limits of the bug 006 Save feature; failures are loud, never data loss)
**Triage:** Actionable — tighten the parser regex and persist explicit method ordering. No product decisions needed.
**Found:** 2026-10-18, reviewer finding during the bug 006 fix
**Repo:** rq-path-to-enlightenment

## Summary

The Save feature added for bug 006 round-trips edited editor source through `MinitestTestClass.parse_code` / `#update_from_code`. Two limitations:

1. `METHOD_DEFINITION` regex (`test_[a-z_]+`) only matches lowercase-and-underscore test names. A method like `def test_returns_2_items` is not recognized as a method definition, so saving such a class 422s ("unparseable") instead of saving.
2. Method reordering in the editor isn't preserved — records keep their original (`created_at`) order regardless of where the user moves a method in the source.

Both fail/ignore loudly rather than corrupting data, but both surprise users.

## Where

| File | Problem |
|------|---------|
| `app/models/minitest_test_class.rb` | `METHOD_DEFINITION` regex rejects digits (and non-`test_` helper defs are silently folded elsewhere) |
| `app/models/minitest_test_class.rb` (`parse_code` / `update_from_code`) | Method order in source is discarded; records keep `created_at` order |

## Impact

Users writing idiomatic test names with digits can't save at all (422 with a confusing error). Reordering tests in the editor silently doesn't take effect on reload.

## What done looks like

- Regex accepts any valid Ruby identifier after `test_` (digits, capitals), e.g. `test_[A-Za-z0-9_]+`.
- Saving persists method order explicitly (e.g. a `position` column on `minitest_test_methods`, backfilled from `created_at`, applied on `update_from_code`) so editor order survives a round-trip.
- Model tests: digit-bearing test names round-trip; reordering two methods and saving preserves the new order; unparseable input still 422s.

## Suggested direction

Small migration + regex fix; the existing round-trip test coverage in `test/models/minitest_test_class_test.rb` is the right place to extend.
