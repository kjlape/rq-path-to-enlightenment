# QA Guide — Ruby Path to Enlightenment

How to run a full QA pass on this app: setup, driving it with a real browser, known gotchas, and where to file what you find. Written for future agents — assume you have shell access and `agent-browser` installed (`npm i -g agent-browser && agent-browser install`; check with `agent-browser doctor`).

## 1. Boot the app

```bash
bin/rails db:prepare                                  # set up / migrate dev DB
nohup bin/rails server -p 3000 > tmp/qa-server.log 2>&1 &
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/up   # expect 200
```

- Rails 7.1, importmap + Tailwind, SQLite dev DB.
- Server log lands in `tmp/qa-server.log` — grep it when a click "does nothing" to see if a request was even received.
- Teardown when done: `agent-browser close`, then kill the server process.

### Fresh state

To start from a clean slate: `bin/rails db:drop db:create db:migrate` (or just use a fresh signup — each QA run can use a throwaway account like `qa+<n>@test.dev`).

## 2. Accounts, passwords, 2FA

- **Signup**: any email; password must be **≥ 12 chars** and pass a pwned-password check. Known-good throwaway passwords are fine; famous example passwords ("correct horse battery staple") are rejected as "easily guessed".
- **Seeded user**: `db/seeds.rb` creates `admin@example.com` / `password`.
- **Password change/reset and email change** all require a `password_challenge` (current password). Reset requires a **verified email** — see bugs/004; in dev, verification mail is discarded, so prefer changing the password while signed in, or update the digest directly via `bin/rails runner`.
- **2FA**: if the test account has TOTP enabled (`user.otp_required_for_sign_in?`), every sign-in needs a six-digit code. Generate it server-side:

  ```bash
  SECRET=$(bin/rails runner 'print User.find_by(email: "...").otp_secret' 2>/dev/null)
  CODE=$(bin/rails runner 'require "rotp"; print ROTP::TOTP.new("'"$SECRET"'").now' 2>/dev/null)
  ```

  Sign in → you land on `/two_factor_authentication/challenge/totp/new` → fill the code → Verify.

## 3. Driving the app (agent-browser)

Core loop — **open → snapshot → act → re-snapshot**. Refs (`@e1`, `@e2`, …) go stale after any DOM change; always re-snapshot after navigation or form submission.

```bash
agent-browser open http://localhost:3000
agent-browser snapshot -i        # interactive elements only
agent-browser fill @e3 "value"; agent-browser click @e6
sleep 1                          # let Turbo/submit settle
agent-browser eval "location.pathname"   # verify where you actually are
```

Useful throughout:

- `agent-browser eval "<js>"` — ground truth (pathname, element state, computed styles)
- `agent-browser network requests --type xhr,fetch` — did the UI actually call the backend?
- `agent-browser console` — JS errors after a click
- `agent-browser snapshot` (no `-i`) — full text, needed to read validation error lists and copy
- Unauthenticated probes: `for u in /journeys/999 ...; do curl -s -o /dev/null -w "%{http_code} $u\n" http://localhost:3000$u; done` (expect 302 → sign-in); authenticated probes via `agent-browser eval "fetch('$u').then(r=>r.status)"` (expect 404)

### Harness gotchas (don't file these as app bugs)

- **Stale refs after navigation** — the #1 source of false positives. A click against an old ref can silently land on the wrong element (this once made a successful password change look like a silent failure). After any navigation, `snapshot -i` again before the next action.
- **Below-the-fold coordinate clicks** can report "✓ Done" but hit nothing. If a click does nothing, `eval` the element's `getBoundingClientRect` vs `innerHeight`, scroll (`scrollIntoView`), and retry. Verify against `location.pathname` and the server log — if the log shows no request, it was the harness, not the app.
- **First Run of the Ruby WASM runner takes ~5-10s** (30MB compile) with no feedback (see bugs/007). `sleep 8` before reading the `<pre>` output.
- Turbo renders make snapshots momentarily stale; a 1-2s sleep after submit is usually enough.

## 4. App map

