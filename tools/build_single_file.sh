#!/usr/bin/env bash
# Generates docs/assets/fxdart_single.dart: a single-file build of fxdart for
# use in a web playground (the file is meant to be prepended to user code and
# compiled by the DartPad compile service).
#
# Rerunnable: this script always regenerates the output from scratch.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT/docs/assets"
OUT="$OUT_DIR/fxdart_single.dart"

mkdir -p "$OUT_DIR"

# Files to concatenate, in order. fx.dart is handled separately below because
# it needs a source transform.
FILES=(
  "lib/src/config.dart"
  "lib/src/async_iterable.dart"
  "lib/src/pipe.dart"
  "lib/src/lazy/list_range.dart"
  "lib/src/lazy/map.dart"
  "lib/src/lazy/filter.dart"
  "lib/src/lazy/take_drop.dart"
  "lib/src/lazy/zip.dart"
  "lib/src/lazy/combine.dart"
  "lib/src/lazy/effect.dart"
  "lib/src/lazy/parallel_stub.dart"
  "lib/src/lazy/parallel.dart"
  "lib/src/strict/aggregate.dart"
  "lib/src/strict/access.dart"
  "lib/src/strict/object.dart"
  "lib/src/strict/func.dart"
  "lib/src/strict/curried.dart"
  "lib/src/strict/predicates.dart"
  "lib/src/strict/sequence_equal.dart"
  "lib/src/dart_aliases.dart"
  "lib/src/util/timing.dart"
  "lib/src/util/shuffle.dart"
  "lib/src/typed/non_empty_list.dart"
  "lib/src/typed/raise.dart"
  "lib/src/typed/accumulate.dart"
  "lib/src/typed/fx_either.dart"
  "lib/src/stream/events.dart"
  "lib/src/stream/events_chain.dart"
  "lib/src/stream/events_combine.dart"
  "lib/src/stream/events_either.dart"
  "lib/src/stream/events_notify.dart"
  "lib/src/stream/events_pull.dart"
  "lib/src/stream/events_scan.dart"
  "lib/src/stream/events_select.dart"
  "lib/src/stream/events_window.dart"
  "lib/src/stream/connectable.dart"
  "lib/src/stream/values.dart"
  "lib/src/stream/subscriptions.dart"
)

# Strips lines that start with `import `, `export `, or the exact `library;`
# directive.
strip_directives() {
  grep -vE '^(import |export )' "$1" | grep -vE '^library;$'
}

