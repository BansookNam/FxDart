import 'package:fxdart/fxdart.dart';

void main() {
  final users = [
    {'name': 'kim', 'age': 32},
    {'name': 'lee', 'age': 27},
  ];

  final names = fx(users).map((u) => fxProp('name', u)).toList();
  print(names); // [kim, lee]

  print(fxPluck('name', users).toList()); // [kim, lee] — same result, one call
}
