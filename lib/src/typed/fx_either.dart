import 'dart:async';

import '../async_iterable.dart';
import '../fx.dart';
import 'accumulate.dart';
import 'either.dart';
import 'non_empty_list.dart';
import 'raise.dart';

// Typed errors fused with lazy pipelines — the part neither Arrow nor fpdart
// has. All of these are EAGER terminals by design, which also makes them the
// sanctioned escape from the laziness × raise hazard (never return a lazy
// pipeline from a raise block; return one of these results instead).

/// All [Right] values of [iterable], in order.
List<R> rights<L, R>(Iterable<Either<L, R>> iterable) => [
  for (final e in iterable)
    if (e case Right(:final value)) value,
];

/// All [Left] values of [iterable], in order.
List<L> lefts<L, R>(Iterable<Either<L, R>> iterable) => [
  for (final e in iterable)
    if (e case Left(:final value)) value,
];

/// Splits [iterable] into `(lefts, rights)` — the Either analogue of
/// `partition` (port of Arrow's `separateEither`).
(List<L>, List<R>) separateEither<L, R>(Iterable<Either<L, R>> iterable) {
  final ls = <L>[];
  final rs = <R>[];
  for (final e in iterable) {
    switch (e) {
      case Left(:final value):
        ls.add(value);
      case Right(:final value):
        rs.add(value);
    }
  }
  return (ls, rs);
}

/// Collects every success into one list, failing fast on the first [Left].
Either<L, List<R>> sequenceEither<L, R>(Iterable<Either<L, R>> iterable) {
  final out = <R>[];
  for (final e in iterable) {
    switch (e) {
      case Left(:final value):
        return Left(value);
      case Right(:final value):
        out.add(value);
    }
  }
  return Right(out);
}

/// Async twin of [sequenceEither]. Fail-fast: stops pulling from upstream at
/// the first [Left].
Future<Either<L, List<R>>> sequenceEitherAsync<L, R>(
  FxAsyncIterable<Either<L, R>> iterable,
) async {
  final out = <R>[];
  final it = iterable.iterator;
  var res = await it.next();
  while (!res.done) {
    switch (res.value) {
      case Left(:final value):
        return Left(value);
      case Right(:final value):
        out.add(value);
    }
    res = await it.next();
  }
  return Right(out);
}

/// Async twin of [rights].
Future<List<R>> rightsAsync<L, R>(
  FxAsyncIterable<Either<L, R>> iterable,
) async {
  final out = <R>[];
  final it = iterable.iterator;
  var res = await it.next();
  while (!res.done) {
    if (res.value case Right(:final value)) out.add(value);
    res = await it.next();
  }
  return out;
}

/// Async twin of [lefts].
Future<List<L>> leftsAsync<L, R>(FxAsyncIterable<Either<L, R>> iterable) async {
  final out = <L>[];
  final it = iterable.iterator;
  var res = await it.next();
  while (!res.done) {
    if (res.value case Left(:final value)) out.add(value);
    res = await it.next();
  }
  return out;
}

/// Async twin of [separateEither].
Future<(List<L>, List<R>)> separateEitherAsync<L, R>(
  FxAsyncIterable<Either<L, R>> iterable,
) async {
  final ls = <L>[];
  final rs = <R>[];
  final it = iterable.iterator;
  var res = await it.next();
  while (!res.done) {
    switch (res.value) {
      case Left(:final value):
        ls.add(value);
      case Right(:final value):
        rs.add(value);
    }
    res = await it.next();
  }
  return (ls, rs);
}

/// Collects every success, or EVERY failure — the fail-slow twin of
/// [sequenceEither] over an existing collection of `Either`s (port of
/// Arrow's `flattenOrAccumulate`).
Either<NonEmptyList<E>, List<A>> flattenOrAccumulate<E, A>(
  Iterable<Either<E, A>> iterable,
) => mapOrAccumulate((r, Either<E, A> e) => r.bind(e), iterable);

/// Async twin of [flattenOrAccumulate]. Fail-slow: consumes the whole
/// upstream so every [Left] is collected.
Future<Either<NonEmptyList<E>, List<A>>> flattenOrAccumulateAsync<E, A>(
  FxAsyncIterable<Either<E, A>> iterable,
) => mapOrAccumulateAsync((r, Either<E, A> e) => r.bind(e), iterable);

/// Transforms every element of [iterable], collecting ALL failures instead
/// of stopping at the first. The eager, pipeline-level twin of
/// [AccumulatingRaiseOps.mapOrAccumulate].
Either<NonEmptyList<E>, List<R>> mapOrAccumulate<E, T, R>(
  R Function(AccumulatingRaise<E> r, T item) transform,
  Iterable<T> iterable,
) => either<NonEmptyList<E>, List<R>>(
  (r) => r.mapOrAccumulate(iterable, transform),
);

