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
  // A telemetry feed with no natural end — it would run for 5 seconds.
  final telemetry = timed([
    (0, 'cpu 12%'),
    (60, 'cpu 31%'),
    (120, 'cpu 44%'),
    (300, 'cpu 51%'),
  ], 5000);

  // The screen is torn down at 200ms.
  final disposed = timed([(200, null)], 240);

  final watch = Stopwatch()..start();
  final seen = await fxEvents(telemetry).stopOn(disposed).toList();
  watch.stop();

  print(seen); // [cpu 12%, cpu 31%, cpu 44%]
  print('closed after ~${(watch.elapsedMilliseconds / 100).round() * 100}ms');
  // stopOn did not wait out the source's 5 seconds: the first trigger
  // event closed the chain and cancelled BOTH subscriptions.
}
