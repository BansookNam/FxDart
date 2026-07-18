import 'package:fxdart/fxdart.dart';

void main() {
  final people = [
    {'name': 'kim', 'age': 32},
    {'name': 'lee', 'age': 27},
    {'name': 'park', 'age': 41},
  ];

  // Data-first form: key extractor, then the iterable. Ascending, and never
  // mutates the input (same NEW-list guarantee as sort).
  final byAge = sortBy((p) => p['age'], people);
  print(byAge.map((p) => p['name']).toList()); // [lee, kim, park]

  // Chain form:
  final byName = fx(people).sortBy((p) => p['name']).toArray();
  print(byName.map((p) => p['name']).toList()); // [kim, lee, park]
}
