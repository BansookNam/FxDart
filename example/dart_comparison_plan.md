# Final Plan: DartComparison (dart_comparison)

Deploy target: https://bansooknam.github.io/FxDart/DartComparison/
Synthesized from a draft plan + two independent sub-agent reviews (engineering 8/10, content/DX 7/10). All review findings verified against the repo were incorporated.

## 1. Fixed requirements (user spec)

- 50 examples, each with title + short description; TOC page; detail page = requirement + provided data, native Dart (left) vs fxdart (right), both runnable in-browser like FxDart101.
- Tiers by fxdart-function count: #1–10 → 2 functions, #11–20 → 3, #21–30 → 5, #31–50 → 6–10.
- English-only first (i18n later), mixed real-world domains, async included, per-side Run button + console.

## 2. Architecture (confirmed by eng review)

Generated static section of the docs site — NOT a Flutter app. Reuses the verified playground pipeline: CodeMirror → `docs/js/playground.js` → DartPad `compileNewDDC` → `docs/frame.html` iframe. Two playgrounds per page already work independently (each `.playground` gets its own Run/console/iframe; messages filtered by iframe source — playground.js:172,216).

## 3. Positioning / fairness framework (from content review — load-bearing)

- **Do NOT sell laziness for sync code.** Native Dart Iterables (`where`, `map`, `take`, `skipWhile`) are already lazy, and `lib/src/dart_aliases.dart` concedes the idiom overlap. The honest sync pitch is **vocabulary** (core Dart lacks `groupBy`, `chunk`, `zip`, `scan`, `uniqBy`, `partition`, `countBy`, `sortBy`) and **composition** (typed `fx()` chains). The **structural** win is async: the `concurrent(n)` back-channel that native Dart needs manual semaphores / `Future.wait` batching to approximate.
- Every example carries a front-matter `verdict: native-fine | tie | fxdart`, rendered as a colored strip on TOC + detail page with a one-sentence "why". Budget ~10–12 native-fine/tie examples, concentrated in Tiers 1–2. Honesty is the credibility strategy.
- **Native side may use `package:collection`** (core-team package; real idiomatic Dart). Verify DartPad compile-service support in the pilot; fall back to stdlib-only if unsupported (and say so on the page).

## 4. Content model — front matter is the single source of truth

(eng review: avoid examples.json/md dual-source drift; reuse `_loadPage` front-matter machinery)

```
content/pages/comparison.md                  # TOC intro prose
content/comparison/<slug>.md                 # front matter: title, description, order,
                                             #   tier, functions[], domain, verdict, async
                                             # body: requirement, data description, why-differs note,
                                             #   {{comparison}} placeholder, {{output}} placeholder
content/code-comparison/<slug>/native.dart   # runnable, void main(), real imports
content/code-comparison/<slug>/fxdart.dart   # runnable, identical stdout
content/code-comparison/<slug>/expected.txt  # captured stdout, written by harness, committed
```

- No `examples.json`. TOC derives order/tiers/chips from front matter.
- Slugs are permanent (generator never deletes; renames orphan old HTML across locales).

## 5. Authoring rules (hard, harness-enforced)

1. Both files print **identical stdout**. For concurrent examples: seeded randomness only (`createSeededRandom`), fixed simulated delays, **print only after collection in deterministic order** (progress-style prints are nondeterministic under concurrency and would differ between sides).
2. **No `dart:io`** — code must run on both the VM (harness) and web (DartPad). Simulate I/O with in-memory data + `delay`. Harness rejects `dart:io` imports.
3. Doubles printed via `toStringAsFixed(...)` — VM prints `25.0` where DDC prints `25`; formatting sidesteps the mismatch.
4. Native implementations must be idiomatic (collection-for, `where/map/fold`, `package:collection`, `Stream` APIs) — no strawmen.
5. Tier membership counts real operators — trivial terminals (`toList`) don't count toward the tier's function count.
6. Chain-form naming on pages (`.toAsync().map(...).concurrent(3)`); mention top-level data-first forms (`mapAsync`, `concurrentAsync`) once in the TOC intro, not per page.
7. `content/code-comparison/` gets its own `analysis_options.yaml` (strict — don't inherit content/'s relaxed unused-import rules).

