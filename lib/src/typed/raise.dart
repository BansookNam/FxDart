import 'dart:async';

import 'either.dart';

/// The typed-error capability — the heart of the Arrow-style typed error
/// system, ported from Kotlin Arrow 2.x's `Raise<E>`.
///
/// A [Raise] is a *scope* in which computations may short-circuit with a
/// typed error `E`. You never construct one yourself: builders like [either],
/// [eitherAsync], and [nullable] create a scope, hand it to your block, and
/// turn a raised error into their result type at the boundary.
///
/// ```dart
/// Either<String, int> parse(String s) => either((r) {
///   final n = int.tryParse(s);
///   return r.ensureNotNull(n, () => '"$s" is not a number');
/// });
/// ```
///
/// Inside the block you write straight-line Dart; `Either` only appears at
/// the boundary. This replaces wrapper towers (`TaskEither`, `IO`, …) and
/// `flatMap` pyramids entirely.
abstract interface class Raise<E> {
  /// Short-circuits the enclosing raise scope with [error].
  ///
  /// Returns [Never]: Dart's flow analysis knows execution stops here, so
  /// `value ?? r.raise(err)` promotes to non-null.
  Never raise(E error);
}

/// Thrown when `raise` (or a closure capturing the scope) is invoked *after*
/// its enclosing builder already returned.
final class RaiseLeakedError extends Error {
  @override
  String toString() =>
      'RaiseLeakedError: raise was called outside the lifecycle of its '
      'either/nullable scope. Common causes: (1) the block returned a lazy '
      'iterable (fx(...).map(...), sync*) that raises when consumed later — '
      'materialize with toList() inside the block, or use mapOrAccumulate / '
      'sequence terminals; (2) the Raise scope (or a closure over it) was '
      'stored and called after the builder returned; (3) an async branch '
      'outlived the scope after another branch raised. Make sure all raise / '
      'bind / ensure calls happen within the lifecycle of either { }, '
      'nullable { } or similar builders.';
}

/// Internal short-circuit signal.
///
/// Implements [Error] (NOT [Exception]) deliberately: the ubiquitous
/// `on Exception catch (e)` in user code must not swallow it. This is the
/// Dart analogue of Arrow making its signal a `CancellationException` — the
/// one throwable idiomatic Kotlin never catches. A bare `catch (e)` still
/// catches it (unavoidable, same as Arrow); use [catching] instead.
final class _RaiseSignal implements Error {
  _RaiseSignal(this.raised, this.scope);

  /// The raised error value, statically guaranteed to be the scope's `E`
  /// (see [_DefaultRaise] — the covariant parameter check enforces it).
  final Object? raised;

  /// The scope token; builders match it with `identical`.
  final Object scope;

  @override
  StackTrace? get stackTrace => null;

  @override
  String toString() =>
      'fxdart raise signal escaped its either/nullable scope. Did you catch '
      'it with a bare `catch`, `Future.catchError`, `Stream.handleError`, or '
      'leak it across an unawaited future? Use fxdart `catching` instead of '
      'a bare catch inside raise blocks.';
}

/// Reified per-invocation scope. Generic in `E` — unlike Arrow's type-erased
/// `DefaultRaise : Raise<Any?>`. Dart reifies type arguments, so if a scope
/// is covariantly upcast (`Raise<String>` seen as `Raise<Object?>`) and
/// misused, the covariant-parameter check fails AT THE `raise()` CALL SITE
/// with a clean [TypeError] — and the `as E` cast in [foldRaise] is then
/// provably safe.
final class _DefaultRaise<E> implements Raise<E> {
  bool _active = true;

  @override
  Never raise(E error) =>
      _active ? throw _RaiseSignal(error, this) : throw RaiseLeakedError();
}

/// The single primitive every builder derives from — the port of Arrow's
/// `fold` (`Fold.kt`). Runs [block] in a fresh raise scope and dispatches:
///
/// - normal completion → [onValue]
/// - `raise(e)` from *this* scope → [onRaise]
/// - a thrown exception → [onThrow] (default: rethrow)
/// - a raise signal from a *different* scope → rethrown untouched (this is
///   what makes nested scopes correct with no dynamic scoping)
///
/// Named `foldRaise` because top-level `fold` already exists in fxdart —
/// the forced-suffix situation `WHY_CURRIED.md` blesses.
B foldRaise<E, A, B>(
  A Function(Raise<E> r) block, {
  required B Function(E error) onRaise,
  required B Function(A value) onValue,
  B Function(Object thrown, StackTrace stackTrace)? onThrow,
}) {
  final scope = _DefaultRaise<E>();
  try {
    final result = block(scope);
    scope._active = false;
    return onValue(result);
  } on _RaiseSignal catch (signal) {
    scope._active = false;
    if (identical(signal.scope, scope)) return onRaise(signal.raised as E);
    rethrow;
  } catch (thrown, stackTrace) {
    scope._active = false;
    if (onThrow != null) return onThrow(thrown, stackTrace);
    rethrow;
  }
}

