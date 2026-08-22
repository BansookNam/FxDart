import 'dart:async';

import '../async_iterable.dart';
import '../lazy/filter.dart' show filterAsync;
import '../lazy/zip.dart' show zipWithIndexAsync;

/// Returns the first element, or `null` when empty.
///
/// Port of FxTS `head` (TS `undefined` becomes Dart `null`).
A? head<A>(Iterable<A> iterable) {
  final iterator = iterable.iterator;
  return iterator.moveNext() ? iterator.current : null;
}

/// Async counterpart of [head].
@pragma('vm:prefer-inline')
Future<A?> headAsync<A>(FxAsyncIterable<A> iterable) {
  // Not `async`: the function frame and its suspension cost a microtask per
  // call, and `head` is called once per pipeline — which, in a loop that
  // builds one short chain per work item, is once per item. Terminals own
  // their iterator and consume serially, so the internal fast-pull path
  // applies (see [toListAsync]).
  final it = iterable.iterator;
  final r = it is FxFastIterator<A> ? it.nextOr() : it.next();
  if (r is Future<IterResult<A>>) {
    return r.then((rr) => rr.done ? null : rr.value);
  }
  return Future<A?>.value(r.done ? null : r.value);
}

/// Returns the last element, or `null` when empty.
///
/// Port of FxTS `last`. O(1) for a [List].
@pragma('vm:prefer-inline')
A? last<A>(Iterable<A> iterable) {
  if (iterable is List<A>) {
    final length = iterable.length;
    return length == 0 ? null : iterable[length - 1];
  }
  A? result;
  for (final a in iterable) {
    result = a;
  }
  return result;
}

/// Async counterpart of [last].
Future<A?> lastAsync<A>(FxAsyncIterable<A> iterable) async {
  final iterator = iterable.iterator;
  A? result;
  while (true) {
    final r = await iterator.next();
    if (r.done) return result;
    result = r.value;
  }
}

/// Returns the element at [index], or `null` when out of range.
///
/// Port of FxTS `nth`. O(1) for a [List].
@pragma('vm:prefer-inline')
A? nth<A>(int index, Iterable<A> iterable) {
  if (index < 0) return null;
  if (iterable is List<A>) {
    return index < iterable.length ? iterable[index] : null;
  }
  var i = 0;
  for (final a in iterable) {
    if (i++ == index) return a;
  }
  return null;
}

/// Async counterpart of [nth].
Future<A?> nthAsync<A>(int index, FxAsyncIterable<A> iterable) async {
  if (index < 0) return null;
  final iterator = iterable.iterator;
  var i = 0;
  while (true) {
    final r = await iterator.next();
    if (r.done) return null;
    if (i++ == index) return r.value;
  }
}

/// Returns the first element [f] returns true for, or `null`.
///
/// Port of FxTS `find`. A direct loop, not `head(filter(...))` — the filter
/// layer would cost an iterator allocation plus two indirect calls per
/// element; lists iterate by index.
@pragma('vm:prefer-inline')
A? find<A>(bool Function(A a) f, Iterable<A> iterable) {
  if (iterable is List<A>) {
    final length = iterable.length;
    for (var i = 0; i < length; i++) {
      final a = iterable[i];
      if (f(a)) return a;
    }
    return null;
  }
  for (final a in iterable) {
    if (f(a)) return a;
  }
  return null;
}

/// Async counterpart of [find].
Future<A?> findAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => headAsync(filterAsync(f, iterable));

/// Returns the index of the first element [f] returns true for, or `-1`.
///
/// Port of FxTS `findIndex`. A counted direct loop, not `zipWithIndex` —
/// the zip layer would allocate an `(int, A)` record per element.
@pragma('vm:prefer-inline')
int findIndex<A>(bool Function(A a) f, Iterable<A> iterable) {
  if (iterable is List<A>) {
    final length = iterable.length;
    for (var i = 0; i < length; i++) {
      if (f(iterable[i])) return i;
    }
    return -1;
  }
  var i = 0;
  for (final a in iterable) {
    if (f(a)) return i;
    i++;
  }
  return -1;
}

/// Async counterpart of [findIndex].
Future<int> findIndexAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) async {
  final result = await findAsync((r) => f(r.$2), zipWithIndexAsync(iterable));
  return result == null ? -1 : result.$1;
}

/// Returns true when the iterable contains [a] (`==` comparison).
///
/// Port of FxTS `includes`.
bool includes<A>(A a, Iterable<A> iterable) => iterable.contains(a);

/// Async counterpart of [includes].
Future<bool> includesAsync<A>(A a, FxAsyncIterable<A> iterable) =>
    someAsync((A b) => b == a, iterable);

