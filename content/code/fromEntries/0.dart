import 'package:fxdart/fxdart.dart';

void main() {
  final map = fromEntries([('a', 1), ('b', 2), ('c', 3)]);
  print(map); // {a: 1, b: 2, c: 3}

  final keys = ['x', 'y', 'z'];
  final values = [10, 20, 30];
  print(fromEntries(zip(keys, values))); // {x: 10, y: 20, z: 30}
}
