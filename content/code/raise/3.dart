import 'package:fxdart/fxdart.dart';

Either<String, int> checkAge(String raw) => either((r) {
  // TODO: replace int.parse with r.ensureNotNull(int.tryParse(raw), ...)
  // failing with '"$raw" is not a number', then use
  // r.ensure(age >= 18, ...) failing with 'must be an adult'.
  final age = int.parse(raw);
  return age;
});

void main() {
  print(checkAge('30')); // expect: Right(30)
  print(checkAge('12')); // expect: Left(must be an adult)
  print(checkAge('abc')); // expect: Left("abc" is not a number)
}
