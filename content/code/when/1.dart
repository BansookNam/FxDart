import 'package:fxdart/fxdart.dart';

void main() {
  final clamped = fx([-3, 4, -1, 10])
      .map((n) => fxWhen((x) => x < 0, (x) => 0, n))
      .toList();
  print(clamped); // [0, 4, 0, 10]
}
