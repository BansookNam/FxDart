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
  // Exercise 1: concat plays sources through in order, one at a time.
  print(await FxEvents.concat([
    Stream.fromIterable([1, 2]),
    Stream.fromIterable([3]),
  ]).toList()); // [1, 2, 3]

  // Exercise 2: followedBy is the two-source form — cache first, then
  // the network.
  print(await fxEvents(Stream.fromIterable(['cache']))
      .followedBy(Stream.fromIterable(['network']))
      .toList()); // [cache, network]

  // Exercise 3: raceWith keeps whichever source speaks first and
  // cancels the loser outright.
  print(await fxEvents(timed([(0, 'fast')], 60))
      .raceWith(timed([(300, 'slow')], 360))
      .toList()); // [fast]

  // Exercise 4: mergeWith interleaves both in arrival order.
  print(await fxEvents(timed([(0, 'a'), (100, 'c')], 200))
      .mergeWith(timed([(50, 'b')], 200))
      .toList()); // [a, b, c]
}
