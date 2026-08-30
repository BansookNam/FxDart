import 'dart:async';

import '../async_iterable.dart';
import '../typed/raise.dart';
import 'map.dart';

/// Runs [f], retrying on error until it succeeds or [attempts] runs are
/// exhausted, then rethrows the last error. Between a failure and the next
/// run, waits [delay] (called with the number of failures so far, starting
/// at 1 — return a growing [Duration] for backoff).
///
/// fxdart extension (not part of FxTS), after Rx's `retry`/`retryWhen`.
/// To retry a whole pipeline, wrap its terminal:
/// `retry(3, () => fxAsync(source()).map(parse).toList())`.
///
/// ```dart
/// final user = await retry(3, () => api.fetchUser(id),
///     delay: (failed) => Duration(milliseconds: 100 * failed));
/// ```
Future<T> retry<T>(
  int attempts,
  FutureOr<T> Function() f, {
  Duration Function(int failed)? delay,
}) async {
  _checkAttempts(attempts);
  for (var attempt = 1; ; attempt++) {
    try {
      return await f();
    } catch (_) {
      if (attempt >= attempts) rethrow;
      final wait = delay?.call(attempt);
      if (wait != null && wait > Duration.zero) {
        await Future<void>.delayed(wait);
      }
    }
  }
}

void _checkAttempts(int attempts) {
  if (attempts < 1) {
    throw ArgumentError.value(attempts, 'attempts', 'must be at least 1');
  }
}

/// Lazily maps each value with [f], retrying each call up to [attempts]
/// times (see [retry]) before letting the error propagate. Parallel-safe:
/// composes with `concurrent`, and each in-flight value retries
/// independently.
///
/// fxdart extension (not part of FxTS) — the per-element form of [retry].
///
/// ```dart
/// await fxAsync(toAsync(urls))
///     .mapRetry(3, fetch, delay: (failed) => Duration(seconds: failed))
///     .concurrent(5)
///     .toList();
/// ```
@pragma('vm:prefer-inline')
FxAsyncIterable<R> mapRetryAsync<A, R>(
  int attempts,
  FutureOr<R> Function(A a) f,
  FxAsyncIterable<A> iterable, {
  Duration Function(int failed)? delay,
}) {
  _checkAttempts(attempts);
  return mapAsync((A a) => retry(attempts, () => f(a), delay: delay), iterable);
}

/// Lazily maps each value with [f], handing any error [f] throws to
/// [onError] and yielding what that returns in its place. One element's
/// failure never ends the iteration.
///
/// The library's own raise signal is **rethrown, not recovered**: this
/// delegates to [catching], so a `r.raise(...)` crossing [f] — from a
/// `bind`, an `ensure`, or a nested builder — still short-circuits the
/// enclosing `either {}` / `nullable {}` block. Recovering it here would
/// turn a typed error into a lost one, and leak a raise out of its scope.
///
/// fxdart extension (not part of FxTS) — the per-element form of [catching],
/// the pair [retry]/[mapRetryAsync] already establishes. RxDart writes this
/// as `onErrorReturnWith` in the same position.
///
/// ```dart
/// fx(ids).mapCatching(parse, (e, _) => Reading.invalid(e)).toList();
/// ```
Iterable<R> mapCatching<A, R>(
  R Function(A a) f,
  R Function(Object error, StackTrace stackTrace) onError,
  Iterable<A> iterable,
) => map((A a) => catching(() => f(a), onError), iterable);

/// Async counterpart of [mapCatching]; [f] and [onError] may each return a
/// [Future], and the raise signal is rethrown by [catchingAsync] for the
/// same reason.
@pragma('vm:prefer-inline')
FxAsyncIterable<R> mapCatchingAsync<A, R>(
  FutureOr<R> Function(A a) f,
  FutureOr<R> Function(Object error, StackTrace stackTrace) onError,
  FxAsyncIterable<A> iterable,
) => mapAsync((A a) => catchingAsync(() => f(a), onError), iterable);

