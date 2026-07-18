import 'package:fxdart/fxdart.dart';

void main() {
  final bounds = juxt([min, max]);
  print(bounds([3, 4, 9, 1])); // [1, 9]
}
