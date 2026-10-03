import 'package:fxdart/fxdart.dart';

void main() {
  final map = fxFromEntries([('a', 1), ('a', 2), ('b', 3)]);
  print(map); // {a: 2, b: 3} — later entries win when keys repeat

  final source = {'name': 'kim', 'age': 32, 'city': 'seoul'};
  final onlyStrings =
      fxFromEntries(fxFilter((e) => e.$2 is String, fxEntries(source)));
  print(onlyStrings); // {name: kim, city: seoul}
}
