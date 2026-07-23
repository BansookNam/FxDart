/// Dart-idiomatic currying: the `.curried` / `.uncurried` extension getters.
///
/// FxTS's `curry` cannot be ported as a function — it relies on runtime arity
/// reflection and recursive conditional types, neither of which exists in
/// Dart. Instead, one extension per arity is declared under the same getter
/// name, and the compiler picks the right one from the function's *static*
/// type. Full design rationale: `WHY_CURRIED.md` at the repository root.
///
/// ```dart
/// int add(int a, int b) => a + b;
/// final addOne = add.curried(1); // int Function(int)
/// addOne(2); // 3
/// ```
library;

/// Curries a binary function: `f.curried(a)(b) == f(a, b)`.
///
/// Dart-native replacement for FxTS `curry` (see `WHY_CURRIED.md`).
extension Curry2<A, B, R> on R Function(A, B) {
  /// The curried form: `f.curried(a)(b) == f(a, b)`.
  R Function(B) Function(A) get curried => (a) => (b) => this(a, b);
}

/// Curries a ternary function: `f.curried(a)(b)(c) == f(a, b, c)`.
extension Curry3<A, B, C, R> on R Function(A, B, C) {
  /// The curried form: `f.curried(a)(b)(c) == f(a, b, c)`.
  R Function(C) Function(B) Function(A) get curried =>
      (a) => (b) => (c) => this(a, b, c);
}

/// Curries a 4-ary function.
extension Curry4<A, B, C, D, R> on R Function(A, B, C, D) {
  /// The curried form: `f.curried(a)(b)(c)(d) == f(a, b, c, d)`.
  R Function(D) Function(C) Function(B) Function(A) get curried =>
      (a) => (b) => (c) => (d) => this(a, b, c, d);
}

/// Curries a 5-ary function.
extension Curry5<A, B, C, D, E, R> on R Function(A, B, C, D, E) {
  /// The curried form: `f.curried(a)(b)(c)(d)(e) == f(a, b, c, d, e)`.
  R Function(E) Function(D) Function(C) Function(B) Function(A) get curried =>
      (a) => (b) => (c) => (d) => (e) => this(a, b, c, d, e);
}

/// Uncurries a 2-level function chain: `f.uncurried(a, b) == f(a)(b)`.
///
/// When the chain is nested deeper, the *deepest* matching arity wins; apply
/// an extension explicitly (`Uncurry2(f).uncurried`) to flatten fewer levels.
extension Uncurry2<A, B, R> on R Function(B) Function(A) {
  /// The flattened form: `f.uncurried(a, b) == f(a)(b)`.
  R Function(A, B) get uncurried => (a, b) => this(a)(b);
}

/// Uncurries a 3-level function chain.
extension Uncurry3<A, B, C, R> on R Function(C) Function(B) Function(A) {
  /// The flattened form: `f.uncurried(a, b, c) == f(a)(b)(c)`.
  R Function(A, B, C) get uncurried => (a, b, c) => this(a)(b)(c);
}

/// Uncurries a 4-level function chain.
extension Uncurry4<A, B, C, D, R>
    on R Function(D) Function(C) Function(B) Function(A) {
  /// The flattened form: `f.uncurried(a, b, c, d) == f(a)(b)(c)(d)`.
  R Function(A, B, C, D) get uncurried => (a, b, c, d) => this(a)(b)(c)(d);
}

/// Uncurries a 5-level function chain.
extension Uncurry5<A, B, C, D, E, R>
    on R Function(E) Function(D) Function(C) Function(B) Function(A) {
  /// The flattened form: `f.uncurried(a, b, c, d, e) == f(a)(b)(c)(d)(e)`.
  R Function(A, B, C, D, E) get uncurried =>
      (a, b, c, d, e) => this(a)(b)(c)(d)(e);
}
