# RxDartComparison benchmark case authoring

Each benchmarkable RxDartComparison example gets a scaled case:

```
benchmark/cases-rx/<slug>/data.dart     # deterministic dataset, shared verbatim
benchmark/cases-rx/<slug>/rxdart.dart   # scaled copy of the example's RxDart pipeline
benchmark/cases-rx/<slug>/fxdart.dart   # scaled copy of the example's fxdart pipeline
```

Runner: `dart run benchmark/run_benchmarks.dart --rx [slugs…]` → AOT-compiles
both sides, runs scales **N=100 and the headline only** (no N=10,000 middle
pass), writes `benchmark/results/results-rx.json` + `SUMMARY-RX.md`.
`tool/build_docs.dart` renders the bars on each RxDartComparison page.

Read `benchmark/AUTHORING.md` (the Dart-family rules) FIRST — every rule
there applies (faithfulness, determinism via `Lcg`/formulas, checksum
discipline, n-derived datasets, no printing in `run`, reset mutable state)
except as amended here:

- **Sides.** The left side is `rxdart.dart` (imports package:rxdart, calls
  `bench(slug: ..., impl: 'rxdart', ...)`); the right side is `fxdart.dart`
  (`impl: 'fxdart'`). Checksums must match between them at BOTH scales.
- **Headline sizes.** Sync-shaped examples (`async: false` in the example's
  frontmatter): `final n = caseN(1000000);`. Async-shaped examples
  (`async: true`): `final n = caseN(10000);`. EITHER WAY, verify one
  iteration of EACH side finishes < 2 s — the rx side drives every element
  through the event loop even for "sync" tasks, so if 1M doesn't fit, drop
  that case's headline to `caseN(10000)` and say why in a comment.
- **Delays.** All simulated latency (`Future.delayed`) becomes
  `Duration.zero`; keep concurrency limits, retry counts, and failure
  patterns exactly as in the example.
- **Timeout-style cases** keep the operator but size the limit so it can
  never fire (e.g. seconds against zero-delay reads) — the shape is what is
  measured, not the stall.
- **NOT benchmarked** (wall-clock semantics; no case directory): examples
  #39–#47 (spaced-out-calls, debounced-search, throttled-refresh,
  sampled-gauge, combine-form-fields, with-latest-config,
  switch-to-newest-search, first-mirror-wins, live-latest-value).
- **Event fixtures at scale.** Examples whose small version uses
  `Timer`-scheduled event sources (#49, #50, #48's counters): replace the
  timed fixture with an immediate one derived from `data.dart` (e.g. a
  `Stream.fromIterable` or a controller fed in a loop) — identical shape on
  both sides, zero wall-clock.

## Verify before you're done

```bash
for N in 100 ""; do
  BENCH_N=$N BENCH_SMOKE=1 dart benchmark/cases-rx/<slug>/rxdart.dart
  BENCH_N=$N BENCH_SMOKE=1 dart benchmark/cases-rx/<slug>/fxdart.dart
done   # checksums must match at each scale; note the per-iteration time
dart analyze benchmark/cases-rx/<slug>
```
