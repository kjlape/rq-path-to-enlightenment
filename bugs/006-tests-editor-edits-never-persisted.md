# Bug: Code edits in the Tests list editor are silently lost

**Status:** Open
**Severity:** Medium (data loss for users)
**Triage:** Actionable — preferred fix: explicit Save action (PATCH the class/method body) plus beforeunload warning; acceptable alternative: read-only editor. Either resolves the data loss.
**Found:** 2026-10-18, browser QA run-through

## Summary

On `/minitest_test_classes` (and the class show page), the code editor is fully editable and wired to the Ruby WASM runner — a user can modify the code and Run it. But nothing ever saves the edited text: there is no Save control and the Stimulus controller only reads the value. A user who fixes a test in the editor, sees it pass, and navigates away loses the edit with no warning.

## Where

| File | Problem |
|------|---------|
| `app/javascript/controllers/minitest_controller.js` | Reads `codeTarget.value/textContent` for `run()` only; no persistence |
| `app/views/minitest_test_classes/_minitest_test_class.html.erb` | Editable `<code-input>` with no save affordance next to Run |

## What done looks like

- Either make the editor read-only on list/show pages (view-only preview; edit via the Edit pages), or
- Add an explicit Save action that PATCHes the class/method body, and warn (beforeunload) on unsaved changes.
