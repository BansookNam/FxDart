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
  // Every FxEvents operator builds its own StreamController, so a chain
  // over a live source is SINGLE-SUBSCRIPTION: consumable exactly once.
  var runs = 0;
  final feed = StreamController<int>();
  final chain = fxEvents(feed.stream).map((v) {
    runs++;
    return v * 10;
  });

  final consumer = chain.toList();

  try {
    await chain.toList();
  } on StateError catch (e) {
    print('a second listener: $e');
  }

  feed
    ..add(1)
    ..add(2)
    ..add(3);
  await feed.close();

  print(await consumer); // [10, 20, 30]
  print('the chain ran $runs times');
  // Single-subscription is the right default — it keeps the chain cold
  // and cheap — but it means two widgets cannot watch the same feed.
}
