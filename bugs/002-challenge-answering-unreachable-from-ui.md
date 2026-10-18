# Bug: The core loop is a dead end — challenges can't be answered from the UI

**Status:** Open
**Severity:** High (product-breaking)
**Triage:** Unblocked (bug 001 ownership decided 2026-10-17; core loop and completion decided 2026-10-17, see Decisions below). Dashboard semantics and the answer model follow from these: completion = passing tests, editor auto-runs tests debounced and a passing run is what counts as complete.
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

- Challenge show embeds the code editor (minitest Stimulus controller) preloaded with the challengeable class code. Tests auto-run, debounced as the user types; a passing run creates/updates the `challenge_answer`.
- Dashboard completion reflects passing runs, not mere answer existence.
- "Challenge" picker on any answer form is a select of the challenges (shared/global curriculum per bug 001's decision), never a numeric ID field.

## Decisions (2026-10-17)

- **Core loop: auto-run.** Tests run automatically with debouncing as the user types (no manual Run→Submit flow in the challenge loop).
- **"Complete" = passing tests.** A challenge is complete when the tests pass — dashboard completion reflects passing runs, not mere answer existence (already implied in "What done looks like", now confirmed).
- **Client-side results are trusted (2026-10-18).** The `passed` flag arrives from the browser runner and is not verified server-side; a signed-in user could forge a passing POST. Accepted deliberately: tests run in Ruby WASM in the student's own browser, so the only person a forged result cheats is the forger — they're stubbing their own growth, not gaining anything of value. Progress is private (per bug 001) and unlocks nothing. Revisit only if answers ever gate access, rank users, or drive credentials.
