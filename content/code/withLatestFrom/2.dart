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
  // Orders arrive in dollars; the exchange rate drifts on its own feed.
  final orders = timed([(60, 100), (120, 250)], 300);
  final rate = timed([(0, 1.5), (90, 2.0)], 320);

  // TODO: stamp each order with the rate current at that moment:
  //   fxEvents(orders).withLatestFrom(rate, (o, r) => o * r).toList()
  final out = await orders.toList();

  print(out);
  // currently [100, 250] — want [150.0, 500.0]
}
