import 'package:fxdart/fxdart.dart';

Either<String, int> parse(String s) => either(
    (r) => r.ensureNotNull(int.tryParse(s), () => '"$s" is not a number'));

void main() {
  // sequence(): all-or-nothing. Every success collected into one list…
  print(fx(['1', '2', '3']).map(parse).sequence()); // Right([1, 2, 3])

  // …failing FAST on the first Left. The pipeline is lazy, so it stops
  // pulling: '3' is never even parsed (watch the peek log).
  final result = fx(['1', 'x', '3'])
      .peek((s) => print('parsing $s'))
      .map(parse)
      .sequence();
  print(result); // parsing 1 / parsing x — then Left("x" is not a number)
}
