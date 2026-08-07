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
  // Exercise: the bag is reusable. cancelAll empties it, so the same
  // object can hold a fresh generation of subscriptions afterwards.
  final feed = StreamController<int>.broadcast();
  final subs = FxSubscriptions();

  // add returns what it was handed, so it reads as an expression.
  final first = subs.add(feed.stream.listen((v) => print('gen 1: $v')));
  print('same subscription back: ${identical(first, first)}');

  feed.add(1);
  await Future<void>.delayed(Duration.zero);

  await subs.cancelAll();

  // addAll takes a batch — a second generation, after the first is gone.
  subs.addAll([
    feed.stream.listen((v) => print('gen 2a: $v')),
    feed.stream.listen((v) => print('gen 2b: $v')),
  ]);
  print('holding ${subs.length} again');

  feed.add(2);
  await Future<void>.delayed(Duration.zero);

  await subs.cancelAll();
  await feed.close();
}
