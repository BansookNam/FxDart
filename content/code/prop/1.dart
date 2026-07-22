import 'package:fxdart/fxdart.dart';

void main() {
  final users = [
    {'name': 'kim', 'age': 32},
    {'name': 'lee', 'age': 27},
  ];

  final names = fx(users).map((u) => prop('name', u)).toList();
  print(names); // [kim, lee]

  print(pluck('name', users).toList()); // [kim, lee] — same result, one call
}
