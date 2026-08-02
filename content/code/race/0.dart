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
  // Cache vs network: first answer wins.
  var loserEvents = 0;
  final cache = timed([(40, 'cached: profile v7')], 80);
  final network = timed([(200, 'fresh: profile v8')], 240).map((v) {
    loserEvents++;
    return v;
  });

  final out = await FxEvents.race([network, cache]).toList();
  print(out); // [cached: profile v7]

  await Future<void>.delayed(const Duration(milliseconds: 250));
  print('loser events seen: $loserEvents'); // 0
  // The network stream was CANCELLED the moment the cache emitted —
  // not muted. Its events never even happen.
}
