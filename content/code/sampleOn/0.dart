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
  // A sensor updates every 50ms; the display repaints on its own ticks.
  final sensor = timed([(0, 1), (50, 2), (100, 3), (150, 4), (200, 5)], 600);
  final tick =
      timed([(75, null), (125, null), (300, null), (450, null)], 620);

  final out = await fxEvents(sensor).sampleOn(tick).toList();

  print(out); // [2, 3, 5]
  // 75ms tick → newest is 2; 125ms → 3; 300ms → 5.
  // The 450ms tick sees nothing new and stays silent, and the values
  // that were never sampled (1 and 4) are dropped, not queued.
}
