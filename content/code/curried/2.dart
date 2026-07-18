import 'package:fxdart/fxdart.dart';

int add3(int a, int b, int c) => a + b + c;

void main() {
  // A hand-written 2-level closure, flattened.
  final greet = (String greeting) => (String name) => '$greeting, $name!';
  print(greet.uncurried('Hello', 'FxDart')); // Hello, FxDart!

  // Round trip: the deepest matching arity wins, so the whole chain flattens.
  print(add3.curried.uncurried(1, 2, 3)); // 6

  // Explicit extension application flattens fewer levels.
  final partial = Uncurry2(add3.curried).uncurried; // (a, b) => c => int
  print(partial(1, 2)(3)); // 6
}
