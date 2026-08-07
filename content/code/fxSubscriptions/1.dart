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
  final a = StreamController<int>();
  final b = StreamController<int>();
  final seen = <int>[];

  final subs = FxSubscriptions();
  subs
    ..add(a.stream.listen(seen.add))
    ..add(b.stream.listen(seen.add));

  // Backgrounded: hold everything without tearing it down.
  subs.pauseAll();
  a.add(1);
  b.add(2);
  await Future<void>.delayed(Duration.zero);
  print(seen); // [] — buffered, not lost

  // Foregrounded again.
  subs.resumeAll();
  await Future<void>.delayed(Duration.zero);
  print(seen); // [1, 2]

  await subs.cancelAll();
  await a.close();
  await b.close();
}
