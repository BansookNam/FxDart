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
  // zip pairs sources up by INDEX: 1st with 1st, 2nd with 2nd.
  final paired = await FxEvents.zip<int, String>([
    Stream.fromIterable([1, 2, 3]),
    Stream.fromIterable([10, 20]),
  ], (values) => values.join('+'))
      .toList();
  print(paired); // [1+10, 2+20] — the unmatched 3 is never emitted

  // zipWith is the two-source form, and it can cross types.
  final labelled = await fxEvents(Stream.fromIterable([1, 2]))
      .zipWith<String, String>(
          Stream.fromIterable(['a', 'b', 'c']), (n, s) => '$n$s')
      .toList();
  print(labelled); // [1a, 2b]

  // combineLatestAll re-emits EVERY source's latest on every event.
  final a = timed([(0, 'a1'), (100, 'a2')], 300);
  final b = timed([(50, 'b1')], 300);
  print(await FxEvents.combineLatestAll([a, b]).toList());
  // [[a1, b1], [a2, b1]] — zip pairs by position, combineLatest by time.
}
