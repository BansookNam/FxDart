import 'package:fxdart/fxdart.dart';

void main() {
  final user = {'id': 1, 'name': 'kim', 'password': 'secret', 'age': 32};
  print(pick(['id', 'name'], user)); // {id: 1, name: kim}

  // Keys that don't exist are simply skipped, not filled with null:
  print(pick(['id', 'nickname'], user)); // {id: 1}
}
