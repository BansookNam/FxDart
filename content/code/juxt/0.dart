import 'package:fxdart/fxdart.dart';

void main() {
  final bounds = fxJuxt([fxMin, fxMax]);
  print(bounds([3, 4, 9, 1])); // [1, 9]
}
