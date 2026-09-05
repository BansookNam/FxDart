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
/// before the worker isolate is killed. [A] and [R] must be sendable;
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
/// *result*, which fails the whole batch rather than only its own pull.
/// It also delays the first element until its batch finishes, so a
/// `take(1)` wants a small [chunk] or none.
FxAsyncIterable<R> parallel<A, R>(
  int workers,
  FutureOr<R> Function(A input) worker,
  Iterable<A> iterable, {
  int chunk = 1,
}) {
  _checkArgs(workers, chunk);
  return parallelImpl(workers, worker, iterable, chunk);
}

/// Async-source twin of [parallel].
FxAsyncIterable<R> parallelAsync<A, R>(
  int workers,
  FutureOr<R> Function(A input) worker,
  FxAsyncIterable<A> iterable, {
  int chunk = 1,
}) {
  _checkArgs(workers, chunk);
  return parallelAsyncImpl(workers, worker, iterable, chunk);
}

void _checkArgs(int workers, int chunk) {
  if (workers < 1) {
    throw RangeError("'workers' must be a positive integer");
  }
  if (chunk < 1) {
    throw RangeError("'chunk' must be a positive integer");
  }
}

/// Alias of [parallel] — the CPU twin of [mapConcurrent], under the name
/// that sits next to it.
@pragma('vm:prefer-inline')
FxAsyncIterable<R> mapParallel<A, R>(
  int workers,
  FutureOr<R> Function(A input) worker,
  Iterable<A> iterable, {
  int chunk = 1,
}) => parallel(workers, worker, iterable, chunk: chunk);

/// Alias of [parallelAsync] — the CPU twin of [mapConcurrentAsync].
@pragma('vm:prefer-inline')
FxAsyncIterable<R> mapParallelAsync<A, R>(
  int workers,
  FutureOr<R> Function(A input) worker,
  FxAsyncIterable<A> iterable, {
  int chunk = 1,
}) => parallelAsync(workers, worker, iterable, chunk: chunk);
