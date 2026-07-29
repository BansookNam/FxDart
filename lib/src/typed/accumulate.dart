import 'either.dart';
import 'non_empty_list.dart';
import 'raise.dart';

/// A lazily-detonating box returned by [Accumulate.accumulating] — the port
/// of Arrow's `Value<A>` trick.
///
/// If the branch succeeded, [value] is the result. If it (or any sibling)
/// failed, reading [value] *raises the full accumulated error list* to the
/// enclosing scope. Run all branches first, read values at the end:
///
/// ```dart
/// final user = either<Nel<String>, User>((r) => r.accumulate((acc) {
///   final name = acc.accumulating((r) => validateName(r, input));
///   final age  = acc.accumulating((r) => validateAge(r, input));
///   return User(name.value, age.value); // detonates here if anything failed
/// }));
/// ```
sealed class AccValue<A> {
  /// The branch result — raises the accumulated errors when the branch (or a
  /// sibling) failed.
  A get value;
}

final class _AccOk<A> implements AccValue<A> {
  _AccOk(this.value);

  @override
  final A value;
}

final class _AccErr<A> implements AccValue<A> {
  _AccErr(this._raiseAll);

  final Never Function() _raiseAll;

  // A getter, never an eager field: detonation must stay lazy (Arrow's own
  // implementation carries the same warning).
  @override
  A get value => _raiseAll();
}

/// The accumulating scope handed to [RaiseAccumulateOps.accumulate] —
/// collects errors across independent branches instead of failing fast.
abstract interface class Accumulate<E> {
  /// Runs [block] as an independent branch: a raise inside it is recorded
  /// (not propagated) and an errored [AccValue] is returned.
  AccValue<A> accumulating<A>(A Function(RaiseAccumulate<E> r) block);

  /// Whether any branch has failed so far.
  bool get hasErrors;
}

/// A [Raise] whose errors join a [NonEmptyList] accumulator — what
/// accumulating branches receive, so one branch can contribute *multiple*
/// errors (faithful to Arrow: branches get `RaiseAccumulate`, not bare
/// `Raise`).
abstract interface class RaiseAccumulate<E> implements Raise<E> {
  /// Views a `Raise<NonEmptyList<E>>` as a single-error scope whose raises
  /// are wrapped into singleton lists.
  factory RaiseAccumulate.over(Raise<NonEmptyList<E>> raise) =
      _RaiseAccumulateImpl<E>;

  /// Unwraps an [EitherNel], raising ALL of its errors at once.
  A bindNel<A>(EitherNel<E, A> either);

  /// Nested accumulation over [items]; all errors join this branch's raise.
  List<B> mapOrAccumulate<A, B>(
      Iterable<A> items, B Function(RaiseAccumulate<E> r, A item) transform);
}

final class _RaiseAccumulateImpl<E> implements RaiseAccumulate<E> {
  _RaiseAccumulateImpl(this._nel);

  final Raise<NonEmptyList<E>> _nel;

  @override
  Never raise(E error) => _nel.raise(NonEmptyList.of(error));

  @override
  A bindNel<A>(EitherNel<E, A> either) => _nel.bindNel(either);

  @override
  List<B> mapOrAccumulate<A, B>(Iterable<A> items,
          B Function(RaiseAccumulate<E> r, A item) transform) =>
      _nel.mapOrAccumulate(items, transform);
}

final class _Accumulator<E> implements Accumulate<E> {
  _Accumulator(this._outer);

  final Raise<NonEmptyList<E>> _outer;
  final List<E> _errors = [];

  @override
  bool get hasErrors => _errors.isNotEmpty;

  Never _raiseAll() => _outer.raise(NonEmptyList.orNull(_errors)!);

  @override
  AccValue<A> accumulating<A>(A Function(RaiseAccumulate<E> r) block) =>
      foldRaise<NonEmptyList<E>, A, AccValue<A>>(
        (r) => block(_RaiseAccumulateImpl(r)),
        onRaise: (errors) {
          _errors.addAll(errors);
          return _AccErr<A>(_raiseAll);
        },
        onValue: (value) => _AccOk(value),
      );
}

