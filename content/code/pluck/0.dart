import 'package:fxdart/fxdart.dart';

void main() {
  final people = [
    {'name': 'kim', 'age': 32},
    {'name': 'lee', 'age': 27},
  ];

  // Data-first form. Note the result type: Iterable<Object?> here because
  // the maps mix String and int values -- pluck can't know a key is always
  // present, so missing keys become null rather than throwing.
  print(toList(pluck('name', people))); // [kim, lee]

  final missing = [
    {'name': 'kim'},
    <String, String>{},
  ];
  print(toList(pluck('name', missing))); // [kim, null]

  // No chain method exists for pluck -- use the data-first form inside
  // a chain via `.to(...)`, or call it directly on the source list.
  final ages = pluck('age', people);
  print(toList(ages)); // [32, 27]
}
