import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form. Same argument order rule as difference: the result
  // comes FROM iterable2, filtered by f-keys seen in iterable1. Both
  // iterables share the same element type -- f is applied to both sides.
  final blocked = [
    {'id': 2},
    {'id': 4},
  ];
  final users = [
    {'id': 1, 'name': 'kim'},
    {'id': 2, 'name': 'lee'},
    {'id': 3, 'name': 'park'},
  ];

  final allowed = differenceBy((u) => u['id'], blocked, users);
  print(toList(allowed));
  // [{id: 1, name: kim}, {id: 3, name: park}]
}