/// Fails a pull with a [TimeoutException] when the upstream takes longer
/// than [limit] to produce it. The limit applies to each pull (the time to
/// produce one item), not to inter-item gaps or the whole pipeline.
/// Parallel-safe: overlapping pulls each get their own timer.
///
/// fxdart extension (not part of FxTS), after Rx's `timeout` — but
/// measuring demand-to-item time, the pull-model analog.
///
/// ```dart
/// await fxAsync(toAsync(urls))
///     .map(fetch)
///     .timeout(Duration(seconds: 2))
///     .toList(); // throws TimeoutException if any fetch stalls
/// ```
@pragma('vm:prefer-inline')
FxAsyncIterable<A> timeoutAsync<A>(
  Duration limit,
  FxAsyncIterable<A> iterable,
) {
  return DelegateAsyncIterable(
    () => _TimeoutAsyncIterator(limit, iterable.iterator),
  );
}

class _TimeoutAsyncIterator<A> implements FxFastIterator<A>, StreamPullCancel {
  _TimeoutAsyncIterator(this._limit, this._inner);
  final Duration _limit;
  final FxAsyncIterator<A> _inner;

  @override
  Future<void> cancel() {
    fxCancel(_inner);
    return Future<void>.value();
  }

  @override
  Future<IterResult<A>> next([Concurrent? concurrent]) =>
      _inner.next(concurrent).timeout(_limit);

  @override
  FutureOr<IterResult<A>> nextOr() {
    final inner = _inner;
    if (inner is! FxFastIterator<A>) return inner.next().timeout(_limit);
    final r = inner.nextOr();
    // A synchronously answered pull cannot have stalled — no timer needed.
    if (r is Future<IterResult<A>>) return r.timeout(_limit);
    return r;
  }
}

/// Scopes a resource to one lazy iteration: [acquire] runs on the first
/// pull, [use] builds the elements from the resource, and [release] runs
/// exactly once when iteration completes or throws.
///
/// fxdart extension (not part of FxTS), after Rx's `using`.
///
/// **Abandonment caveat:** a consumer that stops pulling mid-iteration
/// (e.g. `break` inside `for-in`) never reaches the end, so [release] does
/// not run. Drive the iterable to completion — bound it with `take` instead
/// of breaking — or manage the resource with `try`/`finally` yourself.
///
/// ```dart
/// final lines = using(
///   () => File('data.txt').openSync(),
///   (file) => readLines(file),
///   (file) => file.closeSync(),
/// );
/// ```
Iterable<T> using<R, T>(
  R Function() acquire,
  Iterable<T> Function(R resource) use,
  void Function(R resource) release,
) => _UsingIterable(acquire, use, release);

class _UsingIterable<R, T> extends Iterable<T> {
  _UsingIterable(this._acquire, this._use, this._release);
  final R Function() _acquire;
  final Iterable<T> Function(R) _use;
  final void Function(R) _release;
  @override
  Iterator<T> get iterator => _UsingIterator(_acquire, _use, _release);
}

class _UsingIterator<R, T> implements Iterator<T> {
  _UsingIterator(this._acquire, this._use, this._release);
  final R Function() _acquire;
  final Iterable<T> Function(R) _use;
  final void Function(R) _release;
  Iterator<T>? _inner;
  late R _resource;
  bool _done = false;
  @override
  T get current => _inner!.current;
  @override
  bool moveNext() {
    if (_done) return false;
    var inner = _inner;
    if (inner == null) {
      // [_acquire] runs on the first pull; a failing acquire has no resource
      // to release (same as the generator form, where acquire sat outside
      // the try/finally).
      _resource = _acquire();
      try {
        inner = _inner = _use(_resource).iterator;
      } catch (_) {
        _done = true;
        _release(_resource);
        rethrow;
      }
    }
    bool moved;
    try {
      moved = inner.moveNext();
    } catch (_) {
      _done = true;
      _release(_resource);
      rethrow;
    }
    if (!moved) {
      _done = true;
      _release(_resource);
    }
    return moved;
  }
}

