import 'package:fxdart/fxdart.dart';

void main() {
  final people = [
    {'name': 'kim', 'age': 32},
    {'name': 'lee', 'age': 27},
  ];

  final describe = juxt<Map<String, Object>, Object?>([
    (p) => p['name'],
    (p) => p['age'],
  ]);

  for (final p in people) {
    print(describe(p));
  }
  // [kim, 32]
  // [lee, 27]
}
