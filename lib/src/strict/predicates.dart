/// Type/value predicates ported from FxTS. Several of them exist only for
/// API parity — in Dart, prefer `is` checks and pattern matching. They stay
/// useful as tear-offs for `filter`, `takeWhile`, etc.
library;

/// True when [a] is `null`.
///
/// Port of FxTS `fxIsNull`.
bool fxIsNull(Object? a) => a == null;

/// True when [a] is not `null`.
bool isNotNull(Object? a) => a != null;

/// Port of FxTS `fxIsNil` (`null` or `undefined`). Dart has no `undefined`,
/// so this is exactly [fxIsNull].
bool fxIsNil(Object? a) => a == null;

/// Exactly [fxIsNull]: TypeScript distinguishes `undefined` from `null`, Dart
/// has only `null`. Kept so ported FxTS code still compiles.
@Deprecated('Dart has no undefined; use isNull instead')
bool fxIsUndefined(Object? a) => a == null;

/// True when [a] is a [bool]. Port of FxTS `fxIsBoolean` (Dart type: `bool`).
bool fxIsBool(Object? a) => a is bool;

/// FxTS-named alias of [fxIsBool].
bool fxIsBoolean(Object? a) => fxIsBool(a);

/// True when [a] is a [num]. Port of FxTS `fxIsNumber` (Dart type: `num`).
bool fxIsNum(Object? a) => a is num;

/// FxTS-named alias of [fxIsNum].
bool fxIsNumber(Object? a) => fxIsNum(a);

/// True when [a] is a [String]. Port of FxTS `fxIsString`.
bool fxIsString(Object? a) => a is String;

/// True when [a] is a [DateTime]. Port of FxTS `fxIsDate` (Dart type: `DateTime`).
bool isDateTime(Object? a) => a is DateTime;

/// FxTS-named alias of [isDateTime].
bool fxIsDate(Object? a) => isDateTime(a);

/// True when [a] is a [List]. Port of FxTS `fxIsArray`.
bool fxIsList(Object? a) => a is List;

/// True when [a] is a [List] — JavaScript's `Array` is Dart's [List], so
/// this is an alias of [fxIsList] under the FxTS name.
@Deprecated('Use isList instead')
bool fxIsArray(Object? a) => a is List;

/// True when [a] is a [Map]. The closest analogue of FxTS `fxIsObject`
/// (`typeof a === "object"`), whose plain-JS-object semantics do not exist
/// in Dart.
bool fxIsMap(Object? a) => a is Map;

/// True when [a] is a [Map] — JavaScript's plain objects are Dart's [Map]s,
/// so this is an alias of [fxIsMap] under the FxTS name.
@Deprecated('Use isMap instead')
bool fxIsObject(Object? a) => a is Map;

/// Combinators on a unary predicate, so conditions passed to `filter`,
/// `reject`, `takeWhile`, `dropWhile`, ... can be built from named pieces
/// instead of nested lambdas.
///
/// Not an FxTS port — TypeScript composes predicates with `&&` inside an
/// arrow function and keeps the types through inference. In Dart the same
/// thing costs a lambda per combination, so the operators are worth naming.
///
/// ```dart
/// bool isEven(int n) => n % 2 == 0;
/// bool isPositive(int n) => n > 0;
///
/// fx([-4, -3, 2, 3, 4]).filter(isEven.and(isPositive)).toList(); // [2, 4]
/// ```
///
/// Every combinator returns a new predicate and calls neither operand until
/// that predicate runs; [and] and [or] short-circuit exactly like `&&`/`||`.
extension FxPredicateOps<T> on bool Function(T) {
  /// The logical opposite of this predicate.
  ///
  /// The extension-getter form of the top-level `fxNegate` — `isEven.negate`
  /// and `fxNegate(isEven)` are the same function.
  bool Function(T) get negate =>
      (a) => !this(a);

  /// True when both this predicate and [other] hold. [other] is not called
  /// when this one already fails.
  bool Function(T) and(bool Function(T a) other) =>
      (a) => this(a) && other(a);

  /// True when this predicate or [other] holds. [other] is not called when
  /// this one already succeeds.
  bool Function(T) or(bool Function(T a) other) =>
      (a) => this(a) || other(a);

  /// True when exactly one of this predicate and [other] holds. Both are
  /// always called — there is nothing to short-circuit.
  bool Function(T) xor(bool Function(T a) other) =>
      (a) => this(a) ^ other(a);

  /// Moves this predicate onto a different input type by running [f] first
  /// — `map` for the *argument* rather than the result, which is why it is
  /// *contra*map.
  ///
  /// ```dart
  /// final hasEvenLength = isEven.contramap<String>((s) => s.length);
  /// hasEvenLength('abcd'); // true
  /// ```
  bool Function(A) contramap<A>(T Function(A a) f) =>
      (a) => this(f(a));
}