| Area | Path | Notes |
|------|------|-------|
| Dashboard | `/` | Overall completion %, journeys list |
| Journeys | `/journeys` | CRUD; journeys contain challenges (nested routes) |
| Challenges | `/journeys/:id/challenges` | Delegated type: `MinitestTestClass` or `MinitestTestMethod` via `challengeable`; `class_name` must match `\A[A-Z][a-zA-Z]*\z` |
| Tests | `/minitest_test_classes` | Code editor + Run button (Ruby WASM, Stimulus `minitest_controller.js`); nested test methods |
| Challenge answers | `/challenge_answers` | Raw scaffold; "Challenge" is a numeric ID field (see bugs/002) |
| Settings | `/settings` | Password/email change, 2FA, sessions; everything else links out to scaffold pages |
| Auth | `/sign_in`, `/sign_up`, `/identity/password_reset`, `/identity/email` | |
| Health | `/up` | Expect 200 |

Position/order matters on challenges (`position` column, `≥ 0`, ordered index).

## 5. What to test (the standard pass)

Run phases in order; a failing reliability phase ends the run.

1. **Reliability** — the happy path: sign up → create journey → add challenge (with valid `class_name`) → create test class + method → Run in the browser (expect `1 runs, 1 assertions ... ✅`) → view dashboard. Up to 3 passes; it must complete identically every time.
2. **Comb** — groom it: edit records, duplicate positions, empty states, ordering, sign out/in (with TOTP), settings pages, password change (verify with `bin/rails runner 'print !!User.find_by(email: "...").authenticate("newpass")'` — don't trust the redirect alone), password reset, sessions list.
3. **Mischief** — hostile input: blank/whitespace fields, XSS probes in every free-text field (check rendered output via `eval`, not just the page), negative/float positions, namespaced class names (`Foo::Bar` — rejected by regex; is that intended?), bad IDs, double-submit (spam the create button, count rows via `fetch('/journeys.json', ...)`), out-of-order flows (delete the journey, then hit its challenge URL).
4. **Bug hunt (code-first, no browser)** — controllers (scoping/authorization), models (callbacks, validations), the Stimulus controllers, seeds, schema.

Before filing: check `bugs/` — known unfixed bugs live there as numbered files; don't re-file.

## 6. Filing bugs

Add `bugs/<next-number>-<slug>.md` following the format of `bugs/001-no-content-authorization.md`:

```markdown
# Bug: <one-line summary>

**Status:** Open
**Severity:** High|Medium|Low
**Found:** <date>, browser QA run-through

## Summary
<what's wrong>

## Where / Repro
<files + step-by-step repro>

## Impact
<who gets hurt, how>

## What done looks like
<acceptance criteria>
```

Rules of thumb:

- **Verify before filing.** Reproduce twice; rule out harness gotchas (§3). For "it didn't save" claims, check the server log for the request and the DB via `bin/rails runner` — never infer success/failure from redirects alone.
- One bug per file. Include a repro that starts from a fresh account where possible.
- High = breaks the product's core loop or loses data. Medium = misleading behavior, dead ends, real UX harm. Low = polish, feedback, perception.
- Every bug file carries a `**Triage:**` line: either "Actionable" (safe to fix directly — the criteria are in the file) or "Needs product-owner input" (a design/ownership/behavior decision gates the fix; don't code it). Keep this field current when decisions land.
- Don't file styling complaints unless a page is functionally broken — but do file "two design languages" style cohesion gaps once (see bugs/003).

## 7. Known open bugs (as of 2026-10-18)

- `bugs/001` — No content authorization: any user can read/edit/destroy any content.
- `bugs/002` — Challenge answering unreachable from the UI; completion = any answer exists.
- `bugs/003` — Raw scaffold pages across journeys/challenges/answers/sessions.
- `bugs/004` — Email verification dead end blocks password reset in dev.
- `bugs/005` — Empty test class shows ✅ pass.
- `bugs/006` — Code edits in the Tests editor are never persisted.
- `bugs/007` — No loading feedback on first WASM Run.
