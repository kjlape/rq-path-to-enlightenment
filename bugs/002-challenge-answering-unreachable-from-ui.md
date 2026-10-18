# Bug: The core loop is a dead end — challenges can't be answered from the UI

**Status:** Open
**Severity:** High (product-breaking)
**Triage:** Partially unblocked (bug 001 ownership decided 2026-10-17) — still needs decisions on the intended core loop (auto-run tests on submit vs manual Run→Submit) and what "complete" means (passing tests vs submitted answer). Dashboard semantics and the answer model depend on this.
**Found:** 2026-10-18, browser QA run-through
**Repo:** rq-path-to-enlightenment

## Summary

The app's core loop — take a challenge, write code, run it, submit — cannot be completed through the interface. `ChallengeAnswer` is an untouched scaffold that is unreachable from any content page. The challenge show page renders raw scaffold attributes and offers no way to answer, and the only way to submit an answer is to hand-type `/challenge_answers/new` and enter a numeric challenge ID into a bare text field.

## Where / what a user actually hits

| Surface | Problem |
|------|---------|
| `app/views/challenges/show.html.erb` | Shows `Title:`, `Description:`, `Position:`, `Journey: 1`, `Challengeable: 1` — raw IDs, no answer form, no link to the minitest runner for the challengeable class |
| `app/views/journeys/show.html.erb` | Lists challenges but links only to the scaffold challenge show page |
| `app/views/challenge_answers/new.html.erb` | "Challenge" is a raw ID textbox — the user has no idea which ID maps to which challenge |
| Dashboard | "Overall Completion" jumps to 100% the moment *any* string is submitted as an answer — there is no correctness check tying answers to the test runner result |

By contrast, `/minitest_test_classes` has a real code editor + Run button (Ruby WASM), so the test-runner half of the loop exists but is never connected to challenges or answers.

## Repro

1. Sign up, create a journey, add a challenge.
2. Open the challenge → no way to answer it.
3. Visit `/challenge_answers/new`, type `1` into "Challenge", any string into "Submitted code" → Dashboard now reads **Overall Completion: 100%**.

## Impact

The product's stated purpose (journey to Ruby mastery with verifiable challenges) has no user-facing path; progress tracking is trivially gamed.

## What done looks like

- Challenge show embeds the code editor (minitest Stimulus controller) preloaded with the challengeable class code and a Submit button.
- Submitting runs the tests; only a passing run creates/updates the `challenge_answer` (or stores pass/fail).
- Dashboard completion reflects passing runs, not mere answer existence.
- "Challenge" picker on any answer form is a select of the challenges (shared/global curriculum per bug 001's decision), never a numeric ID field.
