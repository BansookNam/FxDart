import 'dart:async';

import '../async_iterable.dart';
import 'parallel_stub.dart' if (dart.library.io) 'parallel_vm.dart';

/// Default pool size for [parallel]: the VM's processor count.
///
/// Pass it when you do not want to pick `n`:
/// `fx(items).parallel(parallelWorkers, parse)`. On the web this is `1`;
/// [parallel] itself still throws [UnsupportedError] there.
int get parallelWorkers => parallelWorkersImpl;

/// CPU-bound twin of [mapConcurrent]. Runs [worker] on a pool of [workers]
/// isolates, preserving source order.
///
/// Prefer a top-level or static [worker]. A capturing closure is fine when
/// every capture is sendable; a closure that captures a non-sendable
/// (a [ReceivePort], an open socket) throws [ArgumentError] at spawn — the
/// isolate contract, not a fxdart invention. [worker] may return a [Future]
/// ([FutureOr], same shape as [mapConcurrent]); a sync callback is still
/// the fast path — the isolate does not `await` a non-Future. Nested
/// `parallel` inside an async worker is allowed: that isolate spawns its
/// own pool, and cancel of the outer chain shuts the nested pool down
/// before the worker isolate is killed. One level of nesting is the
/// contract — a third nested `parallel` is SIGKILL'd with its parent, so
/// it cannot shut down *its* children. [A] and [R] must be sendable;
/// an unsendable input or result fails that pull with [ArgumentError]
/// rather than hanging.
///
/// Unsupported on the web: throws [UnsupportedError]. Use [mapConcurrent]
/// / [concurrentAsync] to overlap Futures on any platform. A cheap
/// callback (`x + 1`) loses to the isolate hop — that work belongs on
/// [concurrent], not here.
///
/// `workers == 1` still uses the pool (the work ran off the main isolate).
/// An empty source does not spawn isolates. A [List] source shorter than
/// the work the pool can take sizes the pool down, so `parallel(8, w)` over
/// two items starts two isolates, not eight. See [parallelWorkers] when you
/// do not want to pick [workers]; [mapParallel] is the same operator under
/// the name that sits next to [mapConcurrent].
///
/// ## [chunk] — how many elements ride one message
///
/// The default 1 is the streaming shape: every element crosses on its own,
/// so the first result comes back as soon as it is ready. That round trip
/// costs about 5µs, which is *more* than most callbacks, and it is why a
/// cheap worker loses. `chunk: k` pays it once per k elements instead:
///
/// ```dart
/// // 20k elements, ~0.4µs of work each, 4 workers:
/// //   chunk: 1     ~132ms   (11x slower than doing it inline)
/// //   chunk: 512     ~3ms   (4x faster than inline)
/// await fx(rows).parallel(4, parseRow, chunk: 512).toList();
/// ```
///
/// Pick it from the work per element: the batch wants to be long enough
/// that `k × callback` clearly exceeds ~5µs, and short enough that there
/// are still several batches per worker to balance across. `length ~/
/// (workers * 4)` is a reasonable starting point for a known length.
///
/// What a batch does not change: order, back-pressure, and where an error
/// lands — a throwing element still emits the results before it, then
/// raises at that element. The one thing it does change is an unsendable
/// *input* or *result*, which fails the whole batch rather than only its
/// own pull. It also delays the first element until its batch finishes,
/// so a `take(1)` wants a small [chunk] or none.
///
/// ## [chunked] — size the message from the source length
///
/// `chunked: true` picks `k = length ~/ (workers * 4)` when the source
/// is a [List] (at least 1). That is the formula the parallel-benchmark
/// page measured; the worker count is not repeated at the call site:
///
/// ```dart
/// await fx(rows).parallel(4, parseRow, chunked: true);
/// ```
///
/// Pass `chunk:` or `chunked:`, not both. `chunked: true` on a source
/// without a length throws [StateError] — give a [List] or pick `chunk: k`.
FxAsyncIterable<R> parallel<A, R>(
  int workers,
  FutureOr<R> Function(A input) worker,
  Iterable<A> iterable, {
  int chunk = 1,
  bool chunked = false,
}) {
  final k = _resolveChunk(
    workers: workers,
    chunk: chunk,
    chunked: chunked,
    sync: iterable,
  );
  return parallelImpl(workers, worker, iterable, k);
}

/// Async-source twin of [parallel].
///
/// [chunked] is not available here — an async source has no length.
/// Pass `chunk: k` to batch.
FxAsyncIterable<R> parallelAsync<A, R>(
  int workers,
  FutureOr<R> Function(A input) worker,
  FxAsyncIterable<A> iterable, {
  int chunk = 1,
  bool chunked = false,
}) {
  final k = _resolveChunk(
    workers: workers,
    chunk: chunk,
    chunked: chunked,
    sync: null,
  );
  return parallelAsyncImpl(workers, worker, iterable, k);
}

int _resolveChunk({
  required int workers,
  required int chunk,
  required bool chunked,
  Iterable<dynamic>? sync,
}) {
  if (workers < 1) {
    throw RangeError("'workers' must be a positive integer");
  }
  if (chunk < 1) {
    throw RangeError("'chunk' must be a positive integer");
  }
  if (!chunked) return chunk;
  if (chunk != 1) {
    throw ArgumentError('pass chunked: true or chunk: k, not both');
  }
  if (sync is! List) {
    throw StateError('chunked: true needs a length; pass a List or chunk: k');
  }
  final k = sync.length ~/ (workers * 4);
  return k < 1 ? 1 : k;
}

