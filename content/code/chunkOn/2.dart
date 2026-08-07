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
  // Exercise: turn a noisy click stream into a per-window summary
  // instead of one report per click.
  final clicks = timed([
    (0, 'home'),
    (40, 'home'),
    (80, 'search'),
    (250, 'cart'),
    (290, 'cart'),
    (330, 'checkout'),
  ], 620);

  final report = await fxEvents(clicks)
      .chunkEvery(const Duration(milliseconds: 200))
      .map((batch) => '${batch.length} clicks: ${batch.toSet().join(", ")}')
      .toList();

  report.forEach(print);
  // 3 clicks: home, search
  // 3 clicks: cart, checkout
  //
  // chunk* is the push-side counterpart of the pull layer's chunk: same
  // idea, but a window can be closed by a clock or a trigger, which a
  // pull pipeline has no way to express.
}
