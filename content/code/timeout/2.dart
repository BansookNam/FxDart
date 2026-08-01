import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// The feed stalls on item 2.
Future<int> readSensor(int id) async {
  await Future.delayed(Duration(milliseconds: id == 2 ? 400 : 20));
  return id * 10;
}

void main() async {
  // TODO: this hangs 400ms on the stalled item. Bound each pull to 80ms
  // with .timeout(...), then retry the flaky read by wrapping the whole
  // attempt in retry(2, () => ...) — timeout turns "hanging" into
  // "failing", retry turns "failing" into "try again".
  final readings = await fx([1, 2, 3])
      .toAsync()
      .map(readSensor) // ← add .timeout(const Duration(milliseconds: 80))
      .toList();

  print(readings);
  // With just the timeout: TimeoutException.
  // With retry around it: still fails (the stall is deterministic) —
  // which is the honest lesson: retry + timeout bounds the damage,
  // it cannot conjure a healthy service.
}
