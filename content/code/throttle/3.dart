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
  // The same idea on a Stream: scroll positions fire constantly; one
  // per 100ms window gets through. Default is leading only.
  final leading = await fxEvents(timed(
          [(0, 0), (30, 40), (60, 90), (130, 160), (160, 220), (300, 400)],
          450))
      .throttle(const Duration(milliseconds: 100))
      .toList();
  print(leading); // [0, 160, 400] — the first event of each window

  // trailing: true emits the NEWEST value seen when each window ends —
  // note the stream form defaults to trailing: false, unlike the
  // callback wrapper above.
  final trailing = await fxEvents(
          timed([(0, 0), (30, 40), (60, 90), (130, 160), (300, 400)], 450))
      .throttle(const Duration(milliseconds: 100),
          leading: false, trailing: true)
      .toList();
  print(trailing); // [90, 160, 400]
}
