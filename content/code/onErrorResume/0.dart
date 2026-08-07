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
  // A flaky sensor that reports the odd bad reading.
  final sensor = StreamController<int>();
  final readings = fxEvents(sensor.stream).onErrorReturn(-1).toList();

  sensor
    ..add(21)
    ..addError(StateError('glitch'))
    ..add(22)
    ..addError(StateError('glitch'))
    ..add(23);
  await sensor.close();

  print(await readings); // [21, -1, 22, -1, 23]
  // Dart stream errors do NOT end a subscription, so this substitutes
  // per error rather than rescuing once: every error became one -1 and
  // the stream carried on.
}
