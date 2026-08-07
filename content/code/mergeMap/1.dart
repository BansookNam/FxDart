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
  // An impatient user taps Submit four times.
  final taps = timed([(0, 1), (50, 2), (100, 3), (400, 4)], 600);

  final submitted = await fxEvents(taps)
      .exhaustMap((n) => timed([(200, 'submit $n')], 240))
      .toList();

  print(submitted); // [submit 1, submit 4]
  // Taps 2 and 3 landed while submit 1 was still in flight, so they were
  // IGNORED outright — no queue, no cancellation, no duplicate order.
  // Tap 4 arrived after the first request had finished, so it ran.
}