/// Async counterpart of [using]: [acquire] and [release] may be
/// asynchronous, and the elements come from an [FxAsyncIterable].
/// [release] runs exactly once — after the terminal pull, or before the
/// error propagates when a pull fails (including a failing [use]).
/// The same abandonment caveat as [using] applies.
@pragma('vm:prefer-inline')
FxAsyncIterable<T> usingAsync<R, T>(
  FutureOr<R> Function() acquire,
  FxAsyncIterable<T> Function(R resource) use,
  FutureOr<void> Function(R resource) release,
) {
  return DelegateAsyncIterable(
    () => _UsingAsyncIterator(acquire, use, release),
  );
}

/// The [usingAsync] iterator. Public `next` stays a pass-through (as
/// before); the fast-pull path serves synchronously answered inner pulls
/// without futures, releasing exactly once on completion or error.
class _UsingAsyncIterator<R, T> implements FxFastIterator<T>, StreamPullCancel {
  _UsingAsyncIterator(this._acquire, this._use, this._release);
  final FutureOr<R> Function() _acquire;
  final FxAsyncIterable<T> Function(R resource) _use;
  final FutureOr<void> Function(R resource) _release;
  late R _resource;
  var _acquired = false;
  var _done = false;
  FxAsyncIterator<T>? _iterator; // cached once [_started] resolves
  Future<FxAsyncIterator<T>>? _started;
  Future<void>? _releasing;

  /// An early stop releases the resource *and* the inner chain — the point
  /// of `using` is that release happens on every exit, a cancelled consumer
  /// included.
  @override
  Future<void> cancel() {
    _done = true;
    fxCancel(_iterator);
    if (!_acquired) return Future<void>.value();
    return _releaseOnce();
  }

  Future<void> _releaseOnce() =>
      _releasing ??= Future.sync(() => _release(_resource));

  Future<FxAsyncIterator<T>> _ensureStarted() =>
      _started ??= Future.sync(_acquire).then((r) {
        _resource = r;
        _acquired = true;
        return _iterator = _use(r).iterator;
      });

  Future<IterResult<T>> _settle(Future<IterResult<T>> pull) => pull.then(
    (result) {
      if (!result.done) return result;
      _done = true;
      return _releaseOnce().then((_) => result);
    },
    onError: (Object e, StackTrace st) {
      _done = true;
      // When acquire itself failed there is no resource to release.
      if (!_acquired) Error.throwWithStackTrace(e, st);
      return _releaseOnce().then<IterResult<T>>(
        (_) => Error.throwWithStackTrace(e, st),
      );
    },
  );

  @override
  Future<IterResult<T>> next([Concurrent? concurrent]) {
    if (_done) return Future.value(IterResult<T>.done());
    final it = _iterator;
    if (it != null) return _settle(it.next(concurrent));
    return _settle(_ensureStarted().then((i) => i.next(concurrent)));
  }

  @override
  FutureOr<IterResult<T>> nextOr() {
    if (_done) return IterResult<T>.done();
    final it = _iterator;
    if (it == null) {
      return _settle(_ensureStarted().then((i) => i.next()));
    }
    if (it is! FxFastIterator<T>) return _settle(it.next());
    final FutureOr<IterResult<T>> r;
    try {
      r = it.nextOr();
    } catch (e, st) {
      _done = true;
      if (!_acquired) rethrow;
      return _releaseOnce().then<IterResult<T>>(
        (_) => Error.throwWithStackTrace(e, st),
      );
    }
    if (r is Future<IterResult<T>>) return _settle(r);
    if (!r.done) return r;
    _done = true;
    return _releaseOnce().then((_) => r);
  }
}
