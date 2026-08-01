import 'package:fxdart/fxdart.dart';

void main() {
  final balance = [1200, 1350, 1280, 1600, 1600, 1750];

  // Each value beside its successor — the delta is one map away:
  final deltas = fx(balance).pairwise().map((p) => p.$2 - p.$1).toList();
  print(deltas); // [150, -70, 320, 0, 150]

  // n elements -> n - 1 pairs; short sources yield nothing:
  print(fx([42]).pairwise().toList()); // []

  // was: for (var i = 1; i < balance.length; i++) { balance[i] - balance[i - 1] ... }
}
