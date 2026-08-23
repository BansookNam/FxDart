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
  // other is context only — withLatestFrom-style: it updates the slot
  // but never fires an emit on its own.
  final src = timed([(0, 1), (80, 2), (160, 3)], 220);
  final other = timed([(40, 10), (120, 20)], 220);

  final out = await combine([
    CombineSpec(src),
    CombineSpec(other, causesEmit: false),
  ]).toList();

  print(out); // [[2, 10], [3, 20]]
  // 1 dropped — other had not spoken yet. 10 and 20 never emit alone.
  // Only src events produce output, stamped with other's latest.
}
