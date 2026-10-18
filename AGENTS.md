# AGENTS.md

## QA

Before/after changing app behavior, run a QA pass following `qa/README.md` — it covers booting the app, driving it with agent-browser (login/2FA specifics, harness gotchas, the reliability → comb → mischief pass structure), and how to file findings.

## Bugs

Known unfixed bugs are written up in `bugs/` as numbered markdown files (`bugs/NNN-slug.md`). Before fixing one, read its file; when adding a new one, use the next number and follow the existing format (summary, where, impact, done criteria).
