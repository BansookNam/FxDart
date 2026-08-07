import 'non_empty_list.dart';
import 'raise.dart' as raise_;

/// `Either<L, R>` where the failure side is a [NonEmptyList] of errors —
/// the accumulation result type (port of Arrow's `EitherNel`).
typedef EitherNel<E, A> = Either<NonEmptyList<E>, A>;

/// A value that is either a failure [Left] of `L` or a success [Right] of
/// `R` — the boundary type of the typed-error system (port of Arrow's
/// `Either`, 2.x method set: curated, no `ap`/`traverse`/`Do`).
///
/// Sealed: `switch` over it is exhaustive without a `default` arm.
///
/// ```dart
/// switch (result) {
///   case Left(:final value):  log('failed: $value');
///   case Right(:final value): use(value);
/// }
/// ```
///
/// Prefer building Eithers with the [raise_.either] builder over chaining
/// `flatMap` — inside the builder you write straight-line Dart.
sealed class Either<L, R> {
  const Either();

  /// Wraps a failure — with Dart 3.10 dot shorthands, `return .left(e)`
  /// works wherever the context type is `Either`.
  const factory Either.left(L value) = Left<L, R>;

  /// Wraps a success — with Dart 3.10 dot shorthands, `return .right(x)`
  /// works wherever the context type is `Either`.
  const factory Either.right(R value) = Right<L, R>;

  /// Whether this is a [Left].
  bool get isLeft => this is Left<L, R>;

  /// Whether this is a [Right].
  bool get isRight => this is Right<L, R>;

  /// Collapses both sides into one result.
  T fold<T>(T Function(L left) ifLeft, T Function(R right) ifRight) =>
      switch (this) {
        Left(:final value) => ifLeft(value),
        Right(:final value) => ifRight(value),
      };

  /// Transforms the success value; a [Left] passes through unchanged.
  Either<L, T> map<T>(T Function(R value) f) => switch (this) {
        Left(:final value) => Left(value),
        Right(:final value) => Right(f(value)),
      };

  /// Transforms the failure value; a [Right] passes through unchanged.
  Either<T, R> mapLeft<T>(T Function(L value) f) => switch (this) {
        Left(:final value) => Left(f(value)),
        Right(:final value) => Right(value),
      };

  /// Chains a dependent computation; short-circuits on [Left].
  Either<L, T> flatMap<T>(Either<L, T> Function(R value) f) => switch (this) {
        Left(:final value) => Left(value),
        Right(:final value) => f(value),
      };

  /// Combines this success with [b]'s, keeping the **first** failure — the
  /// fail-fast counterpart of `zipOrAccumulate2`.
  ///
  /// ```dart
  /// parseName(form).map2(parseAge(form), User.new);
  /// ```
  ///
  /// Both branches are already-evaluated [Either] values, so both ran; what
  /// is fail-fast is the *reporting* — the leftmost [Left] is returned and
  /// the rest are discarded. When you want every failure instead, use
  /// `zipOrAccumulate2` inside an `accumulate` scope, which reports an
  /// `EitherNel`. [combine] runs only when every branch is a [Right].
  // The arities are written as a run of `is Left` checks rather than nested
  // `flatMap`s: it makes "the leftmost Left wins" literally readable, and it
  // allocates no closures per call.
  Either<L, T> map2<B, T>(Either<L, B> b, T Function(R a, B b) combine) {
    final a = this;
    if (a is Left<L, R>) return Left(a.value);
    if (b is Left<L, B>) return Left(b.value);
    return Right(combine((a as Right<L, R>).value, (b as Right<L, B>).value));
  }

  /// 3-ary [map2].
  Either<L, T> map3<B, C, T>(
      Either<L, B> b, Either<L, C> c, T Function(R a, B b, C c) combine) {
    final a = this;
    if (a is Left<L, R>) return Left(a.value);
    if (b is Left<L, B>) return Left(b.value);
    if (c is Left<L, C>) return Left(c.value);
    return Right(combine((a as Right<L, R>).value, (b as Right<L, B>).value,
        (c as Right<L, C>).value));
  }

  /// 4-ary [map2].
  Either<L, T> map4<B, C, D, T>(Either<L, B> b, Either<L, C> c, Either<L, D> d,
      T Function(R a, B b, C c, D d) combine) {
    final a = this;
    if (a is Left<L, R>) return Left(a.value);
    if (b is Left<L, B>) return Left(b.value);
    if (c is Left<L, C>) return Left(c.value);
    if (d is Left<L, D>) return Left(d.value);
    return Right(combine((a as Right<L, R>).value, (b as Right<L, B>).value,
        (c as Right<L, C>).value, (d as Right<L, D>).value));
  }

  /// 5-ary [map2]. Arity capped at 5, like `zipOrAccumulate2..5` and
  /// `Curry2..Curry5` — beyond that, chain [flatMap] or use the `either`
  /// builder.
  Either<L, T> map5<B, C, D, E, T>(
      Either<L, B> b,
      Either<L, C> c,
      Either<L, D> d,
      Either<L, E> e,
      T Function(R a, B b, C c, D d, E e) combine) {
    final a = this;
    if (a is Left<L, R>) return Left(a.value);
    if (b is Left<L, B>) return Left(b.value);
    if (c is Left<L, C>) return Left(c.value);
    if (d is Left<L, D>) return Left(d.value);
    if (e is Left<L, E>) return Left(e.value);
    return Right(combine((a as Right<L, R>).value, (b as Right<L, B>).value,
        (c as Right<L, C>).value, (d as Right<L, D>).value,
        (e as Right<L, E>).value));
  }

