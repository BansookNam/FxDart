import 'package:fxdart/fxdart.dart';

void main() {
  print(every((a) => a > 0, [1, 2, 3]));  // true
  print(every((a) => a > 0, [1, -2, 3])); // false
  print(every((a) => a > 0, <int>[]));    // true — vacuously true

  var checked = 0;
  final result = fx([1, 2, -3, 4]).peek((_) => checked++).every((a) => a > 0);
  print(result);              // false
  print('checked $checked');  // checked 3 — stopped at the first failure
}
