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
  // Both specs cause emit — combineLatest-style: any event re-emits
  // the latest of every slot, once every spec has spoken.
  final a = timed([(0, 1), (80, 2)], 160);
  final b = timed([(40, 10)], 160);

  final out = await combine([
    CombineSpec(a),
    CombineSpec(b),
  ]).toList();

  print(out); // [[1, 10], [2, 10]]
  // 1 waits for b; then 1+10, then 2+10. All-true specs are
  // FxEvents.combineLatestAll.
}
