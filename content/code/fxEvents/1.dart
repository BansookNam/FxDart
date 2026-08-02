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
  // Two sensors, one feed: merge interleaves in arrival order and closes
  // once every source has closed.
  final merged = await FxEvents.merge([
    timed([(0, 'kitchen 21.0'), (100, 'kitchen 21.5')], 200),
    timed([(50, 'attic 15.2'), (150, 'attic 15.1')], 220),
  ]).toList();
  print(merged); // [kitchen 21.0, attic 15.2, kitchen 21.5, attic 15.1]

  // .pull() crosses into the typed pull world: from here on the events
  // are an FxAsync chain, pulled on demand.
  final odds = await fxEvents(Stream.fromIterable([1, 2, 3, 4, 5]))
      .pull()
      .filter((v) => v.isOdd)
      .map((v) => v * 2)
      .toList();
  print(odds); // [2, 6, 10]
}
