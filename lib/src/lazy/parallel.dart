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
/// isolate contract, not a fxdart invention. [A] and [R] must be sendable;
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
/// [workers] sizes the pool to the list, so `parallel(8, w)` over two
/// items starts two isolates, not eight. See [parallelWorkers] when you
/// do not want to pick [workers]; [mapParallel] is the same operator under
/// the name that sits next to [mapConcurrent].
FxAsyncIterable<R> parallel<A, R>(
  int workers,
  R Function(A input) worker,
  Iterable<A> iterable,
) {
  if (workers < 1) {
    throw RangeError("'workers' must be a positive integer");
  }
  return parallelImpl(workers, worker, iterable);
}

/// Async-source twin of [parallel].
FxAsyncIterable<R> parallelAsync<A, R>(
  int workers,
  R Function(A input) worker,
  FxAsyncIterable<A> iterable,
) {
  if (workers < 1) {
    throw RangeError("'workers' must be a positive integer");
  }
  return parallelAsyncImpl(workers, worker, iterable);
}

/// Alias of [parallel] — the CPU twin of [mapConcurrent], under the name
/// that sits next to it.
@pragma('vm:prefer-inline')
FxAsyncIterable<R> mapParallel<A, R>(
  int workers,
  R Function(A input) worker,
  Iterable<A> iterable,
) => parallel(workers, worker, iterable);

/// Alias of [parallelAsync] — the CPU twin of [mapConcurrentAsync].
@pragma('vm:prefer-inline')
FxAsyncIterable<R> mapParallelAsync<A, R>(
  int workers,
  R Function(A input) worker,
  FxAsyncIterable<A> iterable,
) => parallelAsync(workers, worker, iterable);
