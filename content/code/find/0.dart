import 'package:fxdart/fxdart.dart';

void main() {
  final users = [
    {'name': 'kim', 'age': 17},
    {'name': 'lee', 'age': 32},
    {'name': 'park', 'age': 45},
  ];

  final adult = firstWhereOrNull((u) => (u['age'] as int) >= 18, users);
  print(adult); // {name: lee, age: 32}

  // FxTS alias: find is the same operator.
  print(fx(users).firstWhereOrNull((u) => u['name'] == 'nobody')); // null
}
