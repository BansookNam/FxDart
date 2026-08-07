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
  // Exercise: retry rebuilds the whole stream instead of patching over
  // its errors — the right move when the failure is the connection.
  var attempts = 0;

  final out = await FxEvents.retry<String>(() {
    attempts++;
    print('attempt $attempts');
    return attempts < 3
        ? Stream<String>.error(StateError('flaky'))
        : Stream.fromIterable(['ok']);
  }).toList();

  print(out); // [ok] after three attempts

  // With a budget, retry gives up and forwards the last error.
  var tries = 0;
  final seen = <Object>[];
  final done = Completer<void>();
  FxEvents.retry<String>(() {
    tries++;
    return Stream<String>.error(StateError('always down'));
  }, 2)
      .listen(seen.add, onError: seen.add, onDone: done.complete);
  await done.future;

  print('gave up after $tries attempts'); // one attempt plus two retries
  print(seen.single.runtimeType); // StateError
}
