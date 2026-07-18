import 'package:fxdart/fxdart.dart';

void main() {
  print(identity(5)); // 5
  print(identity('hello')); // hello

  // realistic: group numbers by their own value
  final byValue = groupBy(identity, [1, 1, 2, 3, 3, 3]);
  print(byValue); // {1: [1, 1], 2: [2], 3: [3, 3, 3]}
}
