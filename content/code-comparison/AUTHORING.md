# DartComparison example authoring conventions

Repo: /Users/nam/Projects/dart/FxDart. You are authoring examples for the
"Dart vs FxDart" comparison site (docs/DartComparison/). Each example is:

1. `content/comparison/<slug>.md` — the page
2. `content/code-comparison/<slug>/native.dart` — plain-Dart implementation
3. `content/code-comparison/<slug>/fxdart.dart` — fxdart implementation

`expected.txt` is written automatically by the harness — never write it by hand.

## Templates (read these first)

- `content/comparison/food-spending.md` + `content/code-comparison/food-spending/` (sync example)
- `content/comparison/bounded-concurrency.md` + `content/code-comparison/bounded-concurrency/` (async example)

Copy their structure exactly: front-matter keys, 2-space-indented HTML body,
section order (Requirement → `{{output}}` → `<h2>Side by side</h2>` →
`{{comparison}}` → `<h2>Why they differ</h2>`).

## Front matter (all keys required)

```
---
slug: <kebab-slug, must equal the filename>
title: <Heading> — Dart vs FxDart
description: <one line, NO double quotes, ≤160 chars — shown in the TOC row and meta tag>
heading: <plain text, sentence case, no HTML>
order: <number, assigned to you — never change it>
tier: <1|2|3|4>
functions: <comma-separated fxdart functions used, see chip rule>
domain: <transactions|orders|logs|sensors|users|general>
verdict: <fxdart|tie|native>
async: <true|false>
---
```

Optional key `alsoLink:` — extra fxdart function names mentioned in the prose
(outside the chip list) that should auto-link to their tutorials. Prose
`<code>name</code>` mentions auto-link ONLY for names in `functions:` +
`alsoLink:`; mentions of NATIVE Dart functions that share fxdart vocabulary
(`fold`, `reduce`, `sort`…) must stay plain, so never add those.

**Chip rule:** every name in `functions:` (and `alsoLink:`) MUST have a
tutorial at `content/tutorials/<name>.md` (the build fails otherwise — check
with ls).
Use chain-method names (`concurrent`, not `concurrentAsync`). For
`fromStream`/`toStream` use the chip name `streams`. List each function once
(distinct names). `toList` never counts as a function.
Tier sets the count: tier 1 = exactly 2, tier 2 = exactly 3, tier 3 =
exactly 5, tier 4 = 6–10 distinct functions.

## Code rules (harness-enforced — run it before you're done)

- Both files print **byte-identical stdout**. Deterministic always: fixed
  in-memory data, no wall-clock, no unseeded randomness (prefer no randomness).
- Print doubles via `toStringAsFixed(...)` (VM prints `25.0` where the web
  playground prints `25` — formatting sidesteps it).
- **No `dart:io`** (or ffi/isolate/mirrors/html) — code must run both on the VM
  and in the browser playground. Simulate I/O with in-memory data + delays.
- `native.dart` must NOT import fxdart; it MAY import `package:collection/`
  (nothing else). `fxdart.dart` imports only `package:fxdart/fxdart.dart`.
- Async examples: fixed `Future.delayed` of 10–30 ms; **print only after
  collecting results, in deterministic order** (concurrent completion order is
  nondeterministic). To demonstrate a concurrency limit, use the
  `inFlight`/`maxInFlight` counter pattern from the bounded-concurrency pilot.
- Shared data/model classes: duplicate them **verbatim** in both files.
- Keep each file readable in a browser editor: aim ≤ 60 lines; small datasets
  (6–12 records) chosen so the printed result is verifiable by eye.
- fxdart side uses chain style: `fx(xs).filter(...).map(...)`,
  `fx(xs).toAsync().map(...).concurrent(n)`. Note `Fx.groupBy` is TERMINAL
  (returns a Map) — continue with `fx(map.entries)...` (see
  `example/daily_ledger/lib/logic/summaries.dart` for the idiom).
- Native side must be **honest idiomatic Dart**: collection-for, `where/map/
  fold`, `package:collection` helpers (`groupListsBy`, `slices`, `sortedBy`,
  `firstWhereOrNull`), real `Stream` APIs. NO strawmen — write the native
  version the way a good Dart dev actually would.

## Verdict honesty (the site's credibility depends on this)

- `native`: plain Dart is genuinely as good or better (short where/map chains,
  things Dart 3 has built in: `firstOrNull`, `indexed`, `skipWhile`).
- `tie`: both read fine; fxdart adds vocabulary but native isn't worse.
- `fxdart`: fxdart is clearly better — missing native vocabulary (groupBy,
  scan, chunk, zip, uniqBy, partition...), long pipelines where composition
  wins, or bounded concurrency (native needs a worker pool).
The "Why they differ" section must match the verdict — if it's `native` or
`tie`, SAY SO plainly.

## Prose rules

- Requirement section states the task concretely and says data is in the code.
- Use 2026-07 dates in data (site's "this month").
- HTML body only (no markdown), 2-space indent, like the templates.
- `<code>` for function names in prose.

## Verify loop (must pass before you finish)

```
dart run tool/check_comparison.dart <your-slug-1> <your-slug-2> ...
dart analyze content/code-comparison
```

Both must be clean. The harness writes expected.txt for you.
Do NOT run tool/build_docs.dart, do NOT edit anything outside
content/comparison/<your slugs>.md and content/code-comparison/<your slugs>/
(no edits to tool/, docs/, chrome.arb, pages/, or other agents' examples).
