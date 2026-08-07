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
  // By count: fixed-size batches, with a short final one.
  final byCount =
      await fxEvents(Stream.fromIterable([1, 2, 3, 4, 5])).chunk(2).toList();
  print(byCount); // [[1, 2], [3, 4], [5]]

  // By trigger: someone else decides when a batch is due.
  final rows = timed([(0, 'a'), (40, 'b'), (200, 'c')], 400);
  final flush = timed([(100, null), (150, null), (300, null)], 420);

  final byTrigger = await fxEvents(rows).chunkOn(flush).toList();
  print(byTrigger); // [[a, b], [c]]
  // The 100ms flush took [a, b]; the 150ms flush found an empty buffer
  // and stayed silent; the 300ms flush took [c].
}