/// Async twin of [mapOrAccumulate] — fail-slow concurrent validation.
///
/// Implemented by composition: each element runs in its own
/// [eitherAsync] scope (so a raise in one element can never leak into a
/// sibling), mapped through the existing parallel-safe `mapAsync` machinery,
/// then folded eagerly in order. Pass [concurrency] to evaluate up to that
/// many elements at once via the `concurrent(n)` back-channel.
Future<Either<NonEmptyList<E>, List<R>>> mapOrAccumulateAsync<E, T, R>(
  FutureOr<R> Function(AccumulatingRaise<E> r, T item) transform,
  FxAsyncIterable<T> iterable, {
  int? concurrency,
}) async {
  var mapped = FxAsync(iterable).map(
    (item) => eitherAsync<NonEmptyList<E>, R>(
      (r) => transform(AccumulatingRaise.over(r), item),
    ),
  );
  if (concurrency != null) mapped = mapped.concurrent(concurrency);
  final errors = <E>[];
  final results = <R>[];
  await mapped.each((e) {
    switch (e) {
      case Left(:final value):
        errors.addAll(value);
      case Right(:final value):
        if (errors.isEmpty) results.add(value);
    }
  });
  return errors.isEmpty ? Right(results) : Left(NonEmptyList.orNull(errors)!);
}

/// Either-aware terminals for sync chains of `Either` values.
extension FxEitherOps<L, R> on Fx<Either<L, R>> {
  /// All [Right] values, in order.
  List<R> rights() => [
    for (final e in this)
      if (e case Right(:final value)) value,
  ];

  /// All [Left] values, in order.
  List<L> lefts() => [
    for (final e in this)
      if (e case Left(:final value)) value,
  ];

  /// Splits into `(lefts, rights)` — matches the `partition` record shape.
  (List<L>, List<R>) separated() => separateEither(this);

  /// Collects every success into one list, failing fast on the first [Left].
  Either<L, List<R>> sequence() => sequenceEither(this);

  /// Collects every success, or EVERY failure — the fail-slow twin of
  /// [sequence].
  EitherNel<L, List<R>> flattenOrAccumulate() =>
      // The top-level twin is shadowed by this member's name, so the
      // composition is spelled out (the FxEitherOps.rights precedent).
      either<NonEmptyList<L>, List<R>>(
        (r) => r.mapOrAccumulate(this, (br, Either<L, R> e) => br.bind(e)),
      );
}

/// Either-aware terminals for async chains of `Either` values.
extension FxAsyncEitherOps<L, R> on FxAsync<Either<L, R>> {
  /// Async twin of [FxEitherOps.sequence] — stops pulling on the first
  /// [Left].
  Future<Either<L, List<R>>> sequence() => sequenceEitherAsync(this);

  /// Async twin of [FxEitherOps.rights].
  Future<List<R>> rights() => rightsAsync(this);

  /// Async twin of [FxEitherOps.lefts].
  Future<List<L>> lefts() => leftsAsync(this);

  /// Async twin of [FxEitherOps.separated].
  Future<(List<L>, List<R>)> separated() => separateEitherAsync(this);

  /// Async twin of [FxEitherOps.flattenOrAccumulate] — fail-slow, consumes
  /// the whole upstream.
  Future<EitherNel<L, List<R>>> flattenOrAccumulate() =>
      flattenOrAccumulateAsync(this);
}

/// Fail-slow validation over a sync chain.
extension FxAccumulateOps<T> on Fx<T> {
  /// Transforms every element, collecting ALL failures instead of stopping
  /// at the first.
  Either<NonEmptyList<E>, List<R>> mapOrAccumulate<E, R>(
    R Function(AccumulatingRaise<E> r, T item) transform,
  ) => either<NonEmptyList<E>, List<R>>(
    (r) => r.mapOrAccumulate(this, transform),
  );
}

/// Fail-slow (optionally concurrent) validation over an async chain.
extension FxAsyncAccumulateOps<T> on FxAsync<T> {
  /// Async twin of [FxAccumulateOps.mapOrAccumulate]; pass [concurrency] to
  /// evaluate up to that many elements at once.
  Future<Either<NonEmptyList<E>, List<R>>> mapOrAccumulate<E, R>(
    FutureOr<R> Function(AccumulatingRaise<E> r, T item) transform, {
    int? concurrency,
  }) => mapOrAccumulateAsync(transform, this, concurrency: concurrency);
}
