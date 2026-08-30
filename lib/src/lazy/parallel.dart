import '../async_iterable.dart';
import 'parallel_stub.dart' if (dart.library.io) 'parallel_vm.dart';

/// CPU-bound twin of [mapConcurrent]. Runs [worker] on a pool of [workers]
/// isolates, preserving source order.
///
/// Prefer a top-level or static [worker]. A capturing closure is fine when
/// every capture is sendable; a closure that captures a non-sendable
/// (a [ReceivePort], an open socket) throws [ArgumentError] at spawn — the
/// isolate contract, not a fxdart invention. [A] and [R] must be sendable.
///
/// Unsupported on the web: throws [UnsupportedError]. Use [mapConcurrent]
/// / [concurrentAsync] to overlap Futures on any platform.
///
/// `workers == 1` still uses the pool (the work ran off the main isolate).
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
