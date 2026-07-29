import 'package:fxdart/fxdart.dart';

// Dart 3.10 dot shorthands: wherever the context type is Either, the
// Either.left / Either.right factories resolve without naming the type.
Either<String, int> parsePositive(String s) {
  final n = int.tryParse(s);
  if (n == null) return .left('not a number: "$s"');
  if (n <= 0) return .left('not positive: $s');
  return .right(n);
}

// Switch-expression arms inherit the return type as context, so the
// shorthand works there too:
Either<String, int> doubled(Either<String, int> e) => switch (e) {
      Left(:final value) => .left(value),
      Right(:final value) => .right(value * 2),
    };

void main() {
  print(parsePositive('21')); // Right(21)
  print(parsePositive('-3')); // Left(not positive: -3)
  print(parsePositive('abc')); // Left(not a number: "abc")

  print(doubled(parsePositive('21'))); // Right(42)

  // Even == comparisons: the left operand's static type is the context.
  print(parsePositive('3') == .right(3)); // true
}