## 6. Generator changes (`tool/build_docs.dart`)

1. Render `docs/DartComparison/index.html` (TOC) + `docs/DartComparison/<slug>.html` (detail) per locale (English fallback via existing `_loadPage` banner mechanism; untranslated pages auto-excluded from sitemap, canonical → English — all existing behavior).
2. **Extend `_placeholders` regex (build_docs.dart:320)** to cover `{{comparison}}` / `{{output}}` so translation-parity checks guard the new placeholders.
3. Detail page: requirement + data → verdict strip → **Expected output block (from expected.txt — readers get value without clicking Run; degrades gracefully when DartPad service is slow)** → responsive two-column dual playground (stacks on mobile) → "why they differ" note → function chips linking to existing tutorials → prev/next + breadcrumb.
4. TOC: 4 tier groups; each row = number, title, first sentence of requirement, function chips, domain tag, async badge, verdict strip. Client-side filter by function/domain/sync-async. A curated "If you only read 5" strip at top (#1, #11, #30, #41, #50).
5. Nav label **"Dart vs FxDart"** (avoids collision with the existing `comparisons` predicate tutorial); new chrome.arb keys for nav, panel headers ("Native Dart" / "fxdart"), tier names, prev/next — chrome falls back per-key, so zero i18n work now, no generator surgery later.
6. `--check` mode covers new pages automatically (diffs the whole written map).

## 7. Playground changes

- `docs/js/playground.js`: skip fetching/prepending `fxdart_single.dart` when source has no `package:fxdart` import (native panels compile faster; `remapErrors` degrades gracefully at offset 0 — verified).
- CSS for the two-column comparison layout + panel headers.
- Async already works through frame.html (unhandledrejection handled; late prints stream).

## 8. Verification harness (`tool/check_comparison.dart`)

- For each example: run both files, assert identical stdout, write `expected.txt`, reject `dart:io`, `dart analyze` both.
- Run as one aggregated runner (or under `dart test` with concurrency) — 100 separate `dart run` JIT spawns would take minutes. Simulated delays ≤ tens of ms.
- Run before every deploy; `--check`-style mode fails if any `expected.txt` is stale.

## 9. The 50 examples (post-review list)

Domains: T=transactions/DailyLedger, O=orders, L=logs, S=sensors, U=users, G=general. [nf]=native-fine, [tie], default=fxdart-wins. (A)=async.

**Tier 1 — 2 functions**
1. Food spending this month (T) — filter + sumBy
2. Running account balance, formatted (T) — scan + map (no `scan` in core Dart)
3. Top 3 largest expenses (T) — sortBy(-amount) + take [tie]
4. Merchants in first-visit order, deduped (T) — map + uniq (order-preserving dedupe absent from core)
5. Average basket size of orders over $100 (O) — filter + averageBy [tie]
6. First sensor reading over limit (S) — dropWhile + head [nf — `skipWhile().firstOrNull` is fine; framed honestly]
7. Most frequent log level (L) — countBy + maxBy
8. Batch users into pages of 10 (U) — chunk + map
9. Rank labels for a leaderboard (U) — zipWithIndex + map [tie — Dart 3 `indexed`]
10. Load 3 remote configs in order (G) (A) — toAsync + map

**Tier 2 — 3 functions**
11. Top 5 merchants by total spend (T) — groupBy + sortBy + take
12. Recent error messages, deduped (L) — filter + uniqBy + take
13. Spending inside a date window (T) — dropWhile + takeWhile + sumBy [tie]
14. All tags across posts, unique in first-seen order (G) — flatMap + uniq + sort
15. Refunds vs charges, both formatted (T) — partition + map + join
16. Compound interest table (G) — range + scan + map
17. Pair sensors with readings, keep anomalies (S) — zip + filter + map (no `zip` in core)
18. Category with highest average expense (T) — groupBy + map + maxBy
19. First 5 valid emails, normalized (U) — map + filter + take [nf]
20. Fetch user pages with bounded concurrency (U) (A) — toAsync + map + concurrent(2)

**Tier 3 — 5 functions**
21. Monthly category report, sorted by spend (T) — filter+groupBy+map+sortBy+join
22. Paginated product listing (O) — filter+sortBy+drop+take+map [tie — designated honesty example]
23. Weekly averages of chunked sensor data (S) — map+chunk+map+averageBy+join
24. Flag 3 consecutive over-limit readings (S) — zip(xs, drop(1,xs), drop(2,xs))+map+filter+map (redesigned — no `splitWhen` in API)
25. Budget alerts: categories over budget (T) — groupBy+map+filter+sortBy+map
26. Leaderboard with ties handled (U) — sortBy+groupBy+entries+zipWithIndex+flatMap
27. Receipt line items → invoice summary (O) — map+groupBy+map+sumBy+join
28. Longest streak of no-spend days (T) — scan+map+max+… (replaced moving-average — no sliding `window` in API)
29. Detect duplicate transactions (T) — groupBy+filter+flatMap+uniqBy+map
30. Concurrent enrichment of top merchants (T) (A) — filter+sortBy+take+toAsync+map+concurrent

**Tier 4 — 6–10 functions (async-heavy)**
31. Full monthly ledger report: totals, by-category, top merchants (T)
32. Cohort retention table (U)
33. Price-drop detection across snapshots (O)
34. Sensor anomaly readings with context lines (S)
35. Sparse time-series fill + aggregate (T)
36. Multi-currency expense normalization + report (T)
37. Inventory restock plan (O)
38. Log alert digest by service and severity (L)
39. p50/p95 latency report per endpoint (L) — groupBy+map+sortBy+nth+…
40. Diff two ledger snapshots (T) — differenceBy+intersectionBy+map+sortBy+…
41. Fetch 10 user profiles, 3 at a time (U) (A) — the flagship concurrency demo; native side shows the manual-semaphore boilerplate
42. Poll a flaky API until first success (G) (A) — range+toAsync+map+dropWhile+head
43. Concurrent price lookup with fallback (O) (A)
44. Stream of sensor events → windowed alerts (S) (A) — fromStream+chunk+filter+map+toStream (verify async chunk in pilot)
45. Rate-limited batch import (T) (A) — chunk+toAsync+map+concurrent(1)+delay+scan
46. Parallel downloads, results in order (G) (A) — deterministic: collect, then print
47. Two paged API feeds, concatenated, deduped, first N (L) (A) — honest title: `concat` is sequential, not a merge
48. End-of-day settlement pipeline (T) (A) — 8–10 fns, sync prep + concurrent posting
49. Live search over a keystroke Stream (G) (A) — fromStream+uniq+map(fetch)+take (no debounce claim — `debounce` is a function utility, not a stream operator)
50. **Finale: DailyLedger monthly close (T) (A)** — reuses DailyLedger's `Entry` shape and mirrors its real pipelines (`toAsync().map(read).concurrent(3)` + summaries), closing with a link to the live DailyLedger app.

## 10. Work order

1. **Pilot (gates everything):** generator skeleton + layout + 2 examples end-to-end — one sync (#1) and one **concurrent async** (#20, deliberately, to surface determinism issues early). Verify: dual playground, skip-lib-injection tweak, `package:collection` on DartPad, async chunk (#44 dependency).
2. Verification harness + expected.txt capture.
3. Author Tier 1 → 2 → 3 → 4, each example harness-verified as written. (Note: Tier 4's 20 async-heavy examples are the largest line item — likely more effort than Tiers 1–3 combined.)
4. TOC polish (filters, verdict strips, read-5 strip), nav link, chrome keys, sitemap.
5. `dart run tool/build_docs.dart` + harness + `./deploy.sh`.

## 11. Consequences / deferred items (explicit)

- Adding ~51 files to `_translatable()` drops ko coverage from 100% to ~70% at `--status`; new pages show the English-fallback banner in non-English locales until translated. Accepted (English-first decision).
- `window` (sliding) and `splitWhen` operators would strengthen #24/#28-class examples; DailyLedger precedent exists for example-driven operator additions (maxBy/minBy/sumBy/averageBy). **Deferred** — examples redesigned to current API to avoid scope creep; revisit after launch.
- Content reviewer suggested trimming Tier 4 to 12–14 examples; **kept at 20 per user spec** — flagged as an option if authoring effort needs cutting.
- DartPad compile service remains an external runtime dependency (already true for 101); static expected-output blocks are the mitigation.
