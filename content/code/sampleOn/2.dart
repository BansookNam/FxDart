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
  // A drag reports its x-position constantly; you only want one per frame.
  final positions =
      timed([(0, 10), (30, 14), (60, 30), (90, 55), (120, 80)], 400);
  final frames = timed([(50, null), (100, null), (150, null)], 420);

  // TODO: sample the newest position on each frame:
  //   fxEvents(positions).sampleOn(frames).toList()
  final out = await positions.toList();

  print(out);
  // currently every position — want [14, 55, 80]: the newest at each frame
}
