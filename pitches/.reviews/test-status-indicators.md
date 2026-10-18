---
pitch: pitches/test-status-indicators.md
pitch_sha256: f58ca8dbdcb7307a52ff792400cf8ad7823da487a8e983c944f33710ed12193a
verdict: ready_for_betting
betting_decision: pending
rounds_completed: 1
---

# Pitch Review: Test status indicators

## Bet

For learners solving Ruby challenges (pre-launch, near-zero users), single-blob test output prevents quickly seeing which tests fail and why. Enabling at-a-glance per-test status with expandable detail should make the core learning loop's diagnose step usable at launch. The appetite is one cycle, sequenced after bug 002's core-loop fix.

## Evidence Ledger

| Claim | Supported / inferred / unknown | Source and limitations | Decision affected |
|---|---|---|---|
| Test output is a single blob users must parse | Supported | `minitest_controller.js` behavior; enhancement 001; bug 002 QA | Problem is real |
| Blob parsing materially slows/ frustrates users | Inferred | Developer inference; no observed users (pre-launch) | Value magnitude — bounded at one cycle |
| Bug 002's loop will ship as a home for indicators | Unknown (open bug) | bugs/002 is unimplemented | Sequencing: made the bet contingent |
| The core loop is currently broken | Supported | bugs/002, severity High | Whether indicators relieve the actual constraint |

## Constraint and Causal Diagnosis

System boundary: the write-code → run-tests → diagnose → fix loop. Desired outcome: a usable challenge experience at launch. The current constraint is the missing loop itself (bug 002), not output presentation — indicators only relieve a constraint after the loop exists. Chain: indicators → faster failure diagnosis → faster challenge completion. First arrow supported; second inferred, accepted as bounded risk.

## Objections and Dispositions

| ID | Challenged claim and consequence | Smallest resolution | Disposition and reason |
|---|---|---|---|
| O1 | Wrong constraint: core loop is a dead end (bug 002); indicators would polish an unreachable flow | Explicit sequencing after bug 002; challenge-page placement removed from scope | Resolved — user agreed (2026-10-20) |
| O2 | No baseline or observed users for the friction claim | Success signal = QA-pass judgment on post-bug-002 QA run; no baseline collection (pre-launch, no analytics) | Resolved — user agreed; inference accepted as bounded risk |
| O3 | Hover tooltips + floating log drawer are polish; mobile support for them is expensive | Cut both; one click/tap-to-expand interaction pattern; log drawer deferred to a future bet | Resolved — user accepted cuts |

## Alternatives Considered

| Alternative | Outcome preserved or lost | Cost, risk, and evidence | Decision and reason |
|---|---|---|---|
| Defer entirely | Cycle free for bug 002 follow-up | Zero cost; launch ships with blob output | Rejected — diagnosis UX is part of a usable loop at launch |
| No-build (better raw output formatting) | Loses per-test state entirely | Cheap but keeps line-by-line parsing | Rejected — at-a-glance state is the core value |
| Narrower: indicators only, no detail | Loses the "why" — user still opens raw log for messages | Saves little; expandable detail is cheap once results are parsed | Rejected — incomplete journey |
| Full original scope (tooltips + log drawer) | More polish | Back half of a cycle; mobile accessibility burden | Cut per O3 — deferred features need future bets, not promises |

## Scope Decisions

| Capability | Proposed cut | Value or protection lost | Keep / cut / test and reason |
|---|---|---|---|
| Per-test indicators (test-method list) | — | Core value | Keep |
| Click/tap-to-expand detail | — | Failure messages without raw-log spelunking | Keep |
| Hover/focus tooltips | Replaced by click/tap expand | Desktop hover convenience | Cut — one interaction pattern serves desktop + mobile |
| Floating run-log button | Defer | One-click access to full log | Cut — raw output remains where it is today; future bet if wanted |
| Challenge show page placement | Defer to bug 002 follow-on | Indicators in the challenge flow | Cut this cycle — surface doesn't exist yet |
| Colorblind-safe glyphs | — | Accessibility | Keep — cheap, necessary |

**Valuable core retained:** a learner running tests sees each test's state at a glance and can expand any failure to read why — on desktop and mobile.

## Exit Gates

| Gate | Pass / fail / unresolved | Evidence or remaining gap |
|---|---|---|
| Value | Pass | Pre-launch usability of the core loop; deferral cost is a rougher launch experience |
| Evidence | Pass | Proportionate: one cycle, QA-judgment evaluation; friction claim labeled inferred |
| Causality | Pass | Contingent on bug 002 first; chain stated with the inferred link explicit |
| Alternatives | Pass | Defer, no-build, narrower all considered and recorded |
| Scope | Pass | Cuts made; journey (run → see → expand → understand) complete |
| Evaluation | Pass | Agreed: post-bug-002 QA pass judgment; no baseline (stated) |
| Feasibility | Pass | Marker-line emission from WASM runner is low-risk; stop condition bounds it |
| Risk | Pass | Residual inference and dependency explicit and accepted |

## Verdict and Next Action

**ready_for_betting**, contingent on bug 002 shipping first. The bet is a defensible, bounded one-cycle polish on the (soon-to-exist) core loop, not a guarantee the friction was real — that risk is bounded by appetite.

## Human Betting Decision

Pending. User saved the pitch and review but explicitly held off on approving the bet (2026-10-20). Approval is also conditional on bug 002 landing first. When approved, run `draft-slices` against the pitch revision bound to `pitch_sha256` above.

## Outstanding Questions and Resume Notes

- Betting decision outstanding; settled decisions not to reopen without new evidence: sequencing after bug 002, QA-judgment success signal, the three scope cuts (tooltips, log drawer, challenge-page placement).
- Review completed in one round; decision was clear, second round skipped with user's answers incorporated.
