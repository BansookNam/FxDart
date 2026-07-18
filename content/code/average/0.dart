import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form:
  print(average([2, 4, 6, 8])); // 5.0

  // Empty iterable averages to NaN (0/0), not 0 or an error:
  print(average(<num>[])); // NaN

  // Chain form:
  final avg = fx([1, 2, 3, 4, 5]).filter((a) => a > 2).average();
  print(avg); // 4.0
}
