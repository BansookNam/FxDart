import 'package:fxdart/fxdart.dart';

Either<String, int> half(int n) =>
    n.isEven ? Right(n ~/ 2) : Left('$n is odd');

void main() {
  print(half(10)); // Right(5)
  print(half(7)); // Left(7 is odd)

  // Either is sealed — switching over it is exhaustive, no default arm:
  switch (half(10)) {
    case Right(:final value):
      print('ok: $value');
    case Left(:final value):
      print('failed: $value');
  }

  // Bridges out of the Either world:
  print(half(7).getOrNull()); // null
  print(half(7).getOrElse((left) => 0)); // 0
  print(half(10).isRight); // true
}
