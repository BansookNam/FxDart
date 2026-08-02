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
Iterable<int> range(int start, [int? end, int step = 1]) =>
    end == null ? _RangeIterable(0, start, 1) : _RangeIterable(start, end, step);

class _RangeIterable extends Iterable<int> {
  _RangeIterable(this._start, this._end, this._step);
  final int _start;
  final int _end;
  final int _step;
  @override
  Iterator<int> get iterator => _RangeIterator(_start, _end, _step);
}

class _RangeIterator implements Iterator<int> {
  _RangeIterator(this._next, this._end, this._step);
  int _next;
  final int _end;
  final int _step;
  @override
  var current = 0;
  @override
  bool moveNext() {
    if (_step < 0 ? _next <= _end : _next >= _end) return false;
    current = _next;
    _next += _step;
    return true;
  }
}

/// Yields [value] [n] times.
///
/// Port of FxTS `repeat`.
Iterable<T> repeat<T>(int n, T value) => _RepeatIterable(n, value);

class _RepeatIterable<T> extends Iterable<T> {
  _RepeatIterable(this._n, this._value);
  final int _n;
  final T _value;
  @override
  Iterator<T> get iterator => _RepeatIterator(_n, _value);
}

class _RepeatIterator<T> implements Iterator<T> {
  _RepeatIterator(this._remaining, this._value);
  int _remaining;
  final T _value;
  @override
  late T current;
  @override
  bool moveNext() {
    if (_remaining < 1) return false;
    _remaining--;
    current = _value;
    return true;
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
Iterable<A> append<A>(A a, Iterable<A> iterable) =>
    concat(iterable, _SingleIterable(a));

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
Iterable<A> prepend<A>(A a, Iterable<A> iterable) =>
    concat(_SingleIterable(a), iterable);

class _SingleIterable<A> extends Iterable<A> {
  _SingleIterable(this._value);
  final A _value;
  @override
  Iterator<A> get iterator => _RepeatIterator(1, _value);
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
Iterable<A> concat<A>(Iterable<A> iterable1, Iterable<A> iterable2) =>
    _ConcatIterable(iterable1, iterable2);

class _ConcatIterable<A> extends Iterable<A> {
  _ConcatIterable(this._source1, this._source2);
  final Iterable<A> _source1;
  final Iterable<A> _source2;
  @override
  Iterator<A> get iterator => _ConcatIterator(_source1.iterator, _source2);
}

class _ConcatIterator<A> implements Iterator<A> {
  _ConcatIterator(this._it, this._second);
  Iterator<A> _it;
  // The second source's iterator is created only when the first is exhausted,
  // matching the generator form's effect order.
  Iterable<A>? _second;
  @override
  late A current;
  @override
  bool moveNext() {
    while (!_it.moveNext()) {
      final second = _second;
      if (second == null) return false;
      _second = null;
      _it = second.iterator;
    }
    current = _it.current;
    return true;
  }
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

/// Yields [iterable] unchanged, or the result of [fallback] when it turns
/// out to be empty. [fallback] is only invoked in the empty case.
///
/// fxdart extension (not part of FxTS), after Rx's `switchIfEmpty`.
///
/// ```dart
/// ifEmpty(() => [0], [1, 2]); // (1, 2)
/// ifEmpty(() => [0], <int>[]); // (0)
/// ```
Iterable<A> ifEmpty<A>(
        Iterable<A> Function() fallback, Iterable<A> iterable) =>
    _IfEmptyIterable(fallback, iterable);

class _IfEmptyIterable<A> extends Iterable<A> {
  _IfEmptyIterable(this._fallback, this._source);
  final Iterable<A> Function() _fallback;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _IfEmptyIterator(_fallback, _source.iterator);
}

class _IfEmptyIterator<A> implements Iterator<A> {
  _IfEmptyIterator(this._fallback, this._it);
  final Iterable<A> Function() _fallback;
  final Iterator<A> _it;
  late Iterator<A> _active;
  bool _started = false;
  @override
  A get current => _active.current;
  @override
  bool moveNext() {
    if (!_started) {
      _started = true;
      _active = _it;
      if (_it.moveNext()) return true;
      // Source turned out empty: switch to the fallback for good.
      _active = _fallback().iterator;
    }
    return _active.moveNext();
  }
}

/// Yields [iterable] unchanged, or the single [value] when it turns out to
/// be empty.
///
/// fxdart extension (not part of FxTS), after Rx's `defaultIfEmpty`.
///
/// ```dart
/// defaultIfEmpty(0, <int>[]); // (0)
/// ```
Iterable<A> defaultIfEmpty<A>(A value, Iterable<A> iterable) =>
    ifEmpty(() => [value], iterable);

/// Async counterpart of [ifEmpty].
FxAsyncIterable<A> ifEmptyAsync<A>(
    FxAsyncIterable<A> Function() fallback, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var first = true;
    FxAsyncIterator<A>? fb;
    return SerialAsyncIterator((concurrent) async {
      if (fb != null) return fb!.next(concurrent);
      final result = await iterator.next(concurrent);
      if (first) {
        first = false;
        if (result.done) {
          fb = fallback().iterator;
          return fb!.next(concurrent);
        }
      }
      return result;
    });
  });
}

/// Async counterpart of [defaultIfEmpty].
FxAsyncIterable<A> defaultIfEmptyAsync<A>(
        FutureOr<A> value, FxAsyncIterable<A> iterable) =>
    ifEmptyAsync(() => toAsync([value]), iterable);

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

    // Issues parallel pulls to cover this fork's unmet demand — what lets a
    // downstream `concurrent(n)` evaluate the shared source n-wide. Buffered
    // items still ahead of `i` plus the pulls already in flight each settle
    // one queued completer, so only the shortfall is pulled.
    void pullToMeetDemand(Concurrent? concurrent) {
      while (!s.done &&
          settlementQueue.length > (s.buffer.length - i) + s.pullsInFlight) {
        s.pull(concurrent);
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
          // Demand is already covered when the pulls below are issued, so
          // this is a safety net for a shortfall appearing as pulls settle.
          pullToMeetDemand(concurrent);
        };
        s.listeners.add(listener!);
      }
      final completer = Completer<IterResult<T>>();
      settlementQueue.add(completer);
      pullToMeetDemand(concurrent);
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
