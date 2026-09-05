import '../async_iterable.dart';

/// Web / non-isolate implementation. See [parallel] for the contract.
Never parallelImpl<A, R>(
  int workers,
  R Function(A input) worker,
  Iterable<A> iterable,
  int chunk,
) => _unsupported();

/// Web / non-isolate implementation. See [parallelAsync] for the contract.
Never parallelAsyncImpl<A, R>(
  int workers,
  R Function(A input) worker,
  FxAsyncIterable<A> iterable,
  int chunk,
) => _unsupported();

/// Web has no [Platform.numberOfProcessors]; [parallel] still throws.
int get parallelWorkersImpl => 1;

Never _unsupported() => throw UnsupportedError(
  'parallel is VM/Flutter-only; it uses dart:isolate. '
  'On the web, use concurrent(n) for overlapping Futures.',
);
