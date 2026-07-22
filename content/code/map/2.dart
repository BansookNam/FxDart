import 'package:fxdart/fxdart.dart';

void main() {
  final people = [
    {'name': 'kim', 'age': 32},
    {'name': 'lee', 'age': 27},
    {'name': 'park', 'age': 41},
  ];

  // TODO: map each person to '<NAME IN UPPERCASE> (<age>)'
  final labels = fx(people).map((p) => '$p').toList();

  labels.forEach(print);
}
