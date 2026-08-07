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
  // Exercise: record only the ticks that fall inside a session.
  final ticks = timed([
    (0, 1),
    (150, 2),
    (300, 3),
    (450, 4),
    (600, 5),
    (750, 6),
    (900, 7),
    (1050, 8),
  ], 1200);

  final loggedIn = timed([(375, null)], 1300);
  final loggedOut = timed([(825, null)], 1300);

  final session = await fxEvents(ticks)
      .startOn(loggedIn)
      .stopOn(loggedOut)
      .toList();

  print(session); // [4, 5, 6]
  // The two gates compose: startOn opens at 375ms, stopOn closes at
  // 825ms, and the ticks outside that window never reach the chain.
}
