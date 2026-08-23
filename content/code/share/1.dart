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

  // After the source completes, a later listener is handed a closed
  // stream. reset: true (the default) only resubscribes when the last
  // listener left BEFORE complete — and only if the source allows a
  // second listen. share(reset: false) is the old forever-closed
  // behaviour even on a mid-run cancel.
  print(await shared.toList()); // [] — the source already completed

  // fromIterable completes, so the second listen is empty even with
  // reset: true. A cancel-before-complete on a re-listenable source
  // would start a fresh run instead.
  final finished = fxEvents(Stream.fromIterable([7, 8])).share();
  print(await finished.toList()); // [7, 8]
  print(await finished.toList()); // []
}
