import 'package:fxdart/fxdart.dart';

void main() {
  print(isMatch([1, 2, 3], [1, 2]));       // true — pattern is a prefix
  print(isMatch([1, 2, 3], [1, 2, 3, 4])); // false — pattern longer than target
  print(isMatch([1, 2, 3], [1, 9]));       // false — element mismatch

  final events = [
    {'type': 'click', 'x': 1},
    {'type': 'scroll', 'y': 5},
    {'type': 'click', 'x': 9},
  ];
  print(filter((e) => isMatch(e, {'type': 'click'}), events).toList());
  // [{type: click, x: 1}, {type: click, x: 9}]
}
