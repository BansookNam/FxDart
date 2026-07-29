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

  /// Recovers from a failure inside a fresh raise scope: [transform] may
  /// return a replacement success value or raise a new error of type `L2`.
  /// Replaces the whole `orElse`/`handleError`/`handleErrorWith` family
  /// (port of Arrow's `recover`).
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
