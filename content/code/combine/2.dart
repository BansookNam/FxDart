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
  // zipAll waits for the OUTER to complete, then zips collected inners
  // by index. Write zipAll<List<int>>() when omitting project.
  final zipped = await fxEvents(Stream.fromIterable([
    Stream.fromIterable([1, 2]),
    Stream.fromIterable([10, 20]),
  ])).zipAll<List<int>>().toList();
  print(zipped); // [[1, 10], [2, 20]]

  // withLatestFromAll is N-ary withLatestFrom: only SOURCE events emit,
  // stamped with every other's latest. Early source events are dropped
  // until every other has spoken.
  final stamped = await fxEvents(timed([(0, 'r1'), (80, 'r2'), (160, 'r3')], 220))
      .withLatestFromAll(
        [timed([(40, 'v1'), (120, 'v2')], 220)],
        (v, latest) => '$v@${latest.first}',
      )
      .toList();
  print(stamped); // [r2@v1, r3@v2]
}
