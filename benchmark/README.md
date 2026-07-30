# DartComparison benchmarks

Scaled (≈1,000,000-item) performance benchmarks for every example on the
[Dart vs FxDart comparison site](../docs/DartComparison/index.html) — native
Dart and fxdart implementations of the same pipeline, timed and
memory-profiled head to head on your machine.

## Run everything

```bash
dart run benchmark/run_benchmarks.dart
```

Takes ~10–25 minutes. Writes:

- `benchmark/results/results.json` — machine info + per-case medians
  (consumed by `tool/build_docs.dart` to render the bar charts on the
  comparison pages)
- `benchmark/results/SUMMARY.md` — human-readable table

## Run a subset / options

```bash
dart run benchmark/run_benchmarks.dart food-spending top-expenses
dart run benchmark/run_benchmarks.dart --rounds 5     # more base rounds
dart run benchmark/run_benchmarks.dart --smoke        # fast sanity pass (not for reporting)
dart run benchmark/run_benchmarks.dart --scales full  # skip the small-N scales
```

## Method

- Every case × side is **AOT-compiled** (`dart compile exe`, cached in
  `benchmark/.build/`) and runs as a **fresh process**. AOT, not `dart run`,
  because under JIT peak RSS measures the VM compiling the code, not the
  pipeline: on an M1 Max an empty script peaks at ~166 MB and a 3-element
  fxdart pipeline at ~376 MB. Sides are interleaved per round so thermal
  drift affects both equally.
- Every case runs at **three scales**: N=100, N=10,000, and its headline N
  (1M sync / case-specific async) — cases read `BENCH_N` at runtime, so one
  binary serves all scales. Small-N runs are far below timer resolution, so
  the harness batches enough runs per sample to span ≥2 ms and reports the
  per-run average.
- Per process: 2 warmup iterations, then 5 measured iterations (override
  with `BENCH_WARMUP` / `BENCH_ITERS`). The reported time is the **median**
  of all measured iterations across rounds.
- 3 base rounds per case×scale. A scale is a **tie** when the two sides land
  within **5%** of each other — or within an absolute floor (`tieAbsMs` in
  `run_benchmarks.dart`, currently **0.6 ms**: the smallest floor at which
  every N=100 case ties), since calling a winner over an imperceptible
  difference would overstate a distinction no user of the program could
  notice. Close
  relative races re-run for up to 5 rounds total; the rounds count is in the
  results. After changing a verdict rule, `--report-only` re-derives all
  verdicts from the stored medians without re-measuring.
- **Memory** is peak process RSS (`ProcessInfo.maxRss`). VM baseline and the
  dataset are identical on both sides, so the difference between the two bars
  is what the pipeline itself holds onto.
- Both sides return a checksum that must match exactly — a benchmark whose
  two implementations disagree on the answer fails the run.
- Async cases can't await a million real delays; they use a smaller N
  (2k–10k) with zero-length delays and keep the example's concurrency
  structure. The N is shown next to every result.

Case authoring rules: see `AUTHORING.md`.
