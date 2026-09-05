// Shared harness for the DartComparison benchmarks (benchmark/cases/).
//
// VM-only (dart:io) — benchmarks never run in the browser playground, so the
// content/code-comparison import policy does not apply here. The library
// itself stays zero-dependency; this directory is tooling, like tool/.
//
// Each case file calls [bench] once from main(). The harness warms the JIT,
// times the workload, samples peak RSS, and prints ONE machine-readable JSON
// line to stdout (prefixed so the runner can find it among any other output).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Prefix for the result line so `run_benchmarks.dart` can pick it out.
const resultPrefix = '@@BENCH@@ ';

/// True when this process is an AOT executable (`dart compile exe` runs in
/// product mode; `dart run` is a JIT and reports false). Stamped into every
/// result line — the runner refuses non-AOT results, because JIT timings
/// depend on warmup-sensitive compiler state and JIT peak RSS measures the
/// compiler itself (~166 MB for an empty script), not the pipeline.
const isAot = bool.fromEnvironment('dart.vm.product');

/// The dataset size for this process: BENCH_N when set, else the case's
/// headline size. Cases build their dataset from this so one compiled binary
/// serves every scale (the runner runs each case at N=100, N=10,000, and the
/// headline N).
int caseN(int defaultN) {
  final env = Platform.environment['BENCH_N'];
  // Empty string counts as unset so `BENCH_N= ` / `for N in 100 10000 ""`
  // shell loops select the headline scale.
  return env == null || env.isEmpty ? defaultN : int.parse(env);
}

/// Portable deterministic PRNG (64-bit LCG, Numerical Recipes constants).
/// Used instead of dart:math Random so datasets are identical on every SDK.
///
/// CAUTION: like every power-of-two-modulus LCG, the low bits have short
/// periods (bit 0 alternates every draw), so `nextInt(2)` / `nextInt(4)` are
/// degenerate. Draw binary/small choices from [nextDouble] (high bits), e.g.
/// `rng.nextDouble() < 0.25`. Do NOT "fix" this by changing the generator —
/// existing case datasets depend on its exact output.
class Lcg {
  Lcg(this._state);
  int _state;

  int _next() {
    _state =
        (_state * 6364136223846793005 + 1442695040888963407) &
        0x7fffffffffffffff;
    return _state;
  }

  /// Uniform int in [0, max).
  int nextInt(int max) => _next() % max;

  /// Uniform double in [0, 1).
  double nextDouble() => (_next() >> 20) / (1 << 43);
}

/// Worker count for the ParallelComparison cases (`benchmark/cases-parallel/`).
///
/// Every isolate-using variant reads the *same* number from here, so the
/// hand-rolled slices and `parallel`'s pool are given identical hardware to
/// work with and the comparison is about the machinery, not the pool size.
/// BENCH_WORKERS overrides it; the default is the processor count, which is
/// what `parallelWorkers` would pick.
int get benchWorkers {
  final env = Platform.environment['BENCH_WORKERS'];
  if (env != null && env.isNotEmpty) return int.parse(env);
  return Platform.numberOfProcessors;
}

/// Splits [items] into at most [parts] contiguous slices of near-equal size.
///
/// The hand-rolled isolate variant's decomposition: one slice per isolate,
/// sent once. Slices are contiguous so the concatenated result is in source
/// order, which is what makes its checksum comparable with the other three.
List<List<T>> sliceEvenly<T>(List<T> items, int parts) {
  if (items.isEmpty) return const [];
  final k = parts < 1 ? 1 : (parts > items.length ? items.length : parts);
  final out = <List<T>>[];
  final base = items.length ~/ k;
  final extra = items.length % k;
  var start = 0;
  for (var i = 0; i < k; i++) {
    // The first [extra] slices take one more, so no element is left over.
    final end = start + base + (i < extra ? 1 : 0);
    out.add(items.sublist(start, end));
    start = end;
  }
  return out;
}

/// Runs one benchmark side and prints its result line.
///
/// [run] executes the full workload and returns a checksum object; its
/// `toString()` is compared between the native and fxdart sides by the
/// runner, so both implementations must provably compute the same answer.
/// The checksum also keeps the JIT from dead-code-eliminating the work.
///
/// Iterations: BENCH_WARMUP (default 2) unmeasured runs, then BENCH_ITERS
/// (default 5) measured runs. BENCH_SMOKE=1 does 0 warmup / 1 iteration —
/// used when authoring to verify a case works at all.
Future<void> bench({
  required String slug,
  required String impl, // 'native' | 'fxdart' | 'native-isolate' | …
  required int n, // dataset size, echoed into the result
  required FutureOr<Object?> Function() run,
}) async {
  final env = Platform.environment;
  final smoke = env['BENCH_SMOKE'] == '1';
  final warmup = smoke ? 0 : int.parse(env['BENCH_WARMUP'] ?? '2');
  final iters = smoke ? 1 : int.parse(env['BENCH_ITERS'] ?? '5');

  Object? checksum;
  for (var i = 0; i < warmup; i++) {
    checksum = await run();
  }

  // Auto-batching: at small N a single run is at or below Stopwatch's µs
  // resolution, so time a batch of [batch] runs per sample and report the
  // per-run average. Sized so one sample spans ≥ ~2 ms.
  final sw = Stopwatch()..start();
  checksum = await run();
  sw.stop();
  final probeUs = sw.elapsedMicroseconds;
  final batch = probeUs >= 2000 ? 1 : (2000 ~/ (probeUs < 1 ? 1 : probeUs)) + 1;

  final iterUs = <double>[];
  for (var i = 0; i < iters; i++) {
    sw
      ..reset()
      ..start();
    for (var b = 0; b < batch; b++) {
      checksum = await run();
    }
    sw.stop();
    iterUs.add(sw.elapsedMicroseconds / batch);
  }

  final result = {
    'slug': slug,
    'impl': impl,
    'aot': isAot,
    'n': n,
    'batch': batch,
    'iterUs': iterUs,
    'maxRssBytes': ProcessInfo.maxRss,
    'checksum': '$checksum',
  };
  stdout.writeln('$resultPrefix${jsonEncode(result)}');
}
