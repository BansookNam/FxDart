import 'package:fxdart/fxdart.dart';

void main() {
  // Data-first form: dedups now, and hands back a real List.
  final ids = uniqStrict([3, 1, 3, 2, 1, 2]);
  print(ids); // [3, 1, 2]
  print(ids.length); // 3  -- a List, so .length/[i] work right away
  print(ids[0]); // 3

  // Same elements, same order as the lazy version.
  print(toList(distinct([3, 1, 3, 2, 1, 2]))); // [3, 1, 2]

  // uniqByStrict dedups on a computed key instead of the whole value.
  final orders = [
    ('ann', 12.0),
    ('bob', 8.0),
    ('ann', 30.0),
  ];
  print(uniqByStrict((o) => o.$1, orders)); // [(ann, 12.0), (bob, 8.0)]

  // Chain form:
  print(fx([3, 1, 3, 2]).uniqStrict().toList()); // [3, 1, 2]
}
