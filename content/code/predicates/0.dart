import 'package:fxdart/fxdart.dart';

void main() {
  final mixed = <Object?>[1, 'two', null, true, 3.5, DateTime(2024), [1, 2], {'a': 1}];

  print(filter(isNum, mixed).toList());  // [1, 3.5]
  print(filter(isString, mixed).toList());  // [two]
  print(filter(isNull, mixed).toList());    // [null]
  print(filter(isNotNull, mixed).toList()); // [1, two, true, 3.5, 2024-01-01 00:00:00.000, [1, 2], {a: 1}]
  print(filter(isBool, mixed).toList()); // [true]
  print(filter(isDateTime, mixed).toList());    // [2024-01-01 00:00:00.000]
  print(filter(isList, mixed).toList());    // [[1, 2]]
  print(filter(isMap, mixed).toList());     // [{a: 1}]
}
