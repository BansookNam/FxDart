import 'package:fxdart/fxdart.dart';

void main() {
  final user = {'name': 'kim', 'age': 32, 'city': 'seoul'};

  final updated = evolve({
    'name': (v) => (v as String).toUpperCase(),
    'age': (v) => (v as int) + 1,
  }, user);

  print(updated); // {name: KIM, age: 33, city: seoul}
}
