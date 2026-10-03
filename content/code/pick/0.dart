import 'package:fxdart/fxdart.dart';

void main() {
  final user = {'id': 1, 'name': 'kim', 'password': 'secret', 'age': 32};
  print(fxPick(['id', 'name'], user)); // {id: 1, name: kim}

  // Keys that don't exist are simply skipped, not filled with null:
  print(fxPick(['id', 'nickname'], user)); // {id: 1}
}
