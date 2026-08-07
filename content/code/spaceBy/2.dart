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
  // Exercise: a burst of outbound messages, paced to the wire and
  // then batched for the log.
  final outbox = Stream.fromIterable(['m1', 'm2', 'm3', 'm4', 'm5', 'm6']);

  final logged = await fxEvents(outbox)
      .spaceBy(const Duration(milliseconds: 100))
      .chunkEvery(const Duration(milliseconds: 250))
      .toList();

  print(logged); // [[m1, m2], [m3, m4], [m5, m6]] (roughly)
  // spaceBy sets the send rate; chunkEvery sets the reporting rate.
  // Because spaceBy queues rather than drops, an unbounded burst grows
  // an unbounded queue — reach for throttle or debounce when the input
  // is genuinely endless.
}
