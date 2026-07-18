import 'package:fxdart/fxdart.dart';

void main() {
  final users = [
    {'name': 'kim', 'age': 17},
    {'name': 'lee', 'age': 32},
    {'name': 'park', 'age': 45},
  ];

  final adult = find((u) => (u['age'] as int) >= 18, users);
  print(adult); // {name: lee, age: 32}

  print(fx(users).find((u) => u['name'] == 'nobody')); // null
}
