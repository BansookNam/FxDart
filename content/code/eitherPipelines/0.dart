import 'package:fxdart/fxdart.dart';

Either<String, int> parse(String s) => either(
    (r) => r.ensureNotNull(int.tryParse(s), () => '"$s" is not a number'));

void main() {
  final raw = ['1', 'x', '3', 'y'];

  // A chain of Either values gets eager, Either-aware terminals:
  print(fx(raw).map(parse).rights()); // [1, 3]
  print(fx(raw).map(parse).lefts());
  // ["x" is not a number, "y" is not a number]

  // separated() splits both at once — same record shape as partition:
  final (failures, numbers) = fx(raw).map(parse).separated();
  print(numbers); // [1, 3]
  print(failures); // ["x" is not a number, "y" is not a number]
}
