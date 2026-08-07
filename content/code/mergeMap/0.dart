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
  // Three files picked in quick succession; every upload matters.
  final picked = timed([(0, 'a.png'), (60, 'b.png'), (120, 'c.png')], 200);

  final uploaded = await fxEvents(picked)
      .mergeMap((file) => timed([(300, 'uploaded $file')], 340))
      .toList();

  print(uploaded); // [uploaded a.png, uploaded b.png, uploaded c.png]
  // All three uploads ran AT ONCE — the whole thing took ~420ms, not the
  // ~900ms three sequential uploads would have cost. Nothing was
  // cancelled, unlike switchMap, and nothing was ignored, unlike
  // exhaustMap.
}
