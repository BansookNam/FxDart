import 'package:fxdart/fxdart.dart';

void main() {
  final mixed = <Object?>[1, 'two', null, true, 3.5, DateTime(2024), [1, 2], {'a': 1}];

  print(fxFilter(fxIsNum, mixed).toList());  // [1, 3.5]
  print(fxFilter(fxIsString, mixed).toList());  // [two]
  print(fxFilter(fxIsNull, mixed).toList());    // [null]
  print(fxFilter(isNotNull, mixed).toList()); // [1, two, true, 3.5, 2024-01-01 00:00:00.000, [1, 2], {a: 1}]
  print(fxFilter(fxIsBool, mixed).toList()); // [true]
  print(fxFilter(isDateTime, mixed).toList());    // [2024-01-01 00:00:00.000]
  print(fxFilter(fxIsList, mixed).toList());    // [[1, 2]]
  print(fxFilter(fxIsMap, mixed).toList());     // [{a: 1}]
}
