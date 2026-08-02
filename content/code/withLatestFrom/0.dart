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
  // Requests fire on their own schedule; each should carry the config
  // version that was current when it fired.
  final requests = timed([(0, 'r1'), (100, 'r2'), (200, 'r3')], 400);
  final config = timed([(50, 'v1'), (150, 'v2')], 450);

  final out = await fxEvents(requests)
      .withLatestFrom(config, (r, v) => '$r@$v')
      .toList();

  print(out); // [r2@v1, r3@v2]
  // Only SOURCE events emit — config updates alone never do (that is the
  // difference from combineLatest). r1 fired before any config existed,
  // so it was dropped.
}
