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
  // Two independent sensors; the display shows the latest of both.
  final temperature = timed([(0, 21.0), (100, 24.0)], 300);
  final humidity = timed([(50, 40), (150, 65)], 320);

  // TODO: combine the latest of both into one readable state:
  //   fxEvents(temperature)
  //       .combineLatest(humidity, (t, h) => '$t°C / $h%')
  //       .toList()
  final out = await temperature.toList();

  print(out);
  // currently just temperatures —
  // want [21.0°C / 40%, 24.0°C / 40%, 24.0°C / 65%]
}
