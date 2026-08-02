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

/// A download mirror that answers after [ms] milliseconds.
Stream<String> mirror(String name, int ms) =>
    timed([(ms, 'downloaded from $name')], ms + 40);

Future<void> main() async {
  // TODO: race the three mirrors — the first byte wins and the other two
  // connections are cancelled immediately:
  //   FxEvents.race([mirror('eu', 120), mirror('us', 60), mirror('ap', 180)])
  //       .toList()
  final out = await mirror('us', 60).toList();

  print(out);
  // want [downloaded from us] — and with race, the eu/ap sockets are
  // closed the moment us answers, instead of running to completion.
}
