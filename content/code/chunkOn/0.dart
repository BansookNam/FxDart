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
  // Analytics events arrive in two bursts.
  final events = timed([
    (0, 'e1'),
    (30, 'e2'),
    (60, 'e3'),
    (250, 'e4'),
    (280, 'e5'),
  ], 520);

  final batches =
      await fxEvents(events).chunkEvery(const Duration(milliseconds: 200)).toList();

  print(batches); // [[e1, e2, e3], [e4, e5]]
  // Five events became two network calls. An empty window emits NOTHING
  // — you never get a batch just because the clock ticked — and whatever
  // is still buffered when the source closes is flushed before the close.
}
