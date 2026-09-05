import 'dart:async';

import '../async_iterable.dart';

/// Web / non-isolate implementation. See [parallel] for the contract.
Never parallelImpl<A, R>(
  int workers,
  FutureOr<R> Function(A input) worker,
  Iterable<A> iterable,
  int chunk,
) => _unsupported();

/// Web / non-isolate implementation. See [parallelAsync] for the contract.
Never parallelAsyncImpl<A, R>(
  int workers,
  FutureOr<R> Function(A input) worker,
  FxAsyncIterable<A> iterable,
  int chunk,
) => _unsupported();

Never parallelOnImpl<A, R>(
  Future<List<dynamic>> Function(Function worker, List<dynamic> batch) run,
  int workers,
  FutureOr<R> Function(A input) worker,
  Iterable<A> iterable,
  FxAsyncIterable<A>? async,
  int chunk,
) => _unsupported();

Never parallelOnAsyncImpl<A, R>(
  Future<List<dynamic>> Function(Function worker, List<dynamic> batch) run,
  int workers,
  FutureOr<R> Function(A input) worker,
  FxAsyncIterable<A> iterable,
  int chunk,
) => _unsupported();

Future<
  ({
    Future<List<dynamic>> Function(Function worker, List<dynamic> batch) run,
    void Function() kill,
    int workers,
  })
>
spawnSharedPoolImpl(int workers) => _unsupported();

/// Web has no [Platform.numberOfProcessors]; [parallel] still throws.
int get parallelWorkersImpl => 1;

Never _unsupported() => throw UnsupportedError(
  'parallel is VM/Flutter-only; it uses dart:isolate. '
  'On the web, use concurrent(n) for overlapping Futures.',
);
