---
status: pitched
pitched: 2026-10-20
started: ~
completed: ~
audited: ~
slices: ~
---

# Test status indicators

## Executive Summary

**Decision requested:** approve a one-cycle bet to ship per-test status indicators with tap-to-expand detail on the test-class editor — explicitly sequenced **after** bug 002's core-loop fix.
**Expected outcome:** learners (and QA) can see at a glance which tests pass, fail, error, or skip, and read the failure message without parsing raw output.
**Appetite:** one cycle, result presentation only.
**Principal risk:** that blob-parsing was never the real friction — the value claim rests on developer inference, not observed users (pre-launch, near-zero users).

## Problem

When a test run finishes, the user gets one undifferentiated blob: everything Minitest prints — every test line, every backtrace, the summary — streams into a single text panel. To answer the most basic questions ("which tests failed? which one errored? why did this one skip?"), the user has to visually parse free text, scrolling past output for tests they don't care about.

Worse, the blob is transient. A debounced re-run wipes it, so a failure you were mid-read on disappears when you save. And when the whole thing fails to even start — a syntax error, a load failure — every test looks the same as tests that never ran.

There is no at-a-glance state anywhere: no way to see the shape of a run (mostly green with one red?) without reading it line by line.

## Business Outcome and Evidence

**Objective:** make the core learning loop (write code → run tests → diagnose → fix) survivable once bug 002 makes it reachable. This is a pre-launch product with near-zero users; the value is a usable challenge experience at launch, not measurable retention today.

Causal chain: per-test indicators → faster failure diagnosis → faster challenge completion. The first arrow is supported (the output really is a blob); the second is **inferred** — no user has been observed struggling with it. Accepted as a bounded risk at one cycle.

**Sequencing:** this bet is contingent on bug 002's core-loop fix shipping first. Polishing result presentation on a flow users cannot currently complete relieves a non-constraint.

## Appetite

One cycle. Scope is limited to the minitest flow's result presentation on the test-class editor surface: per-test indicators and expandable failure detail. Known opportunity cost: the same cycle spent on bug 002 follow-up QA or post-loop polish.

## Solution

### Per-test status indicators

Every test method in the test-method list on the test-class editor gets a small status badge reflecting its result from the most recent run:

```
✓  test_parses_valid_input
✗  test_rejects_empty_name
!  test_handles_unicode
◌  test_future_behavior        (skipped)
○  test_never_touched_this
```

States: pass, fail, error, skip, not-yet-run, running. States are distinguishable by glyph and shape as well as color, so colorblind users aren't locked out. While a run is in flight, indicators show a running state rather than stale results — never a mix of results from two different runs. When the run can't execute (syntax error, load failure), indicators reset to a neutral "could not run" state.

### Tap/click-to-expand detail

Activating an indicator (click or tap — one interaction pattern that works on desktop and mobile alike) expands a small inline panel beneath the test-method row showing that test's message: the failure message, the top of the error backtrace, or the skip reason. Activating again collapses it.

```
✗  test_rejects_empty_name
   ┌────────────────────────────────────┐
   │ Expected: "Name can't be blank"    │
   │  Actual: nil                       │
   └────────────────────────────────────┘
◌  test_future_behavior
○  test_never_touched_this
```

### Getting per-test results (product-level)

The runner currently only understands Minitest's final summary line. To attribute results per test, the Ruby setup that boots the test environment will emit one structured, marker-prefixed line per test result on standard output — test name, status, and JSON-encoded message. The client parses those lines into per-test results, matches them to test-method rows by name, and strips them from the visible log so the raw output the user reads stays clean. This must not disturb the existing verdict/summary parsing that gates challenge answers.

## Success Signals and Stop Conditions

- **Baseline:** none exists (pre-launch, no analytics). Not collecting one; evaluation is by judgment.
- **Success (agreed):** on the next QA pass after bug 002 ships, the reviewer judges that diagnosing a failing test from the editor is easy — no raw-output spelunking needed for the common failure cases.
- **Evaluation:** the post-bug-002 QA run (per `qa/README.md`), by whoever drives it.
- **Failure or stop:** if the marker-line output proves unreliable from the WASM runner early in the cycle, stop and reconsider rather than building elaborate fallback parsing.

## Key Assumptions and Risks

- **Inferred, unverified:** that blob output is a material friction. Accepted — bounded at one cycle, pre-launch.
- **Dependency:** bug 002 must ship first; otherwise this relieves a non-constraint.
- **Technical risk (low):** structured marker lines from the in-browser Ruby runner; stop condition above bounds it.
- **Protection:** existing verdict-line parsing that gates challenge answers must not regress.

## Rabbit Holes

- **Inline editor gutter indicators.** Tempting, but drags in editor-plugin work that can eat the cycle. The test-method list is the committed surface.
- **Click-to-jump in the editor.** A separate navigation feature — out of scope.
- **Re-running a single test in isolation.** Requires a different run model than "run everything debounced" — a separate problem.
- **Persisting results across sessions.** Dashboard semantics are governed by bug 002's decisions; this cycle stays client-side and ephemeral.
- **A general-purpose structured test protocol.** A minimal Minitest-specific format is sufficient; don't design for RSpec/Jest.
- **Reconstructing Minitest's full output ourselves.** Show the verbatim log with marker lines filtered out, not a re-rendered "nicer" version.
- **Hover/focus tooltips and a floating log drawer.** Cut during review — one click/tap interaction pattern replaces them; the floating log button needs a future bet if still wanted.

## No Gos

- Does not persist test results server-side; a page reload loses them.
- Does not place indicators on the challenge show page (that follows bug 002; not this cycle).
- Does not provide hover/focus tooltips (replaced by click/tap-to-expand).
- Does not provide a floating run-log button or collapsible log panel (deferred — needs a future bet, not a promise).
- Does not navigate the editor (no click-to-jump-to-line).
- Does not re-run an individual test in isolation.
- Does not report test-order randomization or seed.
- Does not change how the verdict line gates challenge answers.
- Does not support runners other than Minitest.
