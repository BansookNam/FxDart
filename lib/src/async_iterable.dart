import 'dart:async';

/// The concurrency signal that lazy operators thread *backwards* through the
/// iterator protocol's `next(concurrent)` argument.
///
/// A [Concurrent] instance turns on concurrent evaluation for the upstream
/// chain; `null` means sequential.
///
/// Port of FxTS `Concurrent` (`Lazy/concurrent.ts`).
class Concurrent {
  final int length;

  const Concurrent(this.length);

  static Concurrent of(int length) => Concurrent(length);
}

/// The result of one pull from an [FxAsyncIterator] — a port of the JS
/// `IteratorResult` (`{done, value}`).
class IterResult<T> {
  final bool done;
  final T? _value;

  const IterResult.done()
      : done = true,
        _value = null;

  const IterResult.value(T value)
      : done = false,
        _value = value;

  /// The yielded value. Only valid when [done] is false.
  T get value => _value as T;

  @override
  String toString() => done ? 'IterResult.done()' : 'IterResult($_value)';
}

/// Pull-based async iterator with a concurrency back-channel.
///
/// Dart's `Stream` is push-based and cannot express FxTS's `concurrent(n)`
/// protocol, where a downstream operator asks the upstream chain to evaluate
/// `n` items at once by passing a [Concurrent] marker through `next()`.
/// This protocol is a faithful port of the JS `AsyncIterator` as FxTS uses it.
abstract interface class FxAsyncIterator<T> {
  Future<IterResult<T>> next([Concurrent? concurrent]);
}

/// Pull-based async iterable — the async counterpart of [Iterable].
///
/// Obtain one from [toAsync], [fromStream], or any `*Async` operator.
/// Consume it with `toArrayAsync`, `eachAsync`, `reduceAsync`, the
/// [FxAsync] chain, or convert it to a [Stream] with [toStream].
abstract interface class FxAsyncIterable<T> {
  FxAsyncIterator<T> get iterator;
}

/// Builds an [FxAsyncIterable] from a factory of iterators.
class DelegateAsyncIterable<T> implements FxAsyncIterable<T> {
  final FxAsyncIterator<T> Function() _make;

  const DelegateAsyncIterable(this._make);

  @override
  FxAsyncIterator<T> get iterator => _make();
}

/// Builds an [FxAsyncIterator] from a `next` closure.
class DelegateAsyncIterator<T> implements FxAsyncIterator<T> {
  final Future<IterResult<T>> Function(Concurrent? concurrent) _next;

  const DelegateAsyncIterator(this._next);

  @override
  Future<IterResult<T>> next([Concurrent? concurrent]) => _next(concurrent);
}

/// Serializes overlapping `next()` calls, mimicking the implicit request
/// queueing of JS async generators. Wrap hand-written sequential state
/// machines with this so that a concurrent consumer cannot interleave pulls.
class SerialAsyncIterator<T> implements FxAsyncIterator<T> {
  final Future<IterResult<T>> Function(Concurrent? concurrent) _inner;
  Future<void> _prev = Future.value();

  SerialAsyncIterator(this._inner);

  @override
  Future<IterResult<T>> next([Concurrent? concurrent]) {
    final result = _prev.then((_) => _inner(concurrent));
    _prev = result.then((_) {}, onError: (_) {});
    return result;
  }
}

/// An empty async iterable.
FxAsyncIterable<T> asyncEmpty<T>() => DelegateAsyncIterable(
    () => DelegateAsyncIterator((_) async => IterResult<T>.done()));

