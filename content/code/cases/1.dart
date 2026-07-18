import 'package:fxdart/fxdart.dart';

void main() {
  final grade = cases<int, String>([
    ((n) => n >= 90, (n) => 'A'),
    ((n) => n >= 80, (n) => 'B'),
    ((n) => n >= 70, (n) => 'C'),
  ], orElse: (n) => 'F');

  print(fx([95, 83, 61, 72]).map(grade).toArray()); // [A, B, F, C]
}
