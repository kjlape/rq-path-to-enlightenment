# Bug: Empty or assertion-less minitest class shows ✅ pass

**Status:** Open
**Severity:** Medium (misleading feedback for a learning app)
**Triage:** Actionable — parse the Minitest summary from stdout; ✅ only when runs > 0 and failures/errors/skips == 0; "⚠️ No tests ran" otherwise. Clear acceptance criteria, no decisions needed.
**Found:** 2026-10-18, browser QA run-through

## Summary

Clicking **Run** on a minitest test class with zero test methods runs `0 runs, 0 assertions, 0 failures` and the UI prints **✅**. For a teaching tool this teaches that an empty test suite passes. Similarly, a class whose methods contain no assertions passes.

## Where

`app/javascript/controllers/minitest_controller.js` — `run()` treats `result.toJS() === true` as success without checking the run/assertion counts reported by Minitest.

## What done looks like

- Parse the Minitest summary (runs/assertions) from stdout; show "⚠️ No tests ran" when runs == 0 (or assertions == 0).
- Only print ✅ when runs > 0 and failures/errors/skips == 0.
