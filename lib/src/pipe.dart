import 'dart:async';

/// Applies [f] to [a], awaiting [a] first when it is a [Future].
///
/// Port of FxTS `pipe1`.
FutureOr<R> pipe1<A, R>(FutureOr<A> a, FutureOr<R> Function(A a) f) {
  if (a is Future<A>) {
    return a.then(f);
  }
  return f(a);
}

dynamic _applyStep(dynamic acc, Function f) {
  if (acc is Future) {
    return acc.then((v) => f(v));
  }
  return f(acc);
}

/// Performs left-to-right function composition over a value.
///
/// Port of FxTS `pipe`. **Dart cannot type variadic composition** (no
/// overloads, no variadic generics), so this version is dynamically typed:
/// each function receives the previous result and any [Future] in the chain
/// makes the rest of the chain awaited. For fully-typed pipelines prefer the
/// `fx()` chain API.
///
/// ```dart
/// pipe([1, 2, 3, 4, 5], [
///   (Iterable<int> a) => map((n) => n + 10, a),
///   (Iterable<int> a) => filter((n) => n % 2 == 0, a),
///   toArray,
/// ]); // [12, 14]
/// ```
dynamic pipe(dynamic a, List<Function> fns) {
  dynamic acc = a;
  for (final f in fns) {
    acc = _applyStep(acc, f);
  }
  return acc;
}

/// Returns a function that pipes its argument through [fns].
///
/// Port of FxTS `pipeLazy`, with the same dynamic-typing caveat as [pipe].
dynamic Function(dynamic a) pipeLazy(List<Function> fns) => (a) => pipe(a, fns);
