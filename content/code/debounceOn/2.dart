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
  // Exercise: a scroll offset firing constantly. throttleOn leading
  // (the default) keeps the first event of each inner window.
  final offsets = timed([(0, 0), (20, 40), (40, 90), (150, 160)], 200);

  final leading = await fxEvents(offsets)
      .throttleOn((_) => Stream<void>.fromFuture(
            Future<void>.delayed(const Duration(milliseconds: 80)),
          ))
      .toList();

  print(leading); // [0, 160]
  // The 80ms inner opened on 0 and swallowed 40 and 90; the next event
  // after that window (160) opened a new one. trailing: true would also
  // emit the newest value seen during each window.
}
