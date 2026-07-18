import 'dart:async';

import '../async_iterable.dart';

/// Returns an iterable of numbers from [start] (inclusive) to [end]
/// (exclusive), stepping by [step]. With one argument, counts `0..start`.
///
/// Port of FxTS `range`.
///
/// ```dart
/// range(4);        // (0, 1, 2, 3)
/// range(1, 4);     // (1, 2, 3)
/// range(4, 1, -1); // (4, 3, 2)
/// ```
Iterable<int> range(int start, [int? end, int step = 1]) sync* {
  if (end == null) {
    yield* range(0, start);
    return;
  }
  if (step < 0) {
    for (var i = start; i > end; i += step) {
      yield i;
    }
  } else {
    for (var i = start; i < end; i += step) {
      yield i;
    }
  }
}

/// Yields [value] [n] times.
///
/// Port of FxTS `repeat`.
Iterable<T> repeat<T>(int n, T value) sync* {
  for (var i = 0; i < n; i++) {
    yield value;
  }
}

/// Yields the source, then repeats its values indefinitely.
///
/// Port of FxTS `cycle`.
Iterable<T> cycle<T>(Iterable<T> iterable) sync* {
  final arr = <T>[];
  for (final a in iterable) {
    yield a;
    arr.add(a);
  }
  while (arr.isNotEmpty) {
    yield* arr;
  }
}

/// Async counterpart of [cycle].
FxAsyncIterable<T> cycleAsync<T>(FxAsyncIterable<T> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    final arr = <T>[];
    var sourceDone = false;
    var i = 0;
    return SerialAsyncIterator((concurrent) async {
      if (!sourceDone) {
        final result = await iterator.next(concurrent);
        if (!result.done) {
          arr.add(result.value);
          return result;
        }
        sourceDone = true;
      }
      if (arr.isEmpty) return IterResult<T>.done();
      final value = arr[i % arr.length];
      i++;
      return IterResult.value(value);
    });
  });
}

/// Yields all values of [iterable], then [a].
///
/// Port of FxTS `append`.
Iterable<A> append<A>(A a, Iterable<A> iterable) sync* {
  yield* iterable;
  yield a;
}

/// Async counterpart of [append]. [a] may be a [Future].
FxAsyncIterable<A> appendAsync<A>(FutureOr<A> a, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var finished = false;
    return SerialAsyncIterator((concurrent) async {
      if (finished) return IterResult<A>.done();
      final result = await iterator.next(concurrent);
      if (result.done) {
        finished = true;
        return IterResult.value(await a);
      }
      return result;
    });
  });
}

/// Yields [a], then all values of [iterable].
///
/// Port of FxTS `prepend`.
Iterable<A> prepend<A>(A a, Iterable<A> iterable) sync* {
  yield a;
  yield* iterable;
}

/// Async counterpart of [prepend]. [a] may be a [Future].
FxAsyncIterable<A> prependAsync<A>(FutureOr<A> a, FxAsyncIterable<A> iterable) {
  return DelegateAsyncIterable(() {
    final iterator = iterable.iterator;
    var isFirstItem = true;
    return DelegateAsyncIterator((concurrent) async {
      if (isFirstItem) {
        isFirstItem = false;
        return IterResult.value(await a);
      }
      return iterator.next(concurrent);
    });
  });
}

/// Concatenates two iterables lazily.
///
/// Port of FxTS `concat`.
Iterable<A> concat<A>(Iterable<A> iterable1, Iterable<A> iterable2) sync* {
  yield* iterable1;
  yield* iterable2;
}

/// Async counterpart of [concat].
FxAsyncIterable<A> concatAsync<A>(
    FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) {
  return DelegateAsyncIterable(() {
    final left = iterable1.iterator;
    final right = iterable2.iterator;
    var leftDone = false;
    // Pass-through (not serialized): overlapping pulls must stay parallel so
    // `concurrent` propagates upstream, as in FxTS `concat`.
    return DelegateAsyncIterator((concurrent) async {
      if (!leftDone) {
        final result = await left.next(concurrent);
        if (!result.done) return result;
        leftDone = true;
      }
      return right.next(concurrent);
    });
  });
}

/// Returns the source in reverse order (materializes the source).
///
/// Port of FxTS `reverse`.
Iterable<A> reverse<A>(Iterable<A> iterable) sync* {
  final arr = iterable.toList(growable: false);
  for (var i = arr.length - 1; i >= 0; i--) {
    yield arr[i];
  }
}

/// Async counterpart of [reverse].
FxAsyncIterable<A> reverseAsync<A>(FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    Iterator<A>? reversed;
    return SerialAsyncIterator((concurrent) async {
      if (reversed == null) {
        final arr = <A>[];
        while (true) {
          final r = await iterator.next(concurrent);
          if (r.done) break;
          arr.add(r.value);
        }
        reversed = arr.reversed.iterator;
      }
      if (reversed!.moveNext()) return IterResult.value(reversed!.current);
      return IterResult<A>.done();
    });
  });
}

// --- fork -----------------------------------------------------------------

class _ForkState<T> {
  final Iterator<T> source;
  final buffer = <T>[];
  bool done = false;
  Object? error;
  StackTrace? stackTrace;

