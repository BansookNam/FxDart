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
  // Four requests queued up at once, against an API that allows one
  // call per 150ms.
  final watch = Stopwatch()..start();
  final sent = await fxEvents(Stream.fromIterable(['r1', 'r2', 'r3', 'r4']))
      .spaceBy(const Duration(milliseconds: 150))
      .toList();
  watch.stop();

  print(sent); // [r1, r2, r3, r4] — every one of them
  print('took ~${(watch.elapsedMilliseconds / 100).round() * 100}ms');

  // throttle, given the same burst, keeps ONE and drops the rest:
  final throttled = await fxEvents(Stream.fromIterable(['r1', 'r2', 'r3', 'r4']))
      .throttle(const Duration(milliseconds: 150))
      .toList();
  print(throttled); // [r1]
  // Same rate limit, opposite trade: spaceBy is lossless and slow,
  // throttle is lossy and immediate.
}