/// Returns true when every element satisfies [f] (true for an empty
/// iterable). Short-circuits.
///
/// Port of FxTS `every`.
@pragma('vm:prefer-inline')
bool every<A>(bool Function(A a) f, Iterable<A> iterable) {
  if (iterable is List<A>) {
    final length = iterable.length;
    for (var i = 0; i < length; i++) {
      if (!f(iterable[i])) return false;
    }
    return true;
  }
  for (final a in iterable) {
    if (!f(a)) return false;
  }
  return true;
}

/// Async counterpart of [every].
Future<bool> everyAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) async {
  final iterator = iterable.iterator;
  while (true) {
    final r = await iterator.next();
    if (r.done) return true;
    if (!await f(r.value)) return false;
  }
}

/// Returns true when at least one element satisfies [f] (false for an empty
/// iterable). Short-circuits.
///
/// Port of FxTS `some`.
@pragma('vm:prefer-inline')
bool some<A>(bool Function(A a) f, Iterable<A> iterable) {
  if (iterable is List<A>) {
    final length = iterable.length;
    for (var i = 0; i < length; i++) {
      if (f(iterable[i])) return true;
    }
    return false;
  }
  for (final a in iterable) {
    if (f(a)) return true;
  }
  return false;
}

/// Async counterpart of [some].
Future<bool> someAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) async {
  final iterator = iterable.iterator;
  while (true) {
    final r = await iterator.next();
    if (r.done) return false;
    if (await f(r.value)) return true;
  }
}

/// Returns true when no element satisfies [f] (true for an empty iterable).
/// Short-circuits on the first match.
///
/// The third quantifier beside [every] and [some]. `!some(f, xs)` says the
/// same thing, but reads as a negated existential rather than a universal,
/// and negation is where quantifier bugs live.
///
/// Dart-native addition (FxTS has only `every`/`some`); Kotlin spells it
/// `none`. Unrelated to `SingletonRaise.none`, which short-circuits a raise
/// scope — that one is a member, so neither name shadows the other.
@pragma('vm:prefer-inline')
bool none<A>(bool Function(A a) f, Iterable<A> iterable) {
  if (iterable is List<A>) {
    final length = iterable.length;
    for (var i = 0; i < length; i++) {
      if (f(iterable[i])) return false;
    }
    return true;
  }
  for (final a in iterable) {
    if (f(a)) return false;
  }
  return true;
}

/// Async counterpart of [none].
Future<bool> noneAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) async {
  final iterator = iterable.iterator;
  while (true) {
    final r = await iterator.next();
    if (r.done) return true;
    if (await f(r.value)) return false;
  }
}

/// Returns the first non-null result of [f], or `null` when [f] returns
/// `null` for every element. Short-circuits.
///
/// [find] returns the *element*, so getting at a projection of the first
/// match costs either a second call to the projection or a manual loop.
/// Here [f] both tests and projects — the `filter_map` shape `mapNotNull`
/// applies lazily, terminated at the first hit.
///
/// Dart-native addition (FxTS has no equivalent); Kotlin spells it
/// `firstNotNullOfOrNull`, nullable like [find]/[nth]. [B] is bound to
/// [Object] so a `null` from [f] unambiguously means *no result for this
/// element*.
///
/// ```dart
/// firstNotNullOf((String s) => int.tryParse(s), ['x', '2', '3']); // 2
/// ```
@pragma('vm:prefer-inline')
B? firstNotNullOf<A, B extends Object>(
  B? Function(A a) f,
  Iterable<A> iterable,
) {
  if (iterable is List<A>) {
    final length = iterable.length;
    for (var i = 0; i < length; i++) {
      final b = f(iterable[i]);
      if (b != null) return b;
    }
    return null;
  }
  for (final a in iterable) {
    final b = f(a);
    if (b != null) return b;
  }
  return null;
}

/// Async counterpart of [firstNotNullOf]. [f] may return a [Future].
Future<B?> firstNotNullOfAsync<A, B extends Object>(
  FutureOr<B?> Function(A a) f,
  FxAsyncIterable<A> iterable,
) async {
  final iterator = iterable.iterator;
  while (true) {
    final r = await iterator.next();
    if (r.done) return null;
    final b = await f(r.value);
    if (b != null) return b;
  }
}

/// Value-based emptiness check: true for `null`, `''`, and empty
/// [Iterable]/[Map]/[Set]; false for everything else (numbers, booleans,
/// functions, arbitrary objects).
///
/// Port of FxTS `isEmpty`.
bool isEmpty(Object? value) {
  if (value == null) return true;
  if (value is String) return value.isEmpty;
  if (value is Iterable) return value.isEmpty;
  if (value is Map) return value.isEmpty;
  return false;
}
