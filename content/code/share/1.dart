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
  var runs = 0;
  final shared = fxEvents(timed([(0, 1), (60, 2)], 150)).map((v) {
    runs++;
    return v * 10;
  }).share();

  // Both listeners attach BEFORE the first event.
  final a = shared.toList();
  final b = shared.toList();

  print(await a); // [10, 20]
  print(await b); // [10, 20]
  print('map ran $runs times for 2 listeners'); // 2, not 4

  // The upstream chain is single-subscription, so it cannot be re-run:
  // when the last listener leaves, the shared stream closes for good.
  print(await shared.toList()); // [] — this listener came too late
}
