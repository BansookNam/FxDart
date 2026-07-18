import 'package:fxdart/fxdart.dart';

void main() {
  final user = {'id': 1, 'name': 'kim', 'age': 32};
  print(props(['name', 'age'], user));      // [kim, 32]
  print(props(['name', 'nickname'], user)); // [kim, null] — missing key is null, not dropped
}
