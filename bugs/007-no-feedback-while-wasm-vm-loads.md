# Bug: First Run of tests gives no feedback while the Ruby VM compiles

**Status:** Open
**Severity:** Low (perceived breakage)
**Found:** 2026-10-18, browser QA run-through

## Summary

The first click of a **Run** button downloads/instantiates `ruby+stdlib.wasm` (~30+ MB from jsdelivr) before any output appears. During this window (observed ~5-8s on a fast connection) the page shows nothing — no spinner, no "loading VM" text — so it reads as a broken button. The "Ruby VM ready" message and results only appear after instantiation completes.

## Where

`app/javascript/controllers/minitest_controller.js` — `createRubyVM()` sets `outputTarget.textContent = 'Ruby VM ready\n'` only after `WebAssembly.instantiate` resolves; nothing is shown before that.

## What done looks like

- On first Run, immediately render "Loading Ruby VM…" (spinner) into the output target before fetching/instantiating.
- Optionally warm the VM on page load so the first Run is instant.
