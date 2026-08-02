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
  // Form validation: two fields typed independently, one validity state.
  final username = timed([(0, 'a'), (100, 'ada')], 400);
  final password = timed([(50, 'x'), (150, 'hunter2')], 450);

  final valid = await fxEvents(username)
      .combineLatest(password, (u, p) => u.length >= 3 && p.length >= 6)
      .toList();

  print(valid); // [false, false, true]
  // Every event on EITHER side re-evaluates the latest pair:
  // (a, x) → false, (ada, x) → false, (ada, hunter2) → true.
  // Nothing emits before both fields have spoken at least once.
}