/// Returns an [FxAsyncIterable] of the given iterable, where any [Future]
/// element is awaited.
///
/// Port of FxTS `toAsync`. The source iterator is advanced *synchronously*,
/// so `n` overlapping `next()` calls start `n` futures at once — this is
/// what makes `concurrent(n)` physically parallel at the source.
///
/// ```dart
/// await toArrayAsync(mapAsync((a) => a + 10, toAsync([1, 2, 3]))); // [11, 12, 13]
/// ```
FxAsyncIterable<T> toAsync<T>(Iterable<FutureOr<T>> iterable) {
  return DelegateAsyncIterable(() {
    final iterator = iterable.iterator;
    return DelegateAsyncIterator((_) {
      if (!iterator.moveNext()) {
        return Future.value(IterResult<T>.done());
      }
      final current = iterator.current;
      if (current is Future<T>) {
        return current.then(IterResult<T>.value);
      }
      return Future.value(IterResult<T>.value(current));
    });
  });
}

/// Converts a single-subscription or broadcast [Stream] into an
/// [FxAsyncIterable].
FxAsyncIterable<T> fromStream<T>(Stream<T> stream) {
  return DelegateAsyncIterable(() {
    final iterator = StreamIterator(stream);
    // StreamIterator cannot handle overlapping moveNext calls; serialize.
    return SerialAsyncIterator((_) async {
      if (await iterator.moveNext()) {
        return IterResult.value(iterator.current);
      }
      return IterResult<T>.done();
    });
  });
}

extension FxAsyncIterableToStream<T> on FxAsyncIterable<T> {
  /// Drives this async iterable sequentially and emits its values as a
  /// [Stream]. The [Concurrent] back-channel is not used; apply
  /// `concurrentAsync` before converting if you need parallel evaluation.
  Stream<T> toStream() async* {
    final iterator = this.iterator;
    while (true) {
      final result = await iterator.next();
      if (result.done) break;
      yield result.value;
    }
  }
}

/// The settled outcome of a [Future] — port of JS `Promise.allSettled`
/// entries, needed so one rejected pull doesn't fail the whole batch.
sealed class Settled<T> {
  const Settled();
}

class Fulfilled<T> extends Settled<T> {
  final T value;
  const Fulfilled(this.value);
}

class Rejected<T> extends Settled<T> {
  final Object error;
  final StackTrace stackTrace;
  const Rejected(this.error, this.stackTrace);
}

Future<List<Settled<T>>> settleAll<T>(Iterable<Future<T>> futures) {
  return Future.wait(futures.map((f) => f
      .then<Settled<T>>((v) => Fulfilled(v))
      .catchError((Object e, StackTrace st) => Rejected<T>(e, st))));
}

/// Balances the load of multiple asynchronous requests: pulls up to [length]
/// items from [iterable] at once, preserving order.
///
/// Port of FxTS `concurrent` (`Lazy/concurrent.ts`).
///
/// ```dart
/// await eachAsync(
///   print,
///   concurrentAsync(
///     3,
///     mapAsync((a) => delay(Duration(seconds: 1), a), toAsync([1, 2, 3, 4, 5, 6])),
///   ),
/// ); // finishes in ~2 seconds instead of ~6
/// ```
FxAsyncIterable<A> concurrentAsync<A>(int length, FxAsyncIterable<A> iterable) {
  if (length < 1) {
    throw RangeError("'length' must be positive integer");
  }
  return DelegateAsyncIterable(() {
    final iterator = iterable.iterator;
    final buffer = <Settled<IterResult<A>>>[];
    var prev = Future<void>.value();
    var nextCallCount = 0;
    var resolvedItemCount = 0;
    var finished = false;
    var pending = false;
    final settlementQueue = <Completer<IterResult<A>>>[];

    void consumeBuffer() {
      while (buffer.isNotEmpty && nextCallCount > resolvedItemCount) {
        final p = buffer.removeAt(0);
        final completer = settlementQueue.removeAt(0);
        switch (p) {
          case Fulfilled(value: final value):
            resolvedItemCount++;
            completer.complete(value);
            if (value.done) {
              finished = true;
            }
          case Rejected(error: final error, stackTrace: final stackTrace):
            completer.completeError(error, stackTrace);
            finished = true;
            return;
        }
      }
    }

    late void Function() recur;

    void fillBuffer() {
      if (pending) {
        prev = prev.then((_) {
          if (!finished && nextCallCount > resolvedItemCount) {
            fillBuffer();
          }
        });
      } else {
        final nextItems = settleAll(List.generate(
            length, (_) => iterator.next(Concurrent.of(length)),
            growable: false));
        pending = true;
        prev = prev.then((_) => nextItems).then((items) {
          buffer.addAll(items);
          pending = false;
          recur();
        });
      }
    }

    recur = () {
      if (finished || nextCallCount == resolvedItemCount) {
        return;
      } else if (buffer.isNotEmpty) {
        consumeBuffer();
      } else {
        fillBuffer();
      }
    };

    return DelegateAsyncIterator((_) {
      nextCallCount++;
      if (finished) {
        return Future.value(IterResult<A>.done());
      }
      final completer = Completer<IterResult<A>>();
      settlementQueue.add(completer);
      recur();
      return completer.future;
    });
  });
}

