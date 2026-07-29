import 'package:fxdart/fxdart.dart';

Either<String, int> parsePort(String raw) => either((r) {
  final n = r.ensureNotNull(int.tryParse(raw), () => '"$raw" is not a number');
  r.ensure(n > 0 && n < 65536, () => '$n is out of range');
  return n;
});

void main() {
  print(parsePort('8080')); // Right(8080)
  print(parsePort('abc')); // Left("abc" is not a number)
  print(parsePort('99999')); // Left(99999 is out of range)
}
