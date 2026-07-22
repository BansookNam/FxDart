/// Dart-idiomatic aliases for the FxTS-named operators.
///
/// fxdart is a port of FxTS, so the primary names follow FxTS. Where Dart's own
/// `Iterable`/collection libraries have an established name for the same
/// operation, that name is provided here as a first-class alias — both spellings
/// are supported, and the FxDart 101 course teaches the Dart-idiomatic one.
///
/// (The lone exception is `toArray`, which was *removed* in favour of `toList`
/// rather than aliased — it claimed a type Dart doesn't have.)
library;

import 'dart:async';

import 'async_iterable.dart';
import 'lazy/filter.dart';
import 'lazy/map.dart';
import 'lazy/take_drop.dart';
import 'lazy/zip.dart';
import 'strict/access.dart';
import 'strict/aggregate.dart';

// --- lazy/filter.dart ---
Iterable<A> where<A>(bool Function(A a) f, Iterable<A> iterable) =>
    filter(f, iterable);
FxAsyncIterable<A> whereAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    filterAsync(f, iterable);

Iterable<A> whereNot<A>(bool Function(A a) f, Iterable<A> iterable) =>
    reject(f, iterable);
FxAsyncIterable<A> whereNotAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    rejectAsync(f, iterable);

Iterable<A> nonNulls<A>(Iterable<A?> iterable) => compact(iterable);
FxAsyncIterable<A> nonNullsAsync<A>(FxAsyncIterable<A?> iterable) =>
    compactAsync(iterable);

Iterable<A> distinct<A>(Iterable<A> iterable) => uniq(iterable);
FxAsyncIterable<A> distinctAsync<A>(FxAsyncIterable<A> iterable) =>
    uniqAsync(iterable);

Iterable<A> distinctBy<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    uniqBy(f, iterable);
FxAsyncIterable<A> distinctByAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    uniqByAsync(f, iterable);

// --- lazy/map.dart ---
Iterable<B> expand<A, B>(Iterable<B> Function(A a) f, Iterable<A> iterable) =>
    flatMap(f, iterable);
FxAsyncIterable<B> expandAsync<A, B>(
        FutureOr<Iterable<B>> Function(A a) f, FxAsyncIterable<A> iterable) =>
    flatMapAsync(f, iterable);

Iterable<dynamic> flattened(Iterable<dynamic> iterable, [int depth = 1]) =>
    flat(iterable, depth);
FxAsyncIterable<dynamic> flattenedAsync(FxAsyncIterable<dynamic> iterable,
        [int depth = 1]) =>
    flatAsync(iterable, depth);

// --- lazy/take_drop.dart ---
Iterable<A> takeLast<A>(int length, Iterable<A> iterable) =>
    takeRight(length, iterable);
FxAsyncIterable<A> takeLastAsync<A>(int length, FxAsyncIterable<A> iterable) =>
    takeRightAsync(length, iterable);

Iterable<A> skip<A>(int length, Iterable<A> iterable) => drop(length, iterable);
FxAsyncIterable<A> skipAsync<A>(int length, FxAsyncIterable<A> iterable) =>
    dropAsync(length, iterable);

Iterable<A> skipWhile<A>(bool Function(A a) f, Iterable<A> iterable) =>
    dropWhile(f, iterable);
FxAsyncIterable<A> skipWhileAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    dropWhileAsync(f, iterable);

// --- lazy/zip.dart ---
Iterable<(int, A)> indexed<A>(Iterable<A> iterable) => zipWithIndex(iterable);
FxAsyncIterable<(int, A)> indexedAsync<A>(FxAsyncIterable<A> iterable) =>
    zipWithIndexAsync(iterable);

// --- strict/access.dart ---
A? firstOrNull<A>(Iterable<A> iterable) => head(iterable);
Future<A?> firstOrNullAsync<A>(FxAsyncIterable<A> iterable) =>
    headAsync(iterable);

A? lastOrNull<A>(Iterable<A> iterable) => last(iterable);
Future<A?> lastOrNullAsync<A>(FxAsyncIterable<A> iterable) => lastAsync(iterable);

A? elementAtOrNull<A>(int index, Iterable<A> iterable) => nth(index, iterable);
Future<A?> elementAtOrNullAsync<A>(int index, FxAsyncIterable<A> iterable) =>
    nthAsync(index, iterable);

A? firstWhereOrNull<A>(bool Function(A a) f, Iterable<A> iterable) =>
    find(f, iterable);
Future<A?> firstWhereOrNullAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    findAsync(f, iterable);

int indexWhere<A>(bool Function(A a) f, Iterable<A> iterable) =>
    findIndex(f, iterable);
Future<int> indexWhereAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    findIndexAsync(f, iterable);

// Note: no top-level `contains` alias — it collides with `package:test`'s
// matcher, and Dart's idiom is the inherited `.contains()` on the chain anyway.
// The FxTS-named top-level `includes` remains.

bool any<A>(bool Function(A a) f, Iterable<A> iterable) => some(f, iterable);
Future<bool> anyAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    someAsync(f, iterable);

// --- strict/aggregate.dart ---
void forEach<A>(void Function(A a) f, Iterable<A> iterable) =>
    each(f, iterable);
Future<void> forEachAsync<A>(
        FutureOr<void> Function(A a) f, FxAsyncIterable<A> iterable) =>
    eachAsync(f, iterable);

int count<A>(Iterable<A> iterable) => size(iterable);
Future<int> countAsync<A>(FxAsyncIterable<A> iterable) => sizeAsync(iterable);

List<A> sorted<A>(int Function(A a, A b) f, Iterable<A> iterable) =>
    toSorted(f, iterable);
