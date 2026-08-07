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
  // A screen listening to three feeds at once.
  final ticks = StreamController<int>();
  final clicks = StreamController<String>();

  final subs = FxSubscriptions();
  subs
    ..add(fxEvents(ticks.stream).map((v) => v * 2).listen((v) => print('tick $v')))
    ..add(fxEvents(clicks.stream).listen((v) => print('click $v')));

  print('holding ${subs.length} subscriptions');

  ticks.add(1);
  clicks.add('home');
  await Future<void>.delayed(Duration.zero);

  // One call ends them all — the dispose() one-liner.
  await subs.cancelAll();
  print('after cancelAll: isEmpty = ${subs.isEmpty}');

  ticks.add(2);
  clicks.add('cart');
  await Future<void>.delayed(Duration.zero); // nothing prints

  await ticks.close();
  await clicks.close();
}
