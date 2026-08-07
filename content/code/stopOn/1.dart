import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Emits each (offsetMs, value) pair at its offset, closing at [closeMs].
Stream<T> timed<T>(List<(int, T)> events, int closeMs) {
  final c = StreamController<T>();
  for (final (ms, v) in events) {
    Timer(Duration(milliseconds: ms), () => c.add(v));
  }
  Timer(Duration(milliseconds: closeMs), c.close);
  return c.stream;
}

Future<void> main() async {
  // Taps start arriving before the app has finished warming up.
  final taps = timed([
    (0, 'tap 1'),
    (50, 'tap 2'),
    (150, 'tap 3'),
    (200, 'tap 4'),
  ], 300);

  // "Ready" fires once, at 100ms.
  final ready = timed([(100, null)], 400);

  final handled = await fxEvents(taps).startOn(ready).toList();

  print(handled); // [tap 3, tap 4]
  // Everything before the trigger is dropped; everything after it passes
  // for good — startOn opens the gate once and never closes it again.
  // Note this is unrelated to startWith, which prepends a value.
}
