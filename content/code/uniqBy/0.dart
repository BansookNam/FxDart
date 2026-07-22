import 'package:fxdart/fxdart.dart';

void main() {
  final people = [
    {'name': 'kim', 'dept': 'eng'},
    {'name': 'lee', 'dept': 'eng'},
    {'name': 'park', 'dept': 'sales'},
  ];

  // Data-first form: keep the first person seen from each department.
  final firstPerDept = distinctBy((p) => p['dept'], people);
  print(toList(firstPerDept));
  // [{name: kim, dept: eng}, {name: park, dept: sales}]
  // FxTS alias: uniqBy((p) => p['dept'], people) does the same thing.

  // Chain form: dedupe numbers by their remainder mod 3.
  final result = fx([1, 4, 2, 7, 9]).distinctBy((a) => a % 3).toList();
  print(result); // [1, 2, 9]
}
