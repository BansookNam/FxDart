import 'package:fxdart/fxdart.dart';

void main() {
  final events = [
    {'type': 'click', 'x': 1},
    {'type': 'scroll', 'y': 5},
    {'type': 'click', 'x': 9},
  ];

  print(filter(matches({'type': 'click'}), events).toList());
  // [{type: click, x: 1}, {type: click, x: 9}]

  print(find(matches({'type': 'scroll'}), events));
  // {type: scroll, y: 5}
}
