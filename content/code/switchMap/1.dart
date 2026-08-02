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
  // The source closes at 30ms — long before the inner stream has said
  // anything. The chain does NOT cut the last inner stream short.
  final out = await fxEvents(timed([(0, 1)], 30))
      .switchMap((v) => timed([(60, v * 10), (90, v * 100)], 120))
      .toList();

  print(out); // [10, 100]
  // Close condition: source done AND the newest inner stream done.
  // Only a NEWER event cancels an inner stream — the source closing
  // never does.
}
