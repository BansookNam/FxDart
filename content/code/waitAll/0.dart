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
  // A dashboard that cannot render until all three panels have loaded.
  final profile = timed([(80, 'profile')], 120);
  final orders = timed([(240, 'orders')], 280);
  final prefs = timed([(40, 'prefs')], 80);

  final watch = Stopwatch()..start();
  final ready = await FxEvents.waitAll([profile, orders, prefs]).toList();
  watch.stop();

  print(ready); // [[profile, orders, prefs]]
  print('all in after ~${(watch.elapsedMilliseconds / 100).round() * 100}ms');
  // ONE event, holding each source's LAST value in source order, once
  // every source has closed — the stream counterpart of Future.wait.
  // A source that closes without ever emitting means no result at all.
}