{
  cat <<'HEADER'
// ignore_for_file: deprecated_member_use_from_same_package, unused_element
// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';
HEADER

  for f in "${FILES[@]}"; do
    echo ""
    echo "// ---- $f ----"
    strip_directives "$ROOT/$f"
  done

  # fx.dart is special: it calls top-level functions through import prefixes
  # (l., s., async_.) because its instance methods shadow the top-level names
  # (e.g. inside class Fx, `map` refers to the instance method). Those
  # prefixes don't exist once everything is merged into one file, so rewrite
  # every prefixed reference to a `_$NAME` wrapper defined further below.
  echo ""
  echo "// ---- lib/src/fx.dart (transformed: l./s./async_. -> _\$NAME) ----"
  strip_directives "$ROOT/lib/src/fx.dart" | perl -pe '
    s/(?<![A-Za-z0-9_])l\.([a-zA-Z0-9_]+)/_\$$1/g;
    s/(?<![A-Za-z0-9_])s\.([a-zA-Z0-9_]+)/_\$$1/g;
    s/(?<![A-Za-z0-9_])async_\.([a-zA-Z0-9_]+)/_\$$1/g;
  '

  # either.dart is also special: it imports raise.dart under the `raise_`
  # prefix because inside `class Either` the plain name `catching` would
  # resolve to the static `Either.catching` (self-reference). Types can be
  # de-prefixed directly; the two function references go through `_$typed*`
  # wrappers defined below.
  echo ""
  echo "// ---- lib/src/typed/either.dart (transformed: raise_. -> _\$typed* / plain) ----"
  strip_directives "$ROOT/lib/src/typed/either.dart" | perl -pe '
    s/(?<![A-Za-z0-9_])raise_\.Raise(?![A-Za-z0-9_])/Raise/g;
    s/(?<![A-Za-z0-9_])raise_\.either(?![A-Za-z0-9_])/_\$typedEither/g;
    s/(?<![A-Za-z0-9_])raise_\.catching(?![A-Za-z0-9_])/_\$typedCatching/g;
  '

  # Wrapper section: every `_$NAME` used above, defined as a small top-level
  # delegating function. At top level the plain names resolve to the
  # top-level functions from the concatenated files (not to Fx/FxAsync
  # instance methods, which only shadow them inside the class body), so these
  # wrappers are legal and just forward the call.
  #
  # This list is static. It was generated once by hand from:
  #   grep -oE '(l|s|async_)\.[a-zA-Z0-9_]+' lib/src/fx.dart | sort -u
  # (ignoring the false matches `s.dart` / `s._inner` that come from import
  # lines / `this._inner`), cross-checked against each function's signature
  # in the lib/src source files.
  cat <<'WRAPPERS'

// ---- wrappers for either.dart's raise_. prefixed calls ----

Either<E, A> _$typedEither<E, A>(A Function(Raise<E> r) block) =>
    either(block);
A _$typedCatching<A>(A Function() block,
        A Function(Object error, StackTrace stackTrace) onError) =>
    catching(block, onError);

// ---- wrappers for fx.dart's l./s./async_. prefixed calls ----

// async_iterable.dart
FxAsyncIterable<T> _$toAsync<T>(Iterable<FutureOr<T>> iterable) =>
    toAsync(iterable);

// lazy/map.dart
Iterable<B> _$map<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    map(f, iterable);
FxAsyncIterable<B> _$mapAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    mapAsync(f, iterable);
Iterable<A> _$peek<A>(void Function(A a) f, Iterable<A> iterable) =>
    peek(f, iterable);
FxAsyncIterable<A> _$peekAsync<A>(
        FutureOr<void> Function(A a) f, FxAsyncIterable<A> iterable) =>
    peekAsync(f, iterable);
Iterable<dynamic> _$flat(Iterable<dynamic> iterable, [int depth = 1]) =>
    flat(iterable, depth);
FxAsyncIterable<dynamic> _$flatAsync(FxAsyncIterable<dynamic> iterable,
        [int depth = 1]) =>
    flatAsync(iterable, depth);
Iterable<B> _$flatMap<A, B>(Iterable<B> Function(A a) f, Iterable<A> iterable) =>
    flatMap(f, iterable);
FxAsyncIterable<B> _$flatMapAsync<A, B>(
        FutureOr<Iterable<B>> Function(A a) f, FxAsyncIterable<A> iterable) =>
    flatMapAsync(f, iterable);
Iterable<B> _$mapWithIndex<A, B>(
        B Function(A a, int index) f, Iterable<A> iterable) =>
    mapWithIndex(f, iterable);
FxAsyncIterable<B> _$mapWithIndexAsync<A, B>(
        FutureOr<B> Function(A a, int index) f, FxAsyncIterable<A> iterable) =>
    mapWithIndexAsync(f, iterable);
Iterable<B> _$flatMapWithIndex<A, B>(
        Iterable<B> Function(A a, int index) f, Iterable<A> iterable) =>
    flatMapWithIndex(f, iterable);
FxAsyncIterable<B> _$flatMapWithIndexAsync<A, B>(
        FutureOr<Iterable<B>> Function(A a, int index) f,
        FxAsyncIterable<A> iterable) =>
    flatMapWithIndexAsync(f, iterable);
Iterable<B> _$scan<A, B>(
        B Function(B acc, A a) f, B seed, Iterable<A> iterable) =>
    scan(f, seed, iterable);
FxAsyncIterable<B> _$scanAsync<A, B>(FutureOr<B> Function(B acc, A a) f,
        FutureOr<B> seed, FxAsyncIterable<A> iterable) =>
    scanAsync(f, seed, iterable);
Iterable<B> _$mapAccum<A, B>(
        B Function(B acc, A a) f, B seed, Iterable<A> iterable) =>
    mapAccum(f, seed, iterable);
FxAsyncIterable<B> _$mapAccumAsync<A, B>(FutureOr<B> Function(B acc, A a) f,
        FutureOr<B> seed, FxAsyncIterable<A> iterable) =>
    mapAccumAsync(f, seed, iterable);
FxAsyncIterable<B> _$mapConcurrent<A, B>(
        int concurrency, FutureOr<B> Function(A a) f, Iterable<A> iterable) =>
    mapConcurrent(concurrency, f, iterable);
FxAsyncIterable<B> _$mapConcurrentAsync<A, B>(int concurrency,
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    mapConcurrentAsync(concurrency, f, iterable);
FxAsyncIterable<R> _$parallel<A, R>(int workers,
        FutureOr<R> Function(A input) worker, Iterable<A> iterable,
        {int chunk = 1, bool chunked = false}) =>
    parallel(workers, worker, iterable, chunk: chunk, chunked: chunked);
FxAsyncIterable<R> _$parallelAsync<A, R>(int workers,
        FutureOr<R> Function(A input) worker, FxAsyncIterable<A> iterable,
        {int chunk = 1, bool chunked = false}) =>
    parallelAsync(workers, worker, iterable, chunk: chunk, chunked: chunked);
FxAsyncIterable<R> _$parallelOn<A, R>(IsolatePool pool,
        FutureOr<R> Function(A input) worker, Iterable<A> iterable,
        {int chunk = 1, bool chunked = false}) =>
    parallelOn(pool, worker, iterable, chunk: chunk, chunked: chunked);
FxAsyncIterable<R> _$parallelOnAsync<A, R>(IsolatePool pool,
        FutureOr<R> Function(A input) worker, FxAsyncIterable<A> iterable,
        {int chunk = 1, bool chunked = false}) =>
    parallelOnAsync(pool, worker, iterable, chunk: chunk, chunked: chunked);
R Function(A a) _$fxPipe<A, R>(R Function(A a) f) => fxPipe(f);
R Function(A a) _$fxPipe2<A, M, R>(
        M Function(A a) first, R Function(M m) second) =>
    fxPipe2(first, second);
R Function(A a) _$fxPipe3<A, M1, M2, R>(
        M1 Function(A a) first, M2 Function(M1 m) second,
        R Function(M2 m) third) =>
    fxPipe3(first, second, third);
R Function(A a) _$fxPipe4<A, M1, M2, M3, R>(
        M1 Function(A a) first, M2 Function(M1 m) second,
        M3 Function(M2 m) third, R Function(M3 m) fourth) =>
    fxPipe4(first, second, third, fourth);
R Function(A a) _$fxPipe5<A, M1, M2, M3, M4, R>(
        M1 Function(A a) first, M2 Function(M1 m) second,
        M3 Function(M2 m) third, M4 Function(M3 m) fourth,
        R Function(M4 m) fifth) =>
    fxPipe5(first, second, third, fourth, fifth);
typedef _$IsolatePool = IsolatePool;
Iterable<(A, B)> _$attach<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    attach(f, iterable);
FxAsyncIterable<(A, B)> _$attachAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    attachAsync(f, iterable);

// lazy/filter.dart
Iterable<A> _$filter<A>(bool Function(A a) f, Iterable<A> iterable) =>
    filter(f, iterable);
FxAsyncIterable<A> _$filterAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    filterAsync(f, iterable);
Iterable<A> _$filterWithIndex<A>(
        bool Function(A a, int index) f, Iterable<A> iterable) =>
    filterWithIndex(f, iterable);
FxAsyncIterable<A> _$filterWithIndexAsync<A>(
        FutureOr<bool> Function(A a, int index) f,
        FxAsyncIterable<A> iterable) =>
    filterWithIndexAsync(f, iterable);
Iterable<A> _$reject<A>(bool Function(A a) f, Iterable<A> iterable) =>
    reject(f, iterable);
FxAsyncIterable<A> _$rejectAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    rejectAsync(f, iterable);
Iterable<A> _$uniq<A>(Iterable<A> iterable) => uniq(iterable);
FxAsyncIterable<A> _$uniqAsync<A>(FxAsyncIterable<A> iterable) =>
    uniqAsync(iterable);
Iterable<A> _$uniqBy<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    uniqBy(f, iterable);
FxAsyncIterable<A> _$uniqByAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    uniqByAsync(f, iterable);
List<A> _$uniqStrict<A>(Iterable<A> iterable) => uniqStrict(iterable);
List<A> _$uniqByStrict<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    uniqByStrict(f, iterable);
Map<K, Acc> _$foldByOrSkip<A, K extends Object, Acc>(
        K? Function(A a) key,
        Acc seed,
        Acc Function(Acc acc, A a) f,
        Iterable<A> iterable) =>
    foldByOrSkip(key, seed, f, iterable);
List<A> _$takeUniqBy<A, B extends Object>(
        int count, B? Function(A a) f, Iterable<A> iterable) =>
    takeUniqBy(count, f, iterable);
Iterable<B> _$mapNotNull<A, B extends Object>(
        B? Function(A a) f, Iterable<A> iterable) =>
    mapNotNull(f, iterable);
FxAsyncIterable<B> _$mapNotNullAsync<A, B extends Object>(
        FutureOr<B?> Function(A a) f, FxAsyncIterable<A> iterable) =>
    mapNotNullAsync(f, iterable);
Iterable<A> _$differenceBy<A, B>(
        B Function(A a) f, Iterable<A> iterable1, Iterable<A> iterable2) =>
    differenceBy(f, iterable1, iterable2);
FxAsyncIterable<A> _$differenceByAsync<A, B>(FutureOr<B> Function(A a) f,
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    differenceByAsync(f, iterable1, iterable2);
Iterable<A> _$difference<A>(Iterable<A> iterable1, Iterable<A> iterable2) =>
    difference(iterable1, iterable2);
FxAsyncIterable<A> _$differenceAsync<A>(
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    differenceAsync(iterable1, iterable2);
Iterable<A> _$intersectionBy<A, B>(
        B Function(A a) f, Iterable<A> iterable1, Iterable<A> iterable2) =>
    intersectionBy(f, iterable1, iterable2);
FxAsyncIterable<A> _$intersectionByAsync<A, B>(FutureOr<B> Function(A a) f,
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    intersectionByAsync(f, iterable1, iterable2);
Iterable<A> _$intersection<A>(Iterable<A> iterable1, Iterable<A> iterable2) =>
    intersection(iterable1, iterable2);
FxAsyncIterable<A> _$intersectionAsync<A>(
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    intersectionAsync(iterable1, iterable2);

// lazy/take_drop.dart
Iterable<A> _$take<A>(int length, Iterable<A> iterable) =>
    take(length, iterable);
FxAsyncIterable<A> _$takeAsync<A>(int length, FxAsyncIterable<A> iterable) =>
    takeAsync(length, iterable);
Iterable<A> _$takeRight<A>(int length, Iterable<A> iterable) =>
    takeRight(length, iterable);
FxAsyncIterable<A> _$takeRightAsync<A>(
        int length, FxAsyncIterable<A> iterable) =>
    takeRightAsync(length, iterable);
Iterable<A> _$takeWhile<A>(bool Function(A a) f, Iterable<A> iterable) =>
    takeWhile(f, iterable);
FxAsyncIterable<A> _$takeWhileAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    takeWhileAsync(f, iterable);
Iterable<A> _$takeWhileRight<A>(bool Function(A a) f, Iterable<A> iterable) =>
    takeWhileRight(f, iterable);
FxAsyncIterable<A> _$takeWhileRightAsync<A>(
        bool Function(A a) f, FxAsyncIterable<A> iterable) =>
    takeWhileRightAsync(f, iterable);
Iterable<A> _$dropWhileRight<A>(bool Function(A a) f, Iterable<A> iterable) =>
    dropWhileRight(f, iterable);
FxAsyncIterable<A> _$dropWhileRightAsync<A>(
        bool Function(A a) f, FxAsyncIterable<A> iterable) =>
    dropWhileRightAsync(f, iterable);
Iterable<A> _$takeUntilInclusive<A>(
        bool Function(A a) f, Iterable<A> iterable) =>
    takeUntilInclusive(f, iterable);
FxAsyncIterable<A> _$takeUntilInclusiveAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    takeUntilInclusiveAsync(f, iterable);
Iterable<A> _$drop<A>(int length, Iterable<A> iterable) =>
    drop(length, iterable);
FxAsyncIterable<A> _$dropAsync<A>(int length, FxAsyncIterable<A> iterable) =>
    dropAsync(length, iterable);
Iterable<A> _$dropRight<A>(int length, Iterable<A> iterable) =>
    dropRight(length, iterable);
FxAsyncIterable<A> _$dropRightAsync<A>(
        int length, FxAsyncIterable<A> iterable) =>
    dropRightAsync(length, iterable);
Iterable<A> _$dropWhile<A>(bool Function(A a) f, Iterable<A> iterable) =>
    dropWhile(f, iterable);
FxAsyncIterable<A> _$dropWhileAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    dropWhileAsync(f, iterable);
Iterable<A> _$dropUntil<A>(bool Function(A a) f, Iterable<A> iterable) =>
    dropUntil(f, iterable);
FxAsyncIterable<A> _$dropUntilAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    dropUntilAsync(f, iterable);
Iterable<A> _$slice<A>(int start, Iterable<A> iterable, [int? end]) =>
    slice(start, iterable, end);
FxAsyncIterable<A> _$sliceAsync<A>(int start, FxAsyncIterable<A> iterable,
        [int? end]) =>
    sliceAsync(start, iterable, end);
Iterable<List<A>> _$chunk<A>(int size, Iterable<A> iterable) =>
    chunk(size, iterable);
FxAsyncIterable<List<A>> _$chunkAsync<A>(
        int size, FxAsyncIterable<A> iterable) =>
    chunkAsync(size, iterable);

// lazy/zip.dart
Iterable<(A, B)> _$zip<A, B>(Iterable<A> iterable1, Iterable<B> iterable2) =>
    zip(iterable1, iterable2);
FxAsyncIterable<(A, B)> _$zipAsync<A, B>(
        FxAsyncIterable<A> iterable1, FxAsyncIterable<B> iterable2) =>
    zipAsync(iterable1, iterable2);
Iterable<(A, B, C)> _$zip3<A, B, C>(Iterable<A> iterable1,
        Iterable<B> iterable2, Iterable<C> iterable3) =>
    zip3(iterable1, iterable2, iterable3);
FxAsyncIterable<(A, B, C)> _$zip3Async<A, B, C>(FxAsyncIterable<A> iterable1,
        FxAsyncIterable<B> iterable2, FxAsyncIterable<C> iterable3) =>
    zip3Async(iterable1, iterable2, iterable3);
Iterable<(int, A)> _$zipWithIndex<A>(Iterable<A> iterable) =>
    zipWithIndex(iterable);
FxAsyncIterable<(int, A)> _$zipWithIndexAsync<A>(
        FxAsyncIterable<A> iterable) =>
    zipWithIndexAsync(iterable);
(List<A>, List<B>) _$unzip<A, B>(Iterable<(A, B)> iterable) =>
    unzip(iterable);
Future<(List<A>, List<B>)> _$unzipAsync<A, B>(
        FxAsyncIterable<(A, B)> iterable) =>
    unzipAsync(iterable);

// lazy/combine.dart
Iterable<A> _$append<A>(A a, Iterable<A> iterable) => append(a, iterable);
FxAsyncIterable<A> _$appendAsync<A>(
        FutureOr<A> a, FxAsyncIterable<A> iterable) =>
    appendAsync(a, iterable);
Iterable<A> _$prepend<A>(A a, Iterable<A> iterable) => prepend(a, iterable);
FxAsyncIterable<A> _$prependAsync<A>(
        FutureOr<A> a, FxAsyncIterable<A> iterable) =>
    prependAsync(a, iterable);
Iterable<A> _$concat<A>(Iterable<A> iterable1, Iterable<A> iterable2) =>
    concat(iterable1, iterable2);
FxAsyncIterable<A> _$concatAsync<A>(
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    concatAsync(iterable1, iterable2);
Iterable<A> _$reverse<A>(Iterable<A> iterable) => reverse(iterable);
FxAsyncIterable<A> _$reverseAsync<A>(FxAsyncIterable<A> iterable) =>
    reverseAsync(iterable);
Iterable<T> _$cycle<T>(Iterable<T> iterable) => cycle(iterable);
FxAsyncIterable<T> _$cycleAsync<T>(FxAsyncIterable<T> iterable) =>
    cycleAsync(iterable);

// lazy/take_drop.dart + lazy/filter.dart + lazy/combine.dart (0.7.2)
Iterable<List<A>> _$windowed<A>(int size, Iterable<A> iterable,
        {int step = 1, bool partial = false}) =>
    windowed(size, iterable, step: step, partial: partial);
FxAsyncIterable<List<A>> _$windowedAsync<A>(
        int size, FxAsyncIterable<A> iterable,
        {int step = 1, bool partial = false}) =>
    windowedAsync(size, iterable, step: step, partial: partial);
Iterable<(A, A)> _$pairwise<A>(Iterable<A> iterable) => pairwise(iterable);
FxAsyncIterable<(A, A)> _$pairwiseAsync<A>(FxAsyncIterable<A> iterable) =>
    pairwiseAsync(iterable);
Iterable<A> _$uniqAdjacent<A>(Iterable<A> iterable) => uniqAdjacent(iterable);
FxAsyncIterable<A> _$uniqAdjacentAsync<A>(FxAsyncIterable<A> iterable) =>
    uniqAdjacentAsync(iterable);
Iterable<A> _$uniqAdjacentBy<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    uniqAdjacentBy(f, iterable);
FxAsyncIterable<A> _$uniqAdjacentByAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    uniqAdjacentByAsync(f, iterable);
Iterable<A> _$ifEmpty<A>(
        Iterable<A> Function() fallback, Iterable<A> iterable) =>
    ifEmpty(fallback, iterable);
FxAsyncIterable<A> _$ifEmptyAsync<A>(FxAsyncIterable<A> Function() fallback,
        FxAsyncIterable<A> iterable) =>
    ifEmptyAsync(fallback, iterable);
Iterable<A> _$defaultIfEmpty<A>(A value, Iterable<A> iterable) =>
    defaultIfEmpty(value, iterable);
FxAsyncIterable<A> _$defaultIfEmptyAsync<A>(
        FutureOr<A> value, FxAsyncIterable<A> iterable) =>
    defaultIfEmptyAsync(value, iterable);

// lazy/effect.dart (0.7.2)
FxAsyncIterable<R> _$mapRetryAsync<A, R>(
        int attempts, FutureOr<R> Function(A a) f, FxAsyncIterable<A> iterable,
        {Duration Function(int failed)? delay}) =>
    mapRetryAsync(attempts, f, iterable, delay: delay);
Iterable<R> _$mapCatching<A, R>(R Function(A a) f,
        R Function(Object error, StackTrace stackTrace) onError,
        Iterable<A> iterable) =>
    mapCatching(f, onError, iterable);
FxAsyncIterable<R> _$mapCatchingAsync<A, R>(FutureOr<R> Function(A a) f,
        FutureOr<R> Function(Object error, StackTrace stackTrace) onError,
        FxAsyncIterable<A> iterable) =>
    mapCatchingAsync(f, onError, iterable);
FxAsyncIterable<A> _$timeoutAsync<A>(
        Duration limit, FxAsyncIterable<A> iterable) =>
    timeoutAsync(limit, iterable);

// strict/aggregate.dart
List<A> _$toList<A>(Iterable<A> iterable) => toList(iterable);
Future<List<A>> _$toListAsync<A>(FxAsyncIterable<A> iterable) =>
    toListAsync(iterable);
A _$reduce<A>(A Function(A acc, A a) f, Iterable<A> iterable) =>
    reduce(f, iterable);
Acc _$fold<A, Acc>(
        Acc seed, Acc Function(Acc acc, A a) f, Iterable<A> iterable) =>
    fold(seed, f, iterable);
void _$each<A>(void Function(A a) f, Iterable<A> iterable) => each(f, iterable);
Future<void> _$eachAsync<A>(
        FutureOr<void> Function(A a) f, FxAsyncIterable<A> iterable) =>
    eachAsync(f, iterable);
void _$consume<A>(Iterable<A> iterable, [int? n]) => consume(iterable, n);
Future<void> _$consumeAsync<A>(FxAsyncIterable<A> iterable, [int? n]) =>
    consumeAsync(iterable, n);
Future<A> _$reduceAsync<A>(
        FutureOr<A> Function(A acc, A a) f, FxAsyncIterable<A> iterable) =>
    reduceAsync(f, iterable);
Future<Acc> _$foldAsync<A, Acc>(FutureOr<Acc> seed,
        FutureOr<Acc> Function(Acc acc, A a) f, FxAsyncIterable<A> iterable) =>
    foldAsync(seed, f, iterable);
Acc _$foldWithIndex<A, Acc>(Acc seed,
        Acc Function(Acc acc, A a, int index) f, Iterable<A> iterable) =>
    foldWithIndex(seed, f, iterable);
Future<Acc> _$foldWithIndexAsync<A, Acc>(
        FutureOr<Acc> seed,
        FutureOr<Acc> Function(Acc acc, A a, int index) f,
        FxAsyncIterable<A> iterable) =>
    foldWithIndexAsync(seed, f, iterable);
Acc _$foldRight<A, Acc>(
        Acc seed, Acc Function(Acc acc, A a) f, Iterable<A> iterable) =>
    foldRight(seed, f, iterable);
Acc _$foldRightWithIndex<A, Acc>(Acc seed,
        Acc Function(Acc acc, A a, int index) f, Iterable<A> iterable) =>
    foldRightWithIndex(seed, f, iterable);
Future<Acc> _$foldRightAsync<A, Acc>(FutureOr<Acc> seed,
        FutureOr<Acc> Function(Acc acc, A a) f, FxAsyncIterable<A> iterable) =>
    foldRightAsync(seed, f, iterable);
Future<Acc> _$foldRightWithIndexAsync<A, Acc>(
        FutureOr<Acc> seed,
        FutureOr<Acc> Function(Acc acc, A a, int index) f,
        FxAsyncIterable<A> iterable) =>
    foldRightWithIndexAsync(seed, f, iterable);
num _$sum(Iterable<num> iterable) => sum(iterable);
Future<num> _$sumAsync(FxAsyncIterable<num> iterable) => sumAsync(iterable);
num _$product(Iterable<num> iterable) => product(iterable);
Future<num> _$productAsync(FxAsyncIterable<num> iterable) =>
    productAsync(iterable);
double _$average(Iterable<num> iterable) => average(iterable);
Future<double> _$averageAsync(FxAsyncIterable<num> iterable) =>
    averageAsync(iterable);
num _$min(Iterable<num> iterable) => min(iterable);
Future<num> _$minAsync(FxAsyncIterable<num> iterable) => minAsync(iterable);
num _$max(Iterable<num> iterable) => max(iterable);
Future<num> _$maxAsync(FxAsyncIterable<num> iterable) => maxAsync(iterable);
A? _$minBy<A>(Object? Function(A a) f, Iterable<A> iterable) =>
    minBy(f, iterable);
Future<A?> _$minByAsync<A>(
        Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    minByAsync(f, iterable);
A? _$maxBy<A>(Object? Function(A a) f, Iterable<A> iterable) =>
    maxBy(f, iterable);
Future<A?> _$maxByAsync<A>(
        Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    maxByAsync(f, iterable);
num _$sumBy<A>(num Function(A a) f, Iterable<A> iterable) =>
    sumBy(f, iterable);
Future<num> _$sumByAsync<A>(
        FutureOr<num> Function(A a) f, FxAsyncIterable<A> iterable) =>
    sumByAsync(f, iterable);
num _$productBy<A>(num Function(A a) f, Iterable<A> iterable) =>
    productBy(f, iterable);
Future<num> _$productByAsync<A>(
        FutureOr<num> Function(A a) f, FxAsyncIterable<A> iterable) =>
    productByAsync(f, iterable);
double _$averageBy<A>(num Function(A a) f, Iterable<A> iterable) =>
    averageBy(f, iterable);
Future<double> _$averageByAsync<A>(
        FutureOr<num> Function(A a) f, FxAsyncIterable<A> iterable) =>
    averageByAsync(f, iterable);
int _$size<A>(Iterable<A> iterable) => size(iterable);
Future<int> _$sizeAsync<A>(FxAsyncIterable<A> iterable) => sizeAsync(iterable);
Future<String> _$joinAsync<A>(String sep, FxAsyncIterable<A> iterable) =>
    joinAsync(sep, iterable);
Map<K, List<A>> _$groupBy<A, K>(K Function(A a) f, Iterable<A> iterable) =>
    groupBy(f, iterable);
Future<Map<K, List<A>>> _$groupByAsync<A, K>(
        FutureOr<K> Function(A a) f, FxAsyncIterable<A> iterable) =>
    groupByAsync(f, iterable);
Map<K, A> _$indexBy<A, K>(K Function(A a) f, Iterable<A> iterable) =>
    indexBy(f, iterable);
Future<Map<K, A>> _$indexByAsync<A, K>(
        FutureOr<K> Function(A a) f, FxAsyncIterable<A> iterable) =>
    indexByAsync(f, iterable);
Map<K, int> _$countBy<A, K>(K Function(A a) f, Iterable<A> iterable) =>
    countBy(f, iterable);
Map<K, Acc> _$foldBy<A, K, Acc>(K Function(A a) key, Acc seed,
        Acc Function(Acc acc, A a) f, Iterable<A> iterable) =>
    foldBy(key, seed, f, iterable);
Future<Map<K, Acc>> _$foldByAsync<A, K, Acc>(
        FutureOr<K> Function(A a) key,
        FutureOr<Acc> seed,
        FutureOr<Acc> Function(Acc acc, A a) f,
        FxAsyncIterable<A> iterable) =>
    foldByAsync(key, seed, f, iterable);
Future<Map<K, int>> _$countByAsync<A, K>(
        FutureOr<K> Function(A a) f, FxAsyncIterable<A> iterable) =>
    countByAsync(f, iterable);
List<A> _$sort<A>(int Function(A a, A b) f, Iterable<A> iterable) =>
    sort(f, iterable);
Future<List<A>> _$sortAsync<A>(
        int Function(A a, A b) f, FxAsyncIterable<A> iterable) =>
    sortAsync(f, iterable);
List<A> _$sortBy<A>(Object? Function(A a) f, Iterable<A> iterable) =>
    sortBy(f, iterable);
Future<List<A>> _$sortByAsync<A>(
        Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    sortByAsync(f, iterable);
List<A> _$sortByDesc<A>(Object? Function(A a) f, Iterable<A> iterable) =>
    sortByDesc(f, iterable);
Future<List<A>> _$sortByDescAsync<A>(
        Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    sortByDescAsync(f, iterable);
List<A> _$topBy<A>(
        int k, Object? Function(A a) f, Iterable<A> iterable) =>
    topBy(k, f, iterable);
List<A> _$bottomBy<A>(
        int k, Object? Function(A a) f, Iterable<A> iterable) =>
    bottomBy(k, f, iterable);
Future<List<A>> _$topByAsync<A>(
        int k, Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    topByAsync(k, f, iterable);
Future<List<A>> _$bottomByAsync<A>(
        int k, Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    bottomByAsync(k, f, iterable);
List<({K key, List<A> items})> _$groupedBy<A, K>(
        K Function(A a) f, Iterable<A> iterable) =>
    groupedBy(f, iterable);
Future<List<({K key, List<A> items})>> _$groupedByAsync<A, K>(
        FutureOr<K> Function(A a) f, FxAsyncIterable<A> iterable) =>
    groupedByAsync(f, iterable);
int _$countWhere<A>(bool Function(A a) f, Iterable<A> iterable) =>
    countWhere(f, iterable);
Future<int> _$countWhereAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    countWhereAsync(f, iterable);
(List<A>, List<A>) _$partition<A>(bool Function(A a) f, Iterable<A> iterable) =>
    partition(f, iterable);
Future<(List<A>, List<A>)> _$partitionAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    partitionAsync(f, iterable);
// tee's fold records reach fx.dart as `s.Fold` / `s.AsyncFold`, so the
// prefix rewrite needs these two names to exist as types, not functions.
typedef _$Fold<A, R> = Fold<A, R>;
typedef _$AsyncFold<A, R> = AsyncFold<A, R>;
(R1, R2) _$tee<A, R1, R2>(
        Iterable<A> iterable, Fold<A, R1> first, Fold<A, R2> second) =>
    tee(iterable, first, second);
(R1, R2, R3) _$tee3<A, R1, R2, R3>(Iterable<A> iterable, Fold<A, R1> first,
        Fold<A, R2> second, Fold<A, R3> third) =>
    tee3(iterable, first, second, third);
Future<(R1, R2)> _$teeAsync<A, R1, R2>(FxAsyncIterable<A> iterable,
        AsyncFold<A, R1> first, AsyncFold<A, R2> second) =>
    teeAsync(iterable, first, second);

// strict/access.dart
A? _$head<A>(Iterable<A> iterable) => head(iterable);
Future<A?> _$headAsync<A>(FxAsyncIterable<A> iterable) => headAsync(iterable);
A? _$last<A>(Iterable<A> iterable) => last(iterable);
Future<A?> _$lastAsync<A>(FxAsyncIterable<A> iterable) => lastAsync(iterable);
A? _$find<A>(bool Function(A a) f, Iterable<A> iterable) => find(f, iterable);
Future<A?> _$findAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    findAsync(f, iterable);
int _$findIndex<A>(bool Function(A a) f, Iterable<A> iterable) =>
    findIndex(f, iterable);
Future<int> _$findIndexAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    findIndexAsync(f, iterable);
bool _$some<A>(bool Function(A a) f, Iterable<A> iterable) => some(f, iterable);
Future<bool> _$someAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    someAsync(f, iterable);
bool _$every<A>(bool Function(A a) f, Iterable<A> iterable) =>
    every(f, iterable);
Future<bool> _$everyAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    everyAsync(f, iterable);
bool _$none<A>(bool Function(A a) f, Iterable<A> iterable) =>
    none(f, iterable);
Future<bool> _$noneAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    noneAsync(f, iterable);
bool _$sequenceEqual<A>(
        Iterable<A> a, Iterable<A> b, [bool Function(A, A)? eq]) =>
    sequenceEqual(a, b, eq);
Future<bool> _$sequenceEqualAsync<A>(
        FxAsyncIterable<A> a, FxAsyncIterable<A> b, [bool Function(A, A)? eq]) =>
    sequenceEqualAsync(a, b, eq);
B? _$firstNotNullOf<A, B extends Object>(
        B? Function(A a) f, Iterable<A> iterable) =>
    firstNotNullOf(f, iterable);
Future<B?> _$firstNotNullOfAsync<A, B extends Object>(
        FutureOr<B?> Function(A a) f, FxAsyncIterable<A> iterable) =>
    firstNotNullOfAsync(f, iterable);
WRAPPERS

} | dart run "$ROOT/tool/strip_dart_comments.dart" > "$OUT.tmp"

# The banner is added after stripping so it survives it. Everything else in
# the file is comment-free: this file's bytes decide every playground
# artifact id (a snippet's id hashes bundle + snippet), so leaving lib/'s
# dartdoc in here meant a comment-only edit rotated all ~450 ids and rewrote
# the data-pg attribute on ~1,900 generated pages. Analyzer `ignore`
# directives are kept — CI runs `dart analyze` on this file.
{
  cat <<'BANNER'
// GENERATED by tools/build_single_file.sh — single-file build of fxdart for the web playground. Do not edit.
// Comments are stripped (tool/strip_dart_comments.dart) so that a dartdoc-only
// change to lib/ leaves this file byte-identical and churns no artifact ids.
BANNER
  cat "$OUT.tmp"
} > "$OUT"
rm -f "$OUT.tmp"

echo "Generated $OUT"
wc -l "$OUT"

echo "Running dart analyze..."
dart analyze "$OUT"