  _ForkState(this.source);
}

final Expando<_ForkState<Object?>> _forkStates = Expando('fxdart fork state');

/// Branches a *single* iteration of [iterable] into an independent cursor:
/// every `fork` of the same iterable object shares one underlying iterator
/// and buffer, so the source is walked only once no matter how many forks
/// read from it.
///
/// Port of FxTS `fork`.
Iterable<T> fork<T>(Iterable<T> iterable) sync* {
  var state = _forkStates[iterable] as _ForkState<T>?;
  if (state == null) {
    state = _ForkState<T>(iterable.iterator);
    _forkStates[iterable] = state;
  }
  var i = 0;
  while (true) {
    if (i < state.buffer.length) {
      yield state.buffer[i++];
      continue;
    }
    if (state.error != null) {
      Error.throwWithStackTrace(
          state.error!, state.stackTrace ?? StackTrace.current);
    }
    if (state.done) return;
    final bool moved;
    try {
      moved = state.source.moveNext();
    } catch (e, st) {
      state.error = e;
      state.stackTrace = st;
      rethrow;
    }
    if (!moved) {
      state.done = true;
      return;
    }
    state.buffer.add(state.source.current);
  }
}

class _ForkAsyncState<T> {
  final FxAsyncIterator<T> source;
  final buffer = <T>[];
  bool done = false;
  Object? error;
  StackTrace? stackTrace;
  int pullsInFlight = 0;
  final listeners = <void Function()>[];

  _ForkAsyncState(this.source);

  void _notify() {
    for (final listener in List.of(listeners)) {
      listener();
    }
  }

  /// Issues one parallel pull on the shared source; results land in the
  /// shared buffer in source order (protocol invariant).
  void pull(Concurrent? concurrent) {
    pullsInFlight++;
    source.next(concurrent).then((result) {
      pullsInFlight--;
      if (result.done) {
        done = true;
      } else {
        buffer.add(result.value);
      }
      _notify();
    }, onError: (Object e, StackTrace st) {
      pullsInFlight--;
      error = e;
      stackTrace = st;
      done = true;
      _notify();
    });
  }
}

final Expando<_ForkAsyncState<Object?>> _forkAsyncStates =
    Expando('fxdart async fork state');

/// Async counterpart of [fork]. All forks of the same [FxAsyncIterable]
/// object share one underlying iterator and buffer.
FxAsyncIterable<T> forkAsync<T>(FxAsyncIterable<T> iterable) {
  var state = _forkAsyncStates[iterable] as _ForkAsyncState<T>?;
  if (state == null) {
    state = _ForkAsyncState<T>(iterable.iterator);
    _forkAsyncStates[iterable] = state;
  }
  final s = state;
  return DelegateAsyncIterable(() {
    var i = 0;
    final settlementQueue = <Completer<IterResult<T>>>[];

    void serve() {
      while (settlementQueue.isNotEmpty && i < s.buffer.length) {
        settlementQueue.removeAt(0).complete(IterResult.value(s.buffer[i++]));
      }
      if (s.done && i >= s.buffer.length) {
        while (settlementQueue.isNotEmpty) {
          final completer = settlementQueue.removeAt(0);
          if (s.error != null) {
            completer.completeError(
                s.error!, s.stackTrace ?? StackTrace.current);
          } else {
            completer.complete(IterResult<T>.done());
          }
        }
      }
    }

    void Function()? listener;

    return DelegateAsyncIterator((concurrent) {
      if (i < s.buffer.length) {
        return Future.value(IterResult.value(s.buffer[i++]));
      }
      if (s.done && i >= s.buffer.length) {
        if (s.error != null) {
          return Future.error(s.error!, s.stackTrace);
        }
        return Future.value(IterResult<T>.done());
      }
      if (listener == null) {
        listener = () {
          serve();
          // Re-pull while this fork still has unserved demand.
          while (!s.done &&
              settlementQueue.length >
                  (s.buffer.length - i) + s.pullsInFlight) {
            s.pull(concurrent);
          }
        };
        s.listeners.add(listener!);
      }
      final completer = Completer<IterResult<T>>();
      settlementQueue.add(completer);
      // Issue parallel pulls to cover unmet demand — this is what lets a
      // downstream `concurrent(n)` evaluate the shared source n-wide.
      while (!s.done &&
          settlementQueue.length > (s.buffer.length - i) + s.pullsInFlight) {
        s.pull(concurrent);
      }
      return completer.future;
    });
  });
}

// --- map/object iteration -------------------------------------------------

/// Yields the `(key, value)` pairs of [map] as records.
///
/// Port of FxTS `entries` (TS objects/Maps become Dart Maps).
Iterable<(K, V)> entries<K, V>(Map<K, V> map) sync* {
  for (final e in map.entries) {
    yield (e.key, e.value);
  }
}

/// Yields the keys of [map].
///
/// Port of FxTS `keys`.
Iterable<K> keys<K, V>(Map<K, V> map) => map.keys;

/// Yields the values of [map].
///
/// Port of FxTS `values`.
Iterable<V> values<K, V>(Map<K, V> map) => map.values;
