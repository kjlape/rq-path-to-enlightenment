# Bug: Resend-verification from the signed-out reset page silently no-ops for unknown emails

**Status:** Fixed (2026-10-18 — fixed in parallel-worktree workflow; see merge commits on master)
**Severity:** Low (edge case, anti-enumeration tradeoff)
**Triage:** Actionable — small UX fix; preserve the anti-enumeration behavior, just make the button's outcome honest.
**Found:** 2026-10-18, reviewer finding during the bug 004 fix
**Repo:** rq-path-to-enlightenment

## Summary

On `/identity/password/new`, when password reset is blocked because the email is unverified, the page now offers a "resend verification" callout (added by the bug 004 fix). But the resend `button_to` posts to `identity_email_verification_path` while signed out, which routes the user through sign-in first — and the reset-blocked state intentionally conflates "unknown email" with "unverified email" (anti-enumeration). For a nonexistent email the resend appears to do nothing.

## Where

| File | Problem |
|------|---------|
| `app/views/identity/password_resets/new.html.erb` | Resend button posts to the verification endpoint that requires a session; signed-out users get bounced to sign-in with no explanation |
| `app/controllers/identity/email_verifications_controller.rb` (or equivalent) | Create action has no signed-out path |

## Impact

A signed-out user who forgot their password and never verified sees the "resend" affordance, clicks it, and lands on the sign-in page — a new dead end, one step removed from the original one.

## What done looks like

- The resend action works for signed-out users who have an unverified account (look up by the email param already on the page, requeue the verification mail via letter_opener in dev).
- For unknown emails, still respond identically to the known case (no enumeration leak) but land the user somewhere that explains "if an account exists, a verification email was sent" rather than the sign-in form.
- Tests cover: signed-out resend for unverified account sends mail; response for unknown email is indistinguishable; no mail is sent for unknown email.

## Suggested direction

Add a param-based resend endpoint usable while signed out (email in the request params, rate-limited), or render the resend form to collect the email explicitly. Keep the existing sign-in-based resend for signed-in users.
