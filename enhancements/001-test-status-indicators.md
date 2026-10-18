# Enhancement: Per-test status indicators with hover details and a run-log reveal

**Status:** Proposed
**Created:** 2026-10-17
**Depends on:** bug 002 (challenge answer loop) for its home on the challenge show page; works standalone on the test-class editor too

## Problem

Today the minitest runner reports results as a single blob of text: raw `stdout`/`stderr` is streamed into one `outputTarget` `<pre>`, capped off with a one-line summary/verdict (see `app/javascript/controllers/minitest_controller.js`). When a run fails, the user must visually parse free-text output to figure out *which* tests failed, which errored, which were skipped, and why. There is no at-a-glance state, and the full log is always in the way (or lost when a debounced re-run wipes it).

## Proposal

Three pieces:

1. **Per-test status indicators.** Next to each test method (in the test-method list, and inline in/next to the editor gutter if feasible), show a small colored dot/badge: pass (green), fail (red), error (red/different glyph), skip (yellow/gray), pending/never-run (neutral).
2. **Hover details.** Hovering (or focusing, for keyboard users) an indicator shows the test's message — failure message, error backtrace's first line(s), or skip reason — in a tooltip/popover.
3. **Floating "run log" button.** A small floating action button reveals the full raw test run output in a panel/drawer (collapsible), so detail is one click away without permanently occupying screen space.

## How to get per-test results

Currently the runner only parses Minitest's summary line. To attribute results per test, add a minimal custom reporter to the Ruby setup code (`rubySetupCode` in the minitest controller):

- Register a `Minitest::Reporter` subclass (via `Minitest::Reporters`-style plugin or `Minitest.reporter <<`) that, on `record`, emits one structured line per test result, e.g. `__RQ_RESULT__ <test_name> <status> <json-encoded-message>`, to a dedicated output (a marker-prefixed `stdout` line is simplest given the `consolePrinter` wiring).
- Parse those lines in JS into `{ name, status, message }` entries; strip them from the displayed log so the raw output stays clean.
- Map results to test-method rows by test method name (the `minitest_test_methods` records already know their names — the controller can receive them as a JSON value, e.g. `data-minitest-test-names-value`).

Caveat: each debounced auto-run (per bug 002's decision) replaces the results — indicators should show a subtle "running" state during a run rather than stale results.

## Done looks like

- [ ] Each test method shows a status indicator reflecting the most recent run: pass / fail / error / skip / not-yet-run / running.
- [ ] Indicator colors and glyphs are distinguishable and not color-only (icon or shape differs), so they work for colorblind users.
- [ ] Hover/focus on an indicator shows the failure/error/skip message in a tooltip or popover; it is dismissible and doesn't trap the pointer.
- [ ] A floating button toggles a collapsible panel containing the full, verbatim run log (stdout + stderr + verdict line).
- [ ] Structured per-test lines are filtered out of the visible log.
- [ ] Results clear or flip to "running" when a new (debounced) run starts; indicators never show results from an older run mixed with a newer one.
- [ ] Works when the code has a syntax error or the VM fails to load (indicators reset to a neutral "could not run" state; the error still shows in the log panel).
- [ ] No regression to the existing verdict line / summary parsing (`minitestVerdict`) used for pass/fail gating of challenge answers.
- [ ] Mobile: indicators still visible/tappable; log panel usable on small screens.

## Out of scope

- Persisting results server-side (dashboard semantics stay governed by bug 002's decisions).
- Jump-to-line / click-to-navigate in the editor.
- Re-running a single test in isolation.
- Test-order randomization reporting ("run in random order" seed display).
