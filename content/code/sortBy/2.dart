import 'package:fxdart/fxdart.dart';

void main() {
  final people = [
    {'name': 'kim', 'age': 32},
    {'name': 'lee', 'age': 27},
    {'name': 'park', 'age': 41},
  ];

  // TODO: sort the people BY AGE, youngest first.
  final sorted = sortBy((p) => p['name'], people);

  print(sorted.map((p) => p['name']).toList());
}
