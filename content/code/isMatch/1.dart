import 'package:fxdart/fxdart.dart';

void main() {
  print(fxIsMatch([1, 2, 3], [1, 2]));       // true — pattern is a prefix
  print(fxIsMatch([1, 2, 3], [1, 2, 3, 4])); // false — pattern longer than target
  print(fxIsMatch([1, 2, 3], [1, 9]));       // false — element mismatch

  final events = [
    {'type': 'click', 'x': 1},
    {'type': 'scroll', 'y': 5},
    {'type': 'click', 'x': 9},
  ];
  print(fxFilter((e) => fxIsMatch(e, {'type': 'click'}), events).toList());
  // [{type: click, x: 1}, {type: click, x: 9}]
}
