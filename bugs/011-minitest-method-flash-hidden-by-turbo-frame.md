# Bug: "Method created" flash is never visible — rendered inside a Turbo Frame

**Status:** Fixed (merged to master)
**Severity:** Low (feedback/perception)
**Triage:** Actionable — small view fix; no product decisions needed.
**Found:** 2026-10-18, during the bug 008 system-suite fix (test worked around it by asserting persistence instead of the flash)

## Summary

`app/views/minitest_test_methods/new.html.erb` renders inside a Turbo Frame. When the create action succeeds, the redirect re-renders only the frame — the layout flash (`notice`) lives outside the frame, so the "successfully created" message is generated but never displayed. The user gets no feedback that the save worked (they must notice the new row themselves).

## Where

| File | Problem |
|------|---------|
| `app/views/minitest_test_methods/new.html.erb` (and the surrounding frame host) | Flash renders outside the Turbo Frame, so post-create redirect never shows the notice |

## Impact

Silent success. The test suite (`test/system/minitest_test_methods_test.rb#create`) currently asserts persistence on the parent page instead of the flash — proof the flash is unverifiable as-is.

## What done looks like

- Creating a method from the editor shows the success flash.
- Either the flash renders inside the frame, or the create redirect escapes the frame (`data: { turbo_frame: "_top" }` on the form) so the full layout (with flash) renders.

## Suggested direction

Prefer `data: { turbo_frame: "_top" }` on the create form — one line, keeps flash in the layout. Then strengthen the system test to assert the flash text again.
