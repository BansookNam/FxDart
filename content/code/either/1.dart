import 'package:fxdart/fxdart.dart';

Either<String, int> parse(String s) {
  final n = int.tryParse(s);
  return n == null ? Left('"$s" is not a number') : Right(n);
}

Either<String, int> reciprocal(int n) =>
    n == 0 ? const Left('division by zero') : Right(100 ~/ n);

void main() {
  // map transforms the success; a Left passes through untouched:
  print(parse('21').map((n) => n * 2)); // Right(42)
  print(parse('x').map((n) => n * 2)); // Left("x" is not a number)

  // mapLeft transforms the failure side:
  print(parse('x').mapLeft((e) => 'parse error: $e'));

  // flatMap chains a dependent fallible step:
  print(parse('4').flatMap(reciprocal)); // Right(25)
  print(parse('0').flatMap(reciprocal)); // Left(division by zero)

  // fold collapses both sides into one value:
  final message = parse('7').fold((e) => 'bad: $e', (n) => 'good: $n');
  print(message); // good: 7
}
