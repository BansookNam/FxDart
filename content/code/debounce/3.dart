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
  // The same idea on a Stream: keystrokes arrive in bursts, and only the
  // trailing value of each burst survives the 150ms quiet window.
  final keystrokes = timed(
      [(0, 'd'), (40, 'da'), (80, 'dar'), (120, 'dart'), (400, 'dart!')], 460);

  final searches = await fxEvents(keystrokes)
      .debounce(const Duration(milliseconds: 150))
      .toList();

  print(searches); // [dart, dart!]
  // 'dart' ends the first burst (150ms of quiet after 120ms); 'dart!' is
  // still waiting for its window when the stream closes at 460ms — a
  // pending value is flushed on close, never dropped.
}
