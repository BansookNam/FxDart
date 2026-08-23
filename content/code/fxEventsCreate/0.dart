import 'dart:async';

import 'package:fxdart/fxdart.dart';

Future<void> main() async {
  // Named constructors are cold: nothing is produced until someone
  // listens. value emits one event and closes; empty closes with none.
  print(await FxEvents.value(7).toList()); // [7]
  print(await FxEvents<int>.empty().toList()); // []

  // generate walks initial, iterate(initial), … while condition holds.
  // Each step is a timer tick so an infinite generator can still be
  // cancelled; three ints is three Duration.zero turns.
  print(
    await FxEvents.generate(1, (n) => n <= 3, (n) => n + 1).toList(),
  ); // [1, 2, 3]
}