/// Alias of [parallel] — the CPU twin of [mapConcurrent], under the name
/// that sits next to it.
@pragma('vm:prefer-inline')
FxAsyncIterable<R> mapParallel<A, R>(
  int workers,
  FutureOr<R> Function(A input) worker,
  Iterable<A> iterable, {
  int chunk = 1,
  bool chunked = false,
}) => parallel(workers, worker, iterable, chunk: chunk, chunked: chunked);

/// Alias of [parallelAsync] — the CPU twin of [mapConcurrentAsync].
@pragma('vm:prefer-inline')
FxAsyncIterable<R> mapParallelAsync<A, R>(
  int workers,
  FutureOr<R> Function(A input) worker,
  FxAsyncIterable<A> iterable, {
  int chunk = 1,
  bool chunked = false,
}) => parallelAsync(workers, worker, iterable, chunk: chunk, chunked: chunked);

/// Runs [first] then [second] inside one isolate hop.
///
/// Two [parallel] stages copy every result back to the main isolate and
/// out again. Compose the workers instead:
///
/// ```dart
/// await fx(blobs)
///     .parallel(4, isolateMap2(decodePng, thumbnail), chunk: 64)
///     .toList();
/// ```
///
/// [first] and [second] must be sendable (top-level or static, or a
/// closure whose captures are). The returned function captures both; it
/// is sendable when they are.
R Function(A a) isolateMap2<A, M, R>(
  M Function(A a) first,
  R Function(M m) second,
) =>
    (A a) => second(first(a));

/// A reused isolate pool for sequential [parallelOn] chains.
///
/// [parallel] spawns on first pull and kills when the chain ends. Two
/// jobs then pay isolate startup twice. Spawn once, run many chains,
/// kill in `finally` — or use [IsolatePool.using]:
///
/// ```dart
/// await IsolatePool.using(4, (pool) async {
///   final a = await fx(batchA).parallelOn(pool, parseRow, chunk: 256).toList();
///   final b = await fx(batchB).parallelOn(pool, parseRow, chunk: 256).toList();
///   return (a, b);
/// });
/// ```
///
/// Cancel of one [parallelOn] chain does not kill the pool — in-flight
/// jobs finish and the isolates go idle. [kill] (and [using]'s `finally`)
/// is what tears the isolates down. Unsupported on the web.
class IsolatePool {
  IsolatePool._(this._run, this._kill, this.workers);

  final Future<List<dynamic>> Function(Function worker, List<dynamic> batch)
  _run;
  final void Function() _kill;

  /// How many worker isolates this pool holds.
  final int workers;

  var _closed = false;

  /// Spawns [workers] isolates with no worker baked in — each
  /// [parallelOn] call sends its function with the batch.
  static Future<IsolatePool> spawn(int workers) async {
    if (workers < 1) {
      throw RangeError("'workers' must be a positive integer");
    }
    final backend = await spawnSharedPoolImpl(workers);
    return IsolatePool._(backend.run, backend.kill, backend.workers);
  }

  /// [spawn], run [body], [kill] in `finally`. Sequential chains share
  /// the pool; the isolates die even if [body] throws.
  static Future<T> using<T>(
    int workers,
    Future<T> Function(IsolatePool pool) body,
  ) async {
    final pool = await spawn(workers);
    try {
      return await body(pool);
    } finally {
      pool.kill();
    }
  }

  /// Whether [kill] has run.
  bool get isClosed => _closed;

  Future<List<dynamic>> _runBatch(Function worker, List<dynamic> batch) {
    if (_closed) {
      return Future.error(StateError('IsolatePool is closed'));
    }
    return _run(worker, batch);
  }

  /// Shuts the isolates down. Idempotent. In-flight [parallelOn] pulls
  /// fail with [StateError].
  void kill() {
    if (_closed) return;
    _closed = true;
    _kill();
  }
}

/// [parallel] over a spawned [IsolatePool]. Does not spawn or kill;
/// see [IsolatePool].
FxAsyncIterable<R> parallelOn<A, R>(
  IsolatePool pool,
  FutureOr<R> Function(A input) worker,
  Iterable<A> iterable, {
  int chunk = 1,
  bool chunked = false,
}) {
  if (pool.isClosed) {
    throw StateError('IsolatePool is closed');
  }
  final k = _resolveChunk(
    workers: pool.workers,
    chunk: chunk,
    chunked: chunked,
    sync: iterable,
  );
  return parallelOnImpl(
    pool._runBatch,
    pool.workers,
    worker,
    iterable,
    null,
    k,
  );
}

/// Async-source twin of [parallelOn].
FxAsyncIterable<R> parallelOnAsync<A, R>(
  IsolatePool pool,
  FutureOr<R> Function(A input) worker,
  FxAsyncIterable<A> iterable, {
  int chunk = 1,
  bool chunked = false,
}) {
  if (pool.isClosed) {
    throw StateError('IsolatePool is closed');
  }
  final k = _resolveChunk(
    workers: pool.workers,
    chunk: chunk,
    chunked: chunked,
    sync: null,
  );
  return parallelOnAsyncImpl(pool._runBatch, pool.workers, worker, iterable, k);
}
