import 'dart:async';

/// Adds two values. Works for any type supporting `+` ([num], [String],
/// [List], ...) — mirrors FxTS `add`, which accepts numbers and strings.
T add<T extends Object>(T a, T b) => (a as dynamic) + b as T;

/// Returns a function that always returns [a], ignoring an optional
/// argument (so it can be used as a unary callback).
///
/// Port of FxTS `always`.
T Function([Object? _]) always<T>(T a) => ([Object? _]) => a;

/// Calls [f] with [args] as positional arguments.
///
/// Port of FxTS `apply`.
R apply<R>(Function f, List<Object?> args) => Function.apply(f, args) as R;

/// Returns its argument unchanged.
///
/// Port of FxTS `identity`.
T identity<T>(T a) => a;

/// Does nothing.
///
/// Port of FxTS `noop`.
void noop() {}

/// Boolean negation.
///
/// Port of FxTS `not` (Dart has no truthiness, so this takes a [bool]).
bool not(bool a) => !a;

/// Returns a predicate that negates [f].
///
/// Port of FxTS `negate`.
bool Function(T) negate<T>(bool Function(T) f) => (a) => !f(a);

/// Calls [f] with [a] for its side effect, then returns [a].
///
/// Port of FxTS `tap` (data-first; close over [f] for the curried style).
T tap<T>(void Function(T a) f, T a) {
  f(a);
  return a;
}

/// Returns `callback(value)` when the predicate holds, otherwise [value].
///
/// Port of FxTS `when`. TS can widen the return union `T | R`; in Dart both
/// branches must share the type [T].
T when<T>(bool Function(T) predicate, T Function(T) callback, T value) =>
    predicate(value) ? callback(value) : value;

/// The opposite of [when]: applies [callback] when the predicate fails.
///
/// Port of FxTS `unless`.
T unless<T>(bool Function(T) predicate, T Function(T) callback, T value) =>
    predicate(value) ? value : callback(value);

/// Returns a unary function that throws `toError(value)`.
///
/// Port of FxTS `throwError`.
Never Function(T) throwError<T>(Object Function(T) toError) =>
    (a) => throw toError(a);

/// Throws `toError(value)` when the predicate holds; otherwise returns
/// [value] unchanged.
///
/// Port of FxTS `throwIf`.
T throwIf<T>(bool Function(T) predicate, Object Function(T) toError, T value) {
  if (predicate(value)) throw toError(value);
  return value;
}

int _compare(Object? a, Object? b) {
  if (a is Comparable && b is Comparable) {
    if (a.runtimeType != b.runtimeType &&
        !(a is num && b is num) &&
        !(a is String && b is String)) {
      throw ArgumentError(
          'The values you want to compare must be of the same type');
    }
    return Comparable.compare(
        a as Comparable<Object?>, b as Comparable<Object?>);
  }
  throw ArgumentError('The values must be Comparable');
}

/// `a > b`. Port of FxTS `gt` (data-first; use a closure for currying:
/// `(b) => gt(5, b)`).
bool gt(Object? a, Object? b) => _compare(a, b) > 0;

/// `a >= b`. Port of FxTS `gte`.
bool gte(Object? a, Object? b) => _compare(a, b) >= 0;

/// `a < b`. Port of FxTS `lt`.
bool lt(Object? a, Object? b) => _compare(a, b) < 0;

/// `a <= b`. Port of FxTS `lte`.
bool lte(Object? a, Object? b) => _compare(a, b) <= 0;

/// Applies every function in [fns] to [a] and collects the results.
///
/// Port of FxTS `juxt` (unary form — Dart has no variadic generics).
///
/// ```dart
/// juxt([min, max])([3, 4, 9, 1]); // [1, 9]
/// ```
List<R> Function(T a) juxt<T, R>(List<R Function(T a)> fns) =>
    (a) => [for (final f in fns) f(a)];

/// Memoizes a unary function by its argument (`==`/`hashCode` keyed).
///
/// Port of FxTS `memoize` (unary only; TS's variadic/`WeakMap` behavior has
/// no Dart equivalent).
R Function(A) memoize<A, R>(R Function(A) f) {
  final cache = <A, R>{};
  return (a) => cache.putIfAbsent(a, () => f(a));
}

/// Returns a [Future] that completes with [value] after [wait].
///
/// Port of FxTS `delay`.
///
/// ```dart
/// await delay(Duration(seconds: 1), 'a'); // 'a' after 1s
/// ```
Future<T> delay<T>(Duration wait, T value) => Future.delayed(wait, () => value);

/// Returns a [Future] that completes after [wait].
Future<void> sleep(Duration wait) => Future.delayed(wait);

/// Builds a matcher from `predicate, mapper` pairs with an optional
/// default. When nothing matches and no [orElse] is given, the value itself
/// is returned (it must then be an `R`).
///
/// Port of FxTS `cases`; Dart cannot type variadic pairs, so they are passed
/// as records.
///
/// ```dart
/// final classify = cases<int, String>([
///   ((n) => n < 0, (n) => 'negative'),
///   ((n) => n == 0, (n) => 'zero'),
/// ], orElse: (n) => 'positive');
/// classify(-4); // 'negative'
/// ```
R Function(T value) cases<T, R>(List<(bool Function(T), R Function(T))> pairs,
    {R Function(T)? orElse}) {
  return (value) {
    for (final (predicate, mapper) in pairs) {
      if (predicate(value)) return mapper(value);
    }
    if (orElse != null) return orElse(value);
    if (value is R) return value;
    throw StateError('cases: no case matched and no orElse given');
  };
}

/// Splits a string into a list of user-perceived characters, handling
/// surrogate pairs — the same behavior as FxTS `unicodeToArray`, which
/// splits by code point. Named `unicodeToList` for Dart idiom (returns a List).
List<String> unicodeToList(String s) =>
    [for (final rune in s.runes) String.fromCharCode(rune)];

/// FxTS-named alias of [unicodeToList].
List<String> unicodeToArray(String s) => unicodeToList(s);

/// TypeScript's `curry` relies on reflection over a function's arity plus
/// recursive conditional types (`Curry<...>`), neither of which exists in
/// Dart. This stub only curries binary functions and is untyped. The typed,
/// Dart-native replacement is the `.curried` extension getter (arities 2–5)
/// — see `WHY_CURRIED.md`.
@Deprecated('Use the .curried extension getter instead (see WHY_CURRIED.md)')
Function curry(Function f) => (Object? a) => (Object? b) => f(a, b);
