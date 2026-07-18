import 'package:fxdart/fxdart.dart';

void main() {
  final people = [
    {'name': 'kim', 'dept': 'eng'},
    {'name': 'lee', 'dept': 'eng'},
    {'name': 'park', 'dept': 'sales'},
  ];

  // Data-first form: keep the first person seen from each department.
  final firstPerDept = uniqBy((p) => p['dept'], people);
  print(toArray(firstPerDept));
  // [{name: kim, dept: eng}, {name: park, dept: sales}]

  // Chain form: dedupe numbers by their remainder mod 3.
  final result = fx([1, 4, 2, 7, 9]).uniqBy((a) => a % 3).toArray();
  print(result); // [1, 2, 9]
}
