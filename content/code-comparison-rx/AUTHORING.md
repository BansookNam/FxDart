# RxDartComparison example authoring conventions

Repo: /Users/nam/Projects/dart/FxDart. You are authoring examples for the
"RxDart vs FxDart" comparison site (docs/RxDartComparison/). Each example is:

1. `content/comparison-rx/<slug>.md` — the page
2. `content/code-comparison-rx/<slug>/rxdart.dart` — RxDart implementation
3. `content/code-comparison-rx/<slug>/fxdart.dart` — fxdart implementation

`expected.txt` is written automatically by the harness — never write it by hand.

The section's framing (read `content/pages/comparison-rx.md`): RxDart is a
push model (Streams, time, multicast), fxdart is a pull model (iterables,
demand, typed errors). The pairs show the same job in both models honestly —
including the jobs where a stream is simply the right shape.

## Templates (read these first)

- `content/comparison-rx/even-totals.md` + `content/code-comparison-rx/even-totals/` (overlap example)
- `content/comparison-rx/debounced-search.md` + `content/code-comparison-rx/debounced-search/` (time-based, RxDart-verdict example)

Copy their structure exactly: front-matter keys, 2-space-indented HTML body,
section order (Requirement → `{{output}}` → `<h2>Side by side</h2>` →
`{{comparison}}` → `<h2>Why they differ</h2>`).

## Front matter (all keys required)

```
---
slug: <kebab-slug, must equal the filename>
title: <Heading> — RxDart vs FxDart
description: <one line, NO double quotes, ≤160 chars — shown in the TOC row and meta tag>
heading: <plain text, sentence case, no HTML>
order: <number, assigned to you — never change it>
tier: <1|2|3|4>
functions: <comma-separated fxdart functions used, see chip rule>
domain: <transactions|orders|logs|sensors|users|general>
verdict: <fxdart|tie|rxdart>
async: <true|false — true when the FXDART side is an async pipeline (toAsync/fxAsync/fxStream)>
---
```

Tiers group by *relationship between the models*, not function count:
tier 1 = the overlap (both express it directly), tier 2 = windowing/state/
order, tier 3 = errors & resilience, tier 4 = concurrency, time & push.
Chips: tier sets no count here — list every distinct fxdart function used
(2–8 typical).

**Chip rule:** every name in `functions:` (and optional `alsoLink:`) MUST
have a tutorial at `content/tutorials/<name>.md` (build fails otherwise —
check with ls). Use chain-method names (`concurrent`, not `concurrentAsync`;
`ifEmpty` covers `defaultIfEmpty`; `uniqAdjacent` covers `uniqAdjacentBy`;
`retry` covers `mapRetry`). For `fromStream`/`toStream`/`fxStream` use the
chip name `streams`. `toList` never counts. RxDart operator names in prose
(`debounceTime`, `switchMap`, …) stay plain `<code>` — they must NOT appear
in `functions:`/`alsoLink:` (no tutorials exist for them, the build would
fail).

## Verdict honesty (the section lives or dies on this)

- `fxdart`: the problem is pull-shaped — bounded/finite data, ordered
  concurrency, typed error handling — and the stream version carries
  ceremony (subscriptions, controllers, completion tracking) the pull
  version simply doesn't have.
- `tie`: both models express it cleanly; the difference is taste/vocabulary.
- `rxdart`: the problem is genuinely push/time-shaped (user events,
  wall-clock windows, latest-value state, cancellation-by-newer). Say so
  plainly — the fxdart panel still prints the same output, but the prose
  must admit the stream version is the natural one.
The "Why they differ" section must match the verdict. NO strawmen in either
direction: write the RxDart side the way a good RxDart user actually would
(extension methods on Stream, `Rx.` constructors where idiomatic, no
hand-rolled StreamControllers where an operator exists), and the fxdart side
idiomatically too.

## Code rules (harness-enforced — run it before you're done)

- Both files print **byte-identical stdout**. Deterministic always: fixed
  in-memory data, no unseeded randomness, no wall-clock *reads*
  (`DateTime.now()` etc.).
- **Time-based operators are allowed** (that's the point of tier 4) but must
  be deterministic by construction: simulated event sources emit at fixed
  offsets (`Timer`/`Stream.periodic`/`Future.delayed` with literal
  Durations), and windows/gaps are separated by ≥3× so scheduler jitter can
  never flip the outcome (events at 0/40/80ms with a 200ms debounce window,
  not 90ms with a 100ms window). **Print only after collecting results**
  (`await stream.toList()` / `await ...toList()`), never from inside a
  subscription as events arrive, unless ordering is structurally guaranteed.
  Keep total runtime under ~2s.
- Print doubles via `toStringAsFixed(...)`.
- **No `dart:io`** (or ffi/isolate/mirrors/html). `dart:async` is fine and
  expected.
- `rxdart.dart` imports `package:rxdart/rxdart.dart` (required) and must NOT
  import fxdart. `fxdart.dart` imports only `package:fxdart/fxdart.dart`
  (+ `dart:async`); it must NOT import rxdart. When an example needs a
  simulated *event source* (a Stream), both sides build it from `dart:async`
  primitives, duplicated **verbatim** — the fxdart side then either bridges
  it (`fxStream`/`fromStream`) or shows the pull-native equivalent, per the
  example's point.
- Shared data/model classes: duplicate them **verbatim** in both files.
- Keep each file readable in a browser editor: aim ≤ 60 lines; small
  datasets (6–12 records) chosen so the printed result is verifiable by eye.
- fxdart side uses chain style (`fx(xs)...`, `fx(xs).toAsync()...`,
  `fxStream(s)...`). `Fx.groupBy` is TERMINAL (returns a Map) — continue
  with `fx(map.entries)...`.
- Use 2026-08 dates in data (site's "this month").

## Prose rules

- Requirement section states the task concretely and says data is in the code.
- "Why they differ" talks about the **models** (push vs pull), not just the
  operator names: what each side had to manage (subscription lifecycle,
  completion, backpressure vs demand, error channel vs error values), in
  2–3 paragraphs. Match the verdict.
- HTML body only (no markdown), 2-space indent, like the templates.
- `<code>` for operator names in prose. fxdart names auto-link only when
  listed in `functions:`/`alsoLink:`; RxDart names never link.

## Verify loop (must pass before you finish)

```
dart run tool/check_comparison.dart --rx <your-slug-1> <your-slug-2> ...
dart analyze content/code-comparison-rx
```

Both must be clean. The harness writes expected.txt for you.
Do NOT run tool/build_docs.dart, do NOT edit anything outside
content/comparison-rx/<your slugs>.md and content/code-comparison-rx/<your
slugs>/ (no edits to tool/, docs/, chrome.arb, pages/, or other agents'
examples).
