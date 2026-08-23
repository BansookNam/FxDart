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
  final started = <int>[];

  final out = await fxEvents(timed([(0, 1), (40, 2)], 80)).switchScan<int>(
    10,
    (acc, v) {
      started.add(v);
      return timed([(80, acc + v)], 100);
    },
  ).toList();

  print('started: $started'); // [1, 2]
  print('emitted: $out'); // [12]
  // 1 started an inner that would have emitted 11 at 80ms — but 2
  // arrived at 40ms and CANCELLED it. 2 saw the seed still (1 never
  // landed), so the only event is 10+2.
}
