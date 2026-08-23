import 'dart:async';

import '../async_iterable.dart';

/// True when [a] and [b] hold the same values in the same order.
///
/// Stops at the first mismatch. A length mismatch is not equal. Optional
/// [eq] replaces `==`. After Rx's `sequenceEqual`.
@pragma('vm:prefer-inline')
bool sequenceEqual<T>(Iterable<T> a, Iterable<T> b, [bool Function(T, T)? eq]) {
  final equal = eq ?? (T x, T y) => x == y;
  final ia = a.iterator;
  final ib = b.iterator;
  while (true) {
    final hasA = ia.moveNext();
    final hasB = ib.moveNext();
    if (!hasA && !hasB) return true;
    if (!hasA || !hasB) return false;
    if (!equal(ia.current, ib.current)) return false;
  }
}

/// Async counterpart of [sequenceEqual]. Pulls both sides in parallel per
/// step; an error from either iterator fails the future.
Future<bool> sequenceEqualAsync<T>(
  FxAsyncIterable<T> a,
  FxAsyncIterable<T> b, [
  bool Function(T, T)? eq,
]) async {
  final equal = eq ?? (T x, T y) => x == y;
  final ia = a.iterator;
  final ib = b.iterator;
  while (true) {
    final fa = ia.next();
    final fb = ib.next();
    final ra = await fa;
    final rb = await fb;
    if (ra.done && rb.done) return true;
    if (ra.done || rb.done) return false;
    if (!equal(ra.value, rb.value)) return false;
  }
}
