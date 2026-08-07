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
  // delay shifts the whole stream — nothing dropped, spacing preserved.
  final watch = Stopwatch()..start();
  final shifted = await fxEvents(Stream.fromIterable([1, 2, 3]))
      .delay(const Duration(milliseconds: 200))
      .toList();
  print('$shifted after ~${(watch.elapsedMilliseconds / 100).round() * 100}ms');

  // sample reads the newest value on its own clock, like sampleOn but
  // with the clock built in.
  final sensor = timed([(0, 'a'), (60, 'b'), (300, 'c')], 640);
  final read = await fxEvents(sensor)
      .sample(const Duration(milliseconds: 200))
      .toList();

  print(read); // [b, c]
  // The 200ms tick saw b, the 400ms tick saw c, and the 600ms tick had
  // nothing new to report — so it stayed silent.
}
