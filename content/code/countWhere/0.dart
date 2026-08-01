import 'package:fxdart/fxdart.dart';

void main() {
  final amounts = [12.5, 89.0, 5.0, 120.0, 42.0, 7.5];

  // One walk, one number:
  print(fx(amounts).countWhere((a) => a > 40)); // 3

  // was: fx(amounts).filter((a) => a > 40).size()

  // Data-first form:
  print(countWhere((int n) => n.isEven, [1, 2, 3, 4, 5, 6])); // 3

  // Empty input and no matches are both just 0:
  print(countWhere((int n) => n > 9, <int>[])); // 0
  print(countWhere((int n) => n > 9, [1, 2])); // 0
}
