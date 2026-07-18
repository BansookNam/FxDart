import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Port of FxTS `generatorMock` (test/utils.ts): an async iterable that
/// records the [Concurrent] marker passed through `next` and completes
/// immediately.
class ConcurrentMock<T> implements FxAsyncIterable<T> {
  Concurrent? received;

  @override
  FxAsyncIterator<T> get iterator => _MockIterator<T>(this);
}

class _MockIterator<T> implements FxAsyncIterator<T> {
  final ConcurrentMock<T> owner;

  _MockIterator(this.owner);

  @override
  Future<IterResult<T>> next([Concurrent? concurrent]) async {
    owner.received ??= concurrent;
    return IterResult<T>.done();
  }
}
