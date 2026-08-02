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
  // The other stream is a LIVE feed that never closes.
  final settings = StreamController<int>();
  settings.add(7); // latest value already waiting

  final out = await fxEvents(timed([(30, 1), (60, 2)], 100))
      .withLatestFrom(settings.stream, (a, b) => a + b)
      .toList();

  print(out); // [8, 9]
  print('settings still open: ${!settings.isClosed}'); // true
  // The chain closed with the SOURCE; the other side's lifetime is
  // ignored, so a live config feed never holds your pipeline hostage.
  await settings.close();
}