/// Async twin of [foldRaise]. Sync and async are separate functions because
/// Dart has no `inline` — the same split fxdart applies to every
/// `op`/`opAsync` pair.
Future<B> foldRaiseAsync<E, A, B>(
  FutureOr<A> Function(Raise<E> r) block, {
  required FutureOr<B> Function(E error) onRaise,
  required FutureOr<B> Function(A value) onValue,
  FutureOr<B> Function(Object thrown, StackTrace stackTrace)? onThrow,
}) async {
  final scope = _DefaultRaise<E>();
  try {
    final result = await block(scope);
    scope._active = false;
    return await onValue(result);
  } on _RaiseSignal catch (signal) {
    scope._active = false;
    if (identical(signal.scope, scope)) {
      return await onRaise(signal.raised as E);
    }
    rethrow;
  } catch (thrown, stackTrace) {
    scope._active = false;
    if (onThrow != null) return await onThrow(thrown, stackTrace);
    rethrow;
  }
}

/// Runs [block] in a raise scope; a raised `E` becomes [Left], a normal
/// return becomes [Right]. Thrown exceptions propagate (use
/// [Either.catching] to capture them).
///
/// Port of Arrow's `either { }` builder.
///
/// ```dart
/// final result = either<String, int>((r) {
///   final n = r.bind(parse('42'));
///   r.ensure(n > 0, () => 'must be positive');
///   return n * 2;
/// }); // Right(84)
/// ```
Either<E, A> either<E, A>(A Function(Raise<E> r) block) =>
    foldRaise<E, A, Either<E, A>>(
      block,
      onRaise: (error) => Left(error),
      onValue: (value) => Right(value),
    );

/// Async twin of [either]. Raise only within the same awaited chain — a
/// raise inside an unawaited future cannot be captured and surfaces as an
/// unhandled zone error.
Future<Either<E, A>> eitherAsync<E, A>(
  FutureOr<A> Function(Raise<E> r) block,
) => foldRaiseAsync<E, A, Either<E, A>>(
  block,
  onRaise: (error) => Left(error),
  onValue: (value) => Right(value),
);

/// [either] with an exception boundary: a *thrown* exception is transformed
/// by [onThrow] into the scope's typed error. The pre-combined form of the
/// `either` + [catching] envelope (Arrow: `either { }` with `Raise.catch`).
///
/// The library's own raise signal is never handed to [onThrow] — a raise
/// from this scope becomes [Left] as usual, and a foreign scope's signal is
/// rethrown untouched.
///
/// ```dart
/// Either<RowError, Entry> parseRow(int line, String raw) => eitherCatching(
///   (r) => entryFrom(r, raw),  // may raise RowError OR throw FormatException
///   (e, _) => RowError.one(line, FieldError('row', 'could not parse: $e')),
/// );
/// ```
Either<E, A> eitherCatching<E, A>(
  A Function(Raise<E> r) block,
  E Function(Object thrown, StackTrace stackTrace) onThrow,
) => foldRaise<E, A, Either<E, A>>(
  block,
  onRaise: (error) => Left(error),
  onValue: (value) => Right(value),
  onThrow: (thrown, stackTrace) => Left(onThrow(thrown, stackTrace)),
);

/// Async twin of [eitherCatching].
Future<Either<E, A>> eitherCatchingAsync<E, A>(
  FutureOr<A> Function(Raise<E> r) block,
  FutureOr<E> Function(Object thrown, StackTrace stackTrace) onThrow,
) => foldRaiseAsync<E, A, Either<E, A>>(
  block,
  onRaise: (error) => Left(error),
  onValue: (value) => Right(value),
  onThrow: (thrown, stackTrace) async =>
      Left(await onThrow(thrown, stackTrace)),
);

/// The info-free raise scope used by [nullable] — the port of Arrow's
/// `SingletonRaise` (errors carry no information).
final class SingletonRaise implements Raise<void> {
  SingletonRaise._(this._raise);

  final Raise<void> _raise;

