# Bug: Signed-out resend-verification endpoint has no rate limiting

**Status:** Open
**Severity:** Medium (before public/production traffic) — mail-bombing / abuse vector
**Triage:** Actionable — mechanical fix (rate-limit the endpoint); no product decisions needed.
**Found:** 2026-10-18, verification of the bug 009 fix (the fix itself carries a comment acknowledging this)

## Summary

The bug 009 fix added a signed-out path to `identity/email_verifications#create`: it accepts an `email` request param and enqueues a verification email with no authentication and no throttling. Any client can POST that endpoint repeatedly and cause unbounded verification mail to a victim's address (mail-bombing, sender-reputation damage).

## Where

| File | Problem |
|------|---------|
| `app/controllers/identity/email_verifications_controller.rb` | Signed-out `create` branch (`resend_by_email`) has no rate limit |

## Impact

Abuse vector. Fine for local/dev; must be closed before any deployment that sends real mail.

## What done looks like

- The endpoint is rate-limited (e.g. `Rails 8 rate_limit`, or a per-email + per-IP throttle via `rack-attack` or a cache-counter).
- When throttled, the response is indistinguishable from the success case for unknown emails (no enumeration leak via the limiter's behavior).
- A test covers: repeated requests beyond the limit stop enqueuing mail.

## Suggested direction

If on Rails 8, `rate_limit to: 3, within: 3.minutes` in the controller is the smallest fix; otherwise a per-email/per-IP cache counter guard before `deliver_later`.
