# Bug: Email verification is a dead end in development — password reset permanently blocked

**Status:** Fixed (2026-10-18 — letter_opener in dev, unverified-email banner with resend, reset-blocked page links to resend)
**Severity:** Medium (dev/onboarding UX)
**Triage:** Actionable — mechanical fix: letter_opener (or logged verification URL) in dev, unverified-email banner with resend, and link the reset-blocked error to the resend action. No decisions needed.
**Found:** 2026-10-18, browser QA run-through

## Summary

Sign-up queues a verification email (`UserMailer#email_verification` via `deliver_later`), but in development the mail is discarded (no letter_opener or similar), there is no "verify your email" banner or prompt anywhere in the UI after signup, and the only in-app resend link is buried on `/identity/email/edit`. Attempting "Forgot your password?" then yields "You can't reset your password until you verify your email" — an instruction the user has no reachable way to complete.

## Repro

1. Sign up as a fresh user.
2. Observe: no verification prompt; mail goes to dev void.
3. Sign out → "Forgot your password?" → submit email.
4. Blocked: "You can't reset your password until you verify your email."

## What done looks like

- Dev environment uses letter_opener (or logs the verification URL) so the flow is completable.
- A persistent "verify your email" banner (with resend) shows on every page while unverified.
- The password-reset page explains the situation and links to the resend action instead of a dead-end error.