  /// Short-circuits with no error value.
  Never none() => _raise.raise(null);

  @override
  Never raise([void error]) => none();

  /// Short-circuits unless [condition] holds.
  void ensure(bool condition) {
    if (!condition) none();
  }

  /// Returns [value] non-null, or short-circuits.
  A ensureNotNull<A>(A? value) => value ?? none();

  /// Unwraps a nullable, short-circuiting on `null`.
  A bind<A>(A? value) => value ?? none();
}

/// Runs [block] in an info-free raise scope; a raise becomes `null`.
///
/// Port of Arrow's `nullable { }` — the nullable-first alternative to an
/// `Option` type (`T?` is fxdart's absence channel).
///
/// ```dart
/// final total = nullable((r) {
///   final a = r.bind(int.tryParse(x));
///   final b = r.bind(int.tryParse(y));
///   return a + b;
/// }); // int? — null if either parse failed
/// ```
A? nullable<A>(A Function(SingletonRaise r) block) => foldRaise<void, A, A?>(
  (r) => block(SingletonRaise._(r)),
  onRaise: (_) => null,
  onValue: (value) => value,
);

/// Async twin of [nullable].
Future<A?> nullableAsync<A>(FutureOr<A> Function(SingletonRaise r) block) =>
    foldRaiseAsync<void, A, A?>(
      (r) => block(SingletonRaise._(r)),
      onRaise: (_) => null,
      onValue: (value) => value,
    );

/// Runs [block]; a thrown exception is handed to [onError]. The library's
/// own raise signal is ALWAYS rethrown first — this is the sanctioned
/// replacement for a bare `catch` inside raise scopes (the port of Arrow's
/// `catch` + `nonFatalOrThrow` discipline; `catch` is a Dart reserved word,
/// hence `catching`).
A catching<A>(
  A Function() block,
  A Function(Object error, StackTrace stackTrace) onError,
) {
  try {
    return block();
  } on _RaiseSignal {
    rethrow;
  } catch (error, stackTrace) {
    return onError(error, stackTrace);
  }
}

/// Async twin of [catching].
Future<A> catchingAsync<A>(
  FutureOr<A> Function() block,
  FutureOr<A> Function(Object error, StackTrace stackTrace) onError,
) async {
  try {
    return await block();
  } on _RaiseSignal {
    rethrow;
  } catch (error, stackTrace) {
    return await onError(error, stackTrace);
  }
}

/// The scope API — everything you do with the `r` a builder hands you.
/// Scope-first by design: type `r.` and discover the whole vocabulary.
extension RaiseOps<E> on Raise<E> {
  /// Unwraps [either], raising its [Left].
  A bind<A>(Either<E, A> either) => switch (either) {
    Left(:final value) => raise(value),
    Right(:final value) => value,
  };

  /// Unwraps every element, raising the first [Left].
  List<A> bindAll<A>(Iterable<Either<E, A>> eithers) => [
    for (final e in eithers) bind(e),
  ];

  /// Raises [error] unless [condition] holds — the typed-error `require`.
  void ensure(bool condition, E Function() error) {
    if (!condition) raise(error());
  }

  /// Returns [value] non-null, or raises [error] — the typed-error
  /// `requireNotNull`, with promotion via the non-null return type.
  A ensureNotNull<A>(A? value, E Function() error) => value ?? raise(error());

  /// Runs [block] in a nested scope; a raised error is handed to [onRaise]
  /// instead of propagating.
  ///
  /// Thrown exceptions propagate unless [onThrow] is given, which completes
  /// Arrow 2.x's three-clause `recover(block, recover, catch)`. The raise
  /// signal itself is never handed to [onThrow] — this scope's raise goes to
  /// [onRaise], a foreign scope's signal is rethrown untouched.
  A recover<A>(
    A Function(Raise<E> r) block,
    A Function(E error) onRaise, {
    A Function(Object thrown, StackTrace stackTrace)? onThrow,
  }) => foldRaise<E, A, A>(
    block,
    onRaise: onRaise,
    onValue: (value) => value,
    onThrow: onThrow,
  );

  /// Runs [block] in a scope with a DIFFERENT error type `E2`, mapping any
  /// raised `E2` into this scope's `E` via [transform] — the error-type
  /// adapter (port of Arrow's `withError`).
  A withError<E2, A>(
    E Function(E2 error) transform,
    A Function(Raise<E2> r) block,
  ) => foldRaise<E2, A, A>(
    block,
    onRaise: (error) => raise(transform(error)),
    onValue: (value) => value,
  );
}