/// The accumulation vocabulary, available on any `Raise<NonEmptyList<E>>`
/// scope (i.e. inside `either<Nel<E>, _>(...)`) — the Arrow 2.x replacement
/// for a `Validated` type.
///
/// Contract (copied from Arrow's `RaiseAccumulate`):
/// 1. independent branches all run; errors concatenate in branch order;
/// 2. after the first error, successful results are no longer retained —
///    but iteration continues so ALL errors are collected;
/// 3. reading an errored [AccValue.value] raises the accumulated list;
/// 4. [accumulate] raises at end-of-block whenever errors exist, even if no
///    `.value` was ever read;
/// 5. a branch that *throws* (rather than raises) wins over accumulation —
///    the exception propagates out of the builder.
extension RaiseAccumulateOps<E> on Raise<NonEmptyList<E>> {
  /// Opens an accumulating scope: run branches via
  /// [Accumulate.accumulating], then combine their [AccValue.value]s.
  R accumulate<R>(R Function(Accumulate<E> acc) block) {
    final acc = _Accumulator<E>(this);
    final result = block(acc);
    if (acc.hasErrors) acc._raiseAll();
    return result;
  }

  /// Unwraps an [EitherNel], raising ALL of its errors at once.
  A bindNel<A>(EitherNel<E, A> either) => switch (either) {
        Left(:final value) => raise(value),
        Right(:final value) => value,
      };

  /// Transforms every element of [items], collecting ALL failures instead
  /// of stopping at the first (fail-slow). Returns the transformed list, or
  /// raises every accumulated error.
  List<B> mapOrAccumulate<A, B>(
      Iterable<A> items, B Function(RaiseAccumulate<E> r, A item) transform) {
    final errors = <E>[];
    final results = <B>[];
    for (final item in items) {
      foldRaise<NonEmptyList<E>, B, void>(
        (r) => transform(_RaiseAccumulateImpl(r), item),
        onRaise: (nel) => errors.addAll(nel),
        onValue: (result) {
          if (errors.isEmpty) results.add(result);
        },
      );
    }
    if (errors.isNotEmpty) raise(NonEmptyList.orNull(errors)!);
    return results;
  }

  /// Runs 2 independent branches, accumulating failures, then combines the
  /// successes. Arity capped at 5, like `Curry2..Curry5` — beyond that, use
  /// [accumulate].
  R zipOrAccumulate2<A, B, R>(
    A Function(RaiseAccumulate<E> r) fa,
    B Function(RaiseAccumulate<E> r) fb,
    R Function(A a, B b) combine,
  ) =>
      accumulate((acc) {
        final a = acc.accumulating(fa);
        final b = acc.accumulating(fb);
        return combine(a.value, b.value);
      });

  /// 3-ary [zipOrAccumulate2].
  R zipOrAccumulate3<A, B, C, R>(
    A Function(RaiseAccumulate<E> r) fa,
    B Function(RaiseAccumulate<E> r) fb,
    C Function(RaiseAccumulate<E> r) fc,
    R Function(A a, B b, C c) combine,
  ) =>
      accumulate((acc) {
        final a = acc.accumulating(fa);
        final b = acc.accumulating(fb);
        final c = acc.accumulating(fc);
        return combine(a.value, b.value, c.value);
      });

  /// 4-ary [zipOrAccumulate2].
  R zipOrAccumulate4<A, B, C, D, R>(
    A Function(RaiseAccumulate<E> r) fa,
    B Function(RaiseAccumulate<E> r) fb,
    C Function(RaiseAccumulate<E> r) fc,
    D Function(RaiseAccumulate<E> r) fd,
    R Function(A a, B b, C c, D d) combine,
  ) =>
      accumulate((acc) {
        final a = acc.accumulating(fa);
        final b = acc.accumulating(fb);
        final c = acc.accumulating(fc);
        final d = acc.accumulating(fd);
        return combine(a.value, b.value, c.value, d.value);
      });

  /// 5-ary [zipOrAccumulate2].
  R zipOrAccumulate5<A, B, C, D, F, R>(
    A Function(RaiseAccumulate<E> r) fa,
    B Function(RaiseAccumulate<E> r) fb,
    C Function(RaiseAccumulate<E> r) fc,
    D Function(RaiseAccumulate<E> r) fd,
    F Function(RaiseAccumulate<E> r) ff,
    R Function(A a, B b, C c, D d, F f) combine,
  ) =>
      accumulate((acc) {
        final a = acc.accumulating(fa);
        final b = acc.accumulating(fb);
        final c = acc.accumulating(fc);
        final d = acc.accumulating(fd);
        final f = acc.accumulating(ff);
        return combine(a.value, b.value, c.value, d.value, f.value);
      });
}
