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
  // Exercise: windowEvery is the clock form — live inners spanning a
  // Duration, tumbling when every is omitted. chunkToggle is the
  // list-family counterpart of windowToggle: overlapping buffers,
  // empty skipped, like chunkOn.
  final events = timed([(0, 1), (30, 2), (60, 3), (150, 4)], 180);

  final windows = await fxEvents(events)
      .windowEvery(const Duration(milliseconds: 80))
      .toList();

  for (final w in windows) {
    final list = await w.toList();
    if (list.isNotEmpty) print(list);
  }
  // [1, 2, 3]
  // [4]
  //
  // The first 80ms window took 1, 2, 3; the next took 4. every: and
  // maxSize close or overlap windows early — the same knobs as
  // windowCount's startEvery, on a clock.
}