  /// Swaps the sides.
  Either<R, L> swap() => switch (this) {
        Left(:final value) => Right(value),
        Right(:final value) => Left(value),
      };

  /// The success value, or `null` — the bridge to nullable-first code.
  R? getOrNull() => switch (this) {
        Left() => null,
        Right(:final value) => value,
      };

  /// The failure value, or `null`.
  L? leftOrNull() => switch (this) {
        Left(:final value) => value,
        Right() => null,
      };

  /// The success value, or the result of [orElse] applied to the failure.
  R getOrElse(R Function(L left) orElse) => switch (this) {
        Left(:final value) => orElse(value),
        Right(:final value) => value,
      };

  /// Runs [action] on the failure value; returns this unchanged.
  Either<L, R> onLeft(void Function(L value) action) {
    if (this case Left(:final value)) action(value);
    return this;
  }

  /// Runs [action] on the success value; returns this unchanged.
  Either<L, R> onRight(void Function(R value) action) {
    if (this case Right(:final value)) action(value);
    return this;
  }

  /// Lifts the failure into a singleton [NonEmptyList] — the bridge from
  /// fail-fast values into accumulating scopes.
  EitherNel<L, R> toEitherNel() => switch (this) {
        Left(:final value) => Left(NonEmptyList.of(value)),
        Right(:final value) => Right(value),
      };

  /// Returns this when it is a [Right], otherwise the result of [other] —
  /// "try this, and if it failed try that".
  ///
  /// [other] is not called on the success path, so the alternative can be an
  /// expensive lookup. The failure is discarded; use [orElse] when the
  /// fallback depends on what went wrong.
  ///
  /// ```dart
  /// fromCache(key).alt(() => fromDisk(key)).alt(() => fromNetwork(key));
  /// ```
  Either<L, R> alt(Either<L, R> Function() other) => switch (this) {
        Left() => other(),
        Right() => this,
      };

  /// Like [alt], but [other] receives the failure and may return a different
  /// failure type — the fallback that gets to look at what went wrong.
  ///
  /// ```dart
  /// parseInt(s).orElse((e) => Left('$s is not a number ($e)'));
  /// ```
  ///
  /// [recover] is the richer sibling: it runs inside a fresh raise scope, so
  /// the handler writes straight-line Dart and raises rather than building an
  /// `Either` by hand. Reach for [orElse] when you already *have* the
  /// replacement `Either` and only want to swap it in.
  Either<L2, R> orElse<L2>(Either<L2, R> Function(L left) other) =>
      switch (this) {
        Left(:final value) => other(value),
        Right(:final value) => Right(value),
      };

  /// Recovers from a failure inside a fresh raise scope: [transform] may
  /// return a replacement success value or raise a new error of type `L2`
  /// (port of Arrow's `recover`). It stands in for the whole
  /// `handleError`/`handleErrorWith` family — a handler that wants to fail
  /// again just calls `r.raise`, no `Either` construction by hand.
  ///
  /// [orElse] is the plainer form for when the replacement is already an
  /// `Either`, and [alt] for when the failure doesn't matter at all.
  Either<L2, R> recover<L2>(
          R Function(raise_.Raise<L2> r, L error) transform) =>
      switch (this) {
        Right(:final value) => Right(value),
        Left(:final value) => raise_.either((r) => transform(r, value)),
      };

  /// Runs [block], capturing any thrown object into a [Left].
  ///
  /// The library's own raise signal is rethrown, never captured — the port
  /// of Arrow's `Either.catch` + non-fatal discipline.
  static Either<Object, R> catching<R>(R Function() block) =>
      raise_.catching<Either<Object, R>>(
          () => Right(block()), (error, stackTrace) => Left(error));

  /// Like [catching], but maps the thrown object to a typed failure first.
  static Either<L, R> catchingWith<L, R>(
          L Function(Object error, StackTrace stackTrace) onError,
          R Function() block) =>
      raise_.catching<Either<L, R>>(() => Right(block()),
          (error, stackTrace) => Left(onError(error, stackTrace)));
}

/// The failure case of [Either].
final class Left<L, R> extends Either<L, R> {
  /// Wraps the failure [value].
  const Left(this.value);

  /// The failure value.
  final L value;

  @override
  bool operator ==(Object other) => other is Left && value == other.value;

  @override
  int get hashCode => Object.hash(Left, value);

  @override
  String toString() => 'Left($value)';
}

/// The success case of [Either].
final class Right<L, R> extends Either<L, R> {
  /// Wraps the success [value].
  const Right(this.value);

  /// The success value.
  final R value;

  @override
  bool operator ==(Object other) => other is Right && value == other.value;

  @override
  int get hashCode => Object.hash(Right, value);

  @override
  String toString() => 'Right($value)';
}
