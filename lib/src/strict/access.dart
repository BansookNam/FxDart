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
Future<A?> headAsync<A>(FxAsyncIterable<A> iterable) async {
  final r = await iterable.iterator.next();
  return r.done ? null : r.value;
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
bool every<A>(bool Function(A a) f, Iterable<A> iterable) {
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
bool some<A>(bool Function(A a) f, Iterable<A> iterable) {
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
