import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

// Exercises what a >=3.10 language floor buys fxdart users, feature by feature.

// Dart 3.10 dot shorthands: the context type (Either) supplies .left/.right.
Either<String, int> parsePositive(String s) {
  final n = int.tryParse(s);
  if (n == null) return .left('not a number: $s');
  if (n <= 0) return .left('not positive: $s');
  return .right(n);
}

// Dot shorthands inside a switch expression — arms get the return context.
Either<String, int> doubled(Either<String, int> e) => switch (e) {
  Left(:final value) => .left(value),
  Right(:final value) => .right(value * 2),
};

// Dart 3.7 wildcards: `_` is non-binding, so it can repeat in one signature.
int arity3(int Function(int _, int _, int _) f) => f(1, 2, 3);

void main() {
  test('dot shorthands build Left/Right via Either factories', () {
    expect(parsePositive('42'), Right<String, int>(42));
    expect(parsePositive('-1'), Left<String, int>('not positive: -1'));
    expect(doubled(parsePositive('21')), Right<String, int>(42));
  });

  test('dot shorthand == comparison', () {
    // Shorthand on the RHS of == resolves against the LHS static type.
    final e = parsePositive('3');
    expect(e == .right(3), isTrue);
  });

  test('null-aware elements (3.8) power compactObject without casts', () {
    expect(compactObject({'a': 1, 'b': null, 'c': 3}), {'a': 1, 'c': 3});
    // And in user code: collection literals drop null inline.
    int? missing;
    expect([1, ?missing, 3], [1, 3]);
  });

  test('digit separators (3.6) in literals', () {
    expect(1_000_000, 1000000);
  });

  test('repeated wildcard params (3.7)', () {
    expect(arity3((_, _, _) => 7), 7);
  });
}
