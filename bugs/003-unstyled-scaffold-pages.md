# Bug: Most of the app is still unstyled scaffold — two design languages in one app

**Status:** Open
**Severity:** Medium (polish/cohesion)
**Triage:** Needs product-owner input — needs a style/design direction (or explicit "scaffold is fine for now"). Agents should not invent branding; fixing functionally broken pages is fine, restyling wholesale is not.
**Found:** 2026-10-18, browser QA run-through

## Summary

The Dashboard and Settings pages are fully styled (Tailwind, hero, cards), but nearly everything behind them is raw `rails generate scaffold` output: unstyled forms, buttons with default browser chrome, and pages that print raw database attributes including IDs and foreign keys.

## Where

| Page | What it shows |
|------|---------------|
| `/journeys`, `/journeys/:id`, `/journeys/new`, edit | "Title: Rails Fundamentals / Description: ..." plain text lists |
| `/journeys/:id/challenges/*`, `/challenges/:id` | Same, plus `Journey: 1`, `Challengeable: 1` |
| `/challenge_answers/*` | `User: 2`, `Challenge: 1` — internal user IDs shown to end users |
| `/password/edit` | Plain `<h1>` + unstyled form, "Back" to root (the styled Settings page that links to it is two design worlds away) |
| `/sessions` | "User Agent: Mozilla/5.0 ... HeadlessChrome/..." raw key:value list |
| `/minitest_test_classes/:id` | Headings like "adds_numbers" with bare Edit/Delete buttons |

## Impact

Reads as unfinished; internal IDs leak into copy; inconsistent trust cues next to the polished Dashboard/Settings.

## What done looks like

- Shared styled form/partial components for journeys, challenges, challenge answers, minitest classes/methods, sessions.
- Human-facing labels instead of raw attributes (`Journey: 1` → journey title; never render `user_id`).
