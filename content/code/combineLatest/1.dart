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
  // One side closing does not end the combination — its LAST value keeps
  // pairing with the other side's updates.
  final a = timed([(0, 1)], 50); // emits once, closes early
  final b = timed([(20, 2), (100, 3), (180, 4)], 250);

  final out = await fxEvents(a).combineLatest(b, (x, y) => x + y).toList();

  print(out); // [3, 4, 5]
  // 1+2, then — with a already closed — 1+3 and 1+4.
  // The result closes only when BOTH sides have closed.
}