/// Like [concurrentAsync] but yields results in **completion order** rather
/// than source order, keeping up to [length] requests in flight.
///
/// Port of FxTS `concurrentPool`.
FxAsyncIterable<A> concurrentPoolAsync<A>(
    int length, FxAsyncIterable<A> iterable) {
  if (length < 1) {
    throw RangeError("'length' must be positive integer");
  }
  return DelegateAsyncIterable(() {
    final iterator = iterable.iterator;
    var inFlight = 0;
    var sourceDone = false;
    var failed = false;
    final ready = <Settled<IterResult<A>>>[];
    final settlementQueue = <Completer<IterResult<A>>>[];

    bool exhausted() => sourceDone && inFlight == 0 && ready.isEmpty;

    void drain() {
      while (ready.isNotEmpty && settlementQueue.isNotEmpty) {
        final item = ready.removeAt(0);
        final completer = settlementQueue.removeAt(0);
        switch (item) {
          case Fulfilled(value: final value):
            completer.complete(value);
          case Rejected(error: final error, stackTrace: final stackTrace):
            completer.completeError(error, stackTrace);
        }
      }
      if (exhausted()) {
        while (settlementQueue.isNotEmpty) {
          settlementQueue.removeAt(0).complete(IterResult<A>.done());
        }
      }
    }

    late void Function() fill;
    fill = () {
      // Eagerly keep the pool full (like FxTS): up to [length] fetches stay
      // in flight regardless of how many consumers are currently waiting, so
      // even a one-pull-at-a-time terminal like toArray overlaps the work.
      while (!sourceDone && !failed && inFlight < length) {
        inFlight++;
        iterator.next(Concurrent.of(length)).then((result) {
          inFlight--;
          if (result.done) {
            sourceDone = true;
          } else {
            ready.add(Fulfilled(result));
          }
          drain();
          fill();
        }, onError: (Object e, StackTrace st) {
          inFlight--;
          failed = true;
          sourceDone = true;
          ready.add(Rejected<IterResult<A>>(e, st));
          drain();
        });
      }
    };

    return DelegateAsyncIterator((_) {
      if (exhausted()) {
        return Future.value(IterResult<A>.done());
      }
      final completer = Completer<IterResult<A>>();
      settlementQueue.add(completer);
      drain();
      fill();
      return completer.future;
    });
  });
}

/// Shared helper implementing the FxTS "sequential wrap" dispatch pattern:
/// an operator whose sequential logic is [build]; when a [Concurrent] marker
/// arrives on the first pull, the upstream is wrapped in [concurrentAsync]
/// so items are still evaluated concurrently upstream while [build] consumes
/// them one at a time.
FxAsyncIterable<B> dispatchAsync<A, B>(
  FxAsyncIterable<A> upstream,
  FxAsyncIterator<B> Function(FxAsyncIterable<A> source) build,
) {
  return DelegateAsyncIterable(() {
    FxAsyncIterator<B>? inner;
    return DelegateAsyncIterator((concurrent) {
      inner ??= build(concurrent is Concurrent
          ? concurrentAsync(concurrent.length, upstream)
          : upstream);
      return inner!.next(concurrent);
    });
  });
}
