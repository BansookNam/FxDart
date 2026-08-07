import 'package:fxdart/fxdart.dart';

Either<String, int> parse(String s) {
  final n = int.tryParse(s);
  return n == null ? Left('not a number: $s') : Right(n);
}

void main() {
  // Combines independent Eithers, keeping the LEFTMOST failure.
  print(parse('2').map2(parse('3'), (a, b) => a * b)); // Right(6)
  print(parse('x').map2(parse('y'), (a, b) => a * b)); // Left(not a number: x)

  print(parse('1').map3(parse('2'), parse('3'), (a, b, c) => a + b + c));
  // Right(6)
}
