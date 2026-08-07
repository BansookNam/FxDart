import 'package:fxdart/fxdart.dart';

Either<String, int> parseAge(String s) {
  final n = int.tryParse(s);
  return n == null ? Left('not a number: $s') : Right(n);
}

void main() {
  // TODO: reject an age outside 0..149, with a message of your own.
  final age = parseAge('200')
      .filterOrElse((n) => n >= 0, (n) => 'age cannot be $n')
      .filterOrElse((n) => n < 150, (n) => 'age $n is implausible');

  print(age); // Left(age 200 is implausible)
}
