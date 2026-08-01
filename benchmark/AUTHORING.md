# Benchmark case authoring conventions

Each DartComparison example (`content/comparison/<slug>.md` +
`content/code-comparison/<slug>/`) gets a scaled benchmark case:

```
benchmark/cases/<slug>/data.dart     # deterministic large dataset, shared verbatim
benchmark/cases/<slug>/native.dart   # scaled copy of the example's native pipeline
benchmark/cases/<slug>/fxdart.dart   # scaled copy of the example's fxdart pipeline
```

Templates: `benchmark/cases/food-spending/` (sync), `benchmark/cases/bounded-concurrency/` (async).

## Rules

- **Faithfulness first.** Each side's `run` closure re-implements the SAME
  pipeline shape as the example in `content/code-comparison/<slug>/` — same
  operators, same order, same algorithmic idea. Scale the data, not the logic.
  Model classes are copied from the example; only the tiny const dataset is
  replaced by a generator in `data.dart`.
- **Sizes.** Declare the headline size as `final n = caseN(1000000);` (from
  `harness.dart`) — the runner also executes every case at N=100 and
  N=10,000 by exporting `BENCH_N`, so **everything about the dataset must be
  derived from `n`, never hardcoded**: forced-unique extremes go at
  `n ~/ 2`-style positions, early-exit trigger depth at `n * 9 ~/ 10`,
  overlap/window ranges as fractions of `n`. If the dataset needs a
  divisibility property (full weeks etc.), round `n` down
  (`final n = caseN(...) ~/ 7 * 7;`) — report the actual count to `bench`.
  Sync cases: headline `1000000`. If the example's algorithm is worse than
  O(n log n) (nested scans), drop the headline to the largest n that
  finishes one iteration in < 2 s and say why in a comment. Async cases:
  headline between 2000 and 10000, all `Future.delayed` become
  `Duration.zero`, keep the example's concurrency limit / retry counts /
  failure pattern. A headline of exactly 10000 is not allowed — it would
  duplicate the N=10,000 scale the runner always runs. A case with no
  concurrency window and no retry bookkeeping may exceed the 10000 ceiling
  (up to ~100000, still < 2 s per iteration) so its headline bar shows
  something the N=10,000 bar does not; say why in a comment.
- **Determinism.** All data comes from `Lcg` (in `benchmark/harness.dart`) or
  plain formulas — never `dart:math` `Random`, never wall-clock. Failure
  injection for retry/fallback cases: deterministic, e.g. `id % 7 == 3`.
- **Checksum.** `run` returns an object whose `toString()` must be identical
  between the two sides (the runner enforces this). Derive it from the
  computed result, format doubles with `toStringAsFixed`, and keep it O(1)-ish
  — e.g. `'${rows.length}|${rows.first}|${total.toStringAsFixed(2)}'`. Never
  join a million elements into the checksum; that would dominate the timing.
- **What's timed.** Only the pipeline: build the dataset once in `main()`
  before calling `bench(...)`. Everything inside `run` is measured, and `run`
  must fully materialize its result (end on `toList()`/fold/etc. — a lazy
  iterable that's never consumed measures nothing).
- **No printing** inside `run` — the harness prints the one result line.
- **Imports.** `native.dart` must not import fxdart; it may import
  `package:collection/collection.dart` if the example does. `fxdart.dart`
  imports `package:fxdart/fxdart.dart`. Both import `../../harness.dart` and
  `data.dart`. `dart:io` is fine here (VM-only) but should not be needed.
- **Mutable module state** (e.g. `inFlight` counters): reset it at the top of
  `run` so warmup iterations don't leak into measured ones.

## Verify before you're done

```bash
# checksums must match between the two sides AT EVERY SCALE:
for N in 100 10000 ""; do
  BENCH_N=$N BENCH_SMOKE=1 dart benchmark/cases/<slug>/native.dart
  BENCH_N=$N BENCH_SMOKE=1 dart benchmark/cases/<slug>/fxdart.dart
done
dart analyze benchmark/cases/<slug>
```

Then one real timing sanity check — a single iteration should be well under
2 s per side:

```bash
dart run benchmark/run_benchmarks.dart --smoke <slug>
```
