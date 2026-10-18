# Bug: System test suite fails at baseline — 5 failures, 23 errors on a clean tree

**Status:** Fixed (2026-10-18 — fixed in parallel-worktree workflow; see merge commits on master)
**Severity:** Medium (CI/test-hygiene; the app itself works, the tests don't)
**Triage:** Actionable — mechanical selector/auth drift; no product decisions needed.
**Found:** 2026-10-18, during the bugs 004–007 fix workflow (three independent agents each confirmed it on the unmodified base commit)
**Repo:** rq-path-to-enlightenment

## Summary

`bin/rails test:system` fails on a completely clean checkout: 29 runs, 5 failures, 23 errors. The failures are auth/UI drift — tests written against an older UI now hit ambiguous or missing selectors (e.g. ambiguous "Sign up" match in `RegistrationsTest`, "Log out"/"Sign in" links that no longer exist as written, scaffold CRUD suites erroring, Turbo `fill_in` races). The unit/integration suite (`bin/rails test`) is green at baseline.

## Where

| File | Problem |
|------|---------|
| `test/system/registrations_test.rb` | Ambiguous "Sign up" selector match |
| `test/system/` (scaffold CRUD suites) | Error out — selectors target pre-styling DOM |
| Sessions-related suites | Assert links/labels ("Log out") that no longer match the styled UI |
| Multiple suites | Turbo `fill_in` race conditions (fill before the form is interactable) |

## Impact

System tests provide no signal: any real regression is indistinguishable from the 28 pre-existing failures, so nobody can trust red or green. New system tests (e.g. `test/system/identity/email_verification_test.rb` from the bug 004 fix) pass in isolation but drown in noise when the whole suite runs.

## What done looks like

- `bin/rails test:system` is fully green on a clean tree.
- Selectors updated to the current styled UI (prefer `data-testid`-style hooks or unique accessible names over bare link text).
- Turbo races handled via proper waiting (`fill_in` after the field is ready, or Capybara's default waiting semantics respected — no hard sleeps).
- A follow-up CI/QA note that the suite must stay green.

## Suggested direction

Fix suite-wide in one pass (not per-feature), running each suite individually to isolate the Turbo races from the selector drift. The bug 004 work left the suite untouched deliberately; nothing in the 004–007 fixes caused these failures.
