# Bug: No content authorization — any user can edit or delete any content

**Status:** Fixed (2026-10-18, merged to master)
**Severity:** High (for a multi-user deployment) / Low (single-user or pre-launch)
**Triage:** Decision made 2026-10-17 — shared curriculum, private progress (see Decision below). Ready to implement.
**Found:** 2026-10-18, during a whole-repo deslop pass
**Repo:** rq-path-to-enlightenment

## Summary

Every content controller loads records globally — `Challenge.all`, `Journey.find(params[:id])`, etc. — with no scoping to the signed-in user and no ownership model anywhere in the schema. Any authenticated user can read, edit, and destroy any journey, challenge, or minitest test class/method, including content authored by other users.

## Where

| File | Problem |
|------|---------|
| `app/controllers/journeys_controller.rb` | `Journey.find(params[:id])` — unscoped; any user can edit/destroy any journey |
| `app/controllers/challenges_controller.rb` | `set_challenge` falls back to `Challenge.all` — any user can edit/destroy any challenge |
| `app/controllers/minitest_test_classes_controller.rb` | `MinitestTestClass.find(params[:id])` — unscoped |
| `app/controllers/minitest_test_methods_controller.rb` | `MinitestTestMethod.find(params[:id])` — unscoped |
| `app/controllers/challenge_answers_controller.rb` | `ChallengeAnswer.find(params[:id])` — unscoped; any user can edit/destroy another user's submitted answer; `index` lists **every** user's answers |
| `db/schema.rb` | No `user_id`/`creator_id` on `journeys`, `challenges`, `minitest_test_classes`, `minitest_test_methods` — there is nothing to scope against even if the controllers wanted to |

Authentication is fine (session login is enforced in `ApplicationController`); it is **authorization** that is entirely missing for content.

## Impact

- Any user can destroy another user's journeys, challenges, and test methods (`dependent: :destroy` cascades the damage).
- Any user can rewrite another user's submitted challenge answer — e.g. overwrite `submitted_code` to claim progress.
- `ChallengeAnswer#index` / `#show` expose other users' submitted code.

Not exploitable pre-authentication (the `authenticate` before_action covers these controllers), but a single shared sign-in field is the only thing standing between users.

## What done looks like

- ~~A decision on the ownership model~~ — made: shared curriculum, private progress (see Decision).
- `user_id` (or equivalent) added via migration wherever ownership applies, backfilled for existing rows.
- Controllers scope every lookup through the current user (e.g. `Current.user.journeys.find(params[:id])`) and the index actions list only the user's own records.
- Tests asserting a second user gets 404 (not 200) on another user's show/edit/update/destroy.
- JSON endpoints (`*.json.jbuilder`) covered by the same scoping.

## Decision (2026-10-17)

**Shared courses, admin edit only; private progress.** Journeys, challenges, and minitest test classes/methods are global, admin-authored content: readable by all signed-in users, editable/destroyable only by admins. Only `challenge_answers` is per-user private progress.

Consequences for implementation:

- Add an admin role/flag on users (e.g. `users.admin: boolean`); only admins reach the write actions on the four content controllers.
- Non-admin users get read-only access to content; write actions redirect/404.
- No `user_id` on content tables — they stay global. Backfill/admin bootstrap is limited to granting the first admin.
- Scope `ChallengeAnswersController` entirely through `Current.user.challenge_answers` (index, show, edit, update, destroy) — this is the user-data exposure and applies regardless of role.
- Update bug 002's answer-form work to assume a global challenge picker (all challenges visible to everyone).

Open follow-up (does not block this fix): how admins are promoted (seed, first-user, UI) — pick the simplest (seed/rake task) unless decided otherwise.

## Suggested direction

The decision above selects shape 1.

1. **Shared curriculum, private progress (recommended):** journeys/challenges/minitests become read-only global content (or admin-managed); only `challenge_answers` is per-user. Scope `ChallengeAnswersController` to `Current.user.challenge_answers` and drop/lock down the write actions on the content controllers.
2. **Per-user content:** add `user_id` to the content tables, scope every controller through `Current.user`, keep the current CRUD.

Either way, `ChallengeAnswersController` needs scoping immediately — that's the user-data exposure.
